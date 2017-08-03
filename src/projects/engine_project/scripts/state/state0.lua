-- Called once, and only once, before entering the state the first time.
function state0:init() end
function state0:leave() end 

-- Called every time when entering the state.
function state0:enter(previous)
	love.graphics.setBackgroundColor(180,0,0)
	new_img = Image('penguin')
	new_img.x = 100
	new_img.y = 120
    
	main_scene = Scene('main_scene')
    
	test_ent = entity0(96, 224)
    test_ent.nickname = "player"
	main_scene:addEntity(test_ent)
    
    main_view = View()
    main_view:follow(test_ent) 
end

function state0:update(dt)

end

function state0:draw()
	love.graphics.setColor(255,0,0,255)
	love.graphics.print("hey how goes it", 100,100)
	love.graphics.setColor(255,255,255,255)
	new_img:draw()
    main_view:draw(function()
        main_scene:draw()
    end)
    Debug.draw()
end	