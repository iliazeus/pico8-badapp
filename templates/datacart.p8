pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
--bad apple data cart

--[[data]]--

v = peek(0x8000)
k = peek(0x8001)
p = peek2(0x8002)
if (p == 0) p = 0x8010

for i = 1, #data do
	local c = ord(data[i])
	if 97<=c and c<=122 then
		c -= 97
	elseif 50<=c and c<=55 then
		c -= 24
	end
	v = (v << 5) | c
	k += 5
	if k >= 8 then
		k -= 8
		poke(p, (v&(0xff<<k))>>k)
		v = v & ~(0xff<<k)
		p += 1
	end
end

v = v << (8 - k)
poke(0x8000, v)
poke(0x8001, k)
poke2(0x8002, p)

extcmd("breadcrumb")