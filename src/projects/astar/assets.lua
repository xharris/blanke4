asset_path=''
if _REPLACE_REQUIRE then
	asset_path=_REPLACE_REQUIRE:gsub('%.','/')
end
assets = Class{}


state0 = Class{classname='state0'}
require 'scripts.state.state0'
_FIRST_STATE = state0
