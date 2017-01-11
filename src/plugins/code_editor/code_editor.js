require('codemirror/addon/edit/matchbrackets');
require('codemirror/addon/edit/closebrackets');
require('codemirror/addon/scroll/annotatescrollbar');
require('codemirror/addon/search/matchesonscrollbar');
require('codemirror/addon/search/searchcursor');
require('codemirror/addon/search/match-highlighter');

require('codemirror/addon/dialog/dialog')
require('codemirror/addon/search/search')
require('codemirror/addon/search/jump-to-line')

var nwCODE = require("codemirror");

// sel_id : ID of the element that will hold the code editor
// options : options to pass to CodeMirror
//
// returns CodeMirror instance
exports.init = function(sel_id, fn_saveScript) {
	return new b_code(sel_id, fn_saveScript);
}

exports.settings = [
	{
		"type" : "file",
		"name" : "external editor",
		"default" : "",
	},
	{
		"type" : "bool",
		"name" : "save on close",
		"default" : false
	}
]

var b_code = function(sel_id, fn_saveScript) {
	var _this = this;

	this.file = '';

	var language = nwENGINES[b_project.getData('engine')].language;
	if (language) {
		require('codemirror/mode/' + language + '/' + language);
	} else {
		language = '';
	}
	this.fontSize = 12
	this.codemirror = nwCODE(document.getElementById(sel_id), {
		mode: language,
		lineWrapping: false,
		extraKeys: {
			'Ctrl-Space': 'autocomplete',
			'Ctrl-S': fn_saveScript,
			'Ctrl-=': function(){_this.setFontSize(_this.fontSize+1);},
			'Ctrl--': function(){_this.setFontSize(_this.fontSize-1);}
		},
		lineNumbers: true,
		theme: 'monokai',
		value: "",
		indentUnit: 4,
		highlightSelectionMatches: {showToken: /\w/, annotateScrollbar: true},
	});

	this.setFontSize = function(size) {
		this.fontSize = size;
		this.codemirror.display.wrapper.style.fontSize = size + "px";
		this.codemirror.refresh();
	}
	this.setFontSize(this.fontSize)

	this.getValue = function(code) {
		if (this.codemirror)
			return this.codemirror.getValue();
	}

	this.setValue = function(code) {
		if (this.codemirror)
			this.codemirror.setValue(code);
	}

	this.openFile = function(path, callback) {
		this.file = path;
		var _this = this;
		nwFILE.readFile(path, 'utf8', function(err, data){
			if (!err)
				_this.codemirror.setValue(data);
			else {
				nwFILE.writeFile(path, '', function(err){
					_this.openFile(path);
				})
			}

			if (callback)
				callback(err);
		});
	};

	this.saveFile = function(path, callback) {
		code = this.codemirror.getValue();

		nwMKDIRP(nwPATH.dirname(path), function(){
			nwFILE.writeFile(path, code, function(err) {
				if (err) 
					b_console.error('ERR: Cannot save ' +path);

				if (callback)
					callback(err);
			});
		});
	};
}