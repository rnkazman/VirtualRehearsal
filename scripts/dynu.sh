echo url="https://api.dynu.com/nic/update?hostname=$(hostname)&username=echang&password=27c13f7329a37645f40190dc9c5be4d1" | curl -k -o /var/log/dynu.log -K - >/dev/null 2>&1
