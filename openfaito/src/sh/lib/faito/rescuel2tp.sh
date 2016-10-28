#!/bin/sh
#FAITO-2014

l2tpifname="l2tp-avlan3316"
l2tpif="$(echo ${l2tpifname#l2tp-})"

#Allow to rescue l2tp connection
[ "$(uci -q get management.enable.rescuel2tp)" == "0" ] && exit 0

#check l2tp-avlan3316 interface available
[ "$(ifconfig | grep -w ${l2tpifname})" != "" ]&& exit 0

#check the connection to AP controller 
apc=$(uci -q get default.settings.APcontroller)
$(/bin/ping -c 1 $apc > /dev/null)
[ $? != 0 ] && exit 0

#check the network configuration 
[ "$(uci -q get network.avlan3316)" != "interface" ]&& exit 0
###update default gateway & l2tp info
/lib/faito/init.d.default 		

#check xl2tpd
[ "$(pidof xl2tpd-control)" != "" ]&& kill -9 $(pidof xl2tpd-control)
[ "$(pidof xl2tpd-control)" != "" ]&& kill -9 $(pidof xl2tpd-control)
/etc/init.d/xl2tpd stop
sleep 2
/etc/init.d/xl2tpd start

#rescue l2tp
[ -f /tmp/l2tp/options.${l2tpif} ]&&{
	xl2tpd-control remove ${l2tpifname}
	xl2tpd-control add  ${l2tpifname} pppoptfile=/tmp/l2tp/options.${l2tpif} lns=${apc} redial=yes redial timeout=20
	xl2tpd-control connect ${l2tpifname}
}

touch /tmp/update/rescuel2tp
