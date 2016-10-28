#/bin/sh
#FAITO-2015,NamPham <nampt282@gmail.com>
# Look-up table for APcSSIDs and athx

echo "" > /tmp/vap2ath_

[ "$(uci -q get wireless.wifi0.disabled)" == "1"  ]||{
    uci show wireless | grep id_ssid=wifi0 > /tmp/vap2ath_
}
  
[ "$(uci -q get wireless.wifi1.disabled)" == "1"  ]||{
  uci show wireless | grep id_ssid=wifi1 >> /tmp/vap2ath_
}
i=0
while read riga ; do
 [ "$riga" != "" ]&&{
    b=$(echo $riga|awk '{FS=".";OFS=".";print $1,$2}')

    [ "$(uci -q get ${b}.disabled)" != "1" ]&&{
      wifix_y=$(echo $riga|awk '{FS="=";print $2}')
      echo "$wifix_y ath${i}" >> /tmp/vap2ath_tmp
      let "i+=1"
    }

 }
done < /tmp/vap2ath_

mv /tmp/vap2ath_tmp /etc/vap2ath
# PHUOC TRAN VAN added vlan generating SSID List for the selectbox WIFI Bridge
cpxvlan --app=get-wifi-ssid
uci set apc.setting.wifi_updown=0
uci commit apc
