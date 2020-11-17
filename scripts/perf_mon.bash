#!/bin/bash
# script should run every 6 hours in crontab
# 0 */6 * * * /root/scripts/perf_mon.bash

typeset cache_dir="/tmp/nmon"
typeset max_files=4
typeset host="$(hostname)"
typeset sendto="log-${host%%.*}@eyc-labs.com"
typeset fromaddr="Logs <logs@$(hostname)>"
typeset cap_delay="300" # capture every 5 minutes
typeset cap_cnt="72" # capture 72 times (6 hours)

which nmon >/dev/null 2>&1 || exit 1
which mail >/dev/null 2>&1 || exit 1
[[ -d "${cache_dir}" ]] || mkdir -p "${cache_dir}"
cd -- "${cache_dir}" || exit 1

# cleanup old nmon files
while (( $(ls "${cache_dir}" | wc -l) > max_files ))
do
  rm -f "$(ls -t | tail -1)"
done

# email most recent log file
echo "Logs up to $(date)" | mail -a "From: ${fromaddr}" -s "$(hostname) Performance Logs" -A "$(ls -t ${cache_dir} | head -1)" "${sendto}"

# setup the next log capture
nmon -f -s "${cap_delay}" -c "${cap_cnt}"

exit 0
