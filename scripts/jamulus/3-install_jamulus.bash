#!/bin/bash

typeset R=$(curl -s https://api.github.com/repos/corrados/jamulus/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")')
typeset jam_bin="/root/jamulus/Jamulus"
typeset install_path="/usr/local/bin/"
typeset service_script="/etc/systemd/system/jamulus.service"

# Move Jamulus binary to the install path
mv "${jam_bin}" "${install_path}"
chmod 755 "${install_path}"/Jamulus

# Create jamulus user
adduser --system --no-create-home jamulus

# Create jamulus service script
cat <<'EOF' > "${service_script}"
[Unit]
Description=Jamulus-Server
After=network.target

[Service]
Type=simple
User=jamulus
Group=nogroup
NoNewPrivileges=true
ProtectSystem=true
ProtectHome=true
Nice=-20
IOSchedulingClass=realtime
IOSchedulingPriority=0

#### Change this to set genre, location and other parameters.
#### See https://github.com/corrados/jamulus/wiki/Command-Line-Options ####
ExecStart=/usr/local/bin/Jamulus -s -n -e jamulus.fischvolk.de -o "yourServerName;yourCity;[country ID]"

Restart=on-failure
RestartSec=30
StandardOutput=journal
StandardError=inherit
SyslogIdentifier=jamulus

[Install]
WantedBy=multi-user.target
EOF
chmod 644 "${service_script}"

# Start and enable jamulus
systemctl start jamulus
systemctl enable jamulus
sleep 2
systemctl status jamulus

exit 0
