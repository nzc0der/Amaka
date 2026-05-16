import os
import json
import psutil
from flask import Flask, jsonify, request
from datetime import datetime

app = Flask(__name__)

# Default Data
DATA_FILE = "data.json"
DEFAULT_DATA = {
    "family": [
        {"id": "1", "name": "Alice", "avatarURL": None, "status": "At Home", "isCurrentUser": True},
        {"id": "2", "name": "Bob", "avatarURL": None, "status": "At Work", "isCurrentUser": False}
    ],
    "events": [
        {"id": "e1", "title": "Dinner with Grandparents", "date": datetime.now().isoformat() + "Z", "personId": "1"}
    ],
    "shopping": [
        {"id": "s1", "title": "Milk", "completed": False},
        {"id": "s2", "title": "Eggs", "completed": True}
    ],
    "note": {"id": "n1", "content": "Welcome to our shared family hub! Keep it organized."}
}

def load_data():
    if not os.path.exists(DATA_FILE):
        return DEFAULT_DATA
    with open(DATA_FILE, "r") as f:
        return json.load(f)

def save_data(data):
    with open(DATA_FILE, "w") as f:
        json.dump(data, f)

@app.route("/api/dashboard", methods=["GET"])
def get_dashboard():
    data = load_data()

    # Add real-time Pi status
    cpu_usage = psutil.cpu_percent() / 100.0
    storage = psutil.disk_usage("/")
    storage_usage = storage.percent / 100.0

    data["pi"] = {
        "id": "pi-1",
        "tailscaleConnected": True, # Usually true if we are reachable
        "cpuUsage": cpu_usage,
        "storageUsage": storage_usage
    }

    return jsonify(data)

@app.route("/api/shopping", methods=["POST"])
def update_shopping():
    req_data = request.json
    data = load_data()
    data["shopping"] = req_data
    save_data(data)
    return jsonify({"status": "success"})

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)
