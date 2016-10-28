#!/bin/sh
#Faito-2014,NamPham

#check-in
local apcip=$(ifconfig l2tp-avlan3316|awk '/P-t-P/{split($2,tmp,":");print tmp[2]}')
[ "$(/sbin/validatingIP $apcip)" == "1" ] && {
  $(ping -q -c 1 $apcip > /dev/null)
  if [ $? -eq 0  ]
  then
   /lib/faito/update_settings_nodes.sh 1minuteUd 
  else
    echo "$(date): No response from APc-L2tp server.Try to restart xl2tpd in AP" >> /etc/APlog
    /etc/init.d/xl2tpd restart
  fi  
 }
 
#start loops
 [ -f /tmp/startloops ]||{
 	 /lib/faito/main-loop &
 	 /lib/faito/powerup_or_rebooted &
 	touch /tmp/startloops
 }

#keep snmpd alive
[ "$(pidof snmpd)" == "" ]&& { 
	echo "$(date): snmpd not running.Try to start" >> /etc/APlog 
	/etc/init.d/snmpd start 
}	

#check used memory of xl2tpd
pid=$(/bin/pidof xl2tpd)
[ $pid != "" ]&&{
  usedmem=$(/bin/ps | grep xl2tpd| grep $(/bin/pidof xl2tpd)|/usr/bin/awk '{print $3}')
  [ $usedmem -gt 7000 ]&&{             
	echo "$(date): xl2tpd used $usedmem VSZ of MEM.Try to restart" >> /etc/APlog
        /etc/init.d/xl2tpd restart 
  }

}

#send hostname from clients to APc
[ "$(uci -q get apc.setting.get_hostname)" == "1" ]&&{
            /usr/bin/lua  /lib/faito/luci-hostname-APc.lua > /tmp/luci-hostname-APc/meshAP
            uci set apc.setting.get_hostname=0
            uci commit apc
          }            

#check the length of the log files
	 /lib/faito/lengthlog /etc/APlog	
	 /lib/faito/lengthlog /etc/kmsglog
	
#ipsec_check=$(ipsec status | grep "ESTABLISHED" | grep $(uci get default.settings.l2tpserver))
#[ "$ipsec_check" == ""  ]&& {  #rescue l2tp connection
#       ipsec stop 
#       kill -9 $(pidof xl2tpd)
#       kill -9 $(pidof xl2tpd-control)
#       sleep 2
#       kill -9 $(pidof xl2tpd-control)
#       rm -rf /tmp/l2tp
#       /etc/init.d/xl2tpd restart
#       /etc/init.d/network restart
#       sleep 3
#}

