local new_states = {}
local state_list = {}
local open_states = {} -- probably don't need this anymore

_empty_state = {classname='_empty_state'}
require ('empty_state')
_FIRST_STATE = _empty_state

local ideState = {
	new = function()
		local state_name = IDE.addGameType('state')
		HELPER.run('newScript', {'state', IDE.getCurrentProject(), state_name})
		table.insert(new_states, state_name)
	end,

	getObjectList = function()
		state_list = {}
		local state_files = love.filesystem.getDirectoryItems(IDE.current_project..'/scripts/state')
		for s, state in ipairs(state_files) do
			local state_name = string.gsub(state,'.lua','')
			table.insert(state_list, state_name)
		end
		return state_list
	end,

	getAssets = function()
		local ret_str = ''
		local first_state = UI.getSetting('initial_state')
		for s, state_name in ipairs(state_list) do
			ret_str = ret_str..
				state_name.." = Class{classname=\'"..state_name.."\'}\n"..
				"require \'scripts.state."..state_name.."\'\n"

			if first_state == '' then
				first_state = state_name
				UI.setSetting('initial_state', first_state)
				ret_str = ret_str .. '_FIRST_STATE = '..first_state..'\n'
			end
		
		end
		state_list = {}
		return ret_str:gsub('\n','\\n')..'\n'
	end,

	onReload = function()
		if #state_list > 0 then
			_FIRST_STATE = state_list[1] -- change later
		end
	end,

	fileChange = function(file_name)
		if string.match(file_name, "state") then
			IDE._reload(file_name)
			local curr_state = BlankE.getCurrentState()
			if string.match(file_name, curr_state) then
				Gamestate.switch(_G[curr_state])
			end
		end
	end,

	edit = function(name)
		open_states[name] = true 
		HELPER.run('editFile',{IDE.getCurrentProject()..'/scripts/state/'..name..'.lua'})
	end,

	draw = function()
	--[[
		for state, val in pairs(open_states) do
			if open_states[state] then
				imgui.SetNextWindowSize(300,300,"FirstUseEver")
				status, open_states[state] = imgui.Begin(state, true)



				imgui.End()
			end
		end
	]]--
	end
}

return ideState

