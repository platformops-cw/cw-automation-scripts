
#!/bin/bash

#------AUTHOR: Ahmad Sami------#

#------IMP variables used------#
m
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++..+++00000000000000000000000000000000000000000000000000000000000000000000000000000000-------------------------------------------------------a/p771
DB_ENGINE=$(cat /etc/ansible/facts.d/packages.fact | egrep -i '(mysql|mariadb)' | cut -d= -f1)
x=1

#------COLOR & Design variables used------#
BGre='\e[1;32m';
IRed='\e[0;91m';
Yel='\e[0;33m';
EndCOLOR="\e[0m"
BRed='\e[1;31m';
BYel='\e[1;33m';
BBlu='\e[1;34m';
BPur='\e[1;35m';
BCya='\e[1;36m';
BWhi='\e[1;37m';


S="*******************************************************************"
D="-------------------------------------------------------------------"
E="==================================================================="
F="..................................................................."



#------FILES variables used------#
MARIADB_CONF="/etc/mysql/conf.d/cw_mariadb_customization.cnf"
MYSQL_CONF="/etc/mysql/conf.d/ccw_customization.cnf"
KERNEL_CONF="/etc/sysctl.d/99-cw_customization.conf"
APACHE_CONF="/etc/apache2/extras/mpm_event.conf"
FPM_CONF="/etc/php.confs/fpm/extras/cw_customization.conf"


echo -e "\n$E"
echo -e "\t $BYel STACK OPTIMIZATION ANALYSIS REPORT $EndCOLOR"
echo -e "$E\n"


		

        if  [[ -f "$KERNEL_CONF" ]]; then
                echo -e "Kernel Settings $BGre ----- OPTIMIZED. $EndCOLOR"
        else 
        		echo -e "Kernel Settings $BRed ----- NOT OPTIMIZED. $EndCOLOR"
        		x=$(( $x + 1 ))
        fi

        if  [[ -f "$APACHE_CONF" ]]; then
                echo -e "Apache Settings $BGre ----- OPTIMIZED. $EndCOLOR"
        else 
        		echo -e "Apache Settings $BRed ----- NOT OPTIMIZED. $EndCOLOR"
        		x=$(( $x + 1 ))
        fi

        if  [[ -f "$FPM_CONF" ]]; then
                echo -e "FPM Settings $BGre ----- OPTIMIZED. $EndCOLOR"
        else 
        		echo -e "FPM Settings $BRed ----- NOT OPTIMIZED. $EndCOLOR"
        		x=$(( $x + 1 ))
        fi

        echo $DB_ENGINE

        if  [[ $DB_ENGINE == "mariadb" &&  -f "$MARIADB_CONF" ]]; then
                echo -e "MariaDB Settings $BGre ----- OPTIMIZED. $EndCOLOR"
        elif [[ $DB_ENGINE == "mysql" &&  -f "$MYSQL_CONF" ]]; then

                echo -e "Mysql Settings $BGre ----- OPTIMIZED. $EndCOLOR"
        else 
        		echo -e "Mysql/MariaDB Settings $BRed ----- NOT OPTIMIZED. $EndCOLOR"
        		x=$(( $x + 1 ))
        fi



echo -e "\n$E"
echo -e "\t \t $BPur REPORT $EndCOLOR"
echo -e "$E\n"

if [[ $x -le 1 ]]
then
  echo -e "$BGre The server is fully Optimized. If you are still facing issues, try contacting on seat senior $EndCOLOR"
 else
  read -p $'\e[0;31m The server is not fully Optimized. Do you wish to run the Optimizations script? [y/n] \n' answer
  	if [[ $answer = y ]] ; then
  		curl -s  https://raw.githubusercontent.com/AhmadSamiKhan/SO/main/Changes.sh | bash
fi

fi
