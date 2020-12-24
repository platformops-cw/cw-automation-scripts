#!/bin/bash -x
#------variables used------#
S="*******************************************************************"
D="-------------------------------------------------------------------"
COLOR="y"
HOME="/home/master"
if [ $COLOR == y ]; then
{
 GCOLOR="\e[92m ------ YES \e[0m"
 RCOLOR="\e[91m ------ NO \e[0m"
 EndCOLOR="\e[0m"
 UYel='\e[4;33m';
 BIGre='\e[1;92m';
 BIRed='\e[1;91m';
}
else
{
 GCOLOR=" ------ OK/HEALTHY "
 WCOLOR=" ------ WARNING "
 CCOLOR=" ------ CRITICAL "
}
fi
file_domain=file-DOMAINNAME
read -r -p "Enter Website Domain: "  RAW_DOMAINNAME
URL_DOMAIN=$(curl -Ls -o /dev/null -w %{url_effective} $RAW_DOMAINNAME)
#DOMAINNAME=http://minhalas.com
DOMAINNAME=$(echo "$RAW_DOMAINNAME" | sed -e 's|^[^/]*//||' -e 's|/.*$||')
clear
#------HTTPS check start------#
echo -e "$S"
echo -e "\tBasic Sanity Checks report of $UYel$DOMAINNAME $EndCOLOR"
echo -e "$S\n"
wget $DOMAINNAME -O /dev/null 2>&1 | grep Location: | tail -n1 > $file_domain
grep -q "https:" $file_domain; [ $? -eq 0 ] && echo -e "HTTPS-ENABLED: $GCOLOR"  ||  echo -e "HTTPS-ENABLED: $RCOLOR"
#------HTTPS check end------#
#------Status code check start------#
code=$(curl -sLo /dev/null -w "%{http_code}"  $DOMAINNAME)
case $code in
     000) status="Not responding " ;;
     100) status="Informational: Continue" ;;
     101) status="Informational: Switching Protocols" ;;
     200) status="Successful: OK " ;;
     201) status="Successful: Created" ;;
     202) status="Successful: Accepted" ;;
     203) status="Successful: Non-Authoritative Information" ;;
     204) status="Successful: No Content" ;;
     205) status="Successful: Reset Content" ;;
     206) status="Successful: Partial Content" ;;
     300) status="Redirection: Multiple Choices" ;;
     301) status="Redirection: Moved Permanently" ;;
     302) status="Redirection: Found residing temporarily under different URI" ;;
     303) status="Redirection: See Other" ;;
     304) status="Redirection: Not Modified" ;;
     305) status="Redirection: Use Proxy" ;;
     306) status="Redirection: status not defined" ;;
     307) status="Redirection: Temporary Redirect" ;;
     400) status="Client Error: Bad Request" ;;
     401) status="Client Error: Unauthorized" ;;
     402) status="Client Error: Payment Required" ;;
     403) status="Client Error: Forbidden" ;;
     404) status="Client Error: Not Found" ;;
     405) status="Client Error: Method Not Allowed" ;;
     406) status="Client Error: Not Acceptable" ;;
     407) status="Client Error: Proxy Authentication Required" ;;
     408) status="Client Error: Request Timeout " ;;
     409) status="Client Error: Conflict" ;;
     410) status="Client Error: Gone" ;;
     411) status="Client Error: Length Required" ;;
     412) status="Client Error: Precondition Failed" ;;
     413) status="Client Error: Request Entity Too Large" ;;
     414) status="Client Error: Request-URI Too Long" ;;
     415) status="Client Error: Unsupported Media Type" ;;
     416) status="Client Error: Requested Range Not Satisfiable" ;;
     417) status="Client Error: Expectation Failed" ;;
     500) status="Server Error: Internal Server Error" ;;
     501) status="Server Error: Not Implemented" ;;
     502) status="Server Error: Bad Gateway" ;;
     503) status="Server Error: Service Unavailable" ;;
     504) status="Server Error: Gateway Timeout " ;;
     505) status="Server Error: HTTP Version Not Supported" ;;
     *)   echo -n "unknown" ;;
esac
if [ "$code" != "200" ]; then
               echo -e "STATUS_CODE: $BIRed  ------ $code $status$EndCOLOR"
            else
               echo -e "STATUS_CODE: $BIGre  ------ $code $status$EndCOLOR"
fi
#------Status code check end------#
APP_NAME=$(grep -lr $DOMAINNAME /home/master/applications/*/conf/server.nginx)
APP_NAME=$(basename $(dirname $(dirname $APP_NAME)))
echo $APP_NAME
#APP_TYPE=$(cat $HOME/applications/$APP_NAME/conf/server.nginx)
APP_TYPE=$(awk '{sub(/-.*/, ""); print}' $HOME/applications/$APP_NAME/conf/server.nginx | grep -v "Domain_alias" | sed -r '/^\s*$/d' | cut -f 3 -d ' ')
echo $APP_TYPE
echo $RAW_DOMAINNAME
CACHE=$(curl -sv $RAW_DOMAINNAME 2>&1 > /dev/null | egrep -i '< (X-Cache|x-magento-cache-debug)' | cut -d':' -f2 | cut -f 2 -d ' ' | sed -e 's/\r//g')
case $APP_TYPE in
wordpress|wordpressmu|woocommerce|drupal|joomla)
        case $CACHE in
        HIT)
                echo "CACHE STATUS: CACHING"
        ;;
        MISS)
                echo "CACHE STATUS: NOT CACHING"
        ;;
             *) echo "VARNISH: IS DISABLED"
        ;;
        esac
;;
magento)
        MAG_VERSION=$(php $HOME/applications/$APP_NAME/public_html/bin/magento --version | cut -f 3 -d ' ' | cut -d'.' -f1)
        case $MAG_VERSION in
        2)
             case $STATUS_CACHE in
                HIT)
                    echo "CACHE STATUS: CACHING"
                ;;
                MISS)
                echo "CACHE STATUS: NOT CACHING"
                ;;
                *) echo "VARNISH: IS DISABLED"
                ;;
            esac
        ;;
        *) echo "Varnish is not supported for Magento-1. Use Cloudways FPC please"
        ;;
        esac
;;
*) echo "Varnish is not supported for this application. Please check https://support.cloudways.com/most-common-varnish-issues-and-queries/"
;;
esac
