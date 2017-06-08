var packager = require('electron-packager')
packager({
	dir : ".",
	out : "../releases/",
	icon : "../logo.icns",
	overwrite : true,
	asar : {
		unpackDir : "engines" //"**/{engines}"
	},
	electronVersion : "1.7.2"
},
function done(err, appPaths){});