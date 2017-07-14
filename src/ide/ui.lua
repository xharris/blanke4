UI = {
	color = {
		background = {33,33,33,255}
	},

	titlebar = { -- short for 'element'
		new_project = false
	}
}

checkUI = function(index, func)
	local parts = index:split('.')
	index = UI
	for p, part in ipairs(parts) do
		index = index[part]
	end
	if index then index = func() end
end