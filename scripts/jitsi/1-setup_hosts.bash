#!/bin/bash

typeset hostname_prompt="Input new fully qualified hostname (name.domain.com):"
typeset ip_warn="Warning: IP must be manually assigned to the server. This program does not modify the server's IP."
typeset ip_prompt="Input new ip for hosts file:"
typeset full_host=""
typeset short_host=""
typeset ip=""
typeset response=""
typeset hostname_file="/etc/hostname"
typeset hosts_file="/etc/hosts"

echo "${hostname_prompt}"
read full_host
short_host=$(echo "${full_host}" | awk -F. '{print $1}')
echo ""
echo "${ip_warn}"
echo "${ip_prompt}"
read ip
echo ""

echo "Reconfiguring..."
echo "${full_host}" > "${hostname_file}"
(
  echo ""
  echo "# Jitsi host information"
  echo "${ip}    ${full_host}    ${short_host}"
) >> "${hosts_file}"

while [[ -z "${response}" ]]
do
  echo "Reconfiguration complete. Reboot required. Reboot now?"
  read response
  case "${response}" in
    y | ye | yes )
      echo "Rebooting now."
      reboot
      ;;
    n | no )
      exit 0
      ;;
    * )
      echo "Invalid response."
      echo ""
      response=""
      ;;
  esac
done

exit 0
