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

homebuttonpic = "assets/graphics/home.png"
goldstarimage = "assets/graphics/goldstar.png"
blackstarimage = "assets/graphics/blackstar.png"


function scene:create( event )
 
   local sceneGroup = self.view

   params = event.params


   local box = display.newRoundedRect( sceneGroup, display.contentCenterX, display.contentCenterY - 100, 750, 1000, 15 )
   box:setFillColor( .25, .25, .25, .9 )

   if (event.params.win == true) then
      local winText = display.newText( sceneGroup, "WIN", display.contentCenterX, display.contentCenterY - 500 )
      local nextButton = display.newGroup( )
      local nextButtonBox = display.newRoundedRect( nextButton, 0, 0, 200, 100, 15 )
      local nextButtonText = display.newText( nextButton, "NEXT", 0, 0)
      nextButtonText:setFillColor( 0, 0, 0)
      nextButton.x = display.contentCenterX
      nextButton.y = display.contentCenterY + 150

      local function nextButtonListener( event )
         if (event.numTaps == 1) then
            if (params.level == 40) then
               timer.cancelAll( )
               composer.removeScene( "game")
               composer.hideOverlay("winlose")
               composer.gotoScene("endGame")
            else
               params["level"] = params["level"] + 1
               options = {
                  params = params
               }
               timer.cancelAll( )
               physics.start()
               composer.removeScene( "game")
               composer.removeScene( "winlose")
               composer.gotoScene( "game", options)
            end
         end
      end

      nextButton:addEventListener( "tap", nextButtonListener )

      sceneGroup:insert(nextButton)

      print(params["stars"])

      local star1 = nil
      local star2 = nil
      local star3 = nil

      if (params["stars"] == 3) then
         star1 = display.newImage(goldstarimage, display.contentCenterX-175, display.contentCenterY - 250)
         star2 = display.newImage(goldstarimage, display.contentCenterX, display.contentCenterY- 250)
         star3 = display.newImage(goldstarimage, display.contentCenterX+175, display.contentCenterY - 250)
      elseif (params["stars"] == 2) then
         star1 = display.newImage(goldstarimage, display.contentCenterX-175, display.contentCenterY - 250)
         star2 = display.newImage(goldstarimage, display.contentCenterX, display.contentCenterY- 250)
         star3 = display.newImage(blackstarimage, display.contentCenterX+175, display.contentCenterY - 250)
      elseif (params["stars"] == 1) then
         star1 = display.newImage(goldstarimage, display.contentCenterX-175, display.contentCenterY - 250)
         star2 = display.newImage(blackstarimage, display.contentCenterX, display.contentCenterY- 250)
         star3 = display.newImage(blackstarimage, display.contentCenterX+175, display.contentCenterY - 250)
      else
         star1 = display.newImage(blackstarimage, display.contentCenterX-175, display.contentCenterY - 250)
         star2 = display.newImage(blackstarimage, display.contentCenterX, display.contentCenterY- 250)
         star3 = display.newImage(blackstarimage, display.contentCenterX+175, display.contentCenterY - 250)
      end

      star1.xScale = 3
      star2.xScale = 3
      star3.xScale = 3
      star1.yScale = 3
      star2.yScale = 3
      star3.yScale = 3

      sceneGroup:insert(star1)
      sceneGroup:insert(star2)
      sceneGroup:insert(star3)

      local savedata = loadsave.loadTable("savedata.json")
      if (params.level ~= 40) then
         savedata[params.level + 1]["unlocked"] = true
      end

      if (savedata[params.level]["stars"] < params["stars"]) then
         savedata[params.level]["stars"] = params["stars"]
      end
      loadsave.saveTable(savedata, "savedata.json")
   else
      local loseText = display.newText( sceneGroup, "LOSE", display.contentCenterX, display.contentCenterY - 500 )
   end

   local resetButton = display.newGroup( )
   local resetButtonBox = display.newRoundedRect( resetButton, 0, 0, 200, 100, 15 )
   local resetButtonText = display.newText( resetButton, "RESET", 0, 0)
   resetButtonText:setFillColor( 0, 0, 0)
   resetButton.x = display.contentCenterX
   resetButton.y = display.contentCenterY

   local function resetButtonListener( event )
      local options = {
         params = params
      }
      timer.cancelAll( )
      physics.start()
      composer.removeScene( "game")
      composer.removeScene( "winlose")
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
      timer.cancelAll( )
      physics.start()
      composer.gotoScene("menu")
      composer.removeScene( "game")
   end

   homeButton:addEventListener( "touch", homeButtonListener )

   sceneGroup:insert(homeButton)



 
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