# Amaka Family Hub

Amaka is a premium family dashboard designed for iOS 16+. It features a modern glassmorphic UI, a weather dashboard, family status tracking, and secure notes.

## Tailscale Integration (tsnet)

Amaka is designed to connect automatically to your home server using Tailscale's `tsnet` library. This allows the app to securely access your home network without requiring the standalone Tailscale app to be installed on the device.

### How to Connect your Tailscale Server

1. **Set up your Tailscale Server**:
   - Ensure your home server (e.g., Raspberry Pi) is running Tailscale and is reachable on your tailnet.
   - Note your server's Tailscale IP address (e.g., `100.x.y.z`).

2. **Generate an Auth Key**:
   - Go to the [Tailscale Admin Console](https://login.tailscale.com/admin/settings/keys).
   - Generate a new **Auth Key**. It is recommended to use an "Ephemeral" and "Reusable" key if you plan to connect multiple devices.

3. **Embed Tailscale in the App**:
   - To fully enable the embedded Tailscale functionality, you must build the `tsnet` Go library as an `xcframework` and link it to the Xcode project.
   - Follow the instructions at [tailscale/tailscale-android](https://github.com/tailscale/tailscale-android) (the process is similar for iOS) or use a pre-built Swift bridge.
   - Once linked, initialize `TailscaleManager` with your auth key in `AmakaApp.swift`:
     ```swift
     TailscaleManager.shared.start(authKey: "tskey-auth-YOUR_KEY_HERE")
     ```

4. **Configure the App**:
   - Open `Amaka/Config.swift` and update the settings:
     ```swift
     static let serverIP = "100.x.y.z" // Your Tailscale IP
     static let serverPort = "8080"
     static let tailscaleAuthKey = "tskey-auth-..." // Your Auth Key
     ```

## Features

- **Hamburger Menu**: Access all sections of the app with a smooth slide-out navigation.
- **Main Dashboard**:
  - **Weather Widget**: Real-time weather updates for your location.
  - **Pi Status**: Monitor your home server's CPU and storage usage.
  - **Family Board**: See where everyone is at a glance.
  - **Upcoming Events**: Stay on top of family schedules.
- **Shopping List**: Collaborative list for family groceries.
- **Secure Notes**: End-to-end encrypted shared notes.

## Raspberry Pi Server Setup

The `server/` directory contains a Python server designed to run on your Raspberry Pi.

### Prerequisites

- Python 3.9+
- `pip install flask psutil`

### Running the Server

1. **Transfer the code**: Copy the `server/` folder to your Raspberry Pi.
2. **Start the server**:
   ```bash
   python3 main.py
   ```
   The server will run on port 8080.

3. **Autostart on boot (optional)**:
   You can use `systemd` to keep the server running:
   ```bash
   sudo nano /etc/systemd/system/amaka-server.service
   ```
   Add the following:
   ```ini
   [Unit]
   Description=Amaka Family Hub Server
   After=network.target

   [Service]
   ExecStart=/usr/bin/python3 /path/to/server/main.py
   WorkingDirectory=/path/to/server
   StandardOutput=inherit
   StandardError=inherit
   Restart=always
   User=pi

   [Install]
   WantedBy=multi-user.target
   ```
   Then enable and start it:
   ```bash
   sudo systemctl enable amaka-server
   sudo systemctl start amaka-server
   ```

## Requirements

- iOS 16.0+
- Xcode 14.0+
- Python 3.9+ (on server)
- A Tailscale account and a configured node.
