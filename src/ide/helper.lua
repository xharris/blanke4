HELPER = {
	run = function(name, args)
		if args == nil then
			args = {}
		end

		str_args = table.concat(args,' ')
		cmd = 'python src/helper.py '..name..' '..str_args
		print(cmd)
		os.execute(cmd)
	end
}