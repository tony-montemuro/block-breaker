local composer = require( "composer" )
local widget = require("widget")
local loadsave = require("loadsave")
local inspect = require("inspect")

local scene = composer.newScene()
 
---------------------------------------------------------------------------------
-- All code outside of the listener functions will only be executed ONCE
-- unless "composer.removeScene()" is called.
---------------------------------------------------------------------------------
 
-- local forward references should go here
 
---------------------------------------------------------------------------------
 
-- "scene:create()"

goldstarimage = "assets/graphics/goldstar.png"
blackstarimage = "assets/graphics/blackstar.png"
homebuttonpic = "assets/graphics/home.png"
settingsbuttonimage = "assets/graphics/settings.png"
lockimage = "assets/graphics/lock.png"

local menuSound = audio.loadSound("assets/sound/menu.mp3");

function scene:create( event )
 
   local sceneGroup = self.view

   local savedata = loadsave.loadTable("savedata.json")
   local j = 200
   local i2 = 1
   for i=1,40 do
         local group = display.newGroup( )
         local box = display.newRoundedRect(group, 0, 0, 175, 175, 15)
         local boxNumber = display.newText( group, savedata[i]["level"], 0, -25 )
         boxNumber:setFillColor( 0, 0, 0)
         if (savedata[i]['unlocked']) then
            if (savedata[i]["stars"] == 3) then
               local star1 = display.newImage( group, goldstarimage, -60, 50)
               local star2 = display.newImage( group, goldstarimage, 0, 50)
               local star3 = display.newImage( group, goldstarimage, 60, 50)
            elseif (savedata[i]["stars"] == 2) then
               local star1 = display.newImage( group, goldstarimage, -60, 50)
               local star2 = display.newImage( group, goldstarimage, 0, 50)
               local star3 = display.newImage( group, blackstarimage, 60, 50)
            elseif (savedata[i]["stars"] == 1) then
               local star1 = display.newImage( group, goldstarimage, -60, 50)
               local star2 = display.newImage( group, blackstarimage, 0, 50)
               local star3 = display.newImage( group, blackstarimage, 60, 50)
            else
               local star1 = display.newImage( group, blackstarimage, -60, 50)
               local star2 = display.newImage( group, blackstarimage, 0, 50)
               local star3 = display.newImage( group, blackstarimage, 60, 50)
            end


            local function levelButton( event )
               if (event.phase == "ended") then
                  options = {
                        params = {
                           level = savedata[i]["level"]
                        }
                     }
                  local muted = composer.getVariable( "muted" )
                  if (not muted) then
                        audio.play(menuSound); --play sound effect of menu selection
                  end
                  composer.gotoScene( "game", options )
               end
            end

            local button = widget.newButton( {
                  width = 175,
                  height = 175,
                  onEvent = levelButton
               } 
            )
            button.x = i2 * 200 - 65
            button.y = j

            sceneGroup:insert(button)

            --box:addEventListener( "touch", levelButton)
         else
            local lock = display.newImage( group, lockimage, 0, 40)
            lock.xScale = .175
            lock.yScale = .175
         end

         group.x = i2 * 200 - 65
         if ( i2 % 5 == 0) then
            i2 = 1
         else
            i2 = i2 + 1
         end 

         group.y = j
         if (i % 5 == 0) then
            j = j + 200
         end



         sceneGroup:insert(group)
   end

   local homeButton = display.newGroup( )
   local homeButtonBox = display.newRoundedRect( homeButton, 0, 0, 100, 100, 15)
   local homeButtonImage = display.newImage(homeButton, homebuttonpic, 0, 0)
   homeButtonImage.xScale = .1
   homeButtonImage.yScale = .1
   homeButton.x = 100
   homeButton.y = display.contentHeight - 100

   local function homeButtonListener( event )
      local muted = composer.getVariable( "muted" )
      if (not muted) then
            audio.play(menuSound); --play sound effect of menu selection
      end
      composer.gotoScene("menu")
   end

   homeButton:addEventListener( "touch", homeButtonListener )

   sceneGroup:insert(homeButton)

   local optionsButton = display.newGroup( )
   local optionsButtonBox = display.newRoundedRect( optionsButton, 0, 0, 100, 100, 15)
   local optionsButtonImage = display.newImage(optionsButton, settingsbuttonimage, 0, 0)
   optionsButtonImage.xScale = .05
   optionsButtonImage.yScale = .05
   optionsButton.x = display.contentWidth  -100
   optionsButton.y = display.contentHeight - 100

   local function optionsButtonListener( event )
      local muted = composer.getVariable( "muted" )
      if (not muted) then
            audio.play(menuSound); --play sound effect of menu selection
      end
      composer.gotoScene("options")
   end

   optionsButton:addEventListener( "touch", optionsButtonListener )

   sceneGroup:insert(optionsButton)
   -- Initialize the scene here.
   -- Example: add display objects to "sceneGroup", add touch listeners, etc.
end
 
-- "scene:show()"
function scene:show( event )
 
   local sceneGroup = self.view
   local phase = event.phase
 
   if ( phase == "will" ) then
      -- Called when the scene is still off screen (but is about to come on screen).
   elseif ( phase == "did" ) then
      -- Called when the scene is now on screen.
      -- Insert code here to make the scene come alive.
      -- Example: start timers, begin animation, play audio, etc.
   end
end
 
-- "scene:hide()"
function scene:hide( event )
 
   local sceneGroup = self.view
   local phase = event.phase
 
   if ( phase == "will" ) then
      -- Called when the scene is on screen (but is about to go off screen).
      -- Insert code here to "pause" the scene.
      -- Example: stop timers, stop animation, stop audio, etc.
   elseif ( phase == "did" ) then
      -- Called immediately after scene goes off screen.
   end
end
 
-- "scene:destroy()"
function scene:destroy( event )
 
   local sceneGroup = self.view
 
   -- Called prior to the removal of scene's view ("sceneGroup").
   -- Insert code here to clean up the scene.
   -- Example: remove display objects, save state, etc.
end
 
---------------------------------------------------------------------------------
 
-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
 
---------------------------------------------------------------------------------
 
return scene