#!/bin/bash

typeset ext_ip_prompt="Input your external IP:"
typeset ext_ip=""
typeset int_ip_prompt="Input your internal IP:"
typeset int_ip=""
typeset config_file="/etc/jitsi/videobridge/sip-communicator.properties"
typeset tempfile="/tmp/sip-communicator.properties.temp"
[[ -f "${tempfile}" ]] && rm -f "${tempfile}"
cp -p "${config_file}" "${tempfile}"

echo "${ext_ip_prompt}"
read ext_ip
echo ""
echo "${int_ip_prompt}"
read int_ip=""
echo ""

cat <<EOF >> "${config_file}"
org.ice4j.ice.harvest.NAT_HARVESTER_LOCAL_ADDRESS=${int_ip}
org.ice4j.ice.harvest.NAT_HARVESTER_PUBLIC_ADDRESS=${ext_ip}
EOF

sed 's/org.ice4j.ice.harvest.STUN_MAPPING_HARVESTER_ADDRESSES/#org.ice4j.ice.harvest.STUN_MAPPING_HARVESTER_ADDRESSES/' "${config_file}" > "${tempfile}"
cp -p "${tempfile}" "${config_file}"

systemctl restart jitsi-videobridge2

exit 0
