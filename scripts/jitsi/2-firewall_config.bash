#!/bin/bash

ufw allow 80/tcp
ufw allow 443/tcp
ufw allow 4443/tcp
ufw allow 10000/udp
ufw allow 22/tcp

ufw enable
ufw reload

ufw status verbose

exit 0
