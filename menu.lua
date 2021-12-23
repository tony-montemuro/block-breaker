local composer = require( "composer" )
local widget = require("widget")
local scene = composer.newScene()

 
---------------------------------------------------------------------------------
-- All code outside of the listener functions will only be executed ONCE
-- unless "composer.removeScene()" is called.
---------------------------------------------------------------------------------
 
-- local forward references should go here
 
---------------------------------------------------------------------------------
 
-- "scene:create()"

local menuSound = audio.loadSound("assets/sound/menu.mp3");
local titletopimagepath = "assets/graphics/titleimg1.png"
local titlebottomimagepath = "assets/graphics/titleimg2.jpg"
local levelsimagepath = "assets/graphics/levelimg.png"
local optionsimagepath = "assets/graphics/optionsimg.png"
local creditsimagepath = "assets/graphics/creditsimg.png"

function scene:create( event )
 
   local sceneGroup = self.view

   --local title = display.newText(sceneGroup, "BLOCK BREAKER", display.contentCenterX, display.contentCenterY - 500)
   local titletop = display.newImage(sceneGroup, titletopimagepath)
   titletop.x = display.contentCenterX
   titletop.y = display.contentCenterY - 500
   titletop.xScale = .75--.82
   titletop.yScale = .75--.82
   --title.size = 115

   local titlebottom = display.newImage(sceneGroup, titlebottomimagepath)
   titlebottom.x = display.contentCenterX
   titlebottom.y = display.contentCenterY - 300
   titlebottom.xScale = .75--.82
   titlebottom.yScale = .75--.82

   local function levelsButtonHandler( event )
      -- body
      local muted = composer.getVariable( "muted" )
      if (not muted) then
            audio.play(menuSound); --play sound effect of menu selection
      end
      composer.gotoScene( "levels")
   end

   local levelsButton = widget.newButton( {
      height = 300,
      width = 1000,
      defaultFile = levelsimagepath,
      onPress = levelsButtonHandler
   } )

   levelsButton.x = display.contentCenterX
   levelsButton.y = display.contentCenterY + 50
   levelsButton.yScale = .6
   levelsButton.xScale = .6

   sceneGroup:insert(levelsButton)

   --local optionsbox = display.newGroup( )
   --local optionsBoxBlock = display.newRoundedRect(optionsbox, 0, 0, 250, 200, 15)
   --local optionsBoxText = display.newText(optionsbox, "OPTIONS", 0, 0)
   --optionsBoxText:setFillColor( 0, 0, 0)

   local function optionsButtonHandler( event )
      -- body
      local muted = composer.getVariable( "muted" )
      if (not muted) then
            audio.play(menuSound); --play sound effect of menu selection
      end
      composer.gotoScene( "options")
   end

   local optionsButton = widget.newButton( {
      height = 300,
      width = 1000,
      defaultFile = optionsimagepath,
      onPress = optionsButtonHandler
   } )

   optionsButton.x = display.contentCenterX
   optionsButton.y = display.contentCenterY + 250
   optionsButton.yScale = .6
   optionsButton.xScale = .6

   sceneGroup:insert(optionsButton)

   local function creditsButtonHandler( event )
      -- body
      local muted = composer.getVariable( "muted" )
      if (not muted) then
            audio.play(menuSound); --play sound effect of menu selection
      end
      composer.gotoScene( "credits")
   end

   local creditsButton = widget.newButton( {
      height = 300,
      width = 1000,
      defaultFile = creditsimagepath,
      onPress = creditsButtonHandler
   } )

   creditsButton.x = display.contentCenterX
   creditsButton.y = display.contentCenterY + 450
   creditsButton.yScale = .6
   creditsButton.xScale = .6

   sceneGroup:insert(creditsButton)
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