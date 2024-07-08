pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
--bad apple playcart

if stat(6) == "" then
	print("no data cart specified")
	stop()
end

n = tonum(stat(6))
if n == nil then
	load(stat(6))
end

p = 0x8000
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

function flush5()
	while k5 != 0 do
		next_bit()
	end
end

function draw_frame()
	local c = 7
	function rec(x0,y0,n,d)
		if d >= maxdepth then
			if next_bit() == 0 then
				c = 0
			else
				c = 7
			end
			rectfill(x0,y0,x0+n-1,y0+n-1,c)
			--debug wireframe
			--if n >= 4 then
			--	rect(x0,y0,x0+n-1,y0+n-1,11)
			--end
		elseif next_bit() == 0 then
			rectfill(x0,y0,x0+n-1,y0+n-1,c)
			--debug wireframe
			--if n >= 4 then
			--	rect(x0,y0,x0+n-1,y0+n-1,11)
			--end
		elseif next_bit() == 0 then
			if c==7 then c=0 else c=7 end
			rectfill(x0,y0,x0+n-1,y0+n-1,c)
			--debug wireframe
			--if n >= 4 then
			--	rect(x0,y0,x0+n-1,y0+n-1,11)
			--end
		else
			rec(x0,y0,n/2,d+1)
			rec(x0+n/2,y0,n/2,d+1)
			rec(x0,y0+n/2,n/2,d+1)
			rec(x0+n/2,y0+n/2,n/2,d+1)
		end
	end
	
	cls()
	rec(0,0,128,0)
	flush5()
end
-->8
maxdepth = 7
framestep = 35
timer = 0

function _init()
	cls()
end

function _update()
	if (p >= n) return
	timer += 1
	--if (btnp(1)) timer += framestep
	while timer >= framestep do
		timer -= framestep
		draw_frame()
	end
end

__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
