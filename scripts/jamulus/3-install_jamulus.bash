#!/bin/bash

typeset R=$(curl -s https://api.github.com/repos/corrados/jamulus/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")')
typeset jamulus="/usr/local/bin/Jamulus"
typeset service_script="/etc/systemd/system/jamulus.service"
typeset server_name_prompt="Input the server name:"
typeset server_name=""

# Confirm that Jamulus is where we expect it to be
if [[ -f "${jamulus}" ]]
then
  chmod 755 "${jamulus}"
else
  echo "WARNING: ${jamulus} does not exist, may need to move the Jamulus file from /root."
fi

# Create jamulus user
adduser --system --no-create-home jamulus

# prompt user for server name
echo "${server_name_prompt}"
read server_name

# Create jamulus service script
cat <<EOF > "${service_script}"
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
ExecStart=/usr/local/bin/Jamulus -s -n -e jamulusallgenres.fischvolk.de:22224 -o "${server_name};Honolulu;225"

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
