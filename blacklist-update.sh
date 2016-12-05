#!/usr/bin/env sh

#
# Required:
# + ipcalc (utility to calculate IP ranges)
# + wget to download DBs
#
# At debian based repository can be installed by:
# apt install wget
# apt install ipcalc
#

# Set your repository path
PATHTOREPOSITORY=/path/to/repository
# Or get it by working directory (comment it out if u want to specify path manually)
PATHTOREPOSITORY="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

#
# Update GeoIP
#
cd "${PATHTOREPOSITORY}"/conf.d/geoip
wget http://geolite.maxmind.com/download/geoip/database/GeoLiteCountry/GeoIP.dat.gz
gunzip -f GeoIP.dat.gz

LISTIP="${PATHTOREPOSITORY}"/conf.d/block-ip.conf
# Update Antizapret
cd "${PATHTOREPOSITORY}"/antizapret
git pull
cd "${PATHTOREPOSITORY}"

getlist() {
    cat ./antizapret/"${1}".txt | sed '/^#/ d' | awk 'NF {print $1" 1;"}' >> /tmp/block-ip.conf
}
getwhitelist(){
    wget "${1}" -O /tmp/whitelist.txt
    cat /tmp/whitelist.txt | sed '/^#/ d' | awk 'NF {print $1"/32 0;"}' | sed '/^\/32 1;/d' >> /tmp/block-ip.conf
}

cat  "${PATHTOREPOSITORY}"/custom-blocks/whitelist-ip.txt | sed '/^#/ d' | awk 'NF {print $1" 0;"}' > /tmp/block-ip.conf
cat  "${PATHTOREPOSITORY}"/custom-blocks/ip.txt | sed '/^#/ d' | awk 'NF {print $1" 1;"}' >> /tmp/block-ip.conf

#
# Antizapret:
# This guys were offended by Russian Government blocking some websites
# So they have made a list of RU gov IP ranges to block them before they will be able to block you
# But actually it won't work if u won't block ranges from "gov + copyright" area
#
getlist blacklist4
getlist blacklist6


# write nginx config
echo '# WARNING! This file was generated. Do not change!' > "${LISTIP}"
echo 'geo $block_ip {' >> "${LISTIP}"
echo 'default 0;' >> "${LISTIP}"
cat /tmp/block-ip.conf | sort | uniq >> "${LISTIP}"
echo '}' >> "${LISTIP}"

rm /tmp/block-ip.conf


#
# Update bad referers
#
cd "${PATHTOREPOSITORY}"/referrer-spam-blacklist
git pull
cd "${PATHTOREPOSITORY}"/referrer-spam-blocker
git pull
cd "${PATHTOREPOSITORY}"

LISTREFERER="${PATHTOREPOSITORY}"/conf.d/block-referer.conf
cat  "${PATHTOREPOSITORY}"/custom-blocks/referers.txt  | sed '/^#/ d' | awk  'NF {gsub("\.","\.",$1);gsub("\-","\-",$1);print "\"~*"$1"\" 1;"}' > /tmp/block-referer.conf
cat  "${PATHTOREPOSITORY}"/referrer-spam-blacklist/spammers.txt | awk  'NF {gsub("\.","\.",$1);gsub("\-","\-",$1);print "\"~*"$1"\" 1;"}' >> /tmp/block-referer.conf
cat  "${PATHTOREPOSITORY}"/referrer-spam-blocker/generator/domains.txt | awk 'NF {gsub("\.","\.",$1);gsub("\-","\-",$1);print "\"~*"$1"\" 1;"}' >> /tmp/block-referer.conf

# write nginx config
echo '# WARNING! This file was generated. Do not change!' > "${LISTREFERER}"
echo 'map $http_referer $block_referer {' >> "${LISTREFERER}"
echo 'default 0;' >> "${LISTREFERER}"
cat /tmp/block-referer.conf | sort | uniq >> "${LISTREFERER}"
echo '}' >> "${LISTREFERER}"

rm /tmp/block-referer.conf


#
# Update IBlockList.com
#
get_blacklist(){
    wget $1 -O /tmp/iblocklist.gz
    gzip -d /tmp/iblocklist.gz
    grep -o '^[^#]*' /tmp/iblocklist | awk -F ":" 'NF {system("ipcalc " $2 " | tail -1 | xargs echo -n"); print " 1;"}' >> /tmp/iblock-list.conf
    rm /tmp/iblocklist
}

rm /tmp/iblocklist.gz
rm /tmp/iblocklist
rm /tmp/iblock-list.conf

# DROP
get_blacklist 'http://list.iblocklist.com/?list=zbdlwrqkabxbcppvrnos&fileformat=p2p&archiveformat=gz'
# hijacked
get_blacklist 'http://list.iblocklist.com/?list=usrcshglbiilevmyfhse&fileformat=p2p&archiveformat=gz'
# known Hackers
get_blacklist 'http://list.iblocklist.com/?list=xpbqleszmajjesnzddhv&fileformat=p2p&archiveformat=gz'
# forum spammers
get_blacklist 'http://list.iblocklist.com/?list=ficutxiwawokxlcyoeye&fileformat=p2p&archiveformat=gz'
# webexploit
get_blacklist 'http://list.iblocklist.com/?list=ghlzqtqxnzctvvajwwag&fileformat=p2p&archiveformat=gz'
# Tor and other open proxies
get_blacklist 'http://list.iblocklist.com/?list=xoebmbyexwuiogmbyprb&fileformat=p2p&archiveformat=gz'
# ZEUS
get_blacklist 'http://list.iblocklist.com/?list=ynkdjqsjyfmilsgbogqf&fileformat=p2p&archiveformat=gz'
# CruzIT
get_blacklist 'http://list.iblocklist.com/?list=czvaehmjpsnwwttrdoyl&fileformat=p2p&archiveformat=gz'
# Spiders
get_blacklist 'http://list.iblocklist.com/?list=mcvxsnihddgutbjfbghy&fileformat=p2p&archiveformat=gz'
get_blacklist 'http://list.iblocklist.com/?list=ua&fileformat=p2p&archiveformat=gz'

# gov + copyright:
# Companies or organizations who are clearly involved with trying to stop filesharing.
# Companies which anti-p2p activity has been seen from.
# Companies that produce or have a strong financial interest in copyrighted material.
# Government ranges or companies that have a strong financial interest in doing work for governments.
# Legal industry ranges.
# IPs or ranges of ISPs from which anti-p2p activity has been observed.
# get_blacklist 'http://list.iblocklist.com/?list=ydxerpxkpcfqjaybcssw&fileformat=p2p&archiveformat=gz'

# write nginx config
LISTIBLOCK="${PATHTOREPOSITORY}"/conf.d/iblock-list.conf
echo '# WARNING! This file was generated. Do not change!' > "${LISTIBLOCK}"
echo 'geo $iblock {' >> "${LISTIBLOCK}"
echo 'default 0;' >> "${LISTIBLOCK}"
cat /tmp/iblock-list.conf | sed -e 's/^[ \t]*//' | sed '/ipcalc 0.41 1;/d' | sed '/^1;/d' | sort | uniq >> "${LISTIBLOCK}"
echo '}' >> "${LISTIBLOCK}"

rm /tmp/iblock-list.conf

# reload nginx conf
service nginx reload