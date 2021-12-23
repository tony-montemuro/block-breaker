-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

-- Your code here

local composer = require("composer")
local loadsave = require("loadsave")

local settings = loadsave.loadTable("settings.json")

if (settings == nil) then

	settings = {
		{muted = false}
	}
	loadsave.saveTable(settings, "settings.json")
end

local savedata = loadsave.loadTable("savedata.json")

if (savedata == nil) then
	local savedata = {}

	for i=1, 40 do
		if (i==1) then
			savedata[i]={
				level=i,
				unlocked=true,
				stars=0,
			}
		else
			savedata[i]={
				level=i,
				unlocked=false,
				stars=0,
			}
		end
	end

	loadsave.saveTable(savedata, "savedata.json")
end

display.setStatusBar( display.HiddenStatusBar )
native.setProperty( "androidSystemUiVisibility", "immersiveSticky" )

composer.setVariable("muted", settings["muted"])
composer.gotoScene("menu") --, options)
--composer.gotoScene("levelcreator")