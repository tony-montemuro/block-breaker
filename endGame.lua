local composer = require( "composer" )
local scene = composer.newScene()
local widget = require("widget")
local inspect = require("inspect")

---------------------------------------------------------------------------------
-- All code outside of the listener functions will only be executed ONCE
-- unless "composer.removeScene()" is called.
---------------------------------------------------------------------------------
 
-- local forward references should go here
 
---------------------------------------------------------------------------------
 
-- "scene:create()"

homebuttonpic = "assets/graphics/home.png"
settingsbuttonimage = "assets/graphics/settings.png"


function scene:create( event )
 
   local sceneGroup = self.view

   
   local winText = display.newText( sceneGroup, "CONGRATS ON BEATING OUR GAME", display.contentCenterX, display.contentCenterY - 500 )
   winText:setFillColor( 1, 1, 1 )


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