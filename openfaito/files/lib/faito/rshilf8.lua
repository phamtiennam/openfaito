#!/usr/bin/lua
--NamPham,03/26/2014
--Pass arguments to Lua file


local wa = require "luci.tools.webadmin"
require "nixio"
local bit  = nixio.bit
local value = {...}
local chainmask = bit.band(bit.rshift(value[1], 8),0xf)
print ('%q' %chainmask)
