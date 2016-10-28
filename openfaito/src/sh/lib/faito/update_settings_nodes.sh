#!/bin/sh
# FAITO - 2013 by NamPham <tn_pham@compex.com.sg>
#-----------------------------------------------------------------------------------------
# Variables
#-----------------------------------------------------------------------------------------
path_of_apc="$(uci -q get default.settings.apc_path)/$(uci -q get default.settings.apc_name)"
apc_snmp_user_name=$(uci -q get default.settings.apc_snmp_user_name)
apc_snmp_pass1=$(uci -q get default.settings.apc_snmp_pass1)
apc_snmp_pass2=$(uci -q get default.settings.apc_snmp_pass2)

ap_snmp_user_name=$(uci -q get snmpd.main.v3user)
ap_snmp_pass1=$(uci -q get snmpd.main.v3authp)
ap_snmp_pass2=$(uci -q get snmpd.main.v3privacyp)

input_value="$1"
apc_host=$(uci -q get default.settings.l2tpserver)

if [ ! -d /tmp/update ];then
	mkdir /tmp/update
fi
WDIR=/tmp/update

#-----------------------------------------------------------------------------------------
# Functions
#-----------------------------------------------------------------------------------------
ifconfig | grep wifi | awk '{print $1}' > /tmp/list_wifi_dev
iwconfig | grep ESSID |tr '"' ' ' | awk '{print $1,$5}' > /tmp/list_ath_ssid_tmp
sort -u < /tmp/list_ath_ssid_tmp > /tmp/list_ath_ssid
rm -f /tmp/list_ath_ssid_tmp
device_mac_address=$(ifconfig wifi0 | grep HWaddr | awk '{print $5}'| awk '{FS="-";OFS=":";print $1,$2,$3,$4,$5,$6}')
device_hotspot_enabled=$(uci -q get coovachilli.@chilli[0].enable_chilli)
[ "$device_hotspot_enabled" != "1" ]&& device_hotspot_enabled=0

ip_addr=$(ifconfig br-lan| grep "inet\ addr"|awk '{print $2}'|tr -d "addr:")
[ "$(uci -q get -q coovachilli.@chilli[0].enable_chilli)" == "1" ]&& {
  eth_coova=$(uci -q get network.wan.ifname)
  ip_addr=$(ifconfig $eth_coova| grep "inet\ addr"|awk '{print $2}'|tr -d "addr:")
}

ip_l2tp=$(ifconfig l2tp-avlan3316| grep "inet\ addr"|awk '{print $2}'|tr -d "addr:")
#-----------------------------------------------------------------------------------------
# Device's Tab
#-----------------------------------------------------------------------------------------

device_mode_func() {
	device_mode=""
	while read wfdev ; do
	
		b=$( uci show wireless | grep -w "id_ssid=${wfdev}_1"|awk '{FS=".";OFS=".";print $1,$2}')
		b_mode=$(uci -q get ${b}.mode )
            case $b_mode in
                    ap)
                        case $(uci -q get wireless.${wfdev}.meshmode) in
                          meshap)   device_mode="${device_mode},2" ;;
                          rootap)   device_mode="${device_mode},3" ;;
                          rootaprc) device_mode="${device_mode},4" ;;
                          *)        device_mode="${device_mode},1" ;;
                        esac  
                       ;;
                    sta) device_mode="${device_mode},0"	;;
            esac	
	done < /tmp/list_wifi_dev

	b_tmp=$(echo ${device_mode} |tr ',' ' '|awk '{print $2}')
	[ "$b_tmp" == "" ] && device_mode=$(echo ${device_mode}|tr -d ',')|| device_mode=$(echo $device_mode|tr ',' ' '|awk '{OFS=",";print $1,$2}')
}

Device_Tab(){
	#Device Name
	device_name=$(uci -q get system.@system[0].hostname)
	#Device Uptime
	TIMEB=`grep btime /proc/stat | awk '{print $2'}`
	TIMENOW=`date +"%s"`
	DIFF=`expr $TIMENOW - $TIMEB`
	DAYS=`expr $DIFF / 86400`
	DIFF=`expr $DIFF \% 86400`
	HOURS=`expr $DIFF / 3600`
	DIFF=`expr $DIFF \% 3600`
	MIN=`expr $DIFF / 60`
	printf "%0dd:%0dh:%02dm" $DAYS $HOURS $MIN > /tmp/now
	x=$(cat /tmp/now)
	#data="${data}&uptime=${x}-${last_reboot_seen}"	
	uptime=${x}		#also can get from:/proc/uptime
	
	#Device Memory Free
	memtotal=$(cat /proc/meminfo | grep MemTotal |awk '{print $2,$3}'|tr -d ' ')
	memfree=$(cat /proc/meminfo | grep MemFree |awk '{print $2,$3}'|tr -d ' ')
	
	#Device Firmware Version
	firmware_version=$(cat /etc/openwrt_release | grep DISTRIB_DESCRIPTION | tr -d '"'|awk '{FS="=";print $2}'| awk '{print $2}')
	
	#Device Hops (Mesh only)
	
	#Device Latency
	
	#Device Model
	
	#Device Bandwidth
	
	#Device Mac Address (Wifi0)

	#Device_mode
        #device_mode_func
        
	device_mode=""
	while read wfdev ; do
	
		b=$( uci show wireless | grep -w "id_ssid=${wfdev}_1"|awk '{FS=".";OFS=".";print $1,$2}')
		b_mode=$(uci -q get ${b}.mode )
            case $b_mode in
                    ap)
                        case $(uci -q get wireless.${wfdev}.meshmode) in
                          meshap)   device_mode="${device_mode},2" ;;
                          rootap)   device_mode="${device_mode},3" ;;
                          rootaprc) device_mode="${device_mode},4" ;;
                          *)        device_mode="${device_mode},1" ;;
                        esac  
                       ;;
                    sta) device_mode="${device_mode},0"	;;
            esac	
	done < /tmp/list_wifi_dev

	b_tmp=$(echo ${device_mode} |tr ',' ' '|awk '{print $2}')
	[ "$b_tmp" == "" ] && device_mode=$(echo ${device_mode}|tr -d ',')|| device_mode=$(echo $device_mode|tr ',' ' '|awk '{OFS=",";print $1,$2}')

	#Device_range
	transmit_antenna=$(uci -q get apc.setting.transmit_antenna)
	received_antenna=$(uci -q get apc.setting.received_antenna)
	transmit_power=$(iwinfo ath0 info | grep Tx-Power | awk '{print $2}')
	cable_loss=-3		#dBm
	received_power=-60	#dBm
	m1=$(echo "${transmit_power} + ${cable_loss} + ${transmit_antenna} + ${received_antenna} - ${received_power}"|bc)
	freq=$(iwinfo ath0 info | grep Channel | awk '{print $5}'| tr -d '('| tr -d '.')
	m2=$(echo "l(${freq})/l(10)" | bc -l )
	m3=$(echo "${m1} - 20*${m2} + 27.55" | bc )
	m4=$(echo "scale=3;${m3}/20"|bc)
	e1=$(echo "e(l(10)*${m4})" |bc -l|awk '{FS=".";print $1}')
	e2=$(echo "e(l(10)*${m4})" |bc -l|awk '{FS=".";print $2}'|head -c3)
	device_range_outdoor="${e1}.${e2}"
	m4=$(echo "scale=3;${m3}/26"|bc)
	e1=$(echo "e(l(10)*${m4})" |bc -l|awk '{FS=".";print $1}')
	e2=$(echo "e(l(10)*${m4})" |bc -l|awk '{FS=".";print $2}'|head -c3)
	device_range_indoor="${e1}.${e2}"

		
	#Echo
	#echo "uptime=$uptime&memtotal=$memtotal&memfree=$memfree&firmware_version=$firmware_version" > $WDIR/DeviceTab
	#Gather
	GATHER="device_name=${device_name}&device_mode=${device_mode}&device_mac_address=${device_mac_address}&device_hotspot_enabled=${device_hotspot_enabled}&device_ip_l2tp=${ip_l2tp}&device_ip_address=${ip_addr}&device_uptime=${uptime}&device_memfree=${memfree}&device_version=${firmware_version}&device_range_outdoor=${device_range_outdoor}&device_range_indoor=${device_range_indoor}"
}

#----------------------------------------------------------------------------------------
#Associate
#----------------------------------------------------------------------------------------
associated_stations_fnc(){
	#Associated stations
	rm -rf  $WDIR/associated_stations
	iwconfig | grep -w "Mode:Master" -B 1| grep ESSID > /tmp/ath_station
	[ "$(cat /tmp/ath_station)" != "" ]&& {
                /usr/bin/lua  /lib/faito/luci-hostname-APc.lua > /tmp/meshAP
		while read nuap ; do
			a=$(echo $nuap|awk '{print $4}'|cut -c 8-)
			station_ssid=$(echo ${a%?})
			station_ath=$(echo $nuap|awk '{print $1}')

			/usr/bin/iwinfo ${station_ath} assoclist  > /tmp/assoclist_${station_ath}
			[ "$(cat /tmp/assoclist_${station_ath})" == "No information available" ] && echo "" > /tmp/assoclist_${station_ath} 
			while [ "$(cat /tmp/assoclist_${station_ath})" != "" ]
			do

			 /bin/cat  /tmp/assoclist_${station_ath} | /usr/bin/head -5	> /tmp/assoclist_${station_ath}_individual
                         
                         vap_name=$(cat /etc/vap2ath | grep ${station_ath}| awk '{print $1}' |sed s/wifi/VAP/g)
			 station_mac=$(/bin/cat /tmp/assoclist_${station_ath}_individual | /usr/bin/head -1 |/usr/bin/awk '{print $1}')
                         station_ip=$(ip neigh| grep $(echo $station_mac|tr [A-Z] [a-z])|awk '{print $1}'|head -1)
                         if [ -f /tmp/luci-hostname-APc/${station_ip} ]
                         then
                           station_host=$(cat /tmp/luci-hostname-APc/${station_ip})
                           [ "$station_host" == "" ]&&{
                                uci set apc.setting.get_hostname=1
                                uci commit apc
                               } 
                         else
                           ajvtmp=$(grep -w "$station_mac" /tmp/meshAP | head -1)
                           station_ip=$(echo $ajvtmp| awk '{print $2}')
                           station_host=$(echo $ajvtmp| awk '{print $3}')
                         fi  
			 station_signal="$(/bin/cat /tmp/assoclist_${station_ath}_individual | /usr/bin/head -1 | /usr/bin/awk '{print $2}')dBm"
			 station_noise="$(/bin/cat /tmp/assoclist_${station_ath}_individual | /usr/bin/head -1 | /usr/bin/awk '{print $5}')dBm"
			 station_signal_chains="$(/bin/cat /tmp/assoclist_${station_ath}_individual | /bin/grep "Signal\ Chains"|awk '{print $5}'|tr -d "Chains="|tr ',' ';' )dBm"	
			 station_tx_rate="$(/bin/cat /tmp/assoclist_${station_ath}_individual |grep TX|awk '{print $2}')Mbits"
			 station_rx_rate="$(/bin/cat /tmp/assoclist_${station_ath}_individual |grep RX|awk '{print $2}')Mbits"
			 station_tx_ccq=$(/bin/cat  /tmp/assoclist_${station_ath}_individual |grep Txccq|awk '{print $2}'|awk '{FS="=";print $2}')

 			 echo "station_flag=1&device_mac_address=${device_mac_address}&station_host=${station_host}&station_ip=${station_ip}&station_mac=${station_mac}&station_ssid=${station_ssid}&station_signal=${station_signal}&station_signal_chains=${station_signal_chains}&station_tx_rate=${station_tx_rate}&station_rx_rate=${station_rx_rate}&station_tx_ccq=${station_tx_ccq}&vap_name=${vap_name}" >> $WDIR/associated_stations

			 /bin/sed -i '1,5d' /tmp/assoclist_${station_ath}
			done
			rm -rf /tmp/assoclist_${station_ath} /tmp/assoclist_${station_ath}_individual
		done < /tmp/ath_station	
	}	
	rm -rf /tmp/ath_station 

}

#----------------------------------------------------------------------------------------
# Radio's Tab
#-----------------------------------------------------------------------------------------
Radio_Tab(){
	device_radio_list=""
	device_model="$(/usr/bin/lua -lluci.sys -e 'local system, model = luci.sys.sysinfo();print(model)'|head -1|awk '{OFS="-";print $1,$2}')"
	device_model="${device_model}_"
	while read nu ; do
		dev_wifi=$nu
		chipset=$(iwinfo $nu info | grep Hardware | tr ']' ' '| tr '[' ' '| awk '{print $4}')
		
		if [ "$(uci -q get wireless.$nu.autoack -q)" == "" ];then
			ack_timeout_mode=manual
		fi
		if [ "$(uci -q get wireless.$nu.autoack -q)" == "1" ];then
			ack_timeout_mode=auto
		fi
		
		ack_timeout_value=$(iwinfo $nu info | grep -F "ACK timeout" | awk '{print $4}')
		dfs_status=$(iwinfo $nu info | grep -F "DFS status" | awk '{print $4}')
		radio_profile=$(iwinfo $nu info |grep "HW Mode" | awk '{print $5}')
		
		case $radio_profile in
			802.11ac/an|802.11ac/abgn) 
				device_model=${device_model}V
				rdpro=device_ac_radio
				;;
			802.11an)
				device_model=${device_model}5
				rdpro=device_5ghz_radio
				;;
			802.11bgn) 
				device_model=${device_model}2
				rdpro=device_24ghz_radio
				;;
			802.11abgn) 
				device_model=${device_model}X
				rdpro=device_524ghz_radio
				;;
			*) ;;
		esac
		echo $radio_profile $rdpro $nu >> /tmp/radio_profile
		#echo "dev_wifi=$dev_wifi&chipset=$chipset&ack_timeout_mode=$ack_timeout_mode&ack_timeout_value=$ack_timeout_value&dfs_status=$dfs_status&radio_profile=$radio_profile" >> /tmp/RadioTab_tmp

		#radio_channel & radio_bitrate
		value_ssid=$(uci -q get $(uci show wireless | grep id_ssid=${nu}|head -1 |awk '{FS=".";OFS=".";print $1,$2}').ssid)
		value_ath=$(grep -w $value_ssid /tmp/list_ath_ssid | awk '{print $1}')
		radio_channel=$(iwinfo ${value_ath} info | grep Channel|awk '{print $4}')	
		radio_bitrate=$(iwlist ${value_ath} rate| grep "Current Bit Rate"|tr ':' ' '|awk '{print $4,$5}'|tr -d ' ')

		device_radio_list="${device_radio_list} ${chipset},${radio_channel},${radio_bitrate},${ack_timeout_mode},${ack_timeout_value},${dfs_status}"
	done < /tmp/list_wifi_dev
	
	[ "$(grep -wc device_524ghz_radio /tmp/radio_profile)" == "2" ]&& {
		sed -i "2s/device_524ghz_radio/device_524ghz_radio2/" /tmp/radio_profile	
	}
	
	echo $device_model > $WDIR/device_model
	mv /tmp/radio_profile $WDIR/radio_profile
	#mv /tmp/RadioTab_tmp $WDIR/RadioTab
	#Gather
	GATHER="$GATHER&device_model=${device_model}&device_radio_list=${device_radio_list}"
}
#-----------------------------------------------------------------------------------------
# SSID's Tab
#-----------------------------------------------------------------------------------------
SSID_Tab(){
	device_vap_list=""
	num1=""
	num2=""
	while read wifiR ; do	
		uci show wireless | grep  "id_ssid=${wifiR}" > /tmp/list_${wifiR}_ssid
		rd_prof=$(iwinfo $wifiR info |grep "HW Mode" | awk '{print $5}')
		[ "$(cat /tmp/list_${wifiR}_ssid)" != "" ] && {	
			
			while read riga ;do	
				id_ssid=$(echo $riga | awk '{FS="=";print $2 }')
                                [ -f /etc/vap2ath ]|| /sbin/vap2ath.sh
				athx=$(grep -w ${id_ssid} /etc/vap2ath |awk '{print $2}')
				b=$(echo $riga|awk '{FS=".";OFS=".";print $1,$2}')
				#ID_SSID
				id_ssid=$(echo $id_ssid | sed s/wifi/VAP/g)
				#SSID
				ssid=$(uci -q get ${b}.ssid)

				#Mode_of_SSID	
				mode=$(uci -q get $b.mode)
				case $mode in
					ap) mode=Master ;;
					sta) mode=Client  ;;
				
				esac
				mode_ssid=$mode
				
				if [ "$(uci -q get $b.wds)" == "1" ];then
					mode_ssid=$mode_ssid-WDS
				fi
				
				#BSSID (Mac address of ssid)
				[ "$athx" != "" ] && bssid=$(ifconfig $athx | grep HWaddr|awk '{print $5}') || bssid="-"
				[ "$(iwinfo $athx info| grep 'Access Point' | awk '{print $3}')" == "00:00:00:00:00:00" ] && bssid="-"
				
				#Encryption
				encryption=$(uci -q get ${b}.encryption)
				case $encryption in
					none)encryption=None;;
					wep-open)encryption=WEPOpen;;
					wep-shared)encryption=WEPShared;;
					psk|psk+ccmp|psk+tkip+ccmp)encryption=WPA-PSK;;
					psk2|psk2+ccmp|psk2+tkip+ccmp)encryption=WPA2-PSK;;
					psk-mixed|psk-mixed+ccmp|psk-mixed+tkip+ccmp)encryption=WPA/WPA2;;
					wpa|wpa+ccmp|wpa+tkip+ccmp)encryption=WPA-EAP;;
					wpa2|wpa2+ccmp|wpa2+tkip+ccmp)encryption=WPA2-EAP;;
				esac
				
				#Radio's Channel
				#channel=$(iwinfo $athx info | grep Channel|awk '{print $4,$5,$6}'|tr -d ' ')
				channel=$(iwinfo $athx info | grep Channel|awk '{print $4}')
				
				#Radio's Bitrate ('bitrate=unknown' mean:no user clients connected )
				bitrate=$(iwlist $athx rate| grep "Current Bit Rate"|tr ':' ' '|awk '{print $4,$5}'|tr -d ' ')
                                [ "$bitrate" == "unknown" ]&&bitrate="__"
				
				#Radio's Tx power
				Tx_Power=$(iwinfo $athx info | grep -F "Tx-Power:"|awk '{print $2,$3}'|tr -d ' ')
		
				#Gateway of ssid,number of users &tx/rx 
				case $mode in
                Master) 
					vap_mode=1
					gateway_ssid=$bssid 
					wlanconfig $athx list sta | sed 1,1d > /tmp/wlanconfig_$athx
					if [ "$(cat /tmp/wlanconfig_$athx)" != "" ];then
						Nub_users=$(awk '{i++}END{ print i}' /tmp/wlanconfig_$athx )
					else
						Nub_users=none
					fi
						TX_RATE=N/A
						RX_RATE=N/A
				;;
                Client) 
					vap_mode=0
					gateway_ssid=$(iwconfig $athx |grep "Access Point" | awk '{print $6}')	
						
					Nub_users=N/A
					TX_RATE=$(iwinfo $athx assoclist | grep TX|awk '{print $2,$3}'|tr -d ' ')
					RX_RATE=$(iwinfo $athx assoclist | grep RX|awk '{print $2,$3}'|tr -d ' ')		
				;;
				
				esac
				tx_rx="${TX_RATE}:${RX_RATE}"
				
				#Profile of SSID(VAP)
				vap_profile=$(iwinfo $athx info | grep "HW Mode" | awk '{print $5}'|tr -d 802.11 )
				
				[ "${bssid}" == "-" ]  && {
					vap_profile="-"
					channel="-"
					encryption="-"
					bitrate="-"
					gateway_ssid="-"
				}
				case $id_ssid in 
					VAP1_3|VAP0_3)    #hide VAPx_3 in RootAP mode
						[ "$(uci -q get wireless.${wifiR}.meshmode)" != "rootap" ]&& device_vap_list="${device_vap_list} ${vap_mode},${id_ssid},${bssid},${ssid},${vap_profile},${channel},${encryption},${bitrate},${gateway_ssid},${tx_rx}"
					;;
					*)
						device_vap_list="${device_vap_list} ${vap_mode},${id_ssid},${bssid},${ssid},${vap_profile},${channel},${encryption},${bitrate},${gateway_ssid},${tx_rx}"	
					;;	
				esac	

				
			done < /tmp/list_${wifiR}_ssid
		}
	done < /tmp/list_wifi_dev
	#echo ${device_vap_list} > /$WDIR/device_vap_list
	GATHER="$GATHER&device_vap_list=${device_vap_list}"
}
#-----------------------------------------------------------------------------------------
# Neighbour¡¯s Tab
#-----------------------------------------------------------------------------------------

	
#-----------------------------------------------------------------------------------------
# User¡¯s Tab
#-----------------------------------------------------------------------------------------
User_Tab(){	
	while read rd ; do
		athX=$(echo $rd | awk '{print $1}') 	
		iwinfo $athX assoclist >> /tmp/user_info_tmp
		wlanconfig $athX list sta | sed 1,1d | awk '{print $1}' > /tmp/list_mac_user_tmp
		  
		#User's Mac address,athX & SSID(Network)
		if [ "$(cat /tmp/list_mac_user_tmp)" != "" ] ; then
			while read rd1; do
				echo "$rd1 $rd " >> /tmp/UserTab_tmp	
			done < /tmp/list_mac_user_tmp	
		fi
		rm -f /tmp/list_mac_user_tmp
		  
	done < /tmp/list_ath_ssid
	mv /tmp/user_info_tmp /tmp/user_info
	
	if [ -f /tmp/UserTab_tmp ];then
		mv /tmp/UserTab_tmp /tmp/UserTab_0
		cat /tmp/dhcp.leases | awk '{print $2,$4}' > /tmp/list_mac_hostname
		
		#User's Hostname
		while read rd2 ; do
			hostname=""
			mac_user=$(echo $rd2 | awk '{print $1}')
			hostname=$(cat /tmp/list_mac_hostname |grep $mac_user |awk '{print $2}' )
			if [ "$hostname" == "" ] ; then
				#hostname="unknown"
                                hostname="__"
			fi
			
			echo "$rd2 $hostname" >> /tmp/UserTab_1
		done < /tmp/UserTab_0
		rm -f /tmp/UserTab_0
		mv /tmp/UserTab_1 /tmp/UserTab_2
	
	
		#User's Signal Strength,Signal Str/Chain,TX,RX,TX-CCQ
		while read rd3 ; do
			mac_rd3=$(echo $rd3 | awk '{print $1}'|tr 'a-z' 'A-Z' )
			signal_str=$(cat /tmp/user_info |grep -F "Txccq[$mac_rd3]" -B 3 | grep dBm | awk '{print $2}')
			signal_str_chain=$(cat /tmp/user_info |grep -F "Txccq[$mac_rd3]" -B 3 | grep Signal | tr '=' ' '| awk '{print $7}')
			rx_rate=$(cat /tmp/user_info |grep -F "Txccq[$mac_rd3]" -B 3 |grep RX |awk '{print $2}' )
			tx_rate=$(cat /tmp/user_info |grep -F "Txccq[$mac_rd3]" -B 3 |grep TX |awk '{print $2}' )
			tx_ccq=$(cat /tmp/user_info |grep -F "Txccq[$mac_rd3]" -B 3 | grep Signal | tr '=' ' '| awk '{print $3}')
			echo "$rd3 $signal_str $signal_str_chain $rx_rate $tx_rate $tx_ccq" >> /tmp/UserTab_3
		done < /tmp/UserTab_2
		rm -f /tmp/UserTab_2
		mv /tmp/UserTab_3 /tmp/UserTab_4
		
		#Gather User's info
		while read rd4 ; do
			mac_rd4=$(echo $rd4|awk '{print $1}')
			athX_rd4=$(echo $rd4|awk '{print $2}')
			ssid_rd4=$(echo $rd4|awk '{print $3}')
			hostname_rd4=$(echo $rd4|awk '{print $4}')
			signal_rd4=$(echo $rd4|awk '{print $5}')
			signal_chain_rd4=$(echo $rd4|awk '{print $6}')
			rx_rd4=$(echo $rd4|awk '{print $7}')
			tx_rd4=$(echo $rd4|awk '{print $8}')
			tx_ccq=$(echo $rd4|awk '{print $9}')
			echo "mac=$mac_rd4&athX=$athX_rd4&network=$ssid_rd4&hostname=$hostname_rd4&signal_str=${signal_rd4}dBm&signal_chain=$signal_chain_rd4&rx_rate=${rx_rd4}MBits&tx_rate=${tx_rd4}MBits&txccq=${tx_ccq}%" >> /tmp/UserTab_5
			
		done < /tmp/UserTab_4
		rm -f /tmp/UserTab_4
		mv /tmp/UserTab_5 $WDIR/UserTab
		
	fi
}	
#-----------------------------------------------------------------------------------------
# Ethernet Tab
#-----------------------------------------------------------------------------------------
Ethernet_Tab(){
	lan_status=$(ubus call  network.interface.lan status | grep -F '"up":' |awk '{print $2}'| tr -d ',')
	if [ "$lan_status" == "true" ];then
		lan_uptime=$(ubus call  network.interface.lan status | grep -F '"uptime":'|awk '{print $2}'|tr -d ',')
		lan_macaddr=$(ifconfig $(uci -q get network.lan.ifname) |grep HWaddr | awk '{print $5}')
		lan_procol=$(ubus call  network.interface.lan status | grep -F '"proto":'|awk '{print $2}'|tr -d '"'|tr -d ',')
		lan_ipv4=$(ifconfig br-lan  | grep -F 'inet addr:' | awk '{print $2}'| tr -d 'addr:')
	else
		lan_uptime=none
		if [ "$(ubus call network.interface.lan status | grep -F '"autostart":'|awk '{print $2}'|tr -d ',')" == "false" ];then
			lan_macaddr=00:00:00:00:00:00
		else
			lan_macaddr=$(ifconfig $(uci -q get network.lan.ifname) |grep HWaddr | awk '{print $5}')
		fi
		lan_procol=$(ubus call  network.interface.lan status | grep -F '"proto":'|awk '{print $2}'|tr -d '"'|tr -d ',')
		lan_ipv4=0.0.0.0
	fi
	
	wan_status=$(ubus call  network.interface.wan status | grep -F '"up":' |awk '{print $2}'| tr -d ',')
	if [ "$wan_status" == "true" ];then
		wan_uptime=$(ubus call  network.interface.wan status | grep -F '"uptime":'|awk '{print $2}'|tr -d ',')
		wan_macaddr=$(ifconfig $(uci -q get network.wan.ifname) |grep HWaddr | awk '{print $5}')
		wan_procol=$(ubus call  network.interface.wan status | grep -F '"proto":'|awk '{print $2}'|tr -d '"'|tr -d ',')
		wan_ipv4=$(ifconfig $(uci -q get network.wan.ifname)  | grep -F 'inet addr:' |awk '{print$2}' | tr -d 'addr:')
	else
		wan_uptime=none
		if [ "$(ubus call network.interface.wan status | grep -F '"autostart":'|awk '{print $2}'|tr -d ',')" == "false" ];then
			wan_macaddr=00:00:00:00:00:00
		else
			wan_macaddr=$(ifconfig $(uci -q get network.wan.ifname) |grep HWaddr | awk '{print $5}')
		fi	
		wan_procol=$(ubus call  network.interface.wan status | grep -F '"proto":'|awk '{print $2}'|tr -d '"'|tr -d ',')
		wan_ipv4=0.0.0.0
	fi
	echo "lan_status=$lan_status&lan_uptime=$lan_uptime&lan_macaddr=$lan_macaddr&lan_procol=$lan_procol&lan_ipv4=$lan_ipv4&wan_status=$wan_status&wan_uptime=$wan_uptime&wan_macaddr=$wan_macaddr&wan_procol=$wan_procol&wan_ipv4=$wan_ipv4" > $WDIR/EthernetTab
}	

#-----------------------------------------------------------------------------------------
#Checking l2tpv3/IPsec
#-----------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------
#Check in AP : Mac&IP only
#-----------------------------------------------------------------------------------------
macip(){
	Gathermacip="device_mac_address=${device_mac_address}&device_ip_l2tp=${ip_l2tp}&device_ip_address=${ip_addr}"
        /usr/bin/lua /sbin/checkmacip $apc_host "${Gathermacip}"
}
#-----------------------------------------------------------------------------------------
# Update Process
#-----------------------------------------------------------------------------------------	
userUd(){
    #update associated stations
    associated_stations_fnc
    [ -f $WDIR/associated_stations -a "$(cat $WDIR/associated_stations)" != "" ] &&{
    	while read nato ; do
    	 [ "$nato" != "" ]&& /usr/bin/lua /sbin/station $apc_host "${nato}"
    	done < $WDIR/associated_stations 
    }	
}

allUd(){
    [ "$(uci -q get strongswan.main.enable)" == "1" ]&&{
      ipsec_check2=$(ipsec status | grep "ESTABLISHED" | grep $(uci -q get default.settings.l2tpserver))
      [ "$ipsec_check2" == "" ]&& exit 0 # do not checkin when l2vpv3/ipsec not estaplished
    } 
	Device_Tab
	Radio_Tab
	SSID_Tab
        /usr/bin/lua /sbin/cpxset $apc_host "${GATHER}"
        userUd
}

one_minuteUd(){
        macip
	device_mode_func
        #device_model_func
        Radio_Tab
        SSID_Tab
        /usr/bin/lua /sbin/cpxset $apc_host "device_mode=${device_mode}&device_mac_address=${device_mac_address}&device_model=${device_model}&device_vap_list=${device_vap_list}"
}


#-----------------------------------------------------------------------------------------
# SNMP Discovery
#-----------------------------------------------------------------------------------------	
discovery(){
	[ "$(uci -q get apc.setting.discovery)" == "1" ] && {
        						        uci set apc.setting.discovery=0
						                uci commit apc
                                                         }                                                                                                                                                                                       	
	Device_Tab
	Radio_Tab
	discovery_host_name="$(uci -q get system.@system[0].hostname)"
	discovery_info="discovery_mode=${device_mode}&discovery_host_name=${discovery_host_name}&device_ip_l2tp=${ip_l2tp}&discovery_ip_address=${ip_addr}&discovery_mac_address=${device_mac_address}&discovery_model=${device_model}&discovery_version=${firmware_version}"	
	echo "$discovery_info" > $WDIR/discovery_info
        /usr/bin/lua /sbin/discovery $apc_host "${discovery_info}"

}
#-----------------------------------------------------------------------------------------
# Upgrade AP:Check FTP settings
#-----------------------------------------------------------------------------------------	
upgradeAP(){
	uci set apc.setting.FTP_flag=0
	uci commit apc
	usernameFtp=$(uci -q get apc.setting.apcSrvUserName)
	passwordFtp=$(uci -q get apc.setting.apcSrvPasswd)
	ipFtp=$(uci -q get apc.setting.apcSrvIpAddress)
	filenameFtp=$(uci -q get apc.setting.apcFileName)
	portFtp=$(uci -q get apc.setting.apcSrvPort)
	#device_mac_address=$(ifconfig wifi0 | grep HWaddr | awk '{print $5}'| awk '{FS="-";OFS=":";print $1,$2,$3,$4,$5,$6}')
	wget --spider ftp://${usernameFtp}:${passwordFtp}@${ipFtp}:${portFtp}/${filenameFtp} --output-file=/tmp/checkFtp.txt &
			
	
	
	if [ "$(cat /tmp/checkFtp.txt| grep Connecting | awk '{print $4}' )" == "failed:" ]; then
		response_log="Connecting to ${ipFtp}:${portFtp}... failed: Connection refused."
		snmpset -t 65  -v3 -u $apc_snmp_user_name -a MD5 -A $apc_snmp_pass1 -x DES -X $apc_snmp_pass2 -l authPriv $apc_host 1.3.6.1.4.1.426.8.1.20.6.1.1.0 s "$path_of_apc/checkin/upgrade.php \"response_code=ftp_settings_issue&device_mac_address=${device_mac_address}&response_log=${response_log}\""
		exit 
	fi
	
	if [ "$(cat /tmp/checkFtp.txt| grep 'Login incorrect')" != "" ]; then
		response_log="Connecting to ${ipFtp}:${portFtp}... failed: Login incorrect."
		snmpset -t 65  -v3 -u $apc_snmp_user_name -a MD5 -A $apc_snmp_pass1 -x DES -X $apc_snmp_pass2 -l authPriv $apc_host 1.3.6.1.4.1.426.8.1.20.6.1.1.0 s "$path_of_apc/checkin/upgrade.php \"response_code=ftp_settings_issue&device_mac_address=${device_mac_address}&response_log=${response_log}\""
		exit 
	fi
	
	if [ "$(cat /tmp/checkFtp.txt | grep 'No such file' )" != "" ];then
		response_log="${ipFtp}:${portFtp} connected ,but no such file ${filenameFtp}"
		snmpset -t 65  -v3 -u $apc_snmp_user_name -a MD5 -A $apc_snmp_pass1 -x DES -X $apc_snmp_pass2 -l authPriv $apc_host 1.3.6.1.4.1.426.8.1.20.6.1.1.0 s "$path_of_apc/checkin/upgrade.php \"response_code=ftp_settings_issue&device_mac_address=${device_mac_address}&response_log=${response_log}\""
	else
		a=$(echo "scale=2;$(cat /tmp/checkFtp.txt | grep SIZE |awk '{print$5}')/1000000"|bc)
		b=$(df -h /tmp |grep tmpfs| awk '{print $4}')
		response_log="FTP server ${ipFtp}:${portFtp} connected --FW Size:${a}MB(${b}B /tmp avaiable)" 
		snmpset -t 65 -v3 -u $apc_snmp_user_name -a MD5 -A $apc_snmp_pass1 -x DES -X $apc_snmp_pass2 -l authPriv $apc_host 1.3.6.1.4.1.426.8.1.20.6.1.1.0 s "$path_of_apc/checkin/upgrade.php \"response_code=ready_to_download&device_mac_address=${device_mac_address}&response_log=${response_log}\""
	fi	
}
#-----------------------------------------------------------------------------------------
#Upgrade AP:Confirm Downloading 
#-----------------------------------------------------------------------------------------
downloadfw(){
        local enterpriseid=$(uci -q get snmpd.@system[0].enterpriseid) 
        [[ $enterpriseid  ]]||enterpriseid=426               #Default Compex ID

	uci set apc.setting.FTP_download_flag=0
	uci commit apc
	
	snmpset -r 1 -t 65 -v3 -u $ap_snmp_user_name -a MD5 -A $ap_snmp_pass1 -x DES -X $ap_snmp_pass2 -l authPriv localhost .1.3.6.1.4.1.${enterpriseid}.8.1.21.12.0 i 1
	tmp_value=$(uci -q get apc.setting.apcTransferStatus)
	
	while [ "${tmp_value}" == "0" ]   #downloading
	do
	        sleep 5
		tmp_value=$(uci -q get apc.setting.apcTransferStatus)
	       
	done
	
	case $tmp_value in
		1) response_code="ready_to_upgrade" ;;
		2) response_code="download_issue" ;;
	esac	

	response_log=$(uci -q get apc.setting.apcTransferFailReason)
	checksumfw=$(uci -q get apc.setting.apcFileChecksum)
	response_log="${response_log} CheckSum=${checksumfw}"	
	snmpset -t 65 -v3 -u $apc_snmp_user_name -a MD5 -A $apc_snmp_pass1 -x DES -X $apc_snmp_pass2 -l authPriv $apc_host 1.3.6.1.4.1.426.8.1.20.6.1.1.0 s "$path_of_apc/checkin/upgrade.php \"response_code=${response_code}&device_mac_address=${device_mac_address}&response_log=${response_log}\""
}
#-----------------------------------------------------------------------------------------
#Upgrade AP:apply firmware to flash
#-----------------------------------------------------------------------------------------
applyfw(){
        local enterpriseid=$(uci -q get snmpd.@system[0].enterpriseid)
        [[ $enterpriseid  ]]||enterpriseid=426                         

	uci set apc.setting.FTP_upgrade_flag=0
	snmpset -t 65 -v3 -u $ap_snmp_user_name -a MD5 -A $ap_snmp_pass1 -x DES -X $ap_snmp_pass2 -l authPriv localhost .1.3.6.1.4.1.${enterpriseid}.8.1.21.13.0 i 1
	uci set apc.setting.FTP_just_upgraded=1
	uci commit apc
}


#-----------------------------------------------------------------------------------------
# Options
#-----------------------------------------------------------------------------------------	
case $input_value in
        allUd)  allUd ;;
        userUd) userUd ;;
	1minuteUd) one_minuteUd ;;
	discovery) discovery ;;
	upgrade) upgradeAP ;;
	downloadfw) downloadfw ;;
	applyfw) applyfw ;;
	macip)	macip	;;
esac	
