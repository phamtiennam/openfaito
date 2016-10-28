#!/bin/sh
#FAITO 2014,NamPham
#Description: apply new settings from AP controller to AP 

#Beginning
ADIR=/tmp/apply
WDIR=/tmp/update
[ ! -d $ADIR ] && mkdir -p $ADIR	
rm -rf $ADIR/*
	
	
#General Settings Function
	
genfunc(){
while read gene ;do
	gene1=$(echo $gene|awk '{FS="=";print $1}')
	gene2=$(echo $gene|awk '{FS="=";print $2}')
	case $gene1 in
		g_device_name)				#Change hostname
			echo $gene2 >  /proc/sys/kernel/hostname
			uci set system.@system[0].hostname=$gene2
			uci commit system
			env -i /etc/init.d/uconfig restart >/dev/null
		;;
		g_device_transmit_antenna)
			uci set apc.setting.transmit_antenna=$gene2
			uci commit apc
		;;
		g_device_received_antenna)
			uci set apc.setting.received_antenna=$gene2
			uci commit apc
		;;
	esac	
done < 	$ADIR/general_settings
}
#Radio Settings
#. /lib/faito/apply_new_settingsB.sh
#Hotspot Settings
	hotsptfunc(){
		#Hotspot General Settings
			#hotspot_enable
			hotspot_enable=$(uci -c $ADIR -q get hotsptset.setting.hotspot_enable)		
			case $hotspot_enable in
				1)	uci -q set coovachilli.@chilli[0].enable_chilli=1  ;;
				0)	uci -q set coovachilli.@chilli[0].enable_chilli="" ;;
				*) ;;
			esac
			#hotspot_mode
			hotspot_mode=$(uci -c $ADIR -q get hotsptset.setting.hotspot_mode)
			case $hotspot_mode in
				1)	uci -q set  coovachilli.@chilli[0].chillimode=captiveportal	;;
				2)	uci -q set  coovachilli.@chilli[0].chillimode=agreementradius	;;
				3)	uci -q set  coovachilli.@chilli[0].chillimode=agreement	;;
				4)	uci -q set  coovachilli.@chilli[0].chillimode=passwordonlyradius	;;
				5)	uci -q set  coovachilli.@chilli[0].chillimode=passwordonly ;;
				*)		;;
			esac
                        #hotspot_passwordonly
                        hotspot_pass=$(uci -c $ADIR -q get hotsptset.setting.hotspot_password)	
                        [ "${hotspot_pass}" != "" ]&& uci -q set coovachilli.@chilli[0].passwordonly=${hotspot_pass}

			#Login page title
			login_title=$(uci -c $ADIR -q get hotsptset.setting.hotspot_login_page_title)
			[ "${login_title}" != "" ] && uci -q set  coovachilli.@chilli[0].locationname=${login_title}		
			#IdleTimeout
			idletimeout=$(uci -c $ADIR -q get hotsptset.setting.hotspot_idle_time_out)
			[ "${idletimeout}" != "" ]&& uci -q set  coovachilli.@chilli[0].defidletimeout=${idletimeout}
			
		#Hotspot Network Configuration
			#hotspot_auto_config
			hotspot_auto_config=$(uci -c $ADIR -q get hotsptset.setting.hotspot_auto_config)
			case $hotspot_auto_config in
				1)	uci -q set  coovachilli.@chilli[0].auto_network_config=1
				;;
				0)	uci -q set  coovachilli.@chilli[0].auto_network_config=0
				;;
				*);;
			esac
			#net address
			hotspot_network_address=$(uci -c $ADIR -q get hotsptset.setting.hotspot_network_address)
			[ "${hotspot_network_address}" != "" ] &&  uci -q set  coovachilli.@chilli[0].net=${hotspot_network_address}
			#dns1
			hotspot_dns_server_1=$(uci -c $ADIR -q get hotsptset.setting.hotspot_dns_server_1)
			[ "${hotspot_dns_server_1}" != "" ] &&  uci -q set  coovachilli.@chilli[0].dns1=${hotspot_dns_server_1}
			#dns2
			hotspot_dns_server_2=$(uci -c $ADIR -q get hotsptset.setting.hotspot_dns_server_2)
			[ "${hotspot_dns_server_2}" != "" ] &&  uci -q set  coovachilli.@chilli[0].dns2=${hotspot_dns_server_2}
		#Hotspot Radius Configuration
			#Radius_server_1
			hotspot_radius_server_1=$(uci -c $ADIR -q get hotsptset.setting.hotspot_radius_server_1)
			[ "${hotspot_radius_server_1}" != "" ] &&  uci -q set  coovachilli.@chilli[0].radiusserver1=${hotspot_radius_server_1}
			
			#Radius_server_2
			hotspot_radius_server_2=$(uci -c $ADIR -q get hotsptset.setting.hotspot_radius_server_2)
			[ "${hotspot_radius_server_2}" != "" ] &&  uci -q set  coovachilli.@chilli[0].radiusserver2=${hotspot_radius_server_2}
					
			#Radius_secret
			hotspot_radius_secret=$(uci -c $ADIR -q get hotsptset.setting.hotspot_radius_secret)
			[ "${hotspot_radius_secret}" != "" ] &&  uci -q set  coovachilli.@chilli[0].radiussecret=${hotspot_radius_secret}
					
			#UAM Server
			hotspot_uam_server=$(uci -c $ADIR -q get hotsptset.setting.hotspot_uam_server)
			[ "${hotspot_uam_server}" != "" ] &&  uci -q set  coovachilli.@chilli[0].uamserver=${hotspot_uam_server}
					
			#UAM Secret		
			hotspot_uam_secret=$(uci -c $ADIR -q get hotsptset.setting.hotspot_uam_secret)
			[ "${hotspot_uam_secret}" != "" ] &&  uci -q set  coovachilli.@chilli[0].uamsecret=${hotspot_uam_secret}
			
			#Walled Garden (Domain) 
			hotspot_walled_garden_domain=$(uci -c $ADIR -q get hotsptset.setting.hotspot_walled_garden_domain)
			[ "${hotspot_walled_garden_domain}" != "" ] &&  uci -q set  coovachilli.@chilli[0].uamdomain=${hotspot_walled_garden_domain}
					
			#Walled Garden (IP Address) :	
			hotspot_walled_garden_ip=$(uci -c $ADIR -q get hotsptset.setting.hotspot_walled_garden_ip)
			[ "${hotspot_walled_garden_ip}" != "" ] &&  uci -q set  coovachilli.@chilli[0].uamallowed=${hotspot_walled_garden_ip}
					
			#Commit
			uci commit  coovachilli						
	}	
#Advanced Settings	
	advfunc(){
	#SSH password
		network_ssh_password=$(uci -c $ADIR -q get advset.setting.network_ssh_password)
		[  "${network_ssh_password}" != "" ] && /usr/bin/printf "${network_ssh_password}\n${network_ssh_password}"|/usr/bin/passwd
	#Enable/Disable Web	
		network_web=$(uci -c $ADIR -q get advset.setting.network_web)
		[  "${network_web}" != "" ] && {
			case ${network_web} in
				1) /etc/init.d/uhttpd start	;;
				0) /etc/init.d/uhttpd stop	;;
			esac
		}
	#Failover APC
		network_failover_ap_controller=$(uci -c $ADIR -q get advset.setting.network_failover_ap_controller)
		[  "${network_failover_ap_controller}" != "" ] && uci set default.settings.FailoverAPC=${network_failover_ap_controller}
	}
		
# Apply new changes or all settings from APC
	parameter=$1
	case $parameter in
		#New changes-----------------------------------------|
		newsets)
			#Apply General Settings
				uci get apc.setting.NewSettings|awk 'BEGIN {RS = "&"}{ print $0}'|grep "g_device_" > $ADIR/general_settings
				[  "$(cat $ADIR/general_settings)" != "" ]  && genfunc || rm -f $ADIR/general_settings
			#Apply Radio Settings
				uci get apc.setting.NewSettings|awk 'BEGIN {RS = "&"}{ print $0}'|grep '_radio' > $ADIR/radio_settings
				[  "$(cat $ADIR/radio_settings)" != "" ]  && { 
					echo "config rdset 'setting' " > $ADIR/rdset
					
					while read riga ;do
						uci -c $ADIR set  rdset.setting.${riga}				
					done < $ADIR/radio_settings
						uci -c $ADIR commit  rdset
						
					env -i /sbin/wifi down >/dev/null 2>/dev/null	
					#radfunc	
					/lib/faito/apply_new_settingsB.sh
					/lib/faito/delete_ssid &
					env -i /sbin/wifi up >/dev/null 2>/dev/null
				}	
				#rm -f  $ADIR/radio_settings
				#Apply Hotspot Settings																				  
				uci get apc.setting.NewSettings|awk 'BEGIN {RS = "&"}{ print $0}'|grep 'hotspot_' > $ADIR/hotspot_settings
				[  "$(cat $ADIR/hotspot_settings)" != "" ]  && { 
					echo "config hotsptset 'setting' " > $ADIR/hotsptset
					
					while read riga ;do
						uci -c $ADIR set  hotsptset.setting.${riga}				
					done < $ADIR/hotspot_settings
						uci -c $ADIR commit  hotsptset
						
					hotsptfunc	
					env -i /etc/init.d/coovachilli restart   >/dev/null 2>/dev/null	
				}
				rm -f $ADIR/hotspot_settings
				#Apply Advanced Settings
				uci get apc.setting.NewSettings|awk 'BEGIN {RS = "&"}{ print $0}'|grep "network_" > $ADIR/advanced_settings
				[  "$(cat $ADIR/advanced_settings)" != "" ]  && { 	
					echo "config advset 'setting' " > $ADIR/advset
					
					while read riga;do
						uci -c $ADIR set advset.setting.${riga}
					done < $ADIR/advanced_settings
					uci -c $ADIR commit advset
					
					advfunc
				}
				rm -f $ADIR/advanced_settings
				#Reset Flag
				uci set apc.setting.ApplyNewSettings=0
				uci set apc.setting.NewSettings=""
				uci commit apc
		;;
		#------------------------------------------------------------||
		
		#All current settings ----------------------------------|
		allsets)				
		;;
		#------------------------------------------------------------||
	esac	
