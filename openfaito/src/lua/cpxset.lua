#!/usr/bin/lua

local sys = require "luci.sys"
local uci = require("luci.model.uci").cursor()

local wifi0
local wifi1
local params = {...}
--params[1] IP address

function string.insert(text, insert)
  lng = string.len(text)/2
  new = 1
  for i=1,lng do
	  twofirst = string.sub(text,1,2)
  	  text = string.sub(text,3)
  	  new = table.concat( {new,twofirst}, insert)
  end
  return string.sub(new,3)	
end

wifi0 = sys.exec("/bin/cat /sys/class/net/wifi0/hwaddr")
--local file_found=io.open("\/sys\/class\/net\/wifi1\/hwaddr", "r")
local file_found=io.open("/sys/class/net/wifi1/hwaddr", "r")
if file_found == nil then
        wifi1 = "NULL"
else
        wifi1 = sys.exec("/bin/cat /sys/class/net/wifi1/hwaddr")
end


mtd1  = sys.exec("hexdump -n 80 -s $((0x2e000)) /dev/mtd0|awk '{OFS=\"\";print $2,$3,$4,$5,$6,$7,$8,$9}'|awk 'BEGIN { ORS = \"\" } { print }'")
mtd2  = sys.exec("hexdump -n 32 -s $((0x1f800)) /dev/mtd0|awk '{OFS=\"\";print $2,$3,$4,$5,$6,$7,$8,$9}'|awk 'BEGIN { ORS = \"\" } { print }'")
a = (80*2 - string.len(mtd1))/2
b = (32*2 - string.len(mtd2))/2
if a ~= 0 then 
	for i=1,a do 
		mtd1 = table.concat( {mtd1,"00"}, "")
	end
end

if b ~= 0 then 
	for i=1,b do 
		mtd2 = table.concat( {mtd2,"00"}, "")
	end
end

mtd1 = string.insert(mtd1,":")
mtd2 = string.insert(mtd2,":")
--print(mtd1)
--print(mtd2)



local apc_snmp_user_name = uci:get("default", "settings", "apc_snmp_user_name")
local apc_snmp_pass1 = uci:get("default", "settings", "apc_snmp_pass1")
local apc_snmp_pass2 = uci:get("default", "settings", "apc_snmp_pass2")
local path_of_apc = "%s/%s" % {uci:get("default", "settings", "apc_path"), uci:get("default", "settings", "apc_name")}
local gatherdata = "mac1=%s&mac2=%s&mtd1=%s&mtd2=%s&%s" %{wifi0, wifi1, mtd1, mtd2, params[2]}

local parasnmp = "%s/checkin/every_1min_checkin.php \"%s\"" %{path_of_apc, gatherdata}

luci.sys.call("/usr/bin/snmpset -t 5  -v3 -u %s -a MD5 -A %s -x DES -X %s -l authPriv %s 1.3.6.1.4.1.426.8.1.20.6.1.1.0 s %q > /dev/null"  %{apc_snmp_user_name, apc_snmp_pass1, apc_snmp_pass2, params[1], parasnmp})
