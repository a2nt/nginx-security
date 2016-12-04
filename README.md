# Improved NGINX security + SilverStripe support
/path/to/repository/frameworks/security.conf
+ Blocks Bad referers
+ Blocks Bad IPs
+ Blocks Direct access to *.php, *.asp, *.php3, *.php4, *.php5, *.phtml, *.inc and etc files
+ Blocks Bad countries (optionally GeoIP support required)
+ Logs sniffers into /var/logs/nginx/sniffer.log
+ Logs very suspicious sniffers into /var/logs/nginx/ban-sniffer.log
+ Logs blocks into /var/logs/nginx/*.log



Script Auto-Updates:
+ NGINX GeoIP DB
+ Piwik Referer black list DB
+ Stevie-Ray referer black list DB
+ IBlockList.com black list DB

Automatically generates NGINX configuration files at ./conf.d/*

## Installation
+ Launch ./install.sh from repository path to clone required git repositories
+ Setup PATHTOREPOSITORY variable at ./blacklist-update.sh
+ Launch ./blacklist-update.sh to generate NGINX configs and update the staff

+ Modify your nginx.conf to include black lists by adding:
```
http {
    ...
    include /path/to/repository/conf.d/*.conf;
    ...
}
```

+ Modify your nginx server (domain) configuration file to include security settings:
```
server {
    server_name your.domain.com;
    ...
    ...
    include /path/to/repository/frameworks/security.conf;
    ...
}
```

## GeoIP DB configuration
Configuration is commented out, but in case your NGINX supports GeoIP you can enable it by editing:
+ /path/to/repository/conf.d/block-country.conf
+ /path/to/repository/frameworks/security.conf

## Extra SilverStripe Framework configuration example:

Setups SilverStripe production configuration and static files directly serve with cache headers

+ Setup your php server path at /path/to/repository/frameworks/fastcgi.conf
+ Setup paths at /path/to/repository/frameworks/silverstripe.conf

+ Include silverstripe.conf:
```
server {
    server_name your.domain.com;
    root /path/to/your/website;
    include /path/to/repository/frameworks/silverstripe.conf;
}
```
