local composer = require( "composer" )
local scene = composer.newScene()
local widget = require("widget")
local inspect = require("inspect")
local loadsave = require("loadsave")


---------------------------------------------------------------------------------
-- All code outside of the listener functions will only be executed ONCE
-- unless "composer.removeScene()" is called.
---------------------------------------------------------------------------------
 
-- local forward references should go here
 
---------------------------------------------------------------------------------
 
-- "scene:create()"

speakeronimage = "assets/graphics/speakeron.png"
speakeroffimage = "assets/graphics/speakeroff.png"
homebuttonpic = "assets/graphics/home.png"
local menuSound = audio.loadSound("assets/sound/menu.mp3");



function scene:create( event )
 
   local sceneGroup = self.view

   local muted = composer.getVariable( "muted" )

   local box = display.newGroup( )
   local boxbox = display.newRoundedRect( box, 0, 0, 1000, 1000, 15 )
   local boximage = nil
   if (muted) then
      local boximage = display.newImage(box, speakeroffimage)
      boximage.xScale = 1.25
      boximage.yScale = 1.25
   else
      local boximage = display.newImage(box, speakeronimage)
      boximage.xScale = 1.25
      boximage.yScale = 1.25
   end

   box.x = display.contentCenterX
   box.y = display.contentCenterY - 300




   local function listener( event )

      local muted = composer.getVariable( "muted" )
      if (not muted) then
            audio.play(menuSound); --play sound effect of menu selection
      end
      if (muted) then
         composer.setVariable( "muted", false )
         muted = false
         box[2]:removeSelf( )
         box[2] = display.newImage(box, speakeronimage)
         box[2].xScale = 1.25
         box[2].yScale = 1.25
      else
         composer.setVariable( "muted", true )
         muted = true
         box[2]:removeSelf( )
         box[2] = display.newImage(box, speakeroffimage)
         box[2].xScale = 1.25
         box[2].yScale = 1.25
      end

      local settings = loadsave.loadTable("settings.json")
      settings["muted"] = muted

      loadsave.saveTable(settings, "settings.json")

   end

   box:addEventListener( "tap", listener )

   sceneGroup:insert(box)

   local homeButton = display.newGroup( )
   local homeButtonBox = display.newRoundedRect( homeButton, 0, 0, 1000, 500, 15 )

   homeButton.x = display.contentCenterX
   homeButton.y = display.contentCenterY + 500

   sceneGroup:insert(homeButton)


   local function homeButtonListener( event )
      if (event.phase == "ended") then
         local muted = composer.getVariable( "muted" )
         if (not muted) then
               audio.play(menuSound); --play sound effect of menu selection
         end

         timer.cancelAll( )
         physics.start()
         composer.gotoScene("menu")
         composer.removeScene( "game")
      end
   end

   local homeButtonButton = widget.newButton(
      {
         onEvent = homeButtonListener,
         width = 90,
         height = 90,
         defaultFile = homebuttonpic
      }
   );

   homeButtonButton.x = display.contentCenterX
   homeButtonButton.y = display.contentCenterY + 500
   homeButtonButton.xScale = 5
   homeButtonButton.yScale = 5

   local whitebutton = widget.newButton({
            onEvent = homeButtonListener,
            left = 100,
            top = display.contentCenterY + 500,
         }
      )

   whitebutton.height = 500
   whitebutton.width = 500

   local whitebutton2 = widget.newButton({
         onEvent = homeButtonListener,
         left = display.contentWidth - 100,
         top = display.contentCenterY + 500,
      }
   )

   whitebutton2.height = 500
   whitebutton2.width = 200

   sceneGroup:insert(homeButtonButton)
   sceneGroup:insert(whitebutton)
   sceneGroup:insert(whitebutton2)

   -- Initialize the scene here.
   -- Example: add display objects to "sceneGroup", add touch listeners, etc.
end
 
-- "scene:show()"
function scene:show( event )
 
   local sceneGroup = self.view
   local phase = event.phase
 
   if ( phase == "will" ) then

      local muted = composer.getVariable( "muted" )

      if (muted) then

      else

      end

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