#!/bin/sh

radfunc(){
local ADIR=/tmp/apply
	#function
		wireless_security_fcn(){
			#encryption
			path=$2
			wireless_security=$(uci -c $ADIR -q get rdset.setting.${path}_wireless_security)	
			case ${wireless_security} in
				0)	uci set wireless.$1.encryption=none	;;
				1)	uci set wireless.$1.encryption=wep-open	;;
				2)	uci set wireless.$1.encryption=wep-shared	;;
				3)	uci set wireless.$1.encryption=psk	;;	
				4)	uci set wireless.$1.encryption=psk2	;;
				5)	uci set wireless.$1.encryption=psk-mixed	;;
				6)	uci set wireless.$1.encryption=wpa	;;
				7)	uci set wireless.$1.encryption=wpa2	;;
							
				*);;
			esac
			#wep-open key
				wepopen_slot=$(uci -c $ADIR -q get rdset.setting.${path}_wepopen_used_key_slot)
				[ "${wepopen_slot}" != "" ] && uci set wireless.$1.key=${wepopen_slot}
				for  k in  1 2 3 4 ;do
					wepopen_key=$(uci -c $ADIR -q get rdset.setting.${path}_wepopen_key_${k})
					[ "${wepopen_key}" != "" ] && uci set wireless.$1.key${k}=${wepopen_key}
				done
			#wep-shared
				wepshared_slot=$(uci -c $ADIR -q get rdset.setting.${path}_wepshared_used_key_slot)
				[ "${wepshared_slot}" != "" ] && uci set wireless.$1.key=${wepshared_slot}
				for  k in  1 2 3 4 ;do
					wepshared_key=$(uci -c $ADIR -q get rdset.setting.${path}_wepshared_key_${k})
					[ "${wepshared_key}" != "" ] && uci set wireless.$1.key${k}=${wepshared_key}
				done
			#psk
				wpapsk_cipher=$(uci -c $ADIR -q get rdset.setting.${path}_wpapsk_cipher)	
				case ${wpapsk_cipher} in
					1)	uci set wireless.$1.encryption=psk+ccmp	;;
					2)	uci set wireless.$1.encryption=psk+tkip+ccmp	;;
					0)	uci set wireless.$1.encryption=psk	;;
					*)	;;
				esac
					
				wpapsk_key=$(uci -c $ADIR -q get rdset.setting.${path}_wpapsk_key)
				[ "${wpapsk_key}" != "" ] && uci set wireless.$1.key=${wpapsk_key}
			#psk2
				wpa2psk_cipher=$(uci -c $ADIR -q get rdset.setting.${path}_wpa2psk_cipher)
				case ${wpa2psk_cipher} in
					1)	uci set wireless.$1.encryption=psk2+ccmp	;;
					2)	uci set wireless.$1.encryption=psk2+tkip+ccmp	;;
					0)	uci set wireless.$1.encryption=psk2	;;	
					*)		;;
				esac
				
				wpa2psk_key=$(uci -c $ADIR -q get rdset.setting.${path}_wpa2psk_key)
				[ "${wpa2psk_key}" != "" ] && uci set wireless.$1.key=${wpa2psk_key}
								
			#psk-mixed
				wpawpa2psk_cipher=$(uci -c $ADIR -q get rdset.setting.${path}_wpawpa2psk_cipher)
				case ${wpawpa2psk_cipher} in
					1)	uci set wireless.$1.encryption=psk-mixed+ccmp	;;
					2)	uci set wireless.$1.encryption=psk-mixed+tkip+ccmp	;;
					0)	uci set wireless.$1.encryption=psk-mixed	;;
					*)	;;
				esac
										
				wpawpa2psk_key=$(uci -c $ADIR -q get rdset.setting.${path}_wpawpa2psk_key)
				[ "${wpawpa2psk_key}" != "" ] && uci set wireless.$1.key=${wpawpa2psk_key}
				
			#wpaeap	
			wpaeap_cipher=$(uci -c $ADIR -q get rdset.setting.${path}_wpaeap_cipher)
			wpaeap_cipher_station=$(uci -c $ADIR -q get rdset.setting.${path}_wpaeap_cipher_station)
			[ "${wpaeap_cipher}" == "0" -o "${wpaeap_cipher_station}" == "0"  ]&& uci set wireless.$1.encryption=wpa
			[ "${wpaeap_cipher}" == "1" -o "${wpaeap_cipher_station}" == "1"  ]&& uci set wireless.$1.encryption=wpa+ccmp
			[ "${wpaeap_cipher}" == "2" -o "${wpaeap_cipher_station}" == "2"  ]&& uci set wireless.$1.encryption=wpa+tkip+ccmp
			#---------------------------wpaeap-station----------------
			wpaeap_eap_station=$(uci -c $ADIR -q get rdset.setting.${path}_wpaeap_eap_station)	
			[ "${wpaeap_eap_station}" != "" ]  && {
				case ${wpaeap_eap_station} in
					1)	uci set wireless.$1.eap_type=tls	;;
					2)	uci set wireless.$1.eap_type=ttls	;;
					3)	uci set wireless.$1.eap_type=peap	;;
				esac			
			}
							
			wpaeap_key_station=$(uci -c $ADIR -q get rdset.setting.${path}_wpaeap_key_station)
			[ "${wpaeap_key_station}" != "" ] && uci set wireless.$1.priv_key_pwd=${wpaeap_key_station}
			#---------------------------wpaeap_ap--------------------

			wpaeap_radius_auth_server=$(uci -c $ADIR -q get rdset.setting.${path}_wpaeap_radius_auth_server)
			[ "${wpaeap_radius_auth_server}" != "" ] && uci set wireless.$1.auth_server=${wpaeap_radius_auth_server}

			wpaeap_radius_auth_port=$(uci -c $ADIR -q get rdset.setting.${path}_wpaeap_radius_auth_port)
			[ "${wpaeap_radius_auth_port}" != "" ]	&&	uci set wireless.$1.auth_port=${wpaeap_radius_auth_port}

			wpaeap_radius_auth_secret=$(uci -c $ADIR -q get rdset.setting.${path}_wpaeap_radius_auth_secret)				
			[ "${wpaeap_radius_auth_secret}" != "" ] && uci set wireless.$1.auth_secret=${wpaeap_radius_auth_secret}

			wpaeap_radius_accounting_server=$(uci -c $ADIR -q get rdset.setting.${path}_wpaeap_radius_accounting_server)				
			[ "${wpaeap_radius_accounting_server}" != "" ] && uci set wireless.$1.acct_server=${wpaeap_radius_accounting_server}

			wpaeap_radius_accounting_port=$(uci -c $ADIR -q get rdset.setting.${path}_wpaeap_radius_accounting_port)	
			[ "${wpaeap_radius_accounting_port}" != "" ] && uci set wireless.$1.acct_port=${wpaeap_radius_accounting_port}

			wpaeap_radius_accounting_secret=$(uci -c $ADIR -q get rdset.setting.${path}_wpaeap_radius_accounting_secret)	
			[ "${wpaeap_radius_accounting_secret}" != "" ] && uci set wireless.$1.acct_secret=${wpaeap_radius_accounting_secret}

			wpaeap_nasid=$(uci -c $ADIR -q get rdset.setting.${path}_wpaeap_nasid)	
			[ "${wpaeap_nasid}" != "" ] && uci set wireless.$1.nasid=${wpaeap_nasid}


			#wpa2eap
			wpa2eap_cipher=$(uci -c $ADIR -q get rdset.setting.${path}_wpa2eap_cipher)
			wpa2eap_cipher_station=$(uci -c $ADIR -q get rdset.setting.${path}_wpa2eap_cipher_station)
			[ "${wpa2eap_cipher}" == "0" -o "${wpa2eap_cipher_station}" == "0"  ]&& uci set wireless.$1.encryption=wpa2
			[ "${wpa2eap_cipher}" == "1" -o "${wpa2eap_cipher_station}" == "1"  ]&& uci set wireless.$1.encryption=wpa2+ccmp
			[ "${wpa2eap_cipher}" == "2" -o "${wpa2eap_cipher_station}" == "2"  ]&& uci set wireless.$1.encryption=wpa2+tkip+ccmp

			#---------------------------wpaeap-station----------------
			wpaeap_eap_station=$(uci -c $ADIR -q get rdset.setting.${path}_wpaeap_eap_station)	
			[ "${wpaeap_eap_station}" != "" ]  && {
				case ${wpaeap_eap_station} in
					1)	uci set wireless.$1.eap_type=tls	;;
					2)	uci set wireless.$1.eap_type=ttls	;;
					3)	uci set wireless.$1.eap_type=peap	;;
				esac			
			}

			wpaeap_key_station=$(uci -c $ADIR -q get rdset.setting.${path}_wpaeap_key_station)
			[ "${wpaeap_key_station}" != "" ] && uci set wireless.$1.priv_key_pwd=${wpaeap_key_station}
			#---------------------------wpa2eap_ap--------------------

			wpa2eap_radius_auth_server=$(uci -c $ADIR -q get rdset.setting.${path}_wpa2eap_radius_auth_server)
			[ "${wpa2eap_radius_auth_server}" != "" ] && uci set wireless.$1.auth_server=${wpa2eap_radius_auth_server}

			wpa2eap_radius_auth_port=$(uci -c $ADIR -q get rdset.setting.${path}_wpa2eap_radius_auth_port)
			[ "${wpa2eap_radius_auth_port}" != "" ]	&&	uci set wireless.$1.auth_port=${wpa2eap_radius_auth_port}

			wpa2eap_radius_auth_secret=$(uci -c $ADIR -q get rdset.setting.${path}_wpa2eap_radius_auth_secret)				
			[ "${wpa2eap_radius_auth_secret}" != "" ] && uci set wireless.$1.auth_secret=${wpa2eap_radius_auth_secret}

			wpa2eap_radius_accounting_server=$(uci -c $ADIR -q get rdset.setting.${path}_wpa2eap_radius_accounting_server)				
			[ "${wpa2eap_radius_accounting_server}" != "" ] && uci set wireless.$1.acct_server=${wpa2eap_radius_accounting_server}

			wpa2eap_radius_accounting_port=$(uci -c $ADIR -q get rdset.setting.${path}_wpa2eap_radius_accounting_port)	
			[ "${wpa2eap_radius_accounting_port}" != "" ] && uci set wireless.$1.acct_port=${wpa2eap_radius_accounting_port}

			wpa2eap_radius_accounting_secret=$(uci -c $ADIR -q get rdset.setting.${path}_wpa2eap_radius_accounting_secret)	
			[ "${wpa2eap_radius_accounting_secret}" != "" ] && uci set wireless.$1.acct_secret=${wpa2eap_radius_accounting_secret}

			wpa2eap_nasid=$(uci -c $ADIR -q get rdset.setting.${path}_wpa2eap_nasid)	
			[ "${wpa2eap_nasid}" != "" ] && uci set wireless.$1.nasid=${wpa2eap_nasid} 
		}	

		ssid_mode_fcn(){	
			case ${ssid_mode} in
				1)	uci set wireless.$1.mode=ap
                                        uci set wireless.$1.wds=""
				;;
				2)	uci set wireless.$1.mode=ap
                                        uci set wireless.$1.wds=1
				;;
				3)	uci set wireless.$1.mode=sta
                                        uci set wireless.$1.wds=""
				;;
				4)	uci set wireless.$1.mode=sta
                                        uci set wireless.$1.wds=1
				;;
			esac		
		}	
		
		guard_interval_fcn(){
			case ${ssid_guard_interval} in
				1)	uci set  wireless.$1.shortgi=1	;;
				2)	uci set  wireless.$1.shortgi=0	;;
			esac
		}

		data_rate_fcn(){
			case ${ssid_data_rate} in
				auto)  uci set wireless.$1.manrate=auto ;;
				"6Mbps") uci set wireless.$1.manrate=0x0b0b0b0b ;;
				"9Mbps") uci set wireless.$1.manrate=0x0f0f0f0f  ;;
				"12Mbps") uci set wireless.$1.manrate=0x0a0a0a0a   ;;
				"18Mbps") uci set wireless.$1.manrate=0x0e0e0e0e  ;;
				"24Mbps") uci set wireless.$1.manrate=0x09090909  ;;
				"36Mbps") uci set wireless.$1.manrate=0x0d0d0d0d  ;;
				"48Mbps") uci set wireless.$1.manrate=0x08080808  ;;
				"54Mbps") uci set wireless.$1.manrate=0x0c0c0c0c  ;;
				"MCS0") uci set wireless.$1.manrate=0x80808080  ;;
				"MCS1") uci set wireless.$1.manrate=0x81818181  ;;
				"MCS2") uci set wireless.$1.manrate=0x82828282  ;;
				"MCS3") uci set wireless.$1.manrate=0x83838383  ;;
				"MCS4") uci set wireless.$1.manrate=0x84848484  ;;
				"MCS5") uci set wireless.$1.manrate=0x85858585  ;;
				"MCS6") uci set wireless.$1.manrate=0x86868686  ;;
				"MCS7") uci set wireless.$1.manrate=0x87878787  ;;
				"MCS8") uci set wireless.$1.manrate=0x88888888  ;;
				"MCS9") uci set wireless.$1.manrate=0x89898989  ;;
				"MCS10") uci set wireless.$1.manrate=0x8a8a8a8a  ;;
				"MCS11") uci set wireless.$1.manrate=0x8b8b8b8b  ;;
				"MCS12") uci set wireless.$1.manrate=0x8c8c8c8c  ;;
				"MCS13") uci set wireless.$1.manrate=x8d8d8d8d  ;;
				"MCS14") uci set wireless.$1.manrate=0x8e8e8e8e  ;;
				"MCS15") uci set wireless.$1.manrate=0x8f8f8f8f  ;;
				"MCS16") uci set wireless.$1.manrate=0x90909090  ;;
				"MCS17") uci set wireless.$1.manrate=0x91919191  ;;
				"MCS18") uci set wireless.$1.manrate=0x92929292  ;;
				"MCS19") uci set wireless.$1.manrate=0x93939393  ;;
				"MCS20") uci set wireless.$1.manrate=0x94949494  ;;
				"MCS21") uci set wireless.$1.manrate=0x95959595  ;;
				"MCS22") uci set wireless.$1.manrate=0x96969696  ;;
				"MCS23") uci set wireless.$1.manrate=0x97979797  ;;
			esac	
		}

		hide_ssid_fcn(){
			pathhidessid=$2 
			hide_ssid=$(uci -c $ADIR -q get rdset.setting.${pathhidessid}_hide_ssid)
			[ "${hide_ssid}" != "" ] && {
				case ${hide_ssid} in
					1) uci set wireless.$1.hidden=1 ;;
					0)	uci -q del wireless.$1.hidden	;;
				esac
			}
		}	

		mac_filter_fcn(){
			pathmacfilter=$2
			mac_acl=$(uci -c $ADIR -q get rdset.setting.${pathmacfilter}_mac_acl)
			policy_allow=$(uci -c $ADIR -q get rdset.setting.${pathmacfilter}_policy_allow)
			policy_deny=$(uci -c $ADIR -q get rdset.setting.${pathmacfilter}_policy_deny)
			case ${mac_acl} in
				0)	
				uci -q del wireless.$1.macpolicy 	
				;;
				1)	
				uci set wireless.$1.macpolicy=allow	
				[ "${policy_allow}" == "" ] && uci -q del wireless.$1.maclist
				;;
				2)	
				uci set wireless.$1.macpolicy=deny	
				[ "${policy_deny}" != "" ] &&	uci -q del wireless.$1.maclist
				;;
			esac		
			
			[ "${policy_allow}" != "" ] &&{
				uci -q del wireless.$1.maclist
				echo ${policy_allow} | awk 'BEGIN { RS = "," };{print $0}'  > /tmp/policy_allow
				while read poli ;do
					[ "$poli" != "" ] && uci add_list wireless.$1.maclist=${poli}
				done < /tmp/policy_allow
				rm -rf /tmp/policy_allow
			}
			
			[ "${policy_deny}" != "" ] &&{
				uci -q del wireless.$1.maclist
				#echo ${policy_deny} | sed s/+/" "/  > /tmp/policy_deny
				echo ${policy_deny} | awk 'BEGIN { RS = "," };{print $0}'   > /tmp/policy_deny
				while read poli ;do
					[ "$poli" != "" ] && uci add_list wireless.$1.maclist=${poli}
				done < /tmp/policy_deny
				rm -rf /tmp/policy_deny
			}
		}	

		advanced_settings_ssid_fcn(){
			pathadvacedsettings=$2
			rts_threshold=$(uci -c $ADIR -q get rdset.setting.${pathadvacedsettings}_rts_threshold)
			
                        [ "$(grep -w ${pathadvacedsettings}_rts_threshold /tmp/apply/radio_settings)" != "" ] && uci set wireless.$1.rts=${rts_threshold} 
			
			station_isolation=$(uci -c $ADIR -q get rdset.setting.${pathadvacedsettings}_station_isolation)
			[ "${station_isolation}" != "" ] && {
				case ${station_isolation} in	
					0)		uci -q del wireless.$1.isolate 		;;
					1)		uci 	 set wireless.$1.isolate=1	;;
				esac				
			}
			
			maximum_stations=$(uci -c $ADIR -q get rdset.setting.${pathadvacedsettings}_maximum_stations)
                        [ "$(grep -w ${pathadvacedsettings}_maximum_stations /tmp/apply/radio_settings)" != "" ] && uci set wireless.$1.maxsta=${maximum_stations}
			
			minimum_stations_rssi=$(uci -c $ADIR -q get rdset.setting.${pathadvacedsettings}_minimum_stations_rssi)
                        [ "$(grep -w ${pathadvacedsettings}_minimum_stations_rssi /tmp/apply/radio_settings)" != "" ] && uci set wireless.$1.minrssi=${minimum_stations_rssi}
			
			nac_only=$(uci -c $ADIR -q get rdset.setting.${pathadvacedsettings}_80211n80211ac_only)
			[ "${nac_only}" != "" ] && {
				case ${nac_only} in	
					0)	uci -q del wireless.$1.puren 	;;
					1)	uci -q set wireless.$1.puren=1	;;
				esac
			}	
			
			ht20ht40_coexistence=$(uci -c $ADIR -q get rdset.setting.${pathadvacedsettings}_ht20ht40_coexistence)
			[ "${ht20ht40_coexistence}" != "" ] && { 
				case ${ht20ht40_coexistence} in
					0)	uci -q del wireless.$1.disablecoext	;;
					1)	uci set wireless.$1.disablecoext=0	;;
				esac			
			}
					
			wmm=$(uci -c $ADIR -q get rdset.setting.${pathadvacedsettings}_wmm)	
			[ "${wmm}" != "" ] &&  {
				case ${wmm} in
					0)	uci set wireless.$1.wmm=0	;;
					1)	uci -q del wireless.$1.wmm 	;;
				esac		
			}
		}	

		duplicate_wireless_security_fcn(){
			joane=$1
			mel=$2
			nam=$(uci -q get ${joane}.encryption)
			uci set ${mel}.encryption=$nam

			case $nam in
				none) ;;
				wep-open|wep-shared)
					uci set ${mel}.key=$(uci -q get ${joane}.key)
					for  k in  1 2 3 4 ;do
						uci set ${mel}.key${k}=$(uci -q get ${joane}.key${k})
					done
				;;
				psk*)
					uci set ${mel}.key=$(uci -q get ${joane}.key)
				;;	
				wpa*)	
					uci set ${mel}.eap_type=$(uci -q get ${joane}.eap_type)
					uci set ${mel}.priv_key_pwd=$(uci -q get ${joane}.priv_key_pwd)
					uci set ${mel}.auth_server=$(uci -q get ${joane}.auth_server)
					uci set ${mel}.auth_port=$(uci -q get ${joane}.auth_port)
					uci set ${mel}.auth_secret=$(uci -q get ${joane}.auth_secret)
					uci set ${mel}.acct_server=$(uci -q get ${joane}.acct_server)
					uci set ${mel}.acct_port=$(uci -q get ${joane}.acct_port)
					uci set ${mel}.acct_secret=$(uci -q get ${joane}.acct_secret)
					uci set ${mel}.nasid=$(uci -q get ${joane}.nasid)
				;;
				
			esac	
		}	
		
	#radio_profile
	for wifix  in wifi0 wifi1 ;do
		case $(iwinfo ${wifix} info|grep "HW Mode"|awk '{print $5}') in 
			802.11ac/an|802.11ac/abgn) rdpro=device_ac_radio;;
			802.11an) rdpro=device_5ghz_radio;;
			802.11bgn)  rdpro=device_24ghz_radio;;
			802.11abgn) rdpro=device_524ghz_radio;;
		esac
		echo "${rdpro}  ${wifix}" >> $ADIR/radio_profile_tmp
	done

	mv  $ADIR/radio_profile_tmp $ADIR/radio_profile

	for iinf in device_ac_radio device_5ghz_radio	device_24ghz_radio device_524ghz_radio ;do

		[ "$(grep -wc $iinf  $ADIR/radio_profile)" == "2" ]&&{

			sed  -i "2s/${iinf}/${iinf}2/"    $ADIR/radio_profile

		}		
	done

	#device_***ghz_radio
	radio1=$(uci get apc.setting.StatusSSIDs | awk '{FS=",";print $1}'|awk '{FS="=";print $1}')
	radio2=$(uci get apc.setting.StatusSSIDs|awk '{FS=",";print $2}'|awk '{FS="=";print $1}')


	e=0
	for radiox in $radio1 $radio2;do
		let "e+=1"
		[ "$(grep -w ${radiox}  $ADIR/radio_profile )" != "" ]&&{
			wfx=$(grep -w ${radiox}  $ADIR/radio_profile|awk '{print $2}')
			case $e in
				1) rdxstr=$(uci get apc.setting.StatusSSIDs|awk '{FS=",";print $1}'|awk '{FS="=";print $2}') ;;
				2) rdxstr=$(uci get apc.setting.StatusSSIDs|awk '{FS=",";print $2}'|awk '{FS="=";print $2}') ;;
			esac
				
			#Radio_main
			#Enable/Disable Radio
			radio_enable=$(uci -c $ADIR -q get rdset.setting.${radiox})
			[ "${radio_enable}" != "" ] && {
				case $radio_enable in
				0)		#Disable	
				uci set  wireless.${wfx}.disabled=1
				;;
				1)		#Enable
				uci del  wireless.${wfx}.disabled	
				;;		
		        esac
				uci  commit  wireless
			}
		
			#Enable/Disable MESH
			
			
			

			mesh_enable=$(uci -c $ADIR -q get rdset.setting.${radiox}_mesh_ind)
			[ "${mesh_enable}" != "" ] && {
				case $mesh_enable in
					1)	#Enable	
					#device meshmode
					uci  set  wireless.${wfx}.meshmode=meshap
					[ "$(uci -q get  wireless.${wfx}.channel)" == "auto" ]&&{
						if [ "$(uci -q get  wireless.${wfx}.hwmode | grep ng)" != "" ];then
						  uci -q set  wireless.${wfx}.channel=1
						else
						  uci -q set  wireless.${wfx}.channel=36
						fi
					}
					#mesh1
					genmesh1=$(uci show wireless | grep -w id_ssid=${wfx}_1|awk '{FS=".";OFS=".";print $1,$2}')		
					uci set ${genmesh1}.mode=ap
					uci set ${genmesh1}.ssid=meshid
					uci set ${genmesh1}.wds=1
					uci set ${genmesh1}.network=lan
					#mesh2	
					[ "$(uci show wireless| grep -w id_ssid=${wfx}_2)" == "" ] && {														
						id2=$(uci add wireless wifi-iface)
						uci set wireless.$id2.id_ssid=${wfx}_2
						uci set wireless.$id2.device=$wfx	
						uci commit wireless
					}
					genmesh2=$(uci show wireless | grep -w id_ssid=${wfx}_2|awk '{FS=".";OFS=".";print $1,$2}')
					uci set ${genmesh2}.mode=ap
					uci set ${genmesh2}.ssid=meshid
					uci set ${genmesh2}.wds=1
					uci set ${genmesh2}.encryption=none
					uci set ${genmesh2}.network=lan
					uci set ${genmesh2}.batmanadv=1
					uci set id_ssid.status.${wfx}_2=on ; uci commit id_ssid
					#mesh3	
					[ "$(uci show wireless| grep -w id_ssid=${wfx}_3)" == "" ] && {														
						id3=$(uci add wireless wifi-iface)
						uci set wireless.$id3.id_ssid=${wfx}_3
						uci set wireless.$id3.device=$wfx	
						uci commit wireless
					}
					genmesh3=$(uci show wireless | grep -w id_ssid=${wfx}_3|awk '{FS=".";OFS=".";print $1,$2}')	
					uci set ${genmesh3}.mode=sta
					uci set ${genmesh3}.ssid=meshid
					uci set ${genmesh3}.wds=1
					uci set ${genmesh3}.encryption=none
					uci set ${genmesh3}.network=lan
					uci set id_ssid.status.${wfx}_3=on 
					uci commit id_ssid
					uci commit wireless
			        #Reorder ssid2 & ssid3
			        /lib/faito/reorder_ssid_2n3 ${wfx}
					;;
					
					0) #Disable
					#mesh1
						uci  -q set  wireless.${wfx}.meshmode=""		
					#mesh2	
						ssid_off2=$(uci show wireless | grep -w id_ssid=${wfx}_2|awk '{FS=".";OFS=".";print $1,$2}')
						uci del $ssid_off2
						uci set id_ssid.status.${wfx}_2=na 
						uci commit id_ssid
					#mesh3	
						ssid_off3=$(uci show wireless | grep -w id_ssid=${wfx}_3|awk '{FS=".";OFS=".";print $1,$2}')
						uci del $ssid_off3
						uci set id_ssid.status.${wfx}_3=na 
						uci commit id_ssid	
					;;	
			    esac
				uci  commit  wireless
			}
			#Mesh ID
			genmesh1=$(uci show wireless | grep -w id_ssid=${wfx}_1|awk '{FS=".";OFS=".";print $1,$2}') #after reoder ssid2 &3 genmesh* has changed
			genmesh2=$(uci show wireless | grep -w id_ssid=${wfx}_2|awk '{FS=".";OFS=".";print $1,$2}')
			genmesh3=$(uci show wireless | grep -w id_ssid=${wfx}_3|awk '{FS=".";OFS=".";print $1,$2}')
			genmeshid=$(uci -c $ADIR -q get rdset.setting.${radiox}_ssid1_gen_meshid)

			[ "$genmeshid" != "" ] && {
			  
			  uci set ${genmesh1}.ssid=$genmeshid

			  uci set ${genmesh2}.ssid=$genmeshid

			  [ "$(uci -q get wireless.${wfx}.meshmode)" != "rootaprc" ] && {
				  
				  uci set ${genmesh3}.ssid=$genmeshid
			  }

			  uci commit wireless
			}
			#Mesh Mode
			genmeshmode=$(uci -c $ADIR -q get rdset.setting.${radiox}_ssid1_gen_meshmode)
			[ "$genmeshmode" != "" ]&&{
			
			case $genmeshmode in
			    1)
				uci set  wireless.${wfx}.meshmode=meshap
			    uci set ${genmesh3}.disabled=""
			    uci set ${genmesh3}.ssid=$(uci -q get ${genmesh1}.ssid)
			    ;;
			    2)
				uci set  wireless.${wfx}.meshmode=rootap
			    uci set  ${genmesh3}.disabled=1
			    ;;
			    3)
				uci set  wireless.${wfx}.meshmode=rootaprc
			    uci set ${genmesh3}.disabled=""
			    uci set ${genmesh3}.ssid=clientssid
			    ;;
			esac  
			uci commit wireless
			}

			#Mesh: Essid for RootAP Router Client(Rootaprc)	
			rootaprc_ssid=$(uci -c $ADIR -q get rdset.setting.device_radio_rc_essid)
			[ "$rootaprc_ssid" != "" ]&&{
				uci set ${genmesh3}.ssid=$rootaprc_ssid
				uci commit wireless
			}
			#Mesh:	Wireless Security for Rootaprc
			genmesh3_tmp=$(echo $genmesh3|awk '{FS=".";print $2}')
			wireless_security_fcn $genmesh3_tmp device_radio_rc
			uci commit wireless
			
			#Mesh:	Wireless Security for MeshAP
			genmesh1_tmp=$(echo $genmesh1|awk '{FS=".";print $2}')
			wireless_security_fcn $genmesh1_tmp ${radiox}_ssid1
			[ "$(uci -q get wireless.${wfx}.meshmode)" == "meshap" ]&& duplicate_wireless_security_fcn ${genmesh1} ${genmesh3}
			uci commit wireless

			#radio_profile	
				# 1->802.11ac->11ac80|11ac*
				# 2->802.11a+n->11na
				# 3->802.11g+n->11ng
			radio_profile=$(uci -c $ADIR -q get rdset.setting.${radiox}_profile)	
			[ "$radio_profile" != "" ] && { 
				case $radio_profile in
					1)	uci set  wireless.${wfx}.hwmode=11ac ;;
					2)	uci set  wireless.${wfx}.hwmode=11na ;;
					3)	uci set  wireless.${wfx}.hwmode=11ng ;;
				esac
				uci commit wireless
	        }
			#radio_country_code
			country_code=$(uci -c $ADIR -q get rdset.setting.${radiox}_country_code)
			[ "$country_code" != "" ]&& uci set wireless.${wfx}.country=$country_code
			#radio_channel
				#Auto-->0	
			radio_channel=$(uci -c $ADIR -q get rdset.setting.${radiox}_channel)	
			[ "$radio_channel" != "" ]&& {
				case $radio_channel in
					Auto)
	                    if [ "$(uci -q get  wireless.${wfx}.meshmode)" != "" ];then
	                    	if [ "$(uci -q get  wireless.${wfx}.hwmode | grep ng)" != ""  ];then
	                    		uci -q set  wireless.${wfx}.channel=1
	                    	else
	                    		uci -q set  wireless.${wfx}.channel=36
	                    	fi
	                    else
	                    	uci set  wireless.${wfx}.channel=auto                   
	                    fi
					;;
					*)  uci set  wireless.${wfx}.channel=$radio_channel 	
					;;
				esac
				uci commit wireless		
			}
			
			#radio_spectrum_width
			#option 1 --> 20/40/80 Mhz --> 11xx80
			#option 2 --> 20/40 Mhz		--> 11xx
			#option 3 --> 20Mhz			--> 11xx20
			radio_spectrum_width=$(uci -c $ADIR -q get rdset.setting.${radiox}_spectrum_width)
			[ "$radio_spectrum_width" != "" ] && {
				hwmode=$(uci -q get wireless.${wfx}.hwmode)
				last2=$(echo ${hwmode} | awk '{print substr($0,length($0)-1,2)}')
				case $last2 in
					80|20) hwmode=$(echo ${hwmode} |sed s/..$// )	;;
					*)	;;
				esac
				case $radio_spectrum_width in
					1)	uci set  wireless.${wfx}.hwmode=${hwmode}80 ;;
					2)	uci set  wireless.${wfx}.hwmode=${hwmode}	;;
					3)	uci set  wireless.${wfx}.hwmode=${hwmode}20	;;
					*)	;;
				esac
				uci commit wireless
			}
			#radio_transmit_power	
			radio_transmit_power=$(uci -c $ADIR -q get rdset.setting.${radiox}_transmit_power)
			[ "${radio_transmit_power}" != "" ] && {
				uci set wireless.${wfx}.txpower=${radio_transmit_power}
				uci commit wireless
			}
			
			#radio_auto_ack_timeout
			radio_auto_ack_timeout=$(uci -c $ADIR -q get rdset.setting.${radiox}_auto_ack_timeout)
			[ "${radio_auto_ack_timeout}" != "" ] && {
			case ${radio_auto_ack_timeout} in
				1) 
				uci set wireless.${wfx}.autoack=1
				[ "$(uci show wireless| grep -w  wireless.${wfx}.distance)" != "" ] &&uci -q del  wireless.${wfx}.distance
				;;
				0) 
				[ "$(uci show wireless| grep -w  wireless.${wfx}.autoack=1)" != "" ] && uci del wireless.${wfx}.autoack 
				;;
			esac	
			uci commit wireless			
			}
			#radio_distance
			radio_distance=$(uci -c $ADIR -q get rdset.setting.${radiox}_distance)
                        [ "$(grep -w ${radiox}_distance /tmp/apply/radio_settings)" != "" ] && {
				uci set wireless.${wfx}.distance=${radio_distance}
				uci commit wireless
			}
				
			#SSIDs

				imao=0
				[ "$(uci -q get wireless.${wfx}.meshmode)" != "" ]&&{
					imao=3
					rdxstr=${rdxstr:3}              #ignore the 3 ssids first for Mesh Mode
				}
					
			while test -n "$rdxstr"; do		#Loop 16 times or 13 times in Mesh Mode
				c=${rdxstr:0:1}     # Get the first character
				let "imao+=1"		
				ssidx="ssid${imao}"	
				#Parameters	
				ssidold=$(uci show wireless| grep -w id_ssid=${wfx}_${imao}|awk '{FS="."; print $2}')
				ssid_mode=$(uci -c $ADIR -q get rdset.setting.${radiox}_${ssidx}_mode)
				ssid_essid=$(uci -c $ADIR -q get rdset.setting.${radiox}_${ssidx}_essid)
				ssid_guard_interval=$(uci -c $ADIR -q get rdset.setting.${radiox}_${ssidx}_guard_interval)
				ssid_data_rate=$(uci -c $ADIR -q get rdset.setting.${radiox}_${ssidx}_data_rate)
							 
				#For the newest  ssid
									
				newest_ssid_fcn() {    
					id=$(uci add wireless wifi-iface)
					uci set wireless.$id.network=lan
					uci set wireless.$id.id_ssid=${wfx}_${imao}
					uci set wireless.$id.device=$wfx												

					#mode
					if [  "${ssid_mode}" == "" ] ;then
								uci set wireless.$id.mode=ap
					else
								ssid_mode_fcn $id
					fi		
					
					#essid
					if [ "${ssid_essid}" != "" ] ;then	
						uci set  wireless.$id.ssid=${ssid_essid}	
					else
					    uci set wireless.$id.ssid=Mimo_${wfx}_${imao}													
					fi
					
					#guard_interval	
					if [ "${ssid_guard_interval}" == "" ];then
						uci set wireless.$id.shortgi=1													
					else
						guard_interval_fcn $id
					fi
					
					#ssid_data_rate
					
					if [ "${ssid_data_rate}" == "" ];then
						uci set wireless.$id.manrate=auto
					else
						data_rate_fcn $id
					fi	
					
					#hide_ssid
					hide_ssid_fcn $id ${radiox}_${ssidx}
					
					#wireless_security
					if [ "$(uci -c $ADIR -q get rdset.setting.${radiox}_${ssidx}_wireless_security)" == "" ] ;then
						uci set wireless.$id.encryption=none
					else
						wireless_security_fcn $id ${radiox}_${ssidx}
					fi		
						
					#MAC Filter
					mac_filter_fcn  $id ${radiox}_${ssidx}
					
					#Advanced Settings
					advanced_settings_ssid_fcn $id ${radiox}_${ssidx}
					
					#Enable/Disable ssid
					[ "$1" == "disable" ]&& uci set wireless.$id.disabled=1
					[ "$1" == "enable" ]&& uci -q del wireless.$id.disabled
					
				    uci set id_ssid.status.${wfx}_${imao}=on 
				    uci commit id_ssid
					uci commit wireless
				}
				#For  the old ssid
				old_ssid_fcn() {   
					#mode
					[  "${ssid_mode}" != "" ] && ssid_mode_fcn $ssidold
					
					#essid
					[ "${ssid_essid}" != "" ] && uci set  wireless.$ssidold.ssid=${ssid_essid}	
					
					#guard_interval	
					[ "${ssid_guard_interval}" != "" ] && guard_interval_fcn $ssidold

					#ssid_data_rate
					
					[ "${ssid_data_rate}" != "" ]&& data_rate_fcn $ssidold

					#hide_ssid
					hide_ssid_fcn $ssidold ${radiox}_${ssidx}
					
					#wireless_security
					wireless_security_fcn $ssidold ${radiox}_${ssidx}
						
					#MAC Filter
					mac_filter_fcn  $ssidold ${radiox}_${ssidx}
					
					#Advanced Settings
					advanced_settings_ssid_fcn $ssidold ${radiox}_${ssidx}
					
					#Enable/Disable ssid
					[ "$1" == "disable" ]&& uci set wireless.$ssidold.disabled=1
					[ "$1" == "enable" ]&& uci -q del wireless.$ssidold.disabled
					
					uci commit wireless
				}							
				case $c in 
					#0  --> disabled ssid
					# 1--> enable ssid 
					#2 --> deleted/not available ssid
					
					0)
					[ "$ssidold" == "" ]  || old_ssid_fcn disable
					;;
					1)
					[ "$ssidold" == "" ] && newest_ssid_fcn enable || old_ssid_fcn enable
					;;
					2) 
					ssid_off=$(uci show wireless | grep -w id_ssid=${wfx}_${imao}|awk '{FS=".";OFS=".";print $1,$2}')
					[ "${ssid_off}" != "" ] && {
						if [ "${imao}" == "1" ] ;then    #Disable SSID1 == Disable Radio1
							uci set ${ssid_off}.disabled=1	
							uci commit wireless
						else
							uci del $ssid_off
							uci commit wireless
						fi	
				    uci set id_ssid.status.${wfx}_${imao}=na 
				    uci commit id_ssid
					}
					;;
				esac
				rdxstr=${rdxstr:1}   # trim the first character
			done
		}
	done	
}
radfunc
