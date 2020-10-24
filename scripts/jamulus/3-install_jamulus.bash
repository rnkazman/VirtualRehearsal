#!/bin/bash

# Jamulus central server options
#         Genre          |            Server Address             
# -----------------------|---------------------------------------
#        all/any         |  jamulusallgenres.fischvolk.de:22224  
#         rock           |  jamulusrock.fischvolk.de:22424       
#         jazz           |  jamulusjazz.fischvolk.de:22324       
#  Classical/Folk/Choir  |  jamulusclassical.fischvolk.de:22524  

typeset R=$(curl -s https://api.github.com/repos/corrados/jamulus/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")')
typeset jamulus="/usr/local/bin/Jamulus"
typeset central_server="jamulusclassical.fischvolk.de:22524"
typeset service_script="/etc/systemd/system/jamulus.service"
typeset server_name_prompt="Input the server name:"
typeset server_name=""
typeset welcome_message_prompt="Input the server welcome message:"
typeset welcome_message=""
typeset welcome_path="/etc/jamulus/jamulus_welcome"

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

# prompt user for welcome message
echo "${welcome_message_prompt}"
echo ""
read welcome_message

# create welcome message file
if ! [[ -d "${welcome_path%/*}" ]]
then
  mkdir -p "${welcome_path%/*}"
  chown jamulus "${welcome_path%/*}"
fi
echo "${welcome_message}" > "${welcome_path}"
chown jamulus "${welcome_path}"

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
ExecStart=/usr/local/bin/Jamulus -s -n -e ${central_server} -o "${server_name};Honolulu;225" -w ${welcome_path} -u 50 -F -T

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
systemctl daemon-reload
systemctl start jamulus
systemctl enable jamulus
sleep 2
systemctl status jamulus

exit 0
