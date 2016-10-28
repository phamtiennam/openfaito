#!/bin/sh
echo $DNSQ

[ "$(ls -A /tmp/luci-hostname-APc)" ] || exit 0

dnsip="$(cat /tmp/resolv.conf.auto | awk '/nameserver/ {print $2}')"
gatewayip="$(ip route | awk '/default/ {print $3}')"
ipdup=0
for dns in $dnsip; do
	[ "$dns" = "$gatewayip" ] && ipdup=1
done
[ "$ipdup" -eq 0 ] && dnsip="$dnsip $gatewayip"
QIFNAME=br-lan
lanip="$(ip addr show dev $QIFNAME | awk '/inet/ {print $2}')"
lanmask="$(echo -n $lanip | awk -F '/' '{print $2}')"
lannet="$(ipcalc.sh $lanip | grep NETWORK)"
seldns=
firstdns=
for dns in $dnsip; do
	if [ "$(ipcalc.sh $dns/$lanmask | grep NETWORK)" = "$lannet" ]; then
		[ -n "$firstdns" ] || firstdns=$dns
		hname=$(cpxhostname -d -s $dns -i $QIFNAME $dns | awk "/$dns/"'{print $2}')
		[ -n "$hname" ] && {
			seldns=$dns
			break
		}
	fi
done
[ -n "$seldns" ] || seldns=$firstdns
DNSQ=
[ -n "$seldns" ] && DNSQ="-s $seldns"


#NPH

for ipf in /tmp/luci-hostname-APc/*; do
	ip=${ipf##*/}
	res=0
	hname=$(cpxhostname $DNSQ -i $QIFNAME $ip | awk "/$ip/"'{print $2}')
	[ -n "$hname" ] && res=1
	[ $res -eq 0 ] && hname=$(snmpget -v 1 -c public -Ln -Ovq -r 1 -t 2 $ip 1.3.6.1.2.1.1.5.0) && res=1
	if [ $res -eq 1 ]; then
		hname="${hname#\"}"; hname="${hname%\"}"
		echo -n $hname > $ipf
	else
		rm -f $ipf
	fi
done
