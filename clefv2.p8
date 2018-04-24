pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
--init

function _init()
	last1 = false
	last2 = false
 b_sp = 50 --bullet speed
 ptime = time() --prev time
 dt = 0 --time diff betw now and ptime

  --player 1, red tank--
 p1 = {}
 p1.s = 1 --sprite
 p1.xs = 64
 p1.ys = 16
 p1.xe = 64
 p1.ye = 128
 p1.theta = .25
 p1.b = {} --all shot bullets
 p1.b_s = 5 --bullet sprite
 p1.muzzlex = p1.xs --base of muzzle
 p1.muzzley = p1.ys-9
 --p1.angle = straight
 
  --player 2, blue tank--
 p2 = {}
 p2.s = 3 --sprite
 p2.xs = 64
 p2.ys = 112
 p2.xe = 0
 p2.ye = 0
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
 
 if(k==-1) k=#player.b+1
 
 return k
end

--shoot a bullet
function shoot(player)
 local k = valid_b(player)
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

function detect_c()
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
   end
  end
 end
 return {c1,c2}
end

function react_c(coll)
 local c1 = coll[1]
 local c2 = coll[2]
 
 for i=1,#c1 do
  local k = c1[i]
  p1.b[k].y = 128
 end
 for i=1,#c2 do
  local k = c2[i]
  p2.b[k].y = -8
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
			p1.xs - (128/tan(p1.theta))
	end
 
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
			p2.xs - (128/tan(p2.theta))
	end	
 
  --shooting, player 1--
 if(btn(4,0)) then
 	if last1 == false then
 	shoot(p1)
 	sfx(0)
 	last1 = true
 end
 else last1 = false
 end
  --shooting, player 2--
 if(btn(4,1)) then
 	if last2 == false then
 	shoot(p2)
 	sfx(0)
 	last2 = true
 end
 else last2 = false
 end
 
 p1.muzzlex = p1.xs+6
 p1.muzzley = p1.ys+7
 p2.muzzlex = p2.xs+6
 p2.muzzley = p2.ys+7
 
 move_b()
 local coll = detect_c()
 react_c(coll)
 ptime = time()
end

function _draw()
 cls()
 spr(p1.s,p1.xs-7,p1.ys-16,2,2)
 spr(p2.s,p2.xs-7,p2.ys,2,2)
 line(p2.xs, p2.ys+8, 
		p2.xe, p2.ye, 12)
	line(p1.xs, p1.ys-9, 
		p1.xe, p1.ye, 8)
 show_b()
end
__gfx__
0000000088444444444448800000000000000000066000000660000000aa00005008800500060000000060000000000000000000009999000000000000000000
0000000088444444444448800000000000000000688600006cc600000a77a000058998500000606666060000000000000000000009aaaa900005500000000000
0070070088444448444448800000000000000000688600006cc60000a7887a00089aa980000006555560000000000055550000009a7777a90055550000000000
00077000884444888444488000000000000000000660000006600000a7887a0089a77a98600665888856600600000588885000009a7777a90555555000000000
000770008844488888444880000000000000000000000000000000000a77a00089a77a98060658999985606000005899998500009a7777a90555555000000000
0070070000448888888440000044444444444000000000000000000000aa0000089aa980006589aaaa985600000589aaaa9850009a7777a90055550000000000
0000000000448888888440000044444c444440000000000000000000000000000589985006589a7777a9856000589a7777a9850009aaaa900005500000000000
000000000044488888444000004444ccc44440000000000000000000000000005008800506589a7777a9856000589a7777a98500009999000000000000000000
00000000004444888444400000444ccccc4440000000000000000000000000000000000006589a7777a9856000589a7777a98500000000000000000000000000
0000000000444448444440000044ccccccc440000000000000000000000000000009900006589a7777a9856000589a7777a98500000000000000000000000000
0000000000444444444440000044ccccccc44000000000000000000000000000009aa900006589aaaa985600000589aaaa985000000000000000000000000000
000000000000000000000000cc444ccccc444cc000000000000000000000000009a77a9006065899998560600000589999850000000000000000000000000000
000000000000000000000000cc4444ccc4444cc000000000000000000000000009a77a9060066588885660060000058888500000000000000000000000000000
000000000000000000000000cc44444c44444cc0000000000000000000000000009aa90000000655556000000000005555000000000000000000000000000000
000000000000000000000000cc44444444444cc00000000000000000000000000009900000006066660600000000000000000000000000000000000000000000
000000000000000000000000cc44444444444cc00000000000000000000000000000000000060000000060000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
885000888800058800000000cc5000cccc0005cc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
55500855558005550000000055500c5555c005550000000000000000000000000007700000000000000000000000000000000000000000000000000000000000
885885555558858800000000cc5cc555555cc5cc0000000000000000000000000077770000000000000000000000000000000000000000000000000000000000
555855888555855500000000555c55ccc555c5550000000000000000000000000077770000000000000000000000000000000000000000000000000000000000
885855855855858800000000cc5c55c55c55c5cc0000000000000000000000000007700000000000000000000000000000000000000000000000000000000000
555855855855855500000000555c55c55c55c5550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
885855855855858800000000cc5c55c55c55c5cc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
555855855855855500000000555c55c55c55c5550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
885855855855858800000000cc5c55c55c55c5cc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
555855588855855500000000555c555ccc55c5550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
885855555555858800000000cc5c55555555c5cc0000000000000000000000000005500000000000000000000000000000000000000000000000000000000000
555855888855855500000000555c55cccc55c5550000000000000000000000000005500000000000000000000000000000000000000000000000000000000000
885858555585858800000000cc5c5c5555c5c5cc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
555888888888855500000000555cccccccccc5550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
885000000000058800000000cc500000000005cc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
bbbbb33bbbbbbbbbbbbbb33bbbbbbbbbccccccccccccccccccccccccccccccccfffff44fffffffffffffffffffffffff00000000000000000000000000000000
bb3333bbbbbbbbbbbb3333bbbbbbbbbbccccccccccccccccccccccccccccccccff4444ffffffffffffffffffffffffff00000000000000000000000000000000
bbbb3bbbbbbbbbbbbbbb3bbbbbbbbbbbccccccccccccccccccccccccccccccccffff4fffffffffffffffffffffffffff00000000000000000000000000000000
bbbb3bbbbbbbbbbbbbbb3bbbbbbbbbbbccccccccccccccccccccccccccccccccffff4fffffffffffffffffffffffffff00000000000000000000000000000000
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
000000cc66666666666666666666660008866666666600000000000000000cc66666666660000000000000000088666666666666666666666666660000000000
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
0000000066666666000000000000000000066666666600000000000000000cc66666666660000000000000000088666666000000000000000000000000000000
000000cc66666666666666666666666008866666666666666666666666880cc66666666666666666666666000088666666000000000000000000000000000000
000000cc666666666666666666666660088666666666666666666666668800066666666666666666666666000000666666000000000000000000000000000000
00000000666666666666666666666660000666666666666666666666660000066666666666666666666666000000666666000000000000000000000000000000
0000000066666666666666666666666008866666666666666666666666880cc66666666666666666666666000088666666000000000000000000000000000000
000000cc66666666666666666666666008866666666666666666666666880cc66666666666666666666666000088666666000000000000000000000000000000
000000cccc00cc00cc00cc00cc00cc000008800880088008800880088000000cc00cc00cc00cc00cc00cc0000000880088000000000000000000000000000000
00000000cc00cc00cc00cc00cc00cc000008800880088008800880088000000cc00cc00cc00cc00cc00cc0000000880088000000000000000000000000000000
__gff__
0001010202010201020200020002020000010102020000010200000000000000000000000000000002000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
010500000a750107501c7502a7502e7502d6532d6532c6532c6532c6532c6532a653286532665324653216531e6531b65317653116530c6530a65307653056530365302653026530165301653016530165301653
010500003f6503e6503d6503c6503b6503a65039650376503565033650306502e6502b6502a65028650266502565022650206501e6501c6501b650186501665013650106500e6500c6500a650086500565002650
000300003e6503d6503c6503b6503765036650306502e6502a65026650246501f6501b6501865015650126500f6500c6500865005650056500165001650016500165001650016500165001650016500165001650
0110000020050010002a0000100023050240001c0001f0002005020000200502000025050200501e05001000200502500027000270502400020000250502500025050250002805027050200501a0000100000000
0010000020050230002305023000270501900020050180001b0501b0501b050000002005016000200500000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
00 01424344
00 03444344
00 04424344

