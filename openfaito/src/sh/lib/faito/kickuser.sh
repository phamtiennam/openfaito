#!/bin/sh
#FAITO-2015 by NamPham<nampt282@gmail.com>
#Description: kick hotspot user from APc

useriskicked=$(uci -q get apc.setting.KickList)
[ "$useriskicked" == "" ]&& exit 0
echo $useriskicked |tr ',' ' '|awk 'BEGIN { RS = " "  };{print $0}'|sed '/^$/d' > /tmp/list_user_kicked

[ "$(cat /tmp/list_user_kicked)" != "" ]&&{
  while read riga ;do
	chilli_query list > /tmp/chilli_query_list
	while read niga ;do
		[ "$(echo $niga|awk '{print $1}')" == "$riga" -a "$(echo $niga|awk '{print $3}')" == "pass" ]&&{    	
			chilli_query logout mac $riga	
                }        
	done < /tmp/chilli_query_list
  done < /tmp/list_user_kicked
}
uci set apc.setting.hotspotKick=""
uci set apc.setting.KickList=""
uci commit apc

