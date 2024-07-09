pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
--bad apple, but it's 1.5 fps
--in 64x64 resolution

datacarts = {
--[[
--64x64; maxdepth=6; framestep=20
	"#iliazeus_badapple_but-6",
	"#iliazeus_badapple_but-7",
	"#iliazeus_badapple_but-8",
]]--
--dev builds
	"./build/datacart-qtree-b32ent-1.p8",
	"./build/datacart-qtree-b32ent-2.p8",
	"./build/datacart-qtree-b32ent-3.p8",
}

stage = peek(0x8004)
for i = 1, #datacarts do
	if stage == i-1 then
		poke(0x8004, i)
		load(datacarts[i], "back")
	end
end

p = 0x8010
n = peek2(0x8002)
k = 7
k5 = 0

printh(n - p)

function next_bit()
	if p >= n then
		return 0
	end
	local b = peek(p)
	b = (b & (1<<k)) >> k
	if k > 0 then
		k -= 1
	else
		k = 7; p += 1
	end
	k5 += 1
	if (k5 == 5) k5 = 0
	return b
end

function draw_frame()
	local c = 7

	function rec(x0,y0,n,d)
		local l = false
		if d >= maxdepth then
			l = true
			c = next_bit()==0 and 0 or 7
		elseif next_bit() == 0 then
			l = true
		elseif next_bit() == 0 then
			l = true
			if c==7 then c=0 else c=7 end
		else
			l = false
		end

		if l then
			rectfill(x0,y0,x0+n-1,y0+n-1,c)
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
	rec(0,0,128,0)
end
-->8
debug = false
maxdepth = 6
framestep = 20
timer = 0

function _init()
	cls()
end

function _update()
	if (p >= n) return
	if btnp(4) or btnp(5) then
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
