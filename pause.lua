local composer = require( "composer" )
local scene = composer.newScene()
local widget = require("widget")
local physics = require("physics")
local loadsave = require("loadsave")


---------------------------------------------------------------------------------
-- All code outside of the listener functions will only be executed ONCE
-- unless "composer.removeScene()" is called.
---------------------------------------------------------------------------------
 
-- local forward references should go here
 
---------------------------------------------------------------------------------
 
-- "scene:create()"

homebuttonpic = "assets/graphics/home.png"
xbuttonpic = "assets/graphics/xbutton.png"
speakeronimage = "assets/graphics/speakeron.png"
speakeroffimage = "assets/graphics/speakeroff.png"
local menuSound = audio.loadSound("assets/sound/menu.mp3");


function scene:create( event )
 
   local sceneGroup = self.view

   local params = event.params

   local box = display.newRoundedRect( sceneGroup, display.contentCenterX, display.contentCenterY - 100, 750, 1000, 15 )
   box:setFillColor( .25, .25, .25, .9 )

   local pauseText = display.newText( sceneGroup, "PAUSED", display.contentCenterX, display.contentCenterY - 500 )

   local resetButton = display.newGroup( )
   local resetButtonBox = display.newRoundedRect( resetButton, 0, 0, 200, 100, 15 )
   local resetButtonText = display.newText( resetButton, "RESET", 0, 0)
   resetButtonText:setFillColor( 0, 0, 0)
   resetButton.x = display.contentCenterX
   resetButton.y = display.contentCenterY

   local function resetButtonListener( event )
      local muted = composer.getVariable( "muted" )
      if (not muted) then
            audio.play(menuSound); --play sound effect of menu selection
      end
      local options = {
         params = params
      }
      timer.cancelAll( )
      physics.start()
      composer.removeScene( "game")
      composer.gotoScene( "game", options)
   end

   resetButton:addEventListener( "tap", resetButtonListener )

   sceneGroup:insert(resetButton)

   local homeButton = display.newGroup( )
   local homeButtonBox = display.newRoundedRect( homeButton, 0, 0, 100, 100, 15)
   local homeButtonImage = display.newImage(homeButton, homebuttonpic, 0, 0)
   homeButtonImage.xScale = .1
   homeButtonImage.yScale = .1
   homeButton.x = display.contentCenterX - 300
   homeButton.y = display.contentCenterY - 500

   local function homeButtonListener( event )
      local muted = composer.getVariable( "muted" )
      if (not muted) then
            audio.play(menuSound); --play sound effect of menu selection
      end
      timer.cancelAll( )
      physics.start()
      composer.gotoScene("menu")
      composer.removeScene( "game")
   end

   homeButton:addEventListener( "touch", homeButtonListener )

   sceneGroup:insert(homeButton)

   --[[local xButton = display.newGroup( )
   local xButtonBox = display.newRoundedRect( xButton, 0, 0, 100, 100, 15)
   local xButtonImage = display.newImage(xButton, xbuttonpic, 0, 0)
   xButtonImage.xScale = .4
   xButtonImage.yScale = .4
   xButton.x = display.contentCenterX + 300
   xButton.y = display.contentCenterY - 500

   local function xButtonListener( event )
      physics.start()
      composer.hideOverlay()
   end

   xButton:addEventListener( "tap", xButtonListener )

   sceneGroup:insert(xButton)]]--

   local xButtonBox = display.newRoundedRect( sceneGroup, display.contentCenterX + 300, display.contentCenterY - 500, 100, 100, 15)

   local function xButtonListener( event )
      if event.phase == "ended" then
         local muted = composer.getVariable( "muted" )
         if (not muted) then
               audio.play(menuSound); --play sound effect of menu selection
         end
         physics.start();
         composer.hideOverlay();
      end

   end

   local xButton = widget.newButton(
      {
         onEvent = xButtonListener,
         width = 90,
         height = 90,
         defaultFile = xbuttonpic
      }
   );

   xButton.x = display.contentCenterX + 300;
   xButton.y = display.contentCenterY - 500;

   sceneGroup:insert(xButton)

   local muted = composer.getVariable( "muted" )

   local mutebox = display.newGroup( )
   local muteboxbox = display.newRoundedRect( mutebox, 0, 0, 100, 100, 15 )
   
   mutebox.x = display.contentCenterX - 300
   mutebox.y = display.contentCenterY + 250

   local function listener( event )
      local muted = composer.getVariable( "muted" )
      if (not muted) then
            audio.play(menuSound); --play sound effect of menu selection
      end
      if (muted) then
         composer.setVariable( "muted", false )
         muted = false
         --mutebox[2]:removeSelf( )
         --mutebox[2] = display.newImage(mutebox, speakeronimage)
         --mutebox[2].xScale = .15
         --mutebox[2].yScale = .15
      else
         composer.setVariable( "muted", true )
         muted = true
         --mutebox[2]:removeSelf( )
         --mutebox[2] = display.newImage(mutebox, speakeroffimage)
         --mutebox[2].xScale = .15
         --mutebox[2].yScale = .15

      end

      local settings = loadsave.loadTable("settings.json")
      settings["muted"] = muted

      loadsave.saveTable(settings, "settings.json")

   end

   local speakerOpt = {
      frames = {
         {x = 80, y = 400, width = 260, height = 241},
         {x = 76, y = 83, width = 260, height = 241}
      }
   }

   local checkboxsheet = graphics.newImageSheet( "assets/graphics/speakerSpriteSheet.png", speakerOpt )

   if (muted) then
      startingimage = 1
      pushimage = 2
   else
      startingimage = 2
      pushimage = 1
   end

   local checkboxButton = widget.newSwitch(
       {
           left = display.contentCenterX,
           top = display.contentCenterX,
           style = "checkbox",
           id = "checkbox",
           width = 90,
           height = 90,
           sheet = checkboxsheet,
           frameOn = startingimage,
           frameOff = pushimage,
           onPress = listener
       }
   )

   checkboxButton.x = display.contentCenterX - 300
   checkboxButton.y = display.contentCenterY + 250

   sceneGroup:insert(mutebox)
   sceneGroup:insert(checkboxButton)

 
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