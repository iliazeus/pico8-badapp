pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
--bad apple, but it's 1.5 fps
--in 64x64 resolution

--[[data]]--

stage = peek(0x8004)
if stage == 0 then
	poke2(0x8002, 0x8010)
end
for i = 1, #datacarts do
	if stage == i-1 then
		poke(0x8004, i)
		load(datacarts[i], "back")
	end
end

v = peek(0x8000)
k = peek(0x8001)
p = peek2(0x8002)

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

if outp > 0 then
	v = (v << outp) | outc
	k += outp
	if k >= 8 then
		k -= 8
		poke(p, (v&(0xff<<k))>>k)
		v = v & ~(0xff<<k)
		p += 1
	end
end

if k > 0 then
	v = v << (8 - k)
	poke(p, v)
	p += 1
end

printh(tostr(p, true))

n = p
p = 0x8010
k = 7

function next_bit()
	if p == n then
		return 0
	end
	local b = peek(p)
	b = (b & (1<<k)) >> k
	if k > 0 then
		k -= 1
	else
		k = 7; p += 1
	end
	return b
end

function draw_frame()
	local ch = {2,0,1}

	function rec(x0,y0,n,d)
		local c
		if d >= maxdepth then
			c = next_bit()
		elseif next_bit() == 0 then
			c = ch[1]
		elseif next_bit() == 0 then
			c = ch[2]
			ch[2] = ch[1]; ch[1] = c
		else
			c = ch[3]
			ch[3] = ch[2]; ch[2] = ch[1]; ch[1] = c
		end

		if c < 2 then
			color(c == 1 and 7 or 0)
			rectfill(x0,y0,x0+n-1,y0+n-1)
			if debug and n>=4 then
				rect(x0,y0,x0+n-1,y0+n-1,11)
			end
		else
			rec(x0,y0,n/2,d+1)
			rec(x0+n/2,y0,n/2,d+1)
			rec(x0,y0+n/2,n/2,d+1)
			rec(x0+n/2,y0+n/2,n/2,d+1)
		end
	end
	
	cls()
	rec(0,-16,128,0)
end
-->8
debug = false
timer = 0

function _init()
	cls()
end

function _update()
	if 0x5e00<=p and p<=0x7fff then
		return
	end
	if btnp(4) then
		printh(tostr(p, true))
	end
	if btnp(5) then
		debug = not debug
	end
	if (not btn(0)) timer += 1
	if (btn(1)) timer = framestep
	while timer >= framestep do
		timer -= framestep
		draw_frame()
	end
end

__label__
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777700000007777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777700000000000777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777770000000000000077777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777000000000000000077777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777770000000000000000077777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777700000000000077777000000000000000000000077777777777777777777777777777777777777777777
77777777777777777777777777777777777777777700000000000000007700000000000000000000000077777777777777777777777777777777777777777777
77777777777777777777777777777777777777777000000000000000000000000000000000000000000007777777777777777777777777777777777777777777
77777777777777777777777777777777777777770000000000000000000000000000000000000000000077777777777777777777777777777777777777777777
77777777777777777777777777777777777777770000000000000000000000000000000000000000000007777777777777777777777777777777777777777777
77777777777777777777777777777777777777777000000000000000000000000000000000000000000007777777777777777777777777777777777777777777
77777777777777777777777777777777777777777000000000000000000000000000000000000000000007777777777777777777777777777777777777777777
77777777777777777777777777777777777777777700000000000000000000000000000000000000000007777777777777777777777777777777777777777777
77777777777777777777777777777777777777777700000000000000000000000000000000000000000007777777777777777777777777777777777777777777
77777777777777777777777777777777777777777770000000000000000000000000000000000000000007777777777777777777777777777777777777777777
77777777777777777777777777777777777777777770000000000000000000000000000000000000000077777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777000000000000000000000000000000000000000077777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777000000000000000000000000000000000007000077777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777700000000000000000000000000000000000777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777700000000000000000000000000000000000777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777770000000000000000000000000000000000077777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777000000000000000000000000000000000007777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777700000000000000000000000000000000000777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777700000000000000000000000000000000000077777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777700000000000000000000000000000000000077777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777700000000000000000000000000000000000077777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777770000000000000000000000000000000000777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777770000000000000000000000000000000777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777000000000000000000000000000000777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777000000000000000000000000000000777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777000000000000000000000000000000777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777000000000000000000000000000000777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777000000000000000000000000000000777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777000000000000000000000000000000777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777000000000000000000000000000000777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777000000000000000000000000000000777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777000000000000000000000000000007777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777770000000000000000000000000000007777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777770000000000000000000000000000007777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777770000000000000000000000000000007777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777770000000007000000000000000000007777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777770000000000000000000000000000077777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777770000000000000000000000000000777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777770000000000000000000000000000007777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777770000000000000000000000000000000777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777700000000000000000000000000000000077777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777700000000000000000000000000000000007777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777000000000000000000000000000000000000777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777770000000000000000000000000000000000000777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777700000000000000000000000000000000000000777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777700000000000000000000000000000000000000077777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777000000000000000000000000000000000000000077777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777000000000000000000000000000000000000000077777777777777777777777777777777777777777777
77777777777777777777777777777777777777777770000000000000000000000000000000000000000077777777777777777777777777777777777777777777
77777777777777777777777777777777777777777700000000000000000000000000000000000000000077777777777777777777777777777777777777777777
77777777777777777777777777777777777777777700000000000000000000000000000000000000000007777777777777777777777777777777777777777777
77777777777777777777777777777777777777777000000000000000000000000000000000000000000007777777777777777777777777777777777777777777
77777777777777777777777777777777777777777000000000000000000000000000000000000000000007777777777777777777777777777777777777777777
77777777777777777777777777777777777777770000000000000000000000000000000000000000000000000777777777777777777777777777777777777777
77777777777777777777777777777777777777770000000000000000000000000000000000000000000000000777777777777777777777777777777777777777
77777777777777777777777777777777777777700000000000000000000000000000000000000000000000000777777777777777777777777777777777777777
77777777777777777777777777777777777777700000000000000000000000000000000000000000000000007777777777777777777777777777777777777777
77777777777777777777777777777777777777700000000000000000000000000000000000000000000000007777777777777777777777777777777777777777
77777777777777777777777777777777777777000000700000000000000000000000000000000000000000007777777777777777777777777777777777777777
77777777777777777777777777777777777777000000770000000000000000000000000000000000000000000777777777777777777777777777777777777777
77777777777777777777777777777777777777000007770000000000000000000000000000000000000000000777777777777777777777777777777777777777
77777777777777777777777777777777777777000007770000000000000000000000000000000000000000000777777777777777777777777777777777777777
77777777777777777777777777777777777770000007700000000007000000000000000000000000000000000077777777777777777777777777777777777777
77777777777777777777777777777777777770000007700000000007000000000000000000000000000000000077777777777777777777777777777777777777
77777777777777777777777777777777777770000077700000000007700000000000000000000000000000000077777777777777777777777777777777777777
77777777777777777777777777777777777770000077700000000007700000000000000000000000000000000007777777777777777777777777777777777777
77777777777777777777777777777777777770000077700000000007700000000000000000000000000000000007777777777777777777777777777777777777
77777777777777777777777777777777777700000077700000000007700000000000000000000000000000000007777777777777777777777777777777777777
77777777777777777777777777777777777700000077000000000007700000000000000000000000000000000000777777777777777777777777777777777777
77777777777777777777777777777777777700000077000000000007700000000000000000000000000000000000777777777777777777777777777777777777
77777777777777777777777777777777777700000070000000000007700000000000000000000000000000000000077777777777777777777777777777777777
77777777777777777777777777777777777700000070000000000007700000000000000000000000000000000000077777777777777777777777777777777777
77777777777777777777777777777777777700000000000000000007700000000000000000000000000000000000007777777777777777777777777777777777
77777777777777777777777777777777777700000000000000000007700000000000000000000000000000000000007777777777777777777777777777777777
77777777777777777777777777777777777700000000000000000007700000000000000000000000000000000000007777777777777777777777777777777777
77777777777777777777777777777777777700000000000000000007700000000000000000000000000000000000000777777777777777777777777777777777
77777777777777777777777777777777777700000000000000000007700000000000000000000000000000000000000777777777777777777777777777777777
77777777777777777777777777777777777700000000000000000007700000000000000000000000000000000000000077777777777777777777777777777777
77777777777777777777777777777777777700000000000000000077700000000000000000000000000000000000000077777777777777777777777777777777
77777777777777777777777777777777777700000000000000000077700000000000000000000000000000000000000007777777777777777777777777777777
77777777777777777777777777777777777700000000000000000077700000000000000000000000000000000000000007777777777777777777777777777777
77777777777777777777777777777777777700000000000000000077700000000000000000000000000000000000000000777777777777777777777777777777
77777777777777777777777777777777777700000000000000000077000000000000000000000000000000000000000000777777777777777777777777777777
77777777777777777777777777777777777700000000000000000077000000000000000000000000000000000000000000077777777777777777777777777777
77777777777777777777777777777777777700000000000000000077000000000000000000000000000000000000000000077777777777777777777777777777
77777777777777777777777777777777777700000000000000000770000000000000000000000000000000000000000000077777777777777777777777777777
77777777777777777777777777777777777770000000000000000770000000000000000000000000000000000000000000777777777777777777777777777777
77777777777777777777777777777777777777000000000000000770000000000000000000000000000000000000000000777777777777777777777777777777
77777777777777777777777777777777777770000000000000000700000000000000000000000000000000000000000000777777777777777777777777777777
77777777777777777777777777777777777770000000000000007700000000000000000000000000000000000000000000777777777777777777777777777777
77777777777777777777777777777777777770000000000000007700000000000000000000000000000000000000000000777777777777777777777777777777
77777777777777777777777777777777777770000000000000007700000000000000000000000000000000000000000007777777777777777777777777777777
77777777777777777777777777777777777770000000000000007000000000000000000000000000000000000000000007777777777777777777777777777777
77777777777777777777777777777777777770000000000000077000000000000000000000000000000000000000000007777777777777777777777777777777
77777777777777777777777777777777777770000000000000077000000000000000000000000000000000000000000007777777777777777777777777777777
77777777777777777777777777777777777770000000000000077000000000000000000000000000000000000000000007777777777777777777777777777777
77777777777777777777777777777777777777000000000000770000000000000000000000000000000000000000000007777777777777777777777777777777
77777777777777777777777777777777777777700000000000770000000000000000000000000000000000000000000007777777777777777777777777777777
77777777777777777777777777777777777777000000000007770000000000000000000000000000000000000000000077777777777777777777777777777777
77777777777777777777777777777777777777000000000007700000000000000000000000000000000000000000000777777777777777777777777777777777
77777777777777777777777777777777777777000000000077700000000000000000000000000000000000000000000777777777777777777777777777777777
77777777777777777777777777777777777777000000000077000000000000000000000000000000000000000000000777777777777777777777777777777777
77777777777777777777777777777777777770000000000777000000000000000000000000000000000000000000000777777777777777777777777777777777
77777777777777777777777777777777777770000000000770000000000000000000000000000000000000000000007777777777777777777777777777777777
77777777777777777777777777777777777770000000007770000000000000000000000000000000000000000000007777777777777777777777777777777777
77777777777777777777777777777777777770000000077700000000000000000000000000000000000000000000007777777777777777777777777777777777
77777777777777777777777777777777777770000000077700000000000000000000000000000000000000000000077777777777777777777777777777777777
77777777777777777777777777777777777770000000777000000000000000000000000000000000000000000000077777777777777777777777777777777777
77777777777777777777777777777777777770000007777000000000000000000000000000000000000000000000077777777777777777777777777777777777
77777777777777777777777777777777777770000007770000000000000000000000000000000000000000000000007777777777777777777777777777777777
77777777777777777777777777777777777770000077770000000000000000000000000000000000000000000000007777777777777777777777777777777777
77777777777777777777777777777777777777000777700000000000000000000000000000000000000000000000007777777777777777777777777777777777
77777777777777777777777777777777777777700777700000000000000000000000000000000000000000000000007777777777777777777777777777777777
77777777777777777777777777777777777777770777000000000000000000000000000000000000000000000000000777777777777777777777777777777777
77777777777777777777777777777777777777777777000000000000000000000000000000000000000000000000000777777777777777777777777777777777
77777777777777777777777777777777777777777770000000000000000000000000000000000000000000000000000777777777777777777777777777777777
77777777777777777777777777777777777777777770000000000000000000000000000000000000000000000000000777777777777777777777777777777777