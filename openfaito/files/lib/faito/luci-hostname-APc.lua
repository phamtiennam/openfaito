#!/usr/bin/lua

--Purpose: collect data about the IP & hostname of clients then send to APc

local function net_assoclist(net)
	local rv = net:assoclist()
	local do_hostname = 0
	local dname = "/tmp/luci-hostname-APc"
	if not nixio.fs.access(dname) then
		nixio.fs.mkdir(dname)
	end
	for k,v in pairs(rv) do
		if not v.deviceid or v.deviceid == "" then
			if v.lastip and v.lastip ~= "" then
				local fname = dname .. "/" .. v.lastip
				if nixio.fs.access(fname) then
					v.deviceid = nixio.fs.readfile(fname)
				else
					nixio.fs.writefile(fname, "")
				end
				do_hostname = 1
			end
                else
                        print(tostring(k),v.lastip,v.deviceid)  --v.deviceid == hostname of mesh AP
		end
	end
		--print(do_hostname)
	if do_hostname then
		luci.sys.call("start-stop-daemon -q -S -b -x /lib/faito/luci-hostname-APc.sh") --get hostname of clients
	end
	return rv
end


local rv = { }
local ntm = require "luci.model.network".init()

local dev
for _, dev in ipairs(ntm:get_wifidevs()) do
	local rd = {
	networks = { }
	}
	                                                                                        
        local net
        for _, net in ipairs(dev:get_wifinets()) do
		rd.networks[#rd.networks+1] = {
		        assoclist  = net_assoclist(net)
		}
		rv[#rv+1] = rd
        end
end
                                                        
                                                                
