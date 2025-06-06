import hashlib
import hmac
import logging
import requests
import time
from flask import Flask, request, jsonify, abort

app = Flask(__name__)

# Set up logging to see the logs
logging.basicConfig(level=logging.DEBUG)

# Environment variables for security
SLACK_SIGNING_SECRET ="efaa09cee80ed8ef6f99dc1e8e5887af"  # Set this in your environment variables

# Set the Slack IP ranges (Fetch dynamically in production for the latest ranges)
SLACK_IP_RANGES = ["52.66.6.0/24", "52.65.7.0/24"]  # Replace this with dynamic fetching if needed


# Function to validate Slack signature
def validate_slack_signature(request):
    slack_signature = request.headers.get("X-Slack-Signature", "")
    slack_request_timestamp = request.headers.get("X-Slack-Request-Timestamp", "")

    logging.debug("Request Headers: %s", request.headers)

    if not slack_signature or not slack_request_timestamp:
        logging.error("Missing Slack signature or timestamp")
        abort(403)


    # Prevent replay attacks (5-minute window)
    if abs(time.time() - int(slack_request_timestamp)) > 60 * 5:
        logging.error("Request timestamp is out of range")
        abort(403)

    # Construct the signature base string

    sig_basestring = f"v0:{slack_request_timestamp}:{request.get_data(as_text=True)}"
    # Generate the signature using HMAC-SHA256
    my_signature = (
            "v0="
            + hmac.new(
        SLACK_SIGNING_SECRET.encode("utf-8"),
        sig_basestring.encode("utf-8"),
        hashlib.sha256,
    ).hexdigest()
    )


    # Compare the generated signature with the Slack signature
    if not hmac.compare_digest(my_signature, slack_signature):
        logging.error("Slack signature mismatch")
        abort(403)

    logging.debug("Slack signature validated successfully")
    return True


# Function to validate Slack IP (Optional, for extra security)
def validate_slack_ip(request):
    client_ip = request.remote_addr
    # Replace this with dynamic IP validation logic for Slack ranges
    for ip_range in SLACK_IP_RANGES:
        if ip_in_range(client_ip, ip_range):
            logging.debug("Request originates from a valid Slack IP range")
            return True
    logging.error(f"Unauthorized IP: {client_ip}")
    abort(403)


def ip_in_range(ip, cidr):
    from ipaddress import ip_address, ip_network
    return ip_address(ip) in ip_network(cidr)

# Validation and Payload Preparation for check_hash
def validate_and_prepare_check_hash(slack_text):
    hash_value = slack_text[1]
    amount = float(slack_text[2])
    currency = slack_text[3].upper()

    if len(hash_value) > 8:
        hash_value = hash_value[:8]

    return {"hash": hash_value, "amount": amount, "currency": currency}

# Validation and Payload Preparation for check_ref
def validate_and_prepare_check_ref(slack_text):
    external_ref=slack_text[1]
    if not external_ref:
        return jsonify({"error": "Invalid input. Please provide an external reference."}), 400

    return {"externalRef": external_ref}

def validate_and_prepare_check_instruction_ref(slack_text):
    instruction_ref=slack_text[1]
    if not instruction_ref:
        return jsonify({"error": "Invalid input. Please provide an instruction ref."}), 400

    return {"instructionRef": instruction_ref}

def check_transaction(slack_data):
    # Base URL
    # Extract hash, currency, and amount from Slack's parameters
    slack_text = slack_data.get('text').split(',')

    command = slack_text[0]

    base_url = "https://api-bakong.nbc.gov.kh/local/v1/"

    # Map commands to their respective endpoints and payloads
    # Map commands to their respective endpoints and payload generators
    commands = {
        "hash": {
            "endpoint": "check_transaction_by_short_hash",
            "validate_and_payload": lambda: validate_and_prepare_check_hash(slack_text)
        },
        "ext": {
            "endpoint": "check_transaction_by_external_ref",
            "validate_and_payload": lambda: validate_and_prepare_check_ref(slack_text)
        },
        "inst": {
            "endpoint": "check_transaction_by_instruction_ref",
            "validate_and_payload": lambda: validate_and_prepare_check_instruction_ref(slack_text)
        }
    }

    # Get the command configuration
    command_config = commands.get(command)
    if not command_config:
        return {"error": f"Invalid command: {command}"}

    # Construct the URL
    url = f"{base_url}{command_config['endpoint']}"

    # Generate the payload
    try:
        data = command_config["validate_and_payload"]()
    except TypeError as e:
        return {"error": f"Invalid payload parameters: {e}"}

    headers = {
        "Content-Type": "application/json;charset=UTF-8",
        "Origin": "https://api-bakong.nbc.gov.kh"
    }

    # Send the request
    try:
        response = requests.post(url, json=data, headers=headers)
        if response.status_code == 200:
            response_data = response.json()
            response_data['check_by'] = convert_to_normal_text(command_config['endpoint'])
            return response_data
        else:
            logging.error(f"Error from Bakong API: {response.text}")
            return {"error": "Failed to check transaction"}
    except Exception as e:
        logging.error(f"Error sending request to Bakong API: {e}")
        return {"error": "An error occurred while contacting the Bakong API"}

def convert_to_normal_text(text):
    # Replace underscores with spaces and capitalize each word
    return ' '.join(word.capitalize() for word in text.split('_'))

@app.route('/')
def home():
    return "Welcome to the Sarin Slack Command API!"


# Define a route for the Slack command
@app.route('/slack/command', methods=['POST'])
def slack_command():
    try:
        # Validate Slack request
        validate_slack_signature(request)
        #validate_slack_ip(request)

        logging.debug("Request Headers: %s", request.form)
        # Capture the incoming data from Slack's POST request
        slack_data = request.form

        transaction_info= check_transaction(slack_data)

        # Check if transaction info contains an error
        if "error" in transaction_info:
            response_text = f"Error: {transaction_info['error']}"
            response = {
                "response_type": "ephemeral",  # Private message to the user
                "text": response_text,
            }
            return jsonify(response)
        else:
            # Handle the response based on responseCode
            response_code = transaction_info.get("responseCode", 1)

            if response_code == 0:  # Transaction found
                data = transaction_info.get("data", {})
                response = {
                    "response_type": "in_channel",  # Makes the message visible to everyone in the Slack channel
                    "attachments": [
                        {
                            "fallback": "Transaction details",  # Fallback text for when the attachment isn't rendered
                            "color": "#36a64f",  # Green color for success
                            "title": "Transaction Found "+f"{transaction_info.get('check_by', 'Not Available')}",  # Pre-text before the block
                            "fields": [
                                {
                                    "title": "Hash",
                                    "value": f"`{data.get('hash', 'Not Available')}`",  # Wrapped in backticks for block code
                                    "short": True,
                                },
                                {
                                    "title": "From Account",
                                    "value": f"`{data.get('fromAccountId', 'Not Available')}`",  # Wrapped in backticks
                                    "short": True,
                                },
                                {
                                    "title": "To Account",
                                    "value": f"`{data.get('toAccountId', 'Not Available')}`",  # Wrapped in backticks
                                    "short": True,
                                },
                                {
                                    "title": "Receiver Bank",
                                    "value": f"`{data.get('receiverBank', 'Not Available')}`",  # Wrapped in backticks
                                    "short": True,
                                },
                                {
                                    "title": "Amount",
                                    "value": f"`{data.get('amount', 0)} {data.get('currency', '')}`",  # Wrapped in backticks
                                    "short": True,
                                },
                                {
                                    "title": "Description",
                                    "value": f"`{data.get('description', 'No Description Available')}`",  # Wrapped in backticks
                                    "short": True,
                                },
                                {
                                    "title": "External Ref",
                                    "value": f"`{data.get('externalRef', 'Not Available')}`",  # Wrapped in backticks
                                    "short": True,
                                },
                                {
                                    "title": "Instruction Ref",
                                    "value": f"`{data.get('instructionRef', 'Not Available')}`",  # Wrapped in backticks
                                    "short": True,
                                },
                                {
                                    "title": "Tracking Status",
                                    "value": f"`{data.get('trackingStatus', 'Not Available')}`",  # Wrapped in backticks
                                    "short": True,
                                },
                            ],
                            "footer": "Bakong API",
                            "footer_icon": "https://api-bakong.nbc.gov.kh/img/ic_bakong_logo_red.f4bd4b94.png",
                            "ts": int(data.get('createdDateMs', 0) / 1000),  # Unix timestamp for Slack formatting
                        }
                    ],
                }
            else:  # Transaction not found
                response = {
                    "response_type": "ephemeral",  # Private message to the user
                    "text": f"Error: {transaction_info.get('responseMessage', 'Transaction not found.')}."
                }

        return jsonify(response)

    except Exception as e:
        logging.error(f"Error processing the Slack command: {e}")
        return jsonify({"error": "An error occurred while processing the request."}), 500


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)
