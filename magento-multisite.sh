#!/bin/bash
#------variables used------#
clear

S="*******************************************************************"
D="-------------------------------------------------------------------"
E="==================================================================="
F="..................................................................."



COLOR="y"
HOME="/home/master/applications/"

IRed='\e[0;91m';
Yel='\e[0;33m';
EndCOLOR="\e[0m"
BRed='\e[1;31m';

x=1
y=1

now="$(date)"

#############--Processing--#################
echo "*********************" >> /home/master/Script_stats
echo "Date: $now" >> /home/master/Script_stats
echo "*********************" >> /home/master/Script_stats
echo -e "$S"
echo -e "$IRed      MAGENTO 2 MULTISITE CONFIGURATION SCRIPT $EndCOLOR"
echo -e "$S\n"

echo -e "$Yel Gathering Initial Details $EndCOLOR"
echo -e "$F\n"
read -r -p $'\e[0;32m1- Enter the Database name\e[0m: '  DB_NAME

echo "Appname: $DB_NAME" >> /home/master/Script_stats

if [[ $DB_NAME == "" ]]; then
  echo "You have not entered any value. Please re-initiate the script" && exit
    fi
read -r -p $'\e[0;32m2- Enter the number of websites to configure (count with and without www seperate)\e[0m: '  NO_OF_STORES

echo "Stores_count: $NO_OF_STORES" >> /home/master/Script_stats

if [[ $NO_OF_STORES == "" ]]; then
  echo "You have not entered any value. Please re-initiate the script" && exit
    fi
echo " "
#echo "THANKYOU"

sleep 0.5
echo -ne $'\e[1;32mFETCHING STORE LIST --         \r\e[0m'
sleep 0.5
echo -ne $'\e[1;33mFETCHING STORE LIST ----          \r\e[0m'
sleep 0.5
echo -ne $'\e[1;34mFETCHING STORE LIST -------          \r\e[0m'
sleep 0.5
echo -ne $'\e[1;35mFETCHING STORE LIST ---------          \r\e[0m'
sleep 0.5
echo -ne $'\e[1;36mFETCHING STORE LIST ------------          \r\e[0m'
echo -e "$F"
echo -ne '\n'

echo "===============================" >> /home/master/Script_stats

while [ $y -le $NO_OF_STORES ];
do
        echo -ne '\n'
        php $HOME/$DB_NAME/public_html/bin/magento store:website:list
                while [ $x -le $NO_OF_STORES ] || [[ $SITE_DOMAIN == '' ]]; do

                                echo -e "\n"
                                echo -e "$Yel Gathering SITE-$x Details $EndCOLOR"
                                echo -e "$F\n"

                                read -r -p $'\e[0;32m a- Enter the DOMAIN of the site \e[0m: '  SITE_DOMAIN
                                

                                
                                if [[ $SITE_DOMAIN == "" ]]; then
                                echo "You have not entered any value. Please re-initiate the script" && exit
                                fi

                                echo "Domain$x: $SITE_DOMAIN" >> /home/master/Script_stats

                                SITE_DOMAIN=$(echo "$SITE_DOMAIN" | sed -e 's|^[^/]*//||' -e 's|/.*$||')

                                eval "SITE_DOMAIN${x}=${SITE_DOMAIN}"


                                read -r -p $'\e[0;32m b- Enter the CODE of the site from the above list\e[0m: '  SITE_CODE
                                
                                
                                if [[ $SITE_CODE == "" ]]; then
                                echo "You have not entered any value. Please re-initiate the script" && exit
                                fi
                                echo "Code$x: $SITE_CODE" >> /home/master/Script_stats


                                cat <<EOT >> block
        case '$SITE_DOMAIN':
                \$mageRunCode = '$SITE_CODE';
                \$mageRunType = 'website';
                break;



EOT


                x=$(( $x + 1 ))
                y=$(( $y + 1 ))

done

done

cat <<EOT >> block
          default:
                \$mageRunCode = 'base';
                \$mageRunType = 'website';
                break;
            }
EOT

echo -e "$F"
echo -e "$F\n"


sleep 0.7
echo -ne $'\e[1;32mPROCESSING --         \r\e[0m'
sleep 0.5
echo -ne $'\e[1;33mPROCESSING ----          \r\e[0m'
sleep 0.5
echo -ne $'\e[1;34mPROCESSING -------          \r\e[0m'
sleep 0.7
echo -ne $'\e[1;38mPROCESSING ---------          \r\e[0m'
sleep 0.5
echo -ne $'\e[1;36mPROCESSING ------------          \r\e[0m'
echo -e "$F"
echo -ne '\n'

wget -q https://raw.githubusercontent.com/AhmadSamiKhan/magento2-index/main/index1
wget -q https://raw.githubusercontent.com/AhmadSamiKhan/magento2-index/main/index2

clear

echo -e "$E"
echo -e "$IRed CHECKS TO CONFIGURE THE MAGENTO MULTISITE 2 $EndCOLOR"
echo -e "$E\n"


echo "Running from public_html" > $HOME/$DB_NAME/public_html/mag-script-challenge
echo "Running from pub" > $HOME/$DB_NAME/public_html/pub/mag-script-challenge
APP_FQDN=$(head -n1 $HOME/$DB_NAME/conf/server.nginx  |  cut -f 3 -d ' ')
APP_FQDN=$(curl -Ls -o /dev/null -w %{url_effective} $APP_FQDN)
CONTENT=$(curl -sk $APP_FQDN/mag-script-challenge)



echo -e $'\e[1;32mHere are the configuration steps. Please follow as guided.\e[0m'

if [[ $CONTENT == "Running from pub" ]]; then
                                    echo -e $'\e[1;32m1- The webroot is fine. It is set to /pub which is correct.\e[0m ----- DONE' 
                                else 
                                    echo -e $'\e[1;31m1- The webroot is not correct. Please change it to /pub from app settings\e[0m ----- DONE'
                                fi
echo -e $'\e[1;32m2- Renamed the original index.php as "index.php-backup-script" and Updated the pub/index.php.\e[0m ----- DONE' 


cp $HOME/$DB_NAME/public_html/pub/index.php $HOME/$DB_NAME/public_html/pub/index.php-backup-script
echo > $HOME/$DB_NAME/public_html/pub/index.php
cat index1 >> $HOME/$DB_NAME/public_html/pub/index.php
cat block >> $HOME/$DB_NAME/public_html/pub/index.php
cat index2 >> $HOME/$DB_NAME/public_html/pub/index.php


echo -e $'\e[1;32m3- Flushing the cache of application\e[0m ----- DONE'
php $HOME/$DB_NAME/public_html/bin/magento c:f  > /tmp/test



echo -e $'\e[1;32m4- Check the URL entries (STORES -> CONFIGURATIONS -> SELECT SCOPE -> WEB.\e[0m ----- TO DO'
echo -e $'\e[1;32m5- Verify if all above steps have been completed. Kindly check the stores now.\e[0m ----- TO DO'


rm block index1 index2
rm $HOME/$DB_NAME/public_html/pub/mag-script-challenge
rm $HOME/$DB_NAME/public_html/mag-script-challenge
