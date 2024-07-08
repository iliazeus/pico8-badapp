pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
--bad apple data cart

--[[data]]--

v = 0
k = 0

p = stat(6)
if p != "" then
	p = tonum(p)
	v = peek(p)
	k = peek(p+1)
else
	p = 0x8000
end

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
poke(p, v)
poke(p+1, k)

load(nextcart, nil, tostr(p))
