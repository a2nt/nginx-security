#!/usr/bin/env sh

# Ban sniffers by parsing NGINX log

# Set your repository path
PATHTOREPOSITORY=/path/to/repository
# Or get it by working directory (comment it out if u want to specify path manually)
PATHTOREPOSITORY="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"


LISTIP="${PATHTOREPOSITORY}"/conf.d/block-ip.conf
cat "${PATHTOREPOSITORY}"/conf.d/block-ip.conf | head -n -1 > /tmp/block-ip.conf
cat /var/logs/nginx/ban-sniffer.log | awk -F " - " 'NF {print $2"/32 1;"}' >> /tmp/block-ip.conf
echo "}" >> /tmp/block-ip.conf
cat /tmp/block-ip.conf | uniq > "${LISTIP}"

rm /tmp/block-ip.conf
rm /var/logs/nginx/ban-sniffer.log

service nginx reload