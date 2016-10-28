#!/bin/sh
# FAITO - 2014 by NamPham <tn_pham@compex.com.sg>

#path_of_apc="$(uci get default.settings.apc_path)/$(uci get default.settings.apc_name)"
#apc_snmp_user_name=$(uci get default.settings.apc_snmp_user_name)
#apc_snmp_pass1=$(uci get default.settings.apc_snmp_pass1)
#apc_snmp_pass2=$(uci get default.settings.apc_snmp_pass2)

#Prepare
iwconfig |awk '/Master/{split(h,tmp," ");print tmp[1]};{h=$0}' > /tmp/list_ath_master


while read niga ; do
	iwinfo $niga l  >> /tmp/user_list_tmp
done < /tmp/list_ath_master

sed -i "/@/d" /tmp/user_list_tmp
sed -i "/No information available/d" /tmp/user_list_tmp
sed -i "/mac;ifname;signal;noise;snr;inactive;rx;txccq;signalchains;tx/d" /tmp/user_list_tmp
sort -u  < /tmp/user_list_tmp > /tmp/user_list
rm -rf /tmp/user_list_tmp

awk '{FS=";";print $1,$2}' /tmp/user_list > /tmp/user_mac_current


[ ! -f /tmp/user_mac_last ] && touch /tmp/user_mac_last

diff /tmp/user_mac_last  /tmp/user_mac_current |awk "/\+/"'{if (NR > 3) b=gensub(/\+/,"","g",$0);if (b != "") print b}' > /tmp/user_mac_new
diff /tmp/user_mac_last  /tmp/user_mac_current |awk "/\-/"'{if (NR > 3) b=gensub(/\-/,"","g",$0);if (b != "") print b}' > /tmp/user_mac_gone


#update status of user

[ "$(cat /tmp/user_mac_new )" != "" ] && {
                /usr/bin/lua  /lib/faito/luci-hostname-APc.lua > /tmp/meshAP
                device_mac_address=$(ifconfig wifi0|awk /HWaddr/'{split($5,x,"-");OFS=":";print x[1],x[2],x[3],x[4],x[5],x[6]}')
		check_type=1								#1:checkin,0 checkout
                apc_host=$(uci get default.settings.l2tpserver)
                [ -f /etc/vap2ath  ]||  /sbin/vap2ath.sh
		while read nigu ; do
			nigu_mac=$(echo $nigu|awk '{print $1}')
			nigu_ath=$(echo $nigu|awk '{print $2}')
			a=$(awk /$nigu_mac/ /tmp/user_list |head -1)
                        vap_name=$(awk "/$nigu_ath/"'{gsub(/wifi/,"VAP");print $1}' /etc/vap2ath)

			local __a=$(echo ${nigu_mac}|tr [A-Z] [a-z])
			local __ip=$(ip neigh |awk "/$__a/"'{print $1}')

			if [ -f /tmp/luci-hostname-APc/${__ip} ]
			then
			  local __host_name=$(cat /tmp/luci-hostname-APc/${__ip})
			else
			  local __tmp=$(awk "/${nigu}/"'{i++;x[i]=$0} END {print x[1]}' /tmp/meshAP)
			  __ip=$(echo $__tmp| awk '{print $2}')
			  __host_name=$(echo $__tmp| awk '{print $3}')
			fi
			[[ $__ip ]]|| __ip="__"
			[[ $__host_name ]]|| __host_name="__"

                        local __signal=$(echo $a|awk '{FS=";";split($3,y," ");OFS="";print y[1],y[2]}')
			[[ $__signal ]]|| __signal="__"

                        local __signal_chains=$(echo $a|awk '{FS=";";print $9}')
			[[ $__signal_chains ]]|| __signal_chains="__"

                        local __rx_rate=$(echo $a|awk '{FS=";";split($7,y," ");OFS="";print y[1],y[2]}')
			[[ $__rx_rate ]]|| __rx_rate="__"

                        local __tx_rate=$(echo $a|awk '{FS=";";split($10,y," ");OFS="";print y[1],y[2]}')
			[[ $__tx_rate ]]|| __tx_rate="__"

			update="vap_name=${vap_name}&station_flag=${check_type}&device_mac_address=${device_mac_address}&\
station_host=${__host_name}&station_ip=${__ip}&station_mac=${nigu_mac}&station_signal=${__signal}&station_signal_chains=${__signal_chains}&\
station_tx_rate=${__tx_rate}&station_rx_rate=${__rx_rate}"
			echo $update > /tmp/update/user_checkin
			
                        /usr/bin/lua /sbin/station $apc_host "$update"
				
		done < /tmp/user_mac_new
}

[ "$(cat /tmp/user_mac_gone )" != "" ] && {
		#device_mac_address=$(ifconfig wifi0 | grep HWaddr | awk '{print $5}'| awk '{FS="-";OFS=":";print $1,$2,$3,$4,$5,$6}')
                device_mac_address=$(ifconfig wifi0|awk /HWaddr/'{split($5,x,"-");OFS=":";print x[1],x[2],x[3],x[4],x[5],x[6]}')
                check_type=0								#1:checkin,0 checkout
                apc_host=$(uci get default.settings.l2tpserver)
                [ -f /etc/vap2ath  ]|| /sbin/vap2ath.sh
		while read nigu ; do
			nigu_mac=$(echo $nigu|awk '{print $1}')
			nigu_ath=$(echo $nigu|awk '{print $2}')
                        vap_name=$(awk "/$nigu_ath/"'{gsub(/wifi/,"VAP");print $1}' /etc/vap2ath)
			update="vap_name=${vap_name}&station_flag=${check_type}&device_mac_address=${device_mac_address}&station_mac=${nigu_mac}"
			echo $update > /tmp/update/user_check_out
                        /usr/bin/lua /sbin/station $apc_host "$update"
		done < /tmp/user_mac_gone
}
cp -f /tmp/user_mac_current /tmp/user_mac_last
