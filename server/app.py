from flask import Flask, jsonify, render_template, request
import json
import os
import datetime
import psutil

app = Flask(__name__)

DATA_FILE = 'data.json'

DEFAULT_DATA = {
    "family": [
        {"id": "1", "name": "Noah", "avatarURL": None, "status": "At Home", "isCurrentUser": True},
        {"id": "2", "name": "Sarah", "avatarURL": None, "status": "At Work", "isCurrentUser": False},
        {"id": "3", "name": "Emma", "avatarURL": None, "status": "School", "isCurrentUser": False}
    ],
    "events": [
        {"id": "e1", "title": "Dinner with Gran", "date": (datetime.datetime.now() + datetime.timedelta(days=1)).isoformat() + "Z", "personId": "1"},
        {"id": "e2", "title": "Piano Lesson", "date": (datetime.datetime.now() + datetime.timedelta(hours=5)).isoformat() + "Z", "personId": "3"}
    ],
    "shopping": [
        {"id": "s1", "title": "Milk", "completed": False},
        {"id": "s2", "title": "Eggs", "completed": True},
        {"id": "s3", "title": "Bread", "completed": False}
    ],
    "note": {"id": "n1", "content": "Welcome to Amaka! This is your secure family note area. You can share passwords, gate codes, or grocery lists here."},
    "pi": {"id": "p1", "tailscaleConnected": True, "cpuUsage": 0.15, "storageUsage": 0.42}
}

def load_data():
    if not os.path.exists(DATA_FILE):
        with open(DATA_FILE, 'w') as f:
            json.dump(DEFAULT_DATA, f)
        return DEFAULT_DATA
    with open(DATA_FILE, 'r') as f:
        return json.load(f)

def save_data(data):
    with open(DATA_FILE, 'w') as f:
        json.dump(data, f)

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/api/dashboard', methods=['GET'])
def get_dashboard():
    data = load_data()
    # Update Pi status dynamically
    data['pi']['cpuUsage'] = psutil.cpu_percent() / 100.0
    data['pi']['storageUsage'] = psutil.disk_usage('/').percent / 100.0
    return jsonify(data)

@app.route('/api/shopping', methods=['POST'])
def add_shopping():
    data = load_data()
    new_item = request.json
    data['shopping'].append(new_item)
    save_data(data)
    return jsonify({"status": "success"})

@app.route('/api/shopping/toggle', methods=['POST'])
def toggle_shopping():
    data = load_data()
    item_id = request.json.get('id')
    for item in data['shopping']:
        if item['id'] == item_id:
            item['completed'] = not item['completed']
            break
    save_data(data)
    return jsonify({"status": "success"})

@app.route('/api/status', methods=['POST'])
def update_status():
    data = load_data()
    user_id = request.json.get('id')
    new_status = request.json.get('status')
    for member in data['family']:
        if member['id'] == user_id:
            member['status'] = new_status
            break
    save_data(data)
    return jsonify({"status": "success"})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5001, debug=True)
