function entity0:init(x, y)
	Entity.init(self,'entity0')

	self.x = x
    self.y = y
    
    self:addShape("main", "rectangle", {0, 0, 32, 32})
    self:addShape("jump_box", "rectangle", {4, 30, 24, 2})
    self:setMainShape("main")
        
    self.friction = 0.05
    self.gravity_direction = 90
    self.gravity = 5
    
    self.move_speed = 125    
    self.can_jump = true
    self.jump_power = 330

    self.show_debug = true
end

function entity0:postDraw()
	Draw.setColor(0,0,255,255)
	Draw.rect('line',self.x-16,self.y-16,32,32)
end

function entity0:preUpdate(dt)
    self.onCollision["main"] = function(other, sep_vector)
        if other.tag == "ground" then
            -- ceiling collision
            if sep_vector.y > 0 and self.vspeed < 0 then
                self:collisionStopY()
            end
            -- horizontal collision
            if math.abs(sep_vector.x) > 0 then
                self:collisionStopX() 
            end
        end
    end
    
    self.onCollision["jump_box"] = function(other, sep_vector)
        if other.tag == "ground" and sep_vector.y < 0 then
                -- floor collision
            self.can_jump = true 
            if self.nickname == 'player' then
                Signal.emit('jump')
            end
        self:collisionStopY()
        end 
    end

    if self.nickname == 'player' then
        local k_right = love.keyboard.isDown("right")
        local k_left = love.keyboard.isDown("left")
        local k_up = love.keyboard.isDown("up")
        
        -- horizontal movement
    	if k_right or k_left then
            if k_left then
    	    self.hspeed = -self.move_speed    
            end
            if k_right then
               self.hspeed = self.move_speed 
            end
        else
           	self.hspeed = 0 
        end
        
        -- jumping
        if k_up and self.can_jump then
            self.vspeed = -self.jump_power
            self.can_jump = false
        end	
    end
end	
