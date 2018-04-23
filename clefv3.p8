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
 local cp1 = {}
 local cp2 = {}
 
  --collision box for p1
 local lx1=p1.xs-7
 local ly1=p1.ys-16
 local rx1=p1.xs+7
 local ry1=p1.ys-6
   
  --collision box for p2
 local lx2=p2.xs-7
 local ly2=p2.ys+5
 local rx2=p2.xs+7
 local ry2=p2.ys+15
 
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
   end
   

   
   --p1 bullet hit tank 2
   --x and y = p1 bullets
   if(
    x>=lx2 and x<=rx2 
    	and y2>=ly2 and y2<=ry2 or
    x2>=lx2 and x2<=rx2 
    	and y2>=ly2 and y2<=ry2
     )
   then
    sfx(3)
   end
   
   --p2 bullet hit tank 1
   --a and b = p2 bullets
   if(
    a>=lx1 and a<=rx1 
    	and b>=ly1 and b<=ry1 or
    a2>=lx1 and a2<=rx1 
    	and b>=ly1 and b<=ry1
    )
   then
    sfx(3)
   end

  end
 end
 
 return {c1,c2,cp1,cp2}
end

function react_c(coll)
 local c1 = coll[1]
 local c2 = coll[2]
 cp1 = coll[3]
 cp2 = coll[4]
 
 for i=1,#c1 do
  local k = c1[i]
  p1.b[k].y = 128
 end
 for i=1,#c2 do
  local k = c2[i]
  p2.b[k].y = -8
 end
 
 for i=1,#cp1 do
  local k = cp1[i]
  p1.b[k].y = 128
  p2.hp -= 1
 end
 
 for i=1,#cp2 do
  local k = cp2[i]
  p2.b[k].y = 128
  p1.hp -= 1
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
 local coll = detect_c()
 react_c(coll)
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
 local lx1=p1.xs-7
 local ly1=p1.ys-16
 local rx1=p1.xs+7
 local ry1=p1.ys-6
 spr(8,lx1,ly1)
 spr(8,rx1,ry1)
end
__gfx__
0000000088444444444448800000000000000000066000000660000000aa000090000000b0000000000000000000000000000000000000000000000000000000
0000000088444444444448800000000000000000688600006cc600000a77a0000000000000000000000000000000000000000000000000000000000000000000
0070070088444448444448800000000000000000688600006cc60000a7887a000000000000000000000000000000000000000000000000000000000000000000
00077000884444888444488000000000000000000660000006600000a7887a000000000000000000000000000000000000000000000000000000000000000000
000770008844488888444880000000000000000000000000000000000a77a0000000000000000000000000000000000000000000000000000000000000000000
0070070000448888888440000044444444444000000000000000000000aa00000000000000000000000000000000000000000000000000000000000000000000
0000000000448888888440000044444c444440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000044488888444000004444ccc44440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000004444888444400000444ccccc4440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000444448444440000044ccccccc440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000444444444440000044ccccccc440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000cc444ccccc444cc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000cc4444ccc4444cc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000cc44444c44444cc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000cc44444444444cc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000cc44444444444cc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0001010202010201020200000000000000010102020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
010500000a750107501c7502a7502e7502d6532d6532c6532c6532c6532c6532a653286532665324653216531e6531b65317653116530c6530a65307653056530365302653026530165301653016530165301653
011000001805018050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000003067030670306703067000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
