pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
--init

function _init()
 map_s = 0 --set randomly when game starts
	last1 = false
	last2 = false
 b_sp = 50 --bullet speed
 ptime = time() --prev time
 dt = 0 --time diff betw now and ptime
 boom = {}
 boomt = 0
 boom_s = {11,10,9,8,12}
  --player 1, red tank--
 p1 = {}
 p1.s = 1 --sprite
 p1.xs = 64
 p1.ys = 16
 p1.xe = 64
 p1.ye = 128
 p1.hp = 10
 p1.theta = .25
 p1.b = {} --all shot bullets
 p1.b_s = 5 --bullet sprite
 p1.muzzlex = p1.xs --base of muzzle
 p1.muzzley = p1.ys
 --p1.angle = straight
 
  --player 2, blue tank--
 p2 = {}
 p2.s = 3 --sprite
 p2.xs = 64
 p2.ys = 112
 p2.xe = 0
 p2.ye = 0
 p2.hp = 10
 p2.theta = .25
 p2.b = {} --all shot bullets
 p2.b_s = 6 --bullet sprite
 p2.muzzlex = p2.xs --base of muzzle
 p2.muzzley = p2.ys+8
 --p2.angle = straight
end

-->8
--custom functions

function tan(x)
	return sin(x)/cos(x)
end

--find a valid bullet
function valid_b(player)
 local k = -1
 for i=1,#player.b do
  if player.b[i].y<0 
  or player.b[i].y>128 then
   k = i
   break
  end
 end
 
 if k==-1 and #player.b < 45 then
  k=#player.b+1
 end
  
 return k
end

function invalid_b()
 sfx(1) 
end

--shoot a bullet
function shoot(player)
 local k = valid_b(player)
 if(k==-1) then
  invalid_b()
 else
  sfx(0)
  player.b[k] = {}
  player.b[k].yv = -b_sp*dt*sin(player.theta)
  player.b[k].xv = b_sp*dt*cos(player.theta)
  player.b[k].x 
  	= player.muzzlex
  player.b[k].y 
  	= player.muzzley
  player.b[k].x2 
  	= player.b[k].x + 3
  player.b[k].y2 
  	= player.b[k].y + 3
 end
end

--move bullets
function move_b()
 dt = time() - ptime
 for i=1,#p1.b do
  if p1.b[i].y > 128 then
   p1.b[i].y = 128
  else
   p1.b[i].y += p1.b[i].yv
  end
  
  if p1.b[i].x < 0 then
  	p1.b[i].xv = -p1.b[i].xv
  end
  if p1.b[i].x > 128 then
  	p1.b[i].xv = -p1.b[i].xv
  end
  p1.b[i].x += p1.b[i].xv
  
  p1.b[i].x2 = p1.b[i].x+3
  p1.b[i].y2 = p1.b[i].y+3
 end
 
 
 for i=1,#p2.b do
  if p2.b[i].y < 0 then
   p2.b[i].y =- 8
  else
   p2.b[i].y -= p2.b[i].yv
  end
  
  if p2.b[i].x < 0 then
  	p2.b[i].xv = -p2.b[i].xv
  end
  if p2.b[i].x > 128 then
  	p2.b[i].xv = -p2.b[i].xv
  end
  p2.b[i].x += p2.b[i].xv
  
  
  p2.b[i].x2 = p2.b[i].x+3
  p2.b[i].y2 = p2.b[i].y+3
 end
 
 
end

--display bulelts
function show_b()
 for i=1,#p1.b do
  spr(p1.b_s,
  p1.b[i].x,p1.b[i].y)
 end
 for i=1,#p2.b do
  spr(p2.b_s,
  p2.b[i].x,p2.b[i].y)
 end
end

--detect bullet hit bullet collisions
function hit_bullet()
 local c1 = {}
 local c2 = {}
 
 for i=1,#p1.b do
  local x = p1.b[i].x
  local y = p1.b[i].y
  local x2 = p1.b[i].x2
  local y2 = p1.b[i].y2
  
  for j=1,#p2.b do
   local a = p2.b[j].x
   local b = p2.b[j].y
   local a2 = p2.b[j].x2
   local b2 = p2.b[j].y2

   --bullet hit bullet
   if(
    x>=a and x<=a2 
    	and y>=b and y<=b2 or
    x>=a and x<=a2 
    	and y2>=b and y2<=b2 or
    x2>=a and x2<=a2 
    	and y>=b and y<=b2 or
    x2>=a and x2<=a2 
    	and y2>=b and y2<=b2)
   then
    add(c1,i)
    add(c2,j)
    sfx(2)
   end
  end
 end
 
 return {c1,c2}
end

--react to bullet hit bullet collisions
function react_bhit(coll)
 local c1 = coll[1]
 local c2 = coll[2]
 local b = #boom+1
 
 for i=1,#c1 do
  local k = c1[i]
  boom[b] = {} --start explosion
  boom[b].t = time()
  boom[b].s = 1
  boom[b].x = p1.b[k].x
  boom[b].y = p1.b[k].y-1
  b += 1
  p1.b[k].y = 128 --make bullet invalid
 end
 
 for i=1,#c2 do
  local k = c2[i]
  boom[b] = {} --start explosion
  boom[b].t = time()
  boom[b].s = 1
  boom[b].x = p2.b[k].x
  boom[b].y = p2.b[k].y
  b += 1
  p2.b[k].y = -8 --make bullet invalid
 end
end

--detect bullet hit tank collisions
function hit_tank()
 --collision box for p1
 local lx1=p1.xs-7
 local ly1=p1.ys-16
 local rx1=p1.xs+8
 local ry1=p1.ys-2
 
 --collision box for p2
 local lx2=p2.xs-7
 local ly2=p2.ys+1
 local rx2=p2.xs+8
 local ry2=p2.ys+15
 
 --p2 bullet hit p1 tank
 --a and b = p2 bullets
 for i=1,#p2.b do
  local a = p2.b[i].x
  local b = p2.b[i].y
  local a2 = p2.b[i].x2
  local b2 = p2.b[i].y2
  
  if(
     a>=lx1 and a<=rx1 and
     b>=ly1 and b<=ry1 or
     a2>=lx1 and a2<=rx1 and
     b>=ly1 and b<=ry1
    )
  then
   p2.b[i].y = -8
   p1.hp -= 1
  end
 end
 
  --p1 bullet hit p2 tank
 --x and y = p1 bullets
 for i=1,#p1.b do
  local x = p1.b[i].x
  local y = p1.b[i].y
  local x2 = p1.b[i].x2
  local y2 = p1.b[i].y2
  
  if(
     x>=lx2 and x<=rx2 and
     y>=ly2 and y<=ry2 or
     x2>=lx2 and x2<=rx2 and
     y>=ly2 and y<=ry2
    )
  then
   p1.b[i].y = 128
   p2.hp -= 1
  end
 end
end

--draw explosions
function explode()
 for i=1,#boom do
  local k = boom[i].s
  spr(boom_s[k],boom[i].x,boom[i].y)
  if time()-boom[i].t > 0.1 and
     k < #boom_s
  then
   boom[i].t = time()
   boom[i].s = k+1
   i += 1
  end
--[[  if time()-boom[i].t > 0.5 and
     k == #boom_s
  then
   boom[i].done = true
  end--]]
 end
end
-->8
--update and draw functions

function _update60()
 dt = time() - ptime
 
  --player 1 movement
 if btn(0,0) then --left
  if p1.xs < 8 then xs = 7
		else
			p1.xs -= .75
			p1.xe -= .75
		end
 end

 if btn(1,0) then --right
  if p1.xs > 119 
		then p1.xs = 120
		else
			p1.xs += .75
			p1.xe += .75
		end
 end
 
 if btn(2,0) then
 	if p1.theta > .496 then
			p1.theta = .497
		else
			p1.theta += .003
		end 
 end
 
 if btn(3,0) then
 	if p1.theta < .004 then
			p1.theta = .003
		else
			p1.theta -= .003
		end
 end
 
 if p1.theta==.25 
	then p1.xe = p1.xs
	else 
		p1.xe = 
			p1.xs + (10*cos(p1.theta))
	end
	p1.ye = 
		p1.ys - (10*sin(p1.theta))
 
  --player 2 movement
 if btn(0,1) then --left
  if p2.xs < 8 then xs = 7
		else
			p2.xs -= .75
			p2.xe -= .75
		end
 end

 if btn(1,1) then --right
  if p2.xs > 119 
		then p2.xs = 120
		else
			p2.xs += .75
			p2.xe += .75
		end
 end
 
 if btn(2,1) then
 	if p2.theta > .496 then
			p2.theta = .497
		else
			p2.theta += .003
		end 
 end
 
 if btn(3,1) then
 	if p2.theta < .004 then
			p2.theta = .003
		else
			p2.theta -= .003
		end
 end
 
 if p2.theta==.25 
	then p2.xe = p2.xs
	else 
		p2.xe = 
			p2.xs + (10*cos(p2.theta))
	end	
	p2.ye = 
		p2.ys + (10*sin(p2.theta))
 
  --shooting, player 1--
 if(btn(4,0)) then
 	if last1 == false then
 	shoot(p1)
 	last1 = true
 end
 else last1 = false
 end
  --shooting, player 2--
 if(btn(4,1)) then
 	if last2 == false then
 	shoot(p2)
 	last2 = true
 end
 else last2 = false
 end
 
 p1.muzzlex = p1.xs-1
 p1.muzzley = p1.ys-8
 p2.muzzlex = p2.xs-1
 p2.muzzley = p2.ys+8
 
 move_b()
 local coll = hit_bullet()
 hit_tank()
 react_bhit(coll)
 ptime = time()
end

function _draw()
 cls()
 spr(p1.s,p1.xs-7,p1.ys-16,2,2)
 spr(p2.s,p2.xs-7,p2.ys,2,2)
 line(p2.xs, p2.ys+8, 
		p2.xe, p2.ye+8, 12)
	line(p1.xs, p1.ys-9, 
		p1.xe, p1.ye-9, 8)
 show_b()
 print(p1.hp,0,0,8)
 print(p2.hp,0,120,8)
 explode()
end
__gfx__
0000000088500000000005880000000000000000066000000660000000aa00005008800500000000000000000000000000000000000000000000000000000000
000000005558888888888555cc5000cccc0005cc688600006cc600000a77a0000589985000099000000000000000000000000000000000000000000000000000
00700700885858555585858855500c5555c00555688600006cc60000a7887a00089aa980009aa900000770000000000000000000000000000000000000000000
000770005558558888558555cc5cc555555cc5cc0660000006600000a7887a0089a77a9809a77a90007777000005500000000000000000000000000000000000
000770008858555555558588555c55ccc555c55500000000000000000a77a00089a77a9809a77a90007777000005500000000000000000000000000000000000
007007005558558888558555cc5c55c55c55c5cc000000000000000000aa0000089aa980009aa900000770000000000000000000000000000000000000000000
000000008858558558558588555c55c55c55c5550000000000000000000000000589985000099000000000000000000000000000000000000000000000000000
000000005558558558558555cc5c55c55c55c5cc0000000000000000000000005008800500000000000000000000000000000000000000000000000000000000
000000008858558558558588555c55c55c55c5550006000000006000000000000000000000999900000000000000000000000000000000000000000000000000
000000005558558558558555cc5c55c55c55c5cc0000606666060000000000000000000009aaaa90000550000000000000000000000000000000000000000000
000000008858558558558588555c55cccc55c555000006555560000000000055550000009a7777a9005555000000000000000000000000000000000000000000
000000005558558885558555cc5c55555555c5cc600665888856600600000588885000009a7777a9055555500000000000000000000000000000000000000000
000000008858855555588588555c55cccc55c555060658999985606000005899998500009a7777a9055555500000000000000000000000000000000000000000
000000005550085555800555cc5c5c5555c5c5cc006589aaaa985600000589aaaa9850009a7777a9005555000000000000000000000000000000000000000000
000000008850008888000588555cccccccccc55506589a7777a9856000589a7777a9850009aaaa90000550000000000000000000000000000000000000000000
000000000000000000000000cc500000000005cc06589a7777a9856000589a7777a9850000999900000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000006589a7777a9856000589a7777a9850000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000006589a7777a9856000589a7777a9850000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000006589aaaa985600000589aaaa98500000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000606589999856060000058999985000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000006006658888566006000005888850000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000065555600000000000555500000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000606666060000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000006000000006000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbccccccccccccccccccccccccccccccccffffffffffffffffffffffffffffffff00000000000000000000000000000000
bbbbb33bbbbbbbbbbbbbbbbbbbbbbbbbccccccccccccccccccccccccccccccccfffffffffffffffffffff44fffffffff00000000000000000000000000000000
bb3333bbbbbbbbbbbbbbbbbbbbbbbbbbccccccccccccccccccccccccccccccccffffffffffffffffff4444ffffffffff00000000000000000000000000000000
bbbb3bbbbbbbbbbbbbbbbbbbbbbbbbbbcccccc11111cccccccccccccccccccccffffffffffffffffffff4fffffffffff00000000000000000000000000000000
bbbb3bbbbbbbbbbbbbbbbbbbbbbbbbbbccccc1ccccc1ccccccccccccccccccccffffffffffffffffffff4fffffffffff00000000000000000000000000000000
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbcccc1ccc111c1cccccccccccccccccccffffffffffffffffffffffffffffffff00000000000000000000000000000000
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbccc1ccc11cccccccccccccccccccccccffffffffffffffffffffffffffffffff00000000000000000000000000000000
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbcc11ccc11cccccccccccccccccccccccffffffffffffffffffffffffffffffff00000000000000000000000000000000
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbc11ccccc11ccccccccccccccccccccccffffffffffffffffffffffffffffffff00000000000000000000000000000000
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbccccccccccccccccccccccccccccccccfffffffffffff44fffffffffffffffff00000000000000000000000000000000
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbccccccccccccccccccccccccccccccccffffffffff4444ffffffffffffffffff00000000000000000000000000000000
bbbbbbbbbbbb33bbbbbbbbbbbbbbbbbbcccccccccccccccccccccc11111cccccffffffffffff4fffffffffffffffffff00000000000000000000000000000000
bbbbbbbbbbbbb333bbbbbbbbbbbbbbbbccccccccccccccccccccc1ccccc1ccccffffffffffff4fffffffffffffffffff00000000000000000000000000000000
bbbbbbbbbbbbb3bbbbbbbbbbbbbbbbbbcccccccccccccccccccc1ccc111c1cccffffffffffffffffffffffffffffffff00000000000000000000000000000000
bbbbbbbbbbbbb3bbbbbbbbbbbbbbbbbbccccccccccccccccccc1ccc11cccccccffffffffffffffffffffffffffffffff00000000000000000000000000000000
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbcccccccccccccccccc11ccc11cccccccffffffffffffffffffffffffffffffff00000000000000000000000000000000
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbccccccccccccccccc11ccccc11ccccccffffffffffffffffffffffffffffffff00000000000000000000000000000000
bbbbbbbbbbbbbbbbbbbbbbbbbbbbb33bccccccccccccccccccccccccccccccccfffffffffffffffffffffffffffff44f00000000000000000000000000000000
bbbbbbbbbbbbbbbbbbbbbbbbbb3333bbccccccccccccccccccccccccccccccccffffffffffffffffffffffffff4444ff00000000000000000000000000000000
bbbbbbbbbbbbbbbbbbbbbbbbbbbb3bbbcccccc11111cccccccccccccccccccccffffffffffffffffffffffffffff4fff00000000000000000000000000000000
bbbbbbbbbbbbbbbbbbbbbbbbbbbb3bbbccccc1ccccc1ccccccccccccccccccccffffffffffffffffffffffffffff4fff00000000000000000000000000000000
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbcccc1ccc111c1cccccccccccccccccccffffffffffffffffffffffffffffffff00000000000000000000000000000000
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbccc1ccc11cccccccccccccccccccccccffffffffffffffffffffffffffffffff00000000000000000000000000000000
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbcc11ccc11cccccccccccccccccccccccffffffffffffffffffffffffffffffff00000000000000000000000000000000
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbc11ccccc11ccccccccccccccccccccccffffffffffffffffffffffffffffffff00000000000000000000000000000000
bbbbbbbbbbbbbbbbbbbbb33bbbbbbbbbccccccccccccccccccccccccccccccccfffff44fffffffffffffffffffffffff00000000000000000000000000000000
bbbbbbbbbbbbbbbbbb3333bbbbbbbbbbccccccccccccccccccccccccccccccccff4444ffffffffffffffffffffffffff00000000000000000000000000000000
bbbbbbbbbbbbbbbbbbbb3bbbbbbbbbbbccccccccccccccccccccccccccccccccffff4fffffffffffffffffffffffffff00000000000000000000000000000000
bbbbbbbbbbbbbbbbbbbb3bbbbbbbbbbbccccccccccccccccccccccccccccccccffff4fffffffffffffffffffffffffff00000000000000000000000000000000
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbccccccccccccccccccccccccccccccccffffffffffffffffffffffffffffffff00000000000000000000000000000000
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbccccccccccccccccccccccccccccccccffffffffffffffffffffffffffffffff00000000000000000000000000000000
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbccccccccccccccccccccccccccccccccffffffffffffffffffffffffffffffff00000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000cc00cc00cc00cc00cc00cc0000000880088008800880088008800880000000000
00000000cc00cc00cc00cc00cc00cc000008808800880000000000000000000cc00cc00cc00cc00cc00cc0000000880088008800880088008800880000000000
00000000cc00cc00cc00cc00cc00cc0000088088008800000000000000000cc66666666666666666666666000088666666666666666666666666660000000000
000000cc66666666666666666666660008866666666600000000000000000cc66666666666666666666666000088666666666666666666666666660000000000
000000cc666666666666666666666600088666666666000000000000000000066666666666666666666666000000666666666666666666666666660000000000
00000000666666666666666666666600000666666666000000000000000000066666666666666666666666000000666666666666666666666666660000000000
0000000066666666666666666666660000066666666600000000000000000cc66666666666666666666666000088666666666666666666666666660000000000
000000cc66666666000000000000000008866666666600000000000000000cc66666666660000000000000000088666666666666666666666666660000000000
000000cc666666660000000000000000088666666666000000000000000000066666666660000000000000000000666666000000000000000000000000000000
00000000666666660000000000000000000666666666000000000000000000066666666660000000000000000000666666000000000000000000000000000000
0000000066666666000000000000000000066666666600000000000000000cc66666666660000000000000000088666666000000000000000000000000000000
000000cc66666666000000000000000008866666666600000000000000000cc66666666660000000000000000088666666000000000000000000000000000000
000000cc666666660000000000000000088666666666000000000000000000066666666660000000000000000000666666000000000000000000000000000000
00000000666666660000000000000000000666666666000000000000000000066666666660000000000000000000666666666666666666000000000000000000
0000000066666666000000000000000000066666666600000000000000000cc66666666666666666660000000088666666666666666666000000000000000000
000000cc66666666000000000000000008866666666600000000000000000cc66666666666666666660000000088666666666666666666000000000000000000
000000cc666666660000000000000000088666666666000000000000000000066666666666666666660000000000666666000000000000000000000000000000
00000000666666660000000000000000000666666666000000000000000000066666666660000000000000000000666666000000000000000000000000000000
0000000066666666000000000000000000066666666600000000000000000cc66666666660000000000000000088666666000000000000000000000000000000
000000cc66666666000000000000000008866666666600000000000000000cc66666666660000000000000000088666666000000000000000000000000000000
000000cc666666660000000000000000088666666666000000000000000000066666666660000000000000000000666666000000000000000000000000000000
00000000666666660000000000000000000666666666000000000000000000066666666660000000000000000000666666000000000000000000000000000000
000000cc66666666000000000000000000066666666600000000000000000cc66666666660000000000000000088666666000000000000000000000000000000
000000cc66666666666666666666660008866666666666666666666666880cc66666666666666666666666000088666666000000000000000000000000000000
00000000666666666666666666666600088666666666666666666666668800066666666666666666666666000000666666000000000000000000000000000000
00000000666666666666666666666600000666666666666666666666660000066666666666666666666666000000666666000000000000000000000000000000
000000cc66666666666666666666660008866666666666666666666666880cc66666666666666666666666000088666666000000000000000000000000000000
000000cc66666666666666666666660008866666666666666666666666880cc66666666666666666666666000088666666000000000000000000000000000000
00000000cc00cc00cc00cc00cc00cc000008800880088008800880088000000cc00cc00cc00cc00cc00cc0000000880088000000000000000000000000000000
00000000cc00cc00cc00cc00cc00cc000008800880088008800880088000000cc00cc00cc00cc00cc00cc0000000880088000000000000000000000000000000
__gff__
0000000000010201020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
00000000000000000000be000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
010500000a750107501c7502a7502e7502d6532d6532c6532c6532c6532c6532a653286532665324653216531e6531b65317653116530c6530a65307653056530365302653026530165301653016530165301653
010500003f6503e6503d6503c6503b6503a65039650376503565033650306502e6502b6502a65028650266502565022650206501e6501c6501b650186501665013650106500e6500c6500a650086500565002650
010300003e6503d6503c6503b6503765036650306502e6502a65026650246501f6501b6501865015650126500f6500c6500865005650056500165001650016500165001650016500165001650016500165001650
0110000020050000000000000000230500000000000000002005000000200500000025050200501e0500000020050000000000027050000000000025050000002505000000280502705020050000000000000000
0110000020050000002305000000270500000020050000001b0501b0501b050000002005000000200500000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
01 03444344
02 05044344

