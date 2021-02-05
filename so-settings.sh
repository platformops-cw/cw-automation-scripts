#!/bin/bash

#------AUTHOR: Ahmad Sami------#

#------IMP variables used------#
PHP_VERSION=$(php --version | head -n 1 | cut -d " " -f 2 | cut -c 1,2,3)

if [[ $PHP_VERSION = 5.6 ]]; then
    PHP_VERSION=$(php --version | head -n 1 | cut -d " " -f 2 | cut -c 1)
fi


DB_ENGINE=$(cat /etc/ansible/facts.d/packages.fact | egrep -i '(mysql=5|mariadb=10)' | cut -d= -f1)
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
MYSQL_CONF="/etc/mysql/conf.d/cw_customization.cnf"
KERNEL_CONF="/etc/sysctl.d/99-cw_customization.conf"
APACHE_CONF="/etc/apache2/extras/mpm_event.conf"
FPM_CONF="/etc/php.confs/fpm/extras/cw_customization.conf"

#function to create dir of file, if not exist
mktouch() {
  mkdir -p "$(dirname "$1")"
  touch "$1"
}


mktouch /etc/sysctl.d/99-cw_customization.conf
mktouch /etc/apache2/extras/mpm_event.conf
mktouch /etc/php.confs/fpm/extras/cw_customization.conf




echo -e "\n$D"
echo -e "\t $BCya Optimizing Kernel Configurations $EndCOLOR"
echo -e "$D\n"

###########################################################
cat <<EOT > /etc/sysctl.d/99-cw_customization.conf
fs.file-max = 100000
fs.inotify.max_queued_events = 64384
fs.inotify.max_user_watches = 524288
fs.inotify.max_user_instances = 512

net.core.somaxconn = 65000
net.core.netdev_max_backlog = 65536

net.ipv4.tcp_tw_recycle = 1
net.ipv4.ip_local_port_range = 11000 60999
net.ipv4.tcp_max_syn_backlog = 65536
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_keepalive_time = 300
net.ipv4.tcp_fin_timeout = 15
net.ipv4.tcp_keepalive_intvl = 15
net.ipv4.tcp_keepalive_probes = 5
EOT

sysctl -p /etc/sysctl.d/99-cw_customization.conf


###########################################################

echo -e "\n$D"
echo -e "\t $BCya Optimizing FPM Configurations $EndCOLOR"
echo -e "$D\n"

for n in /etc/phppool.d/*; do

        if [[ $n != "/etc/phppool.d/cloudways.conf" ]];
        then
                if grep -q "cw_customization.conf" $n; then
                        echo "cw_customization.conf file exists in $n"
                else

                sed -i '/^pm/d' $n
                sed -i '/listen.mode/a include = /etc/php.confs/fpm/extras/cw_customization.conf' $n
                echo "Optimized parameters added in: " $n

        fi
        else
                echo "" >/dev/null 2>/dev/null
        fi
done

cat <<EOT > /etc/php.confs/fpm/extras/cw_customization.conf
pm = ondemand
pm.max_children = 6000
pm.max_requests = 750
pm.process_idle_timeout = 1s
EOT



#############################################################

echo -e "\n$D"
echo -e "\t $BCya Optimizing Apache Configurations $EndCOLOR"
echo -e "$D\n"

a2dismod mpm_itk
a2dismod mpm_prefork
a2enmod mpm_event

cat <<EOT > /etc/apache2/extras/mpm_event.conf
<IfModule mpm_event_module>
          StartServers             20
          ServerLimit              300
          MinSpareThreads          150
          MaxSpareThreads          300
          ThreadLimit              200
          ThreadsPerChild          120
          MaxRequestWorkers        36000
          MaxConnectionsPerChild   7500
</IfModule>
EOT
rm /etc/apache2/mods-enabled/mpm_event.conf
ln -s /etc/apache2/extras/mpm_event.conf /etc/apache2/mods-enabled/mpm_event.conf


#############################################################

echo -e "\n$D"
echo -e "\t $BCya Optimizing MySQL Configurations $EndCOLOR"
echo -e "$D\n"


if  [[ $DB_ENGINE == "mariadb" ]]; then
                        mktouch /etc/mysql/conf.d/cw_mariadb_customization.cnf
                cat <<EOT > /etc/mysql/conf.d/cw_mariadb_customization.cnf
                                        [mysqld]
                                        ##
                                        # * Multi thread configuration
                                        ##
                                        thread_handling=pool-of-threads
                                        thread_cache_size=16384
                                        thread_concurrency=512
                                        ##
                                        # * Thread pooling configuration
                                        ##
                                        thread_pool_idle_timeout=3
                                        thread_pool_max_threads=65536
                                        thread_pool_oversubscribe=20000
                                        thread_pool_size=128
                                        thread_pool_stall_limit=30

EOT

echo "Optimized $DB_ENGINE"
        else [[ $DB_ENGINE == "mysql" ]]

                        mktouch /etc/mysql/conf.d/ccw_customization.cnf

                cat <<EOT > /etc/mysql/conf.d/cw_mariadb_customization.cnf
                                        [mysqld]
                                        ##
                                        # * Connection Configuration
                                        ##
                                        max_connections=100000
                                        max_prepared_stmt_count=100000
                                        wait_timeout=30
                                        interactive_timeout=180

EOT
echo "Optimized $DB_ENGINE"
        fi

echo -e "\n$D"
echo -e "\t $BCya Restarting managed services $EndCOLOR"
echo -e "$D\n"


/etc/init.d/apache2 restart
/etc/init.d/memcached restart
/etc/init.d/varnish restart
/etc/init.d/mysql restart
/etc/init.d/nginx restart
/etc/init.d/php$PHP_VERSION-fpm restart



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

        if  [[ $DB_ENGINE == "mariadb" &&  -f "$MARIADB_CONF" ]] then
                echo -e "MariaDB Settings $BGre ----- OPTIMIZED. $EndCOLOR"
        elif [[ $DB_ENGINE == "mysql" &&  -f "$MYSQL_CONF" ]] then
                echo -e "Mysql Settings $BGre ----- OPTIMIZED. $EndCOLOR"
        else
                echo -e "$DB_ENGINE Settings $BRed ----- NOT OPTIMIZED. $EndCOLOR"
                        x=$(( $x + 1 ))
        fi

echo -e "\n$E"
echo -e "\t \t $BPur REPORT $EndCOLOR"
echo -e "$E\n"


if [[ $x -le 1 ]]
then
  echo -e "$BGre Congrats !! The server is fully Optimized Now. If you are still facing issues, try contacting on seat senior. $EndCOLOR"
 else

  echo -e "$BRed There is an unknown problem. Please escalate this to senior Asap. $EndCOLOR"


fi
