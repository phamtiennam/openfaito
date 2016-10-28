#!/bin/sh
#FAITO-2014,NamPham 
#-----------------------------------------------------------------------------------------
# Update current settings of AP to APC
#----------------------------------------------------------------------------------------
path_of_apc="$(uci get default.settings.apc_path)/$(uci get default.settings.apc_name)"
apc_snmp_user_name=$(uci get default.settings.apc_snmp_user_name)
apc_snmp_pass1=$(uci get default.settings.apc_snmp_pass1)
apc_snmp_pass2=$(uci get default.settings.apc_snmp_pass2)
apc_host=$(uci get default.settings.l2tpserver)
option_snmp="-t 5  -v3 -u $apc_snmp_user_name -a MD5 -A $apc_snmp_pass1 -x DES -X $apc_snmp_pass2 -l authPriv $apc_host 1.3.6.1.4.1.426.8.1.20.6.1.1.0"
WDIR=/tmp/update
device_model=$(cat $WDIR/device_model )
device_mac_address=$(ifconfig wifi0 | grep HWaddr | awk '{print $5}'| awk '{FS="-";OFS=":";print $1,$2,$3,$4,$5,$6}')
#Sub functions
wpa_functions(){
  path1=$1	
  GATHER_Radio="${GATHER_Radio}&${path1}_wpaeap_radius_auth_server=$(uci -q get ${base}.auth_server )"
  GATHER_Radio="${GATHER_Radio}&${path1}_wpaeap_radius_auth_port=$(uci -q get ${base}.auth_port )"
  GATHER_Radio="${GATHER_Radio}&${path1}_wpaeap_radius_auth_secret=$(uci -q get ${base}.auth_secret)"
  GATHER_Radio="${GATHER_Radio}&${path1}_wpaeap_radius_accounting_server=$(uci -q get ${base}.acct_server)"
  GATHER_Radio="${GATHER_Radio}&${path1}_wpaeap_radius_accounting_port=$(uci -q get ${base}.acct_port)"
  GATHER_Radio="${GATHER_Radio}&${path1}_wpaeap_radius_accounting_secret=$(uci -q get ${base}.acct_secret)"
  GATHER_Radio="${GATHER_Radio}&${path1}_wpaeap_nasid=$(uci -q get ${base}.nasid)"
}
wpa2_functions(){
  path2=$1	
  GATHER_Radio="${GATHER_Radio}&${path2}_wpa2eap_radius_auth_server=$(uci -q get ${base}.auth_server )"
  GATHER_Radio="${GATHER_Radio}&${path2}_wpa2eap_radius_auth_port=$(uci -q get ${base}.auth_port )"
  GATHER_Radio="${GATHER_Radio}&${path2}_wpa2eap_radius_auth_secret=$(uci -q get ${base}.auth_secret)"
  GATHER_Radio="${GATHER_Radio}&${path2}_wpa2eap_radius_accounting_server=$(uci -q get ${base}.acct_server)"
  GATHER_Radio="${GATHER_Radio}&${path2}_wpa2eap_radius_accounting_port=$(uci -q get ${base}.acct_port)"
  GATHER_Radio="${GATHER_Radio}&${path2}_wpa2eap_radius_accounting_secret=$(uci -q get ${base}.acct_secret)"
  GATHER_Radio="${GATHER_Radio}&${path2}_wpa2eap_nasid=$(uci -q get ${base}.nasid)"

}
wpa_sta_functions(){
	path3=$1
	case $(uci -q get ${base}.eap_type) in
		tls) GATHER_Radio="${GATHER_Radio}&${path3}_wpaeap_eap_station=1" ;;
		ttls) GATHER_Radio="${GATHER_Radio}&${path3}_wpaeap_eap_station=2" ;;
		peap) GATHER_Radio="${GATHER_Radio}&${path3}_wpaeap_eap_station=3" ;;
	esac		
		GATHER_Radio="${GATHER_Radio}&${path3}_wpaeap_key_station=$(uci -q get ${base}.priv_key_pwd)"
}
wpa2_sta_functions(){
	path4=$1
	case $(uci -q get ${base}.eap_type) in
		tls)  GATHER_Radio="${GATHER_Radio}&${path4}_wpa2eap_eap_station=1"	;;
		ttls)  GATHER_Radio="${GATHER_Radio}&${path4}_wpa2eap_eap_station=2"	;;
		peap)  GATHER_Radio="${GATHER_Radio}&${path4}_wpa2eap_eap_station=3"	;; 
	esac			
		
	GATHER_Radio="${GATHER_Radio}&${path4}_wpa2eap_key_station=$(uci -q get ${base}.priv_key_pwd)"
}

wireless_security_function(){
	path=$1		
	encryption=$(uci get ${base}.encryption)
	case $encryption in
      	none) 
			GATHER_Radio="${GATHER_Radio}&${path}_wireless_security=0" 
			;;
	  
      	wep-open)  
			GATHER_Radio="${GATHER_Radio}&${path}_wireless_security=1"
			tmpkey=$(uci -q get $base.key)
		    GATHER_Radio="${GATHER_Radio}&${path}_wepopen_used_key_slot=$tmpkey"
		    GATHER_Radio="${GATHER_Radio}&${path}_wepopen_key_${tmpkey}=$(uci get $base.key${tmpkey})"
		    ;;
					   
      	wep-shared) 
			GATHER_Radio="${GATHER_Radio}&${path}_wireless_security=2" 
			tmpkey=$(uci -q get $base.key)
		    GATHER_Radio="${GATHER_Radio}&${path}_wepshared_used_key_slot=$tmpkey"
		    GATHER_Radio="${GATHER_Radio}&${path}_wepshared_key_${tmpkey}=$(uci get $base.key${tmpkey})"
		    ;;
							
      	psk) 			
			GATHER_Radio="${GATHER_Radio}&${path}_wireless_security=3"    
			GATHER_Radio="${GATHER_Radio}&${path}_wpapsk_key=$(uci -q get ${base}.key)"		
	        GATHER_Radio="${GATHER_Radio}&${path}_wpapsk_cipher=0"		#Auto
			;;
	  	psk+ccmp) 	
			GATHER_Radio="${GATHER_Radio}&${path}_wireless_security=3"    
			GATHER_Radio="${GATHER_Radio}&${path}_wpapsk_key=$(uci -q get ${base}.key)"
			GATHER_Radio="${GATHER_Radio}&${path}_wpapsk_cipher=1"		#CCMP(AES)
			;;
	  	psk+tkip+ccmp) 	
			GATHER_Radio="${GATHER_Radio}&${path}_wireless_security=3" 	
			GATHER_Radio="${GATHER_Radio}&${path}_wpapsk_key=$(uci -q get ${base}.key)"
			GATHER_Radio="${GATHER_Radio}&${path}_wpapsk_cipher=2"		#TKIP and CCMP (AES)
			;;
      	psk2)
				GATHER_Radio="${GATHER_Radio}&${path}_wireless_security=4" 
			GATHER_Radio="${GATHER_Radio}&${path}_wpa2psk_key=$(uci -q get ${base}.key)"		
	        GATHER_Radio="${GATHER_Radio}&${path}_wpa2psk_cipher=0"		#Auto
			;;
	  	psk2+ccmp) 	
			GATHER_Radio="${GATHER_Radio}&${path}_wireless_security=4"    
			GATHER_Radio="${GATHER_Radio}&${path}_wpa2psk_key=$(uci -q get ${base}.key)"
			GATHER_Radio="${GATHER_Radio}&${path}_wpa2psk_cipher=1"		#CCMP(AES)
			;;
	  	psk2+tkip+ccmp) 
			GATHER_Radio="${GATHER_Radio}&${path}_wireless_security=4" 	
			GATHER_Radio="${GATHER_Radio}&${path}_wpa2psk_key=$(uci -q get ${base}.key)"
			GATHER_Radio="${GATHER_Radio}&${path}_wpa2psk_cipher=2"		#TKIP and CCMP (AES)
			;;
      	psk-mixed) 
			GATHER_Radio="${GATHER_Radio}&${path}_wireless_security=5"
			GATHER_Radio="${GATHER_Radio}&${path}_wpawpa2psk_key=$(uci -q get ${base}.key)"
			GATHER_Radio="${GATHER_Radio}&${path}_wpawpa2psk_cipher=0"	 #Auto
			;;
	  	psk-mixed+ccmp) 
			GATHER_Radio="${GATHER_Radio}&${path}_wireless_security=5"
		    GATHER_Radio="${GATHER_Radio}&${path}_wpawpa2psk_key=$(uci -q get ${base}.key)"
		    GATHER_Radio="${GATHER_Radio}&${path}_wpawpa2psk_cipher=1"	 #CCMP
		    ;;
	  	psk-mixed+tkip+ccmp) 
			GATHER_Radio="${GATHER_Radio}&${path}_wireless_security=5"
		    GATHER_Radio="${GATHER_Radio}&${path}_wpawpa2psk_key=$(uci -q get ${base}.key)"
		    GATHER_Radio="${GATHER_Radio}&${path}_wpawpa2psk_cipher=2"	 #TKIP and CCMP (AES)				
			;;
	  	wpa) 
			GATHER_Radio="${GATHER_Radio}&${path}_wireless_security=6"
			if [ "$(uci get $base.mode)" == "ap" ] ;then
					GATHER_Radio="${GATHER_Radio}&${path}_wpaeap_cipher=0" #Auto
					wpa_functions $path
			else
					GATHER_Radio="${GATHER_Radio}&${path}_wpaeap_cipher_station=0" #Auto
					wpa_sta_functions $path
			fi
			;;
	  	wpa+ccmp) 
			GATHER_Radio="${GATHER_Radio}&${path}_wireless_security=6" 
			if [ "$(uci get $base.mode)" == "ap" ] ;then
					GATHER_Radio="${GATHER_Radio}&${path}_wpaeap_cipher=1" #CCMP
					wpa_functions $path
			else
					GATHER_Radio="${GATHER_Radio}&${path}_wpaeap_cipher_station=1" #CCMP
					wpa_sta_functions $path
			fi
  			;;
		wpa+tkip+ccmp) 
			GATHER_Radio="${GATHER_Radio}&${path}_wireless_security=6" 
			if [ "$(uci get $base.mode)" == "ap" ] ;then
					GATHER_Radio="${GATHER_Radio}&${path}_wpaeap_cipher=2" #TKIP and CCMP (AES)	
					wpa_functions $path
			else
					GATHER_Radio="${GATHER_Radio}&${path}_wpaeap_cipher_station=2" #TKIP and CCMP (AES)	
					wpa_sta_functions $path
			fi
			;;
		wpa2) 
			GATHER_Radio="${GATHER_Radio}&${path}_wireless_security=7" 
			if [ "$(uci get $base.mode)" == "ap" ] ;then
					GATHER_Radio="${GATHER_Radio}&${path}_wpa2eap_cipher=0" #Auto
					wpa2_functions $path
			else
					GATHER_Radio="${GATHER_Radio}&${path}_wpa2eap_cipher_station=0" #Auto
					wpa2_sta_functions $path
			fi
			;;
		wpa2+ccmp) GATHER_Radio="${GATHER_Radio}&${path}_wireless_security=7" 
			if [ "$(uci get $base.mode)" == "ap" ] ;then
					GATHER_Radio="${GATHER_Radio}&${path}_wpa2eap_cipher=1" #CCMP
					wpa2_functions $path
			else
					GATHER_Radio="${GATHER_Radio}&${path}_wpa2eap_cipher_station=1" #CCMP
					wpa2_sta_functions $path
			fi		
			;;
		wpa2+tkip+ccmp) GATHER_Radio="${GATHER_Radio}&${path}_wireless_security=7" 
			if [ "$(uci get $base.mode)" == "ap" ] ;then
					GATHER_Radio="${GATHER_Radio}&${path}_wpa2eap_cipher=2" #TKIP and CCMP (AES)
					wpa2_functions $path
			else
					GATHER_Radio="${GATHER_Radio}&${path}_wpa2eap_cipher_station=2" #TKIP and CCMP (AES)
					wpa2_sta_functions $path
			fi		
			;;
	esac
}
#Main functions

#General Settings----------------------------------------------------------------------------------------------------------------------------------------|
general_settings(){
 device_name=$(uci get system.@system[0].hostname)
 device_transmit_antenna=$(uci get apc.setting.transmit_antenna)
 device_received_antenna=$(uci get apc.setting.received_antenna)
 GATHER="device_mac_address=${device_mac_address}&device_model=${device_model}&device_name=${device_name}&device_transmit_antenna=${device_transmit_antenna}&device_received_antenna=${device_received_antenna}"
 snmpset $option_snmp s "$path_of_apc/checkin/update_ap_settings.php \"${GATHER}\""
}	
#Radio Settings ------------------------------------------------------------------------------------------------------------------------------------------|
radio_settings(){
 	while read radi;do
	 	#Main-------------------------------------------
		radiox=$(echo $radi|awk '{print $2}')
		wifix=$(echo $radi|awk '{print $3}')
		uci show wireless | grep  "id_ssid=${wifix}" > /tmp/list_${wifix}_ssid
		radio_hwmode=$(uci get wireless.${wifix}.hwmode)
		radio_disabled=$(uci -q get wireless.${wifix}.disabled)
		GATHER_Radio="device_mac_address=${device_mac_address}&device_model=${device_model}"
		
		#radio enable/disable
			#0 -> Disable
			#1--> Enable
		[ "${radio_disabled}" == "" ] && GATHER_Radio="${GATHER_Radio}&${radiox}=1" 
		[ "${radio_disabled}" == "1" ] && GATHER_Radio="${GATHER_Radio}&${radiox}=0"

	        #mesh enable/disable
	        [ "$(uci -q get wireless.${wifix}.meshmode)" != "" ]&& GATHER_Radio="${GATHER_Radio}&${radiox}_mesh_ind=1" || GATHER_Radio="${GATHER_Radio}&${radiox}_mesh_ind=0"

	        #mesh_gen_meshid
	        mesh1=$(uci show wireless| grep -w id_ssid=${wifix}_1|awk '{FS=".";OFS=".";print $1,$2}')
	        mesh_gen_meshid=$(uci -q get ${mesh1}.ssid)
	        [ "$mesh_gen_meshid" != "" ]&& GATHER_Radio="${GATHER_Radio}&${radiox}_ssid1_gen_meshid=${mesh_gen_meshid}"

	        #mesh_mode
	        mesh_mode=$(uci -q get wireless.${wifix}.meshmode)
	        case $mesh_mode in 
	          meshap)GATHER_Radio="${GATHER_Radio}&${radiox}_ssid1_gen_meshmode=1";;
	          rootap)GATHER_Radio="${GATHER_Radio}&${radiox}_ssid1_gen_meshmode=2";; 
	          rootaprc)GATHER_Radio="${GATHER_Radio}&${radiox}_ssid1_gen_meshmode=3";;
	           *)GATHER_Radio="${GATHER_Radio}&${radiox}_ssid1_gen_meshmode=1";;
	        esac

		#radio_profile	
			# 1->802.11ac->11ac80|11ac*
			# 2->802.11a+n->11na
			# 3->802.11g+n->11ng
		case $radio_hwmode in
			11ac*) GATHER_Radio="${GATHER_Radio}&${radiox}_profile=1"	;;
			11na*) GATHER_Radio="${GATHER_Radio}&${radiox}_profile=2"	;;
			11ng*) GATHER_Radio="${GATHER_Radio}&${radiox}_profile=3"	;;
		esac
		#device_xxx_radio_channel
		radiox_channel=$(uci get wireless.${wifix}.channel)	
		[ "$radiox_channel" == "auto" ]&& radiox_channel=Auto
		GATHER_Radio="${GATHER_Radio}&${radiox}_channel=${radiox_channel}"
		#device_xxx_radio_country_code
			
		radiox_country_code=$(uci -q get wireless.${wifix}.country)	
		[ "$radiox_country_code" == "" ]&& radiox_country_code=1001

		GATHER_Radio="${GATHER_Radio}&${radiox}_country_code=${radiox_country_code}"
		
		#device_xxx_radio_spectrum_width
			#option 1 --> 20/40/80 Mhz --> 11xx80
			#option 2 --> 20/40 Mhz		--> 11xx
			#option 3 --> 20Mhz			--> 11xx20
		case $radio_hwmode in
			11na80|11ng80|11ac80) 	GATHER_Radio="${GATHER_Radio}&${radiox}_spectrum_width=1"	;;
			11na|11ng|11ac) 				GATHER_Radio="${GATHER_Radio}&${radiox}_spectrum_width=2"	;;
			11na20|11ng20|11ac20) 	GATHER_Radio="${GATHER_Radio}&${radiox}_spectrum_width=3"	;;
		esac	
			
		
		#device_xxx_radio_transmit_power
		radiox_transmit_power=$(uci get wireless.${wifix}.txpower)
	        [ "${radiox_transmit_power}" == "max"  ]&& radiox_transmit_power=0
		GATHER_Radio="${GATHER_Radio}&${radiox}_transmit_power=${radiox_transmit_power}"
		wifix_hwcap=$(iwpriv $wifix get_hwcap|awk '{FS=":";print $2}' )
		wifix_chainmask=$(lua /lib/faito/rshilf8.lua $wifix_hwcap)
		case $wifix_chainmask in
			7) numchain=3 ;;
			6|5|3) numchain=2;;
			*) numchain=1;;
		esac
		v=$(uci -q get wireless.${wifix}.chainmask )
		case $v in
			7) nchn=3 ;;
			3) nchn=2 ;;
			1) nchn=1 ;;
			*)  nchn=$numchain ;;
		esac
		case $nchn in
			3) mpwr=5 ;;
			2) mpwr=3 ;;
			*)  mpwr=0 ;;
		esac
		GATHER_Radio="${GATHER_Radio}&${radiox}_transmit_power_min=$((mpwr+1))"
		GATHER_Radio="${GATHER_Radio}&${radiox}_transmit_power_max=$(iwinfo ${wifix} txpowerlist | awk '{print $1}')"
		
		#device_xxx_radio_auto_ack_timeout
		[ "$(uci show wireless | grep -w wireless.${wifix}.autoack=1)"  != "" ]&&  GATHER_Radio="${GATHER_Radio}&${radiox}_auto_ack_timeout=1" ||GATHER_Radio="${GATHER_Radio}&${radiox}_auto_ack_timeout=0"
		#device_xghz_radio_distance
		[ " $(uci show wireless)| grep wireless.${wifix}.distance"  != "" ] &&  GATHER_Radio="${GATHER_Radio}&${radiox}_distance=$(uci get -q wireless.${wifix}.distance) "
		
		#SSIDs On /Off/NA
		for c in `seq 1 16` ; do
			tmpa=$(grep -w ${wifix}_$c /tmp/list_${wifix}_ssid | awk '{FS=".";OFS=".";print $1,$2}')
			if [ "${tmpa}" != "" ] ;then
				
				case $(uci -q get ${tmpa}.disabled)  in
					1)	GATHER_Radio="${GATHER_Radio}&${radiox}_ssid${c}=0"		;;		#Off (ssid disabled)
					*)		
						GATHER_Radio="${GATHER_Radio}&${radiox}_ssid${c}=1"		;;		#1 = On
						#ssidname=$(uci -q get ${tmpa}.ssid)
						#ssidname=$( iwconfig | grep -w ESSID:\"${ssidname}\" -A 1|grep "Access Point"|awk '{print $6}')
						#[ "${ssidname}" == "Not-Associated" ] && GATHER_Radio="${GATHER_Radio}&${radiox}_ssid${c}=0" || GATHER_Radio="${GATHER_Radio}&${radiox}_ssid${c}=1"	;;			#0 = Off (ssid not associated ) | 1 = On
				esac
				
			else	
				GATHER_Radio="${GATHER_Radio}&${radiox}_ssid${c}=2"      #NA
			fi	
		done
		
		#=================================================SNMPSET=====================================================
		#echo $GATHER_Radio >> /tmp/GATHER_Radio
		snmpset $option_snmp s "$path_of_apc/checkin/update_ap_settings.php \"${GATHER_Radio}\""
		#==============================================================================================================
		
		#xxxRadio--------------------------------------------------
		#General Setup
		
		while read sadi;do
			GATHER_Radio="device_mac_address=${device_mac_address}&device_model=${device_model}"
			#Mode    	  option=1  -->Access Point
				 #option=2  -->Access Point(WDS)
				 #option=3  -->Station
				 #option=4  -->Station(WDS)
			#mode
			base=$(echo $sadi |awk  '{FS=".";OFS=".";print $1,$2}')
			ssidx="ssid$(echo $sadi |awk -F"=" '{print $2}'|awk -F"_" '{print $2}')"
			
			case $(uci get $base.mode) in
				ap) 		
				[ "$(uci -q get $base.wds)" == "1" ] && GATHER_Radio="${GATHER_Radio}&${radiox}_${ssidx}_mode=2" || GATHER_Radio="${GATHER_Radio}&${radiox}_${ssidx}_mode=1"
								;;
				sta) 
				[ "$(uci -q get $base.wds)" == "1" ] && GATHER_Radio="${GATHER_Radio}&${radiox}_${ssidx}_mode=4" || GATHER_Radio="${GATHER_Radio}&${radiox}_${ssidx}_mode=3"		
								;;
			esac
			
			#essid
			GATHER_Radio="${GATHER_Radio}&${radiox}_${ssidx}_essid=$(uci -q get ${base}.ssid)"
			[ "${mesh_mode}" == "rootaprc" -a "$ssidx" == "ssid3" ]&& GATHER_Radio="${GATHER_Radio}&device_radio_rc_essid=$(uci -q get ${base}.ssid)"
			#guard_interval
					#option=1-->Short-->shortgi=1
					#option=2-->Long-->shortgi=0
			[ "$(uci -q get $base.shortgi)" == "0" ]&& GATHER_Radio="${GATHER_Radio}&${radiox}_${ssidx}_guard_interval=2"|| GATHER_Radio="${GATHER_Radio}&${radiox}_${ssidx}_guard_interval=1"

			#data_rate	
			case $(uci -q get $base.manrate) in
				0x0b0b0b0b)  GATHER_Radio="${GATHER_Radio}&${radiox}_${ssidx}_data_rate=6Mbps" ;;
				0x0f0f0f0f)     GATHER_Radio="${GATHER_Radio}&${radiox}_${ssidx}_data_rate=9Mbps" ;;
				0x0a0a0a0a)  GATHER_Radio="${GATHER_Radio}&${radiox}_${ssidx}_data_rate=12Mbps" ;;
				0x0e0e0e0e)	 GATHER_Radio="${GATHER_Radio}&${radiox}_${ssidx}_data_rate=18Mbps"	;;
				0x09090909)  GATHER_Radio="${GATHER_Radio}&${radiox}_${ssidx}_data_rate=24Mbps"	;;
				0x0d0d0d0d)	 GATHER_Radio="${GATHER_Radio}&${radiox}_${ssidx}_data_rate=36Mbps"	;;
				0x08080808)  GATHER_Radio="${GATHER_Radio}&${radiox}_${ssidx}_data_rate=48Mbps"	;;
				0x0c0c0c0c)  GATHER_Radio="${GATHER_Radio}&${radiox}_${ssidx}_data_rate=54Mbps"	;;
				0x80808080)  GATHER_Radio="${GATHER_Radio}&${radiox}_${ssidx}_data_rate=MCS0"	;;
				0x81818181)  GATHER_Radio="${GATHER_Radio}&${radiox}_${ssidx}_data_rate=MCS1"	;;
				0x82828282)  GATHER_Radio="${GATHER_Radio}&${radiox}_${ssidx}_data_rate=MCS2"	;;
				0x83838383)  GATHER_Radio="${GATHER_Radio}&${radiox}_${ssidx}_data_rate=MCS3"	;;
				0x84848484)  GATHER_Radio="${GATHER_Radio}&${radiox}_${ssidx}_data_rate=MCS4"	;;
				0x85858585)  GATHER_Radio="${GATHER_Radio}&${radiox}_${ssidx}_data_rate=MCS5"	;;
				0x86868686)  GATHER_Radio="${GATHER_Radio}&${radiox}_${ssidx}_data_rate=MCS6"	;;
				0x87878787)  GATHER_Radio="${GATHER_Radio}&${radiox}_${ssidx}_data_rate=MCS7"	;;
				0x88888888)  GATHER_Radio="${GATHER_Radio}&${radiox}_${ssidx}_data_rate=MCS8" ;;  
				0x89898989)  GATHER_Radio="${GATHER_Radio}&${radiox}_${ssidx}_data_rate=MCS9" ;;  
				0x8a8a8a8a)  GATHER_Radio="${GATHER_Radio}&${radiox}_${ssidx}_data_rate=MCS10" ;;
				0x8b8b8b8b)  GATHER_Radio="${GATHER_Radio}&${radiox}_${ssidx}_data_rate=MCS11" ;;
				0x8c8c8c8c)  GATHER_Radio="${GATHER_Radio}&${radiox}_${ssidx}_data_rate=MCS12" ;; 
				0x8d8d8d8d)  GATHER_Radio="${GATHER_Radio}&${radiox}_${ssidx}_data_rate=MCS13" ;;
				0x8e8e8e8e)  GATHER_Radio="${GATHER_Radio}&${radiox}_${ssidx}_data_rate=MCS14" ;;
				0x8f8f8f8f) 	 GATHER_Radio="${GATHER_Radio}&${radiox}_${ssidx}_data_rate=MCS15" ;;
				0x90909090)  GATHER_Radio="${GATHER_Radio}&${radiox}_${ssidx}_data_rate=MCS16" ;;
				0x91919191)  GATHER_Radio="${GATHER_Radio}&${radiox}_${ssidx}_data_rate=MCS17" ;;
				0x92929292)  GATHER_Radio="${GATHER_Radio}&${radiox}_${ssidx}_data_rate=MCS18" ;;
				0x93939393)  GATHER_Radio="${GATHER_Radio}&${radiox}_${ssidx}_data_rate=MCS19" ;;
				0x94949494)  GATHER_Radio="${GATHER_Radio}&${radiox}_${ssidx}_data_rate=MCS20" ;;
				0x95959595)  GATHER_Radio="${GATHER_Radio}&${radiox}_${ssidx}_data_rate=MCS21" ;;
				0x96969696)  GATHER_Radio="${GATHER_Radio}&${radiox}_${ssidx}_data_rate=MCS22" ;;
				0x97979797)  GATHER_Radio="${GATHER_Radio}&${radiox}_${ssidx}_data_rate=MCS23" ;; 	
				auto|"") GATHER_Radio="${GATHER_Radio}&${radiox}_${ssidx}_data_rate=auto"       ;;
			esac		
			
			#hide_ssid
				#option 0    NO
				#option 1    YES
			[ "$(uci -q get $base.hidden)" == "1" ] && 	GATHER_Radio="${GATHER_Radio}&${radiox}_${ssidx}_hide_ssid=1" || GATHER_Radio="${GATHER_Radio}&${radiox}_${ssidx}_hide_ssid=0"
			
			#Wireless security
			if [ "${mesh_mode}" == "rootaprc" -a "$ssidx" == "ssid3" ];then
				wireless_security_function device_radio_rc 			#Router Client in MESH Rootaprc
			else
				wireless_security_function ${radiox}_${ssidx}		#Non Mesh
			fi	

			#MAC Filter
			if [ "$(uci get $base.mode)" == "ap" ] ;then
				macpolicy=$(uci -q get ${base}.macpolicy)
				case $macpolicy in
					allow)
						GATHER_Radio="${GATHER_Radio}&${radiox}_${ssidx}_mac_acl=1"	
						GATHER_Radio="${GATHER_Radio}&${radiox}_${ssidx}_policy_allow=$(uci -q get ${base}.maclist | sed s/" "/,/g)"
					;;
					deny)
						GATHER_Radio="${GATHER_Radio}&${radiox}_${ssidx}_mac_acl=2"
						GATHER_Radio="${GATHER_Radio}&${radiox}_${ssidx}_policy_deny=$(uci -q get ${base}.maclist | sed s/" "/,/g)"
					;;
					*)
						GATHER_Radio="${GATHER_Radio}&${radiox}_${ssidx}_mac_acl=0"
					;;
				esac

			fi
			
			#Advanced settings
			if [ "$(uci get $base.mode)" == "ap" ] ;then
				GATHER_Radio="${GATHER_Radio}&${radiox}_${ssidx}_rts_threshold=$(uci -q get  ${base}.rts)"
				case $(uci -q get ${base}.isolate) in
				1) GATHER_Radio="${GATHER_Radio}&${radiox}_${ssidx}_station_isolation=1"		;;
				*)	 GATHER_Radio="${GATHER_Radio}&${radiox}_${ssidx}_station_isolation=0"		;;		
				esac
				GATHER_Radio="${GATHER_Radio}&${radiox}_${ssidx}_maximum_stations=$(uci -q get ${base}.maxsta)"  
				GATHER_Radio="${GATHER_Radio}&${radiox}_${ssidx}_minimum_stations_rssi=$(uci -q get  ${base}.minrssi)"
				case $(uci -q get ${base}.puren) in
				1) GATHER_Radio="${GATHER_Radio}&${radiox}_${ssidx}_80211n80211ac_only=1"		;;		
				 *) GATHER_Radio="${GATHER_Radio}&${radiox}_${ssidx}_80211n80211ac_only=0"	;;
				esac
				case $(uci -q get ${base}.disablecoext) in
				0) GATHER_Radio="${GATHER_Radio}&${radiox}_${ssidx}_ht20ht40_coexistence=1"	;;
				*)	 GATHER_Radio="${GATHER_Radio}&${radiox}_${ssidx}_ht20ht40_coexistence=0"	;;
				esac											
				case $(uci -q get ${base}.wmm) in
				0) GATHER_Radio="${GATHER_Radio}&${radiox}_${ssidx}_wmm=0"	;;
				*)	 GATHER_Radio="${GATHER_Radio}&${radiox}_${ssidx}_wmm=1"	;;
				esac													
			else
				GATHER_Radio="${GATHER_Radio}&${radiox}_${ssidx}_rts_threshold=$(uci -q get  ${base}.rts)"
				case $(uci -q get ${base}.wmm) in
				0) GATHER_Radio="${GATHER_Radio}&${radiox}_${ssidx}_wmm=0"	;;
				*)	 GATHER_Radio="${GATHER_Radio}&${radiox}_${ssidx}_wmm=1"	;;
				esac
			fi

			#=================================================SNMPSET=====================================================
			#echo $GATHER_Radio > /tmp/GATHER_Radio
			snmpset $option_snmp s "$path_of_apc/checkin/update_ap_settings.php \"${GATHER_Radio}\""
			#==============================================================================================================
		done  < /tmp/list_${wifix}_ssid
 	done < $WDIR/radio_profile 
}

#Advanced Settings------------------------------------------------------------------------------------------------------------------------------------- |
advanced_settings(){
network_ssh_password=""
[ "$(pidof uhttpd)" != "" ] && network_web=1||network_web=0
network_failover_ap_controller=$( uci -q get  default.settings.FailoverAPC)
GATHER_adv="device_mac_address=${device_mac_address}&device_model=${device_model}&network_ssh_password=${network_ssh_password}&network_web=${network_web}&network_failover_ap_controller=${network_failover_ap_controller}"
 snmpset $option_snmp s "$path_of_apc/checkin/update_ap_settings.php \"${GATHER_adv}\""
}
#Hotspot Settings-----------------------------------------------------------------------------------------------------------------------------------------|
hotspot_settings(){
	#Hospot General Settings
	
		GATHER_hotspot="device_mac_address=${device_mac_address}&device_model=${device_model}"
		#hotspot_enable
		hotspot_enable=$(uci -q get coovachilli.@chilli[0].enable_chilli)
		case  $hotspot_enable in
					1) GATHER_hotspot="${GATHER_hotspot}&hotspot_enable=1" ;;   #1 Enable
					*)  GATHER_hotspot="${GATHER_hotspot}&hotspot_enable=0" ;;	 # 0 Disable	
		esac	
		
		#hotspot_mode
		hotspot_mode=$(uci -q get  coovachilli.@chilli[0].chillimode)
		case $hotspot_mode in
					captiveportal) GATHER_hotspot="${GATHER_hotspot}&hotspot_mode=1" ;;			#User Name + Password (Radius Required)
					agreementradius) GATHER_hotspot="${GATHER_hotspot}&hotspot_mode=2" ;;	#Agreement (Radius Required)
					agreement) GATHER_hotspot="${GATHER_hotspot}&hotspot_mode=3" ;;				#Agreement (Radius not Required)
					passwordonlyradius) GATHER_hotspot="${GATHER_hotspot}&hotspot_mode=4" ;;#Password (Radius Required)
					passwordonly) GATHER_hotspot="${GATHER_hotspot}&hotspot_mode=5" 			#Password (Radius not Required)
											  GATHER_hotspot="${GATHER_hotspot}&hotspot_password=$(uci -q get coovachilli.@chilli[0].passwordonly)"	;;
		esac
		
		#Login page title
		login_title=$(uci -q get  coovachilli.@chilli[0].locationname)
		GATHER_hotspot="${GATHER_hotspot}&hotspot_login_page_title=${login_title}"
		
		#IdleTimeout
		idletimeout=$(uci -q get  coovachilli.@chilli[0].defidletimeout)
		GATHER_hotspot="${GATHER_hotspot}&hotspot_idle_time_out=${idletimeout}"
	#---------------------------------------------------------------|
	#Hotspot Network Configuration 
		#hotspot_auto_config
		hotspot_auto_config=$(uci -q get  coovachilli.@chilli[0].auto_network_config)
		if [ "${hotspot_auto_config}" == "1" ];then
				GATHER_hotspot="${GATHER_hotspot}&hotspot_auto_config=1"		#1 YES
		else
				GATHER_hotspot="${GATHER_hotspot}&hotspot_auto_config=0"		#0	NO
				GATHER_hotspot="${GATHER_hotspot}&hotspot_network_address=$(uci -q get coovachilli.@chilli[0].net)"
				GATHER_hotspot="${GATHER_hotspot}&hotspot_dns_server_1=$(uci -q get coovachilli.@chilli[0].dns1)"
				GATHER_hotspot="${GATHER_hotspot}&hotspot_dns_server_2=$(uci -q get coovachilli.@chilli[0].dns2)"
		fi
	#---------------------------------------------------------------|	
	#Hospot Radius Configuration
		#Radius_server_1
				GATHER_hotspot="${GATHER_hotspot}&hotspot_radius_server_1=$(uci -q get  coovachilli.@chilli[0].radiusserver1)"
		#Radius_server_2
				GATHER_hotspot="${GATHER_hotspot}&hotspot_radius_server_2=$(uci -q get  coovachilli.@chilli[0].radiusserver2)"
		#Radius_secret
				GATHER_hotspot="${GATHER_hotspot}&hotspot_radius_secret=$(uci -q get  coovachilli.@chilli[0].radiussecret)"
		#UAM Server	
				GATHER_hotspot="${GATHER_hotspot}&hotspot_uam_server=$(uci -q get coovachilli.@chilli[0].uamserver)"
		#UAM Secret		
				GATHER_hotspot="${GATHER_hotspot}&hotspot_uam_secret=$(uci -q get coovachilli.@chilli[0].uamsecret)"
		#Walled Garden (Domain) 
				GATHER_hotspot="${GATHER_hotspot}&hotspot_walled_garden_domain=$(uci -q get coovachilli.@chilli[0].uamdomain)"
		#Walled Garden (IP Address) :	
				GATHER_hotspot="${GATHER_hotspot}&hotspot_walled_garden_ip=$(uci -q get coovachilli.@chilli[0].uamallowed)"
	#-----------------------------------------------------------------|
	#SNMPSET
		snmpset $option_snmp s "$path_of_apc/checkin/update_ap_settings.php \"${GATHER_hotspot}\""
				
}

#==================================================================TRUNK===================================================================#
general_settings
radio_settings
advanced_settings
hotspot_settings
uci set apc.setting.ImmediateUd=0
uci commit apc


