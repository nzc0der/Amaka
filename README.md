# Amaka Private Family Hub

Amaka is a self-hosted family dashboard system consisting of an iOS application and a Go-based server. It uses Tailscale tsnet to provide a private, encrypted network identity for your hub without requiring system-wide Tailscale installation.

## Prerequisites

### Server Requirements
- Go 1.21 or later installed on the host machine (Raspberry Pi, old computer, etc.).
- A Tailscale account.
- Internet access for initial setup and authentication.

### iOS Requirements
- macOS with Xcode 15.0 or later.
- An iPhone running iOS 16.0 or later.
- Tailscale app installed on the iPhone to access the private network.

## Server Setup Instructions

The server acts as the central data hub and provides a web-based dashboard for desktop users.

### 1. Generate a Tailscale Auth Key
To allow the server to join your private network automatically, you need an Auth Key:
1. Log in to the Tailscale Admin Console.
2. Navigate to Settings > Keys.
3. Click "Generate auth key".
4. Settings for the key:
   - Description: Amaka Hub Server
   - Reusable: Off (Recommended for security)
   - Ephemeral: Off
   - Pre-authorized: On
5. Copy the generated key (it starts with `tskey-auth-`).

### 2. Configure and Run the Server
1. Open a terminal on your server machine.
2. Navigate to the server directory:
   ```bash
   cd server
   ```
3. Initialize the Go environment (if not already done):
   ```bash
   go mod tidy
   ```
4. Run the server using the Auth Key generated in Step 1:
   ```bash
   export TS_AUTHKEY=tskey-auth-your-key-here
   go run main.go
   ```
5. On the first run, the server will register itself as `amaka-hub` in your Tailscale fleet.

### 3. Persistent Background Execution
For a production-like setup on a Raspberry Pi, you likely want the server to run in the background.

**Option A: Simple Backgrounding (nohup)**
```bash
export TS_AUTHKEY=tskey-auth-your-key-here
nohup go run main.go > server.log 2>&1 &
```

**Option B: systemd (Recommended)**
Create a service file at `/etc/systemd/system/amaka.service`:
```ini
[Unit]
Description=Amaka Hub Server
After=network.target

[Service]
Type=simple
User=pi
WorkingDirectory=/home/pi/Amaka/server
Environment=TS_AUTHKEY=tskey-auth-your-key-here
ExecStart=/usr/local/go/bin/go run main.go
Restart=always

[Install]
WantedBy=multi-user.target
```
Then enable and start it:
```bash
sudo systemctl enable amaka
sudo systemctl start amaka
```

## iOS App Setup Instructions

### 1. Build the Application
1. Open `Amaka.xcodeproj` in Xcode.
2. Ensure the Deployment Target is set to iOS 16.0 or higher in the Project Settings.
3. Select your iPhone as the build target.
4. Build and Run (Cmd + R).

### 2. Configure Connection
1. Ensure the Tailscale app is installed and connected on your iPhone.
2. Open the Amaka app.
3. Tap the Settings icon (gear) in the top-right corner.
4. Enter your server URL: `http://amaka-hub/`.
5. Tap "Save & Restart Sync".

## Troubleshooting

### Server Cannot Connect to Tailscale
- Verify that the `TS_AUTHKEY` is valid and has not expired.
- Check that the server machine has outbound internet access on port 443.
- If the hostname `amaka-hub` is already taken, you can change it in `server/main.go`.

### App Cannot Find the Server
- Ensure MagicDNS is enabled in your Tailscale Admin Console (Settings > DNS).
- Verify that your iPhone is connected to the same Tailscale network as the server.
- Try using the server's Tailscale IP address (found in the Admin Console) instead of `http://amaka-hub/`.

### Permissions and Ports
- The server listens on a virtual Tailscale interface; it does not require root privileges to bind to port 80 on that virtual interface.
- Standard local firewalls (like ufw or iptables) may need to allow traffic from the Tailscale interface (`tailscale0`).

## Features
- tsnet Powered: Embedded Tailscale identity for zero-install deployment.
- Family Status: Real-time status updates for all family members.
- Shared Shopping: Synchronized list for household essentials.
- Secure Notes: Shared area for sensitive information.
- Server Health: Remote monitoring of CPU and storage usage.
- Web Dashboard: Full access via browser at http://amaka-hub.

## Tech Stack
- iOS: Swift, SwiftUI.
- Server: Go, tsnet, HTML, Vanilla CSS.
- Networking: Tailscale (WireGuard).
