#!/bin/bash

#------AUTHOR: Ahmad Sami------#

rm /home/master/mixed-content-report* 


clear
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
read -r -p $'\e[0;32m1- Enter the Website Domain name\e[0m: '  RAW_DOMAINNAME
URL_DOMAIN=$(curl -Ls -k -o /dev/null -w %{url_effective} $RAW_DOMAINNAME)
#DOMAINNAME=http://minhalas.com
DOMAINNAME=$(echo "$RAW_DOMAINNAME" | sed -e 's|^[^/]*//||' -e 's|/.*$||')
echo -e "\n"
echo -e "\n"


#------HTTPS check start------#

echo -e "$S"
echo -e "$D"
echo -e "\tBasic Sanity Checks report of $UYel$DOMAINNAME $EndCOLOR"
echo -e "$D"
echo -e "$S\n"

wget $DOMAINNAME -O /dev/null 2>&1 | grep Location: | tail -n1 > $file_domain
grep -q "https:" $file_domain; [ $? -eq 0 ] && echo -e "HTTPS-ENABLED: $GCOLOR"  ||  echo -e "HTTPS-ENABLED: $RCOLOR"

#------HTTPS check end------#

#------Status code check start------#

code=$(curl -skLo /dev/null -w "%{http_code}"  $URL_DOMAIN)

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

APP_TYPE=$(awk '{sub(/-.*/, ""); print}' $HOME/applications/$APP_NAME/conf/server.nginx | grep -v "Domain_alias" | sed -r '/^\s*$/d' | cut -f 3 -d ' ')

[ -z "$APP_TYPE" ] && APP_TYPE=$(awk '{sub(/-.*/, ""); print}' $HOME/applications/$APP_NAME/conf/server.nginx | grep -v "Domain_alias" | sed -r '/^\s*$/d' | cut -f 6 -d ' ')

CACHE=$(curl -sv -k $URL_DOMAIN   -H 'authority: $DOMAINNAME'   -H 'upgrade-insecure-requests: 1'   -H 'user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/86.0.4240.198 Safari/537.36'   -H 'accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9'   -H 'sec-fetch-site: none'   -H 'sec-fetch-mode: navigate'   -H 'sec-fetch-dest: document'   -H 'accept-language: en-US,en;q=0.9'  --compressed 2>&1 > /dev/null | egrep -i '< (X-Cache|x-magento-cache-debug)' | cut -d':' -f2 | cut -f 2 -d ' ' | sed -e 's/\r//g')


case $APP_TYPE in

wordpress|wordpressmu|woocommerce)

        case $CACHE in
        HIT)
                echo -e "CACHE STATUS:$BIGre  ------  Varnish is CACHING $EndCOLOR"

        ;;
        MISS)
                echo -e "CACHE STATUS:$BIRed  ------  Varnish is not CACHING $EndCOLOR"
        ;;
             *) echo -e "CACHE STATUS:$BIRed  ------  Varnish is not Enabled, Please check under app settings or managed services tab $EndCOLOR"
        ;;
        esac
;;


magento)

        MAG_VERSION=$(php $HOME/applications/$APP_NAME/public_html/bin/magento --version | cut -f 3 -d ' ' | cut -d'.' -f1)

        case $MAG_VERSION in
        2)
                
             case $CACHE in
                HIT)
                    echo -e "CACHE STATUS:$BIGre  ------ Varnish is CACHING $EndCOLOR"

                ;;
                MISS)
                echo -e "CACHE STATUS:$BIRed  ------   Varnish is not CACHING $EndCOLOR"
                ;;
                *) echo -e "CACHE STATUS:$BIRed  ------   Varnish is not Enabled, Please check under app settings or managed services tab $EndCOLOR"
                ;;
            esac
        ;;
        *) echo -e "CACHE STATUS:$BIRed  ------   Varnish is not supported for Magento-1. Use Cloudways FPC please $EndCOLOR"
        ;;
        esac

;;



*) echo -e "CACHE STATUS:$BIRed  ------   Varnish is not supported for this application. Please check https://support.cloudways.com/most-common-varnish-issues-and-queries/ $EndCOLOR"
;;

esac

if [[ $APP_TYPE == "wordpress" ||  $APP_TYPE == "wordpressmu" || $APP_TYPE == "woocommerce" ]]; then

    if  [[ -f "$HOME/applications/$APP_NAME/public_html/wp-content/advanced-cache.php" ]]; then

       if grep -q "breeze"  $HOME/applications/$APP_NAME/public_html/wp-content/advanced-cache.php 
        then
  
            echo -e "WP CACHE PLUGIN:$BIGre  ------ BREEZE. $EndCOLOR  Please verify the settings from https://support.cloudways.com/breeze-wordpress-cache-configuration/"
            

        elif grep -q "w3-total-cache"  $HOME/applications/$APP_NAME/public_html/wp-content/advanced-cache.php 

        then

            echo -e "WP CACHE PLUGIN:$BIGre  ------ W3 Total Cahe. $EndCOLOR Please verify the settings from https://support.cloudways.com/wordpress-w3-total-cache-configuration-for-optimal-performance/"
           

        elif grep -q "wp-rocket"  $HOME/applications/$APP_NAME/public_html/wp-content/advanced-cache.php 

        then

            echo -e "WP CACHE PLUGIN:$BIGre  ------ Wp-ROCKET. $EndCOLOR Please verify the settings from https://support.cloudways.com/how-to-configure-wp-rocket-plugin-wordpress/"
           

        
        else

            echo -e "WP CACHE PLUGIN:$BIGre  ------ Different Cache plugin is being used, Plesae check /wp-content/advanced-cache.php file to know the name of the plugin and review the settings from it's KB or install Breeze on it. $EndCOLOR"
    
        fi
    else

        echo -e "WP CACHE PLUGIN:$BIRed  ------ No Cache plugin is being used. Please take a help from senior"
    fi

else

    echo -e "WP CACHE PLUGIN:$BIRed  ------ It isn't a WP family"

fi


echo -e "\n"
echo -e "\tChecking the mixed content for $UYel$DOMAINNAME $EndCOLOR"
echo -e "$D\n"

#for user in $(cat /etc/passwd | grep master | awk -F : '{print $1}'); do su $user; done
cd /home/master/
composer global require spatie/mixed-content-scanner-cli -d /home/master/ -q
/home/master/vendor/bin/mixed-content-scanner scan $URL_DOMAIN >> /home/master/mixed-content-report
sed -n -e '/Scan results/,$p' /home/master/mixed-content-report >> /home/master/mixed-content-report-1
sed -n '/non responsive url/q;p' /home/master/mixed-content-report-1  >> /home/master/mixed-content-report-final
#sed -n '/without mixed content/q;p' /home/master/mixed-content-report-final >> /home/master/mixed-content-report-final-2


FILE=/home/master/mixed-content-report-final

if grep -q "found mixed content on"  "$FILE"; then
  
   echo -e "MIXED CONTENT: $BIRed  ------ YES $EndCOLOR"
    echo -e "\n"
   echo -e "Here are the URLs suffering from MIXED CONTENT"
   echo -e "\n"
   sed -n '/without mixed content/q;p' /home/master/mixed-content-report-final >> /home/master/mixed-content-report-final-2
   cat /home/master/mixed-content-report-final-2

else
  echo -e "MIXED CONTENT: $BIGre  ------ NO $EndCOLOR"

fi

rm mixed-content-report* 
