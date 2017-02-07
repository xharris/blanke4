local assets = require "assets"

_Entity = {
	_images = {},		
	_sprites = {}, 			-- is actually the animations
	sprite = nil,			-- currently active animation

	-- x and y coordinate of sprite
	x = 0,	
	y = 0,

	-- sprite/animation variables
	_sprite_prev = '', 		-- previously used sprite
	sprite_index = '',		-- string index of the current sprite
	sprite_width = 0, 		-- readonly
	sprite_height = 0,		-- readonly
	sprite_angle = 0, 		-- angle of sprite in degrees
	sprite_xscale = 1,		
	sprite_yscale = 1,
	sprite_xoffset = 0,
	sprite_yoffset = 0,
	sprite_xshear = 0,
	sprite_yshear = 0,
	sprite_color = {['r']=255,['g']=255,['b']=255},
	sprite_alpha = 255,

	-- movement variables
	direction = 0,
	friction = 0,
	gravity = 0,
	_gravityx = 0,
	_gravityy = 0,
	gravity_direction = 0,
	hspeed = 0,
	vspeed = 0,
	speed = 0,
	xprevious = 0,
	yprevious = 0,
	xstart = 0,
	ystart = 0,

	update = function(self, dt)
		if self.preUpdate then
			self:preUpdate(dt)
		end	

		if self.sprite ~= nil then
			self.sprite:update(dt)
		end

		if self.xstart == 0 then
			self.xstart = self.x
		end
		if self.ystart == 0 then
			self.ystart = self.y
		end
		self.xprevious = self.x
		self.yprevious = self.y

		local speedx = self.speed * math.cos(math.rad(self.direction))
		local speedy = self.speed * math.sin(math.rad(self.direction))
		local gravx = self.gravity * math.cos(math.rad(self.gravity_direction))
		local gravy = self.gravity * math.sin(math.rad(self.gravity_direction))

		if self.gravity == 0 then
			self._gravityx = 0
			self._gravityy = 0
		end	
		self._gravityx = self._gravityx + gravx
		self._gravityy = self._gravityy + gravy
		
		self.x = self.x + self.hspeed*dt + speedx*dt + self._gravityx*dt
		self.y = self.y + self.vspeed*dt + speedy*dt + self._gravityy*dt

		if self.speed > 0 then
			self.speed = self.speed - (self.speed * self.friction)
		end

		if self.postUpdate then
			self:postUpdate(dt)
		end	
	end,

	debugDraw = function(self)
		local sx = self.sprite_xoffset
		local sy = self.sprite_yoffset

		love.graphics.push()
		love.graphics.translate(self.x, self.y)
		love.graphics.rotate(math.rad(self.sprite_angle))
		love.graphics.shear(self.sprite_xshear, self.sprite_yshear)
		love.graphics.scale(self.sprite_xscale, self.sprite_yscale)
		love.graphics.rectangle("line", -sx, -sy, self.sprite_width, self.sprite_height)
		love.graphics.circle("line", 0, 0, 2)
		love.graphics.rotate(0)
		love.graphics.pop()
	end,

	draw = function(self)
		if self.preDraw then
			self:preDraw()
		end

		self.sprite = self._sprites[self.sprite_index]

		if self.sprite ~= nil then
			-- sprite dimensions
			if self._sprite_prev ~= self.sprite_index  then
				self.sprite_width, self.sprite_height = self.sprite:getDimensions()
				self._sprite_prev = self.sprite_index
			end

			-- draw current sprite (image, x,y, angle, sx, sy, ox, oy, kx, ky) s=scale, o=origin, k=shear
			local img = self._images[self.sprite_index]
			love.graphics.setColor(self.sprite_color.r, self.sprite_color.g, self.sprite_color.b, self.sprite_alpha)
			self.sprite:draw(img, self.x, self.y, math.rad(self.sprite_angle), self.sprite_xscale, self.sprite_yscale, self.sprite_xoffset, self.sprite_yoffset, self.sprite_xshear, self.sprite_yshear)
		else
			self.sprite_width = 0
			self.sprite_height = 0
		end

		if self.preDraw then
			self:preDraw()
		end
	end,

	addAnimation = function(...)
		local args = {...}
		local self = args[1]

		local ani_name = args[2]
		local name = args[3]
		local frames = args[4]
		local other_args = {}

		print_r(other_args)

		-- get other args
		for a = 5,#args do
			table.insert(other_args, args[a])
		end

		if assets[name] ~= nil then
			local sprite, image = assets[name]()
			local sprite = anim8.newAnimation(sprite(unpack(frames)), unpack(other_args))

			self._images[ani_name] = image
			self._sprites[ani_name] = sprite
		end	
	end,

	-- other : Entity object
	-- returns distance between center of self and other object in pixels
	distance = function(self, other)
		return math.sqrt((other.x - self.x)^2 + (other.y - self.y)^2)
	end,

	-- self direction and speed will be set towards the given point
	-- this method will not set the speed back to 0 
	move_towards_point = function(self, x, y, speed)
		self.direction = math.deg(math.atan2(y - self.y, x - self.x))
		self.speed = speed
	end
}

return _Entity