#!/bin/bash

ufw allow 22124/udp

ufw enable
ufw reload

ufw status verbose

exit 0
