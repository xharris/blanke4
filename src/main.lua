package.cpath = package.cpath .. ";/usr/local/lib/lua/5.2/?.so;/usr/local/lib/lua/5.2/?.dll;./?.dll;./?.so"

require "imgui"
require "template.plugins.printr"
require "template.plugins.blanke.Util"
_watcher = require 'watcher'

_GAME_NAME = "blanke"
_REPLACE_REQUIRE = 'projects.project4.'

--require "includes"

require "ide.helper"
require "ide.ui"
require "ide.ide"
require "ide.console"

function love.load()
    IDE.setProjectFolder(IDE.project_folder)
    IDE.load()
end

function love.update(dt)
    imgui.NewFrame()
    if BlankE then BlankE.update(dt) end
    IDE.update(dt)
end

function love.draw()
    if BlankE then
        BlankE.draw()
        Gamestate.draw()
    end
    IDE.draw()
end

function love.quit()
    IDE.quit()
    if BlankE then BlankE.quit() end
    imgui.ShutDown();
end

function love.filedropped(file)
    IDE.addResource(file)
end

--
-- User inputs
--
function love.textinput(t)
    imgui.TextInput(t)
    if not imgui.GetWantCaptureKeyboard() then
        -- Pass event to the game
    end
end

function love.keypressed(key)
    imgui.KeyPressed(key)
    if not imgui.GetWantCaptureKeyboard() then
        -- Pass event to the game
        if BlankE then BlankE.keypressed(key) end
    end
end

function love.keyreleased(key)
    imgui.KeyReleased(key)
    if not imgui.GetWantCaptureKeyboard() then
        -- Pass event to the game
        if BlankE then BlankE.keyreleased(key) end
    end
end

function love.mousemoved(x, y)
    imgui.MouseMoved(x, y)
    if not imgui.GetWantCaptureMouse() then
        -- Pass event to the game
    end
end

function love.mousepressed(x, y, button)
    imgui.MousePressed(button)
    if not imgui.GetWantCaptureMouse() then
        -- Pass event to the game
        if BlankE then BlankE.mousepressed(x,y,button) end
    end
end

function love.mousereleased(x, y, button)
    imgui.MouseReleased(button)
    if not imgui.GetWantCaptureMouse() then
        -- Pass event to the game
        if BlankE then BlankE.mousereleased(x,y,button) end
    end
end

function love.wheelmoved(x, y)
    imgui.WheelMoved(y)
    if not imgui.GetWantCaptureMouse() then
        -- Pass event to the game
    end
end

local function error_printer(msg, layer)
    print((debug.traceback("Error: " .. tostring(msg), 1+(layer or 1)):gsub("\n[^\n]+$", "")))
end
function love.errhand(msg)
    msg = tostring(msg)
 
    error_printer(msg, 2)
 
    if not love.window or not love.graphics or not love.event then
        return
    end
 
    if not love.graphics.isCreated() or not love.window.isOpen() then
        local success, status = pcall(love.window.setMode, 800, 600)
        if not success or not status then
            return
        end
    end
 
    -- Reset state
    if love.mouse then
        love.mouse.setVisible(true)
        love.mouse.setGrabbed(false)
        love.mouse.setRelativeMode(false)
    end
    if love.joystick then
        -- Stop all joystick vibrations
        for i,v in ipairs(love.joystick.getJoysticks()) do
            v:setVibration()
        end
    end
    if love.audio then love.audio.stop() end
    love.graphics.reset()
    local font = love.graphics.setNewFont(math.floor(love.window.toPixels(14)))
 
    love.graphics.setBackgroundColor(89, 157, 220)
    love.graphics.setColor(255, 255, 255, 255)
 
    local trace = debug.traceback()
 
    love.graphics.clear(love.graphics.getBackgroundColor())
    love.graphics.origin()
 
    local err = {}
 
    table.insert(err, "Error\n")
    table.insert(err, msg.."\n\n")
 
    for l in string.gmatch(trace, "(.-)\n") do
        if not string.match(l, "boot.lua") then
            l = string.gsub(l, "stack traceback:", "Traceback\n")
            table.insert(err, l)
        end
    end
 
    local p = table.concat(err, "\n")
 
    p = string.gsub(p, "\t", "")
    p = string.gsub(p, "%[string \"(.-)\"%]", "%1")
 
    local function draw()
        local pos = love.window.toPixels(70)
        love.graphics.clear(love.graphics.getBackgroundColor())
        love.graphics.printf(p, pos, pos, love.graphics.getWidth() - pos)
        love.graphics.present()
    end
 
    while true do
        love.event.pump()
 
        for e, a, b, c in love.event.poll() do
            if e == "quit" then
                return
            elseif e == "keypressed" and a == "escape" then
                return
            elseif e == "touchpressed" then
                local name = love.window.getTitle()
                if #name == 0 or name == "Untitled" then name = "Game" end
                local buttons = {"OK", "Cancel"}
                local pressed = love.window.showMessageBox("Quit "..name.."?", "", buttons)
                if pressed == 1 then
                    return
                end
            end
        end

        IDE.update(dt)
 
        draw()
 
        if love.timer then
            love.timer.sleep(0.1)
        end
    end

    if not BlankE or (BlankE and not BlankE._ide_mode) then
        IDE.draw()
    end
end