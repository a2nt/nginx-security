#!/usr/bin/env sh

# Ban sniffers by parsing NGINX log

# Set your repository path
PATHTOREPOSITORY=/path/to/repository
# Or get it by working directory (comment it out if u want to specify path manually)
PATHTOREPOSITORY="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"


LISTIP="${PATHTOREPOSITORY}"/conf.d/block-ip.conf
cat "${PATHTOREPOSITORY}"/conf.d/block-ip.conf | head -n -1 | tail -n +4 > /tmp/block-ip.conf
cat /var/logs/nginx/ban-sniffer.log | awk -F " - " 'NF {print $2"/32 1;"}' | sed '/^\/32 1;/d' >> /tmp/block-ip.conf

# TO-DO: check if it's search engine bot
# check bot: host 66.249.66.1 | tail -1 | grep -oE "(baidu\.jp|googlebot\.com|google\.com|yandex\.com|search\.msn\.com|yahoo\.com|aol\.com|duckduckgo\.com)"
echo '# WARNING! This file was generated. Do not change!' > "${LISTIP}"
echo 'geo $block_ip {' >> "${LISTIP}"
echo 'default 0;' >> "${LISTIP}"
cat /tmp/block-ip.conf | sort | uniq >> "${LISTIP}"
echo '}' >> "${LISTIP}"

rm /tmp/block-ip.conf
#rm /var/logs/nginx/ban-sniffer.log

service nginx reload