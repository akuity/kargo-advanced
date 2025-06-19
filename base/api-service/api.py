from flask import Flask, jsonify
import os

app = Flask(__name__)

SERVICE_VERSION = os.environ.get("SERVICE_VERSION", "0.0.0-dev")

@app.route('/ping', methods=['GET'])
def ping():
    return jsonify(message="pong"), 200

@app.route('/version', methods=['GET'])
def version():
    return jsonify(service="api-service", version=SERVICE_VERSION), 200

@app.route('/hello', methods=['GET'])
def hello():
    return jsonify(message="Hello from the API service!"), 200

if __name__ == '__main__':
    # Use Gunicorn as the production server, Flask dev server for local testing
    # Gunicorn will be specified in the Docker CMD
    app.run(host='0.0.0.0', port=8080, debug=True)
