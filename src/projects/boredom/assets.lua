asset_path=''
if _REPLACE_REQUIRE then
	asset_path=_REPLACE_REQUIRE:gsub('%.','/')
end
assets = Class{}
function assets:level1()
	 return asset_path.."assets/scene/level1.json"
end



level1 = Class{classname='level1'}
require 'scripts.state.level1'
_FIRST_STATE = level1

