-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

-- VARIABLE DECLARATION --

--include libraries: composer and physics
local composer = require("composer");
local scene = composer.newScene();
local physics = require("physics");
local levelsData = require("levelsData")
local inspect = require("inspect")
local widget = require("widget")
local ballObj = require("Ball")
physics.start(); --enable physics
physics.setGravity(0, 0); --no gravity in this game
physics.setDrawMode("normal"); -- Overlays collision outlines on normal display objects
physics.setReportCollisionsInContentCoordinates( true )

--declare and define constant variables for screen positions
local ORIGIN_X, ORIGIN_Y            = display.screenOriginX, display.screenOriginY; --coordinates of screen origin (0, 0)
local SCREEN_WIDTH, SCREEN_HEIGHT   = display.contentWidth, display.contentHeight; --screen width and height
local CENTER_X, CENTER_Y            = display.contentCenterX, display.contentCenterY; --coordinates of screen center
local LEFT, RIGHT                   = ORIGIN_X, ORIGIN_X + SCREEN_WIDTH; --coordinates for the left-most and right-most positions
local TOP, BOTTOM                   = ORIGIN_Y, ORIGIN_Y + SCREEN_HEIGHT; --coordinates for the top-most and bottom-most positions

--define ceiling and floor heights
local FLOOR_HEIGHT, CEILING_HEIGHT = 150, 100;

--function that will convert 3 standard RGB value (0-255) to a value between (0-1)
local function formatColors(color1, color2, color3)
    return color1 / 255, color2 / 255, color3 / 255;
end

--declare and define constant color tables: each table holds the RGB values for each color
local RED           = {formatColors(255, 0, 0)};
local LIGHT_RED     = {formatColors(240, 15, 83)};
local PINK          = {formatColors(255, 128, 142)};
local DARK_RED      = {formatColors(134, 21, 21)};
local ORANGE        = {formatColors(255, 127, 39)};
local LIGHT_ORANGE  = {formatColors(255, 177, 15)};
local DARK_ORANGE   = {formatColors(211, 98, 14)}
local YELLOW        = {formatColors(255, 242, 0)};
local LIGHT_YELLOW  = {formatColors(248, 251, 125)};
local GREEN         = {formatColors(0, 255, 0)};
local DARK_GREEN    = {formatColors(30, 157, 68)};
local WHITE         = {formatColors(255, 255, 255)};
local LIGHTGREEN    = {formatColors(180, 230, 122)};
local GRAY          = {formatColors(125, 125, 125)};
local BLACK         = {formatColors(0, 0, 0)};

--collision filters
local wallCollisionFilter = {categoryBits = 1, maskBits = 2};
local ballCollisionFilter = {categoryBits = 2, maskBits = 1};

--flags
local running = false; --true if balls have been fired, false otherwise
local gameOver = false; --only becomes true if player fails to clear board
local paused = false; --true if player pauses game, otherwise false

--information about balls
local numBalls;
local prevNumBalls = 0; --used in physics logic
local ballRadius = 16;
local TRANSITION_TIME = 500;
local BALL_ORIGIN_X, BALL_ORIGIN_Y = CENTER_X, SCREEN_HEIGHT - FLOOR_HEIGHT - 17;
local blockLength;

--used to store blocks and balls
local blocks = {};
local balls = {}; --will store circle display objects which represent the balls

--Table has LAYOUT_WIDTH x LAYOUT_HEIGHT dimension
local LAYOUT_HEIGHT;
local LAYOUT_WIDTHT;

--gui elements
local ballsText;

-- GLOBAL FUNCTIONS --

function setBlockColor(block, blockNum)
    if blockNum <= 10 then
        block:setFillColor(unpack(LIGHTGREEN));
    elseif blockNum <= 20 then
        block:setFillColor(unpack(GREEN));
    elseif blockNum <= 30 then
        block:setFillColor(unpack(DARK_GREEN));
    elseif blockNum <= 40 then
        block:setFillColor(unpack(LIGHT_YELLOW));
    elseif blockNum <= 50 then
        block:setFillColor(unpack(YELLOW));
    elseif blockNum <= 60 then
        block:setFillColor(unpack(LIGHT_ORANGE));
    elseif blockNum <= 70 then
        block:setFillColor(unpack(ORANGE));
    elseif blockNum <= 80 then
        block:setFillColor(unpack(DARK_ORANGE));
    elseif blockNum <= 90 then
        block:setFillColor(unpack(RED));
    else
        block:setFillColor(unpack(DARK_RED));
    end
end

-- ASSETS --

-- AUDIO --

local blockSound = audio.loadSound("assets/sound/block.mp3");
local bombSound = audio.loadSound("assets/sound/bomb.mp3");
local bombTickSound = audio.loadSound("assets/sound/bomb-tick.mp3");
local laserSound = audio.loadSound("assets/sound/laser.mp3");
local ballOrbSound = audio.loadSound("assets/sound/ball.mp3");
local menuSound = audio.loadSound("assets/sound/menu.mp3");
local loseSound = audio.loadSound("assets/sound/level-fail.mp3");
local winSound = audio.loadSound("assets/sound/level-complete.mp3");

-- GRAPHICS --

local bombPath = "assets/graphics/bomb-sprite-sheet.png";
local laserHorPath = "assets/graphics/laser-sprite-sheet.png";
local laserVerPath = "assets/graphics/laser-sprite-sheet-vertical.png";
local pausePath = "assets/graphics/pause.png";
local ffPath = "assets/graphics/fast-forward.png";
local nextTurnPath = "assets/graphics/next-turn.png";

--frame information for bomb sprite
local bombOpt = {
    frames = {
        {x = 318, y = 52, width = 84, height = 90},
        {x = 67, y = 242, width = 84, height = 90},
        {x = 293, y = 240, width = 115, height = 96},
        {x = 511, y = 213, width = 160, height = 147},
        {x = 11, y = 423, width = 195, height = 181},
        {x = 231, y = 405, width = 235, height = 216},
        {x = 469, y = 396, width = 244, height = 229}
    }
}
local bombSheet = graphics.newImageSheet(bombPath, bombOpt);

--properties of sprite animation
local bombSequenceData = {
    name = "explode",
    start = 1,
    count = 7,
    time = 120,
    loopCount = 1
};

--frame information for laser sprite
local laserHorOpt = {
    frames = {
        {x = 958, y = 158, width = 47, height = 32},
        {x = 77, y = 692, width = 1843, height = 52},
        {x = 958, y = 158, width = 47, height = 32}
    }
};
local laserHorSheet = graphics.newImageSheet(laserHorPath, laserHorOpt); --image sheet using the horizontal laser sprite sheet

local laserVerOpt = {
    frames = {
        {x = 364, y = 500, width = 31, height = 47},
        {x = 1315, y = 0, width = 31, height = 1035},
        {x = 364, y = 500, width = 31, height = 47}
    }
};
local laserVerSheet = graphics.newImageSheet(laserVerPath, laserVerOpt); --image sheet using the vertical laser sprite sheet

--properties of laser sprite animation
local laserSequenceData = 
{
    name = "shoot", 
    start = 1, 
    count = 3,
    time = 100, 
    loopCount = 1
};
 
-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------
 
-- create()
-- Code here runs when the scene is first created but has not yet appeared on screen
function scene:create(event)

    -- VARIABLES --
    composer.removeScene( "levels")
    launches = 0
    params = event.params
    level = tonumber(event.params.level)
    event.params = levelsData[level]
    starstable = {levelsData[level]["threestar"], levelsData[level]["twostar"], levelsData[level]["onestar"]}


    local sceneGroup = self.view;
    LAYOUT_WIDTH = event.params.tableLength;
    LAYOUT_HEIGHT = event.params.tableLength;
    numBalls = event.params.balls;


    -- FUNCTIONS --

    local function pauseFunc(event)
        --opens the pause menu overlay
        if event.phase == "ended" then
            local muted = composer.getVariable("muted");
            if (not muted) then
                audio.play(menuSound); --play sound effect of menu selection
            end
            local options = {
                params = params,
                isModal = true
            };
            physics.pause();
            composer.showOverlay("pause", options);
        end
    end

    local function positionGroup(x, y, group, length)
        --position each block using math
        local xOffset, yOffset = (length / 2) - 4, 50;
        local multiplier = 10;
        group.x = (x * length) - xOffset + (x * multiplier);
        group.y = (y * length) + (multiplier * y) + yOffset;
        group.xPos = x;
        group.yPos = y;
    end

    --important for the collision of the triangles
    local function setShapeParam(block, verticies)
        if verticies == nil then return end --this will always be true for square blocks
        for i = 1, #verticies do
            verticies[i] = verticies[i] - (blockLength / 2);
        end
        block.shape = verticies;
    end

    -- STAGE ELEMENTS --

    --Create border around playable area [floor is defined later]
    
    local leftWall  = display.newLine (LEFT, TOP, LEFT, BOTTOM);
    local rightWall = display.newLine (RIGHT, TOP, RIGHT, BOTTOM); --both walls are line objects
    local ceiling = display.newRect(CENTER_X, ORIGIN_Y + (CEILING_HEIGHT / 2), SCREEN_WIDTH, CEILING_HEIGHT);
    ceiling:setFillColor(unpack(GRAY));

    --Define the type of each border
    leftWall.type = "wall";
    rightWall.type = "wall";
    ceiling.type = "wall";

    --Turn each into physical objects (static)

    physics.addBody(leftWall, 'static', {filter = wallCollisionFilter});
    physics.addBody(rightWall, 'static', {filter = wallCollisionFilter});
    physics.addBody(ceiling, 'static', {filter = wallCollisionFilter});



    --Create blocks using blocksLayoutTable

   blockLength = event.params.blockLength; --this value is defined in 'levelsData.lua'
    for i = 1, LAYOUT_HEIGHT do
        blocks[i] = {};
        for j = 1, LAYOUT_WIDTH do
            local blockInfo = event.params.displayTable[j][i];
            local blockType = blockInfo[1];

            -- EMPTY SPACE --

            if (blockType == 0) then
                blocks[i][j] = nil;

            -- STANDARD BLOCKS --

            elseif blockType >= 1 and blockType <= 5 then --this is a standard block - either a square (1) or triangle (2-5)
                local group = display.newGroup();
                --properties of blocks
                local blockNum = blockInfo[2];
                --create block and corresponding text
                local block, text; --shape and text within shape
                local verticies; --defines the shape of the block [only used on triangles]
                local txtOffset = 20; --for the triangles text
                --Square block
                if blockType == 1 then
                    local blockCornerRadius = 10; --determines 'roundness' of blocks
                    block = display.newRoundedRect(0, 0, blockLength, blockLength, blockCornerRadius);
                    text = display.newText(blockNum, 0, 0);
                --Up-left triangle block
                elseif blockType == 2 then
                    verticies = {0, 0, blockLength, 0, 0, blockLength};
                    block = display.newPolygon(0, 0, verticies);
                    text = display.newText(blockNum, -txtOffset, -txtOffset, native.systemFont, 40);
                --Up-right triangle block
                elseif blockType == 3 then
                    verticies = {0, 0, blockLength, 0, blockLength, blockLength};
                    block = display.newPolygon(0, 0, verticies);
                    text = display.newText(blockNum, txtOffset, -txtOffset, native.systemFont, 40);
                --Down-left triangle block
                elseif blockType == 4 then
                    verticies = {0, 0, 0, blockLength, blockLength, blockLength};
                    block = display.newPolygon(0, 0, verticies);
                    text = display.newText(blockNum, -txtOffset, txtOffset, native.systemFont, 40);
                --Down-right triangle block
                else
                    verticies = {blockLength, 0, 0, blockLength, blockLength, blockLength};
                    block = display.newPolygon(0, 0, verticies);
                    text = display.newText(blockNum, txtOffset, txtOffset, native.systemFont, 40);
                end
                setShapeParam(block, verticies); --important for collision
                text:setFillColor(unpack(BLACK));
                setBlockColor(block, blockNum);
                --add each element to display group
                group:insert(block);
                group:insert(text);
                positionGroup(i, j, group, blockLength); --position the group on the screen
                group.type = "block"; --important during collision logic
                --turn group into physical object (static), and add to blocks table
                local shape = group[1].shape;
                if shape == nil then --square
                    physics.addBody(group, 'static', {density = 0, friction = 0, bounce = 0, filter = wallCollisionFilter});
                else --triangle
                    physics.addBody(group, 'static', {density = 0, friction = 0, bounce = 0, filter = wallCollisionFilter, shape = shape});
                end
                sceneGroup:insert(group);
                blocks[i][j] = group;

            -- LASER BLOCK --

            elseif blockType == 6 or blockType == 7 then
                local group = display.newGroup();
                --create block sprite
                local laserBlock;
                if blockType == 6 then
                    laserBlock = display.newSprite(laserHorSheet, laserSequenceData);
                    laserBlock:scale(2.04, 3.12);
                    laserBlock.orientation = "horizontal";
                else
                    laserBlock = display.newSprite(laserVerSheet, laserSequenceData);
                    laserBlock:scale(3.1, 2.1);
                    laserBlock.orientation = "vertical";
                end
                laserBlock:setSequence("shoot");
                --add each element to display group
                group:insert(laserBlock);
                positionGroup(i, j, group, blockLength); --position the group on the screen
                group.type = "laser"; --important during collision logic
                --turn group into physical object (static), and add to blocks table
                physics.addBody(group, 'static', {density = 0, friction = 0, bounce = 0, filter = wallCollisionFilter});
                group.isSensor = true; --collision will detect, but no physical response (other than animation)
                group.hasCollided = false; --flag that checks for collision (only for laser)
                sceneGroup:insert(group);
                blocks[i][j] = group;

            -- BOMB BLOCK --

            elseif blockType == 8 then
                local group = display.newGroup();
                --properties of bomb
                local bombNum = 30; --all bomb blocks have 30 health
                --create bomb sprite and corresponding text
                local text = display.newText(bombNum, -7, 10);
                text:setFillColor(unpack(WHITE));
                local bomb = display.newSprite(bombSheet, bombSequenceData);
                bomb:setSequence("explode");
                local bombScaleFactor = 1.15; --this scales the bomb to a correct size
                bomb:scale(bombScaleFactor, bombScaleFactor);
                --add each element to display group
                group:insert(bomb);
                group:insert(text);
                positionGroup(i, j, group, blockLength); --position the group on the screen
                group.type = "bomb"; --important during collision logic
                --turn group into physical object (static), and add to blocks table
                physics.addBody(group, 'static', {density = 0, friction = 0, bounce = 0, filter = wallCollisionFilter});
                sceneGroup:insert(group);
                blocks[i][j] = group;

            -- BALL ORB

            else 
                --properties of ball orb
                local group = display.newGroup();
                local ballOrb = display.newCircle(0, 0, 15);
                ballOrb:setFillColor(unpack(YELLOW));
                --add each element to display group
                group:insert(ballOrb);
                positionGroup(i, j, group, blockLength); --position the group on the screen
                group.type = "ball"; --important during collision logic
                --turn group into physical object (static), and add to blocks table
                physics.addBody(group, 'static');
                group.isSensor = true; --detects a collision but performs no physical resonse
                sceneGroup:insert(group);
                blocks[i][j] = group;
            end
        end
    end

    --Create 50 balls

    for i = 1, numBalls do
        --create ball, and create into physical object
        local ball = ballObj:new({id=i})--display.newCircle(BALL_ORIGIN_X, BALL_ORIGIN_Y, ballRadius);
        ball:spawn(BALL_ORIGIN_X, BALL_ORIGIN_Y, ballRadius, i)
        ball.id = i
        ball:setRunning(false)
        --Insert each ball into balls table, and scene group
        table.insert(balls, ball);
        sceneGroup:insert(ball:getShape());
    end

    -- UI ELEMENTS --

    --add each border to scene group

    sceneGroup:insert(leftWall);
    sceneGroup:insert(rightWall);
    sceneGroup:insert(ceiling);

    --Pause Button
    local btnWidth, btnHeight = 100, 100;
    --define pause button
    local pauseButton = widget.newButton(
        {
            width = btnWidth,
            height = btnHeight,
            defaultFile = pausePath,
            onEvent = pauseFunc
        }
    );
    --position button, and add to scene group
    pauseButton.x, pauseButton.y = 60, 50;
    sceneGroup:insert(pauseButton);


    --Create text that displays to user how many balls are left
    ballsText = display.newText({text = "Balls: ".. numBalls, x = 950, y = 50, font = native.systemFont});
    sceneGroup:insert(ballsText);

    --Reset physics timescale back to default

        local levelText = display.newText(sceneGroup, "Level: "..level, display.contentCenterX, 50)

    physics.setTimeScale(1);
end
 
 
-- show()
function scene:show( event )
 
    local sceneGroup = self.view
    local phase = event.phase

    local fys2d = false
    if ( phase == "will" ) then
        -- Code here runs when the scene is still off screen (but is about to come on screen)
 
    elseif ( phase == "did" ) then
        -- Code here runs when the scene is entirely on screen

        -- FUNCTIONS --

        --called when fast forward button is pressed
        local function speedFunc(event)
            --toggles between normal and fast game state
            local muted = composer.getVariable( "muted" )
            if (not muted) then
                audio.play(menuSound); --play sound effect of menu selection
            end
            local gameSpeed = physics.getTimeScale();
            local normalSpeed, fastSpeed = 1, 5;
            if (gameSpeed == normalSpeed) then
                physics.setTimeScale(fastSpeed);
            else
                physics.setTimeScale(normalSpeed);
            end
            return true;
        end

        --function that is called that will end the game
        --plays the appropriate sound effect depending on win/loss, and transition to the end screen overlay
        local function endGame(sfx, hasWon)
            local muted = composer.getVariable("muted")
            if (not muted) then
                audio.play(sfx); --play sound effect
            end
            --If player has won, run the following code
            if (hasWon) then
                fys2d = true;
                timer.performWithDelay( 30, function()
                    physics.stop(); --this will prevent collisions after the game has ended
                end, 1);
                params["win"] = true;
                params['stars'] = 0;
                local j = 3;
                --Determine how many stars the user will receive, based on number of launches required to win
                for i=1, 3 do
                    if (launches <= starstable[i]) then
                        params['stars'] = j;
                        break;
                    end
                    j = j - 1;
                end
            else
                fys2d = true;
                timer.performWithDelay( 30, function()
                    physics.stop(); --this will prevent collisions after the game has ended
                end, 1);
                params["win"] = false;
            end
            --Switch to winlose overlay
            local options = {
                isModal = true,
                effect = "fade",
                time = 400,
                params = params
            };
            composer.showOverlay( "winlose", options);
        end

        --function that will delete any block that is passed to it
        --Removes itself from the screen, memory, and pointer in blocks array is set to nil
        local function deleteBlock(obj)
            local x, y = obj.xPos, obj.yPos;
            obj:removeSelf();
            blocks[x][y] = nil;
        end

        local function moveBlocks()
            local hasWon = true; --flag that determines if player won or not
            for i=1, LAYOUT_HEIGHT do
                for j=1, LAYOUT_WIDTH do
                    local block = blocks[i][j];
                    if block ~= nil then
                        --First, check for laser blocks that have had collision
                        --If they have collided during turn, remove them
                        if block.hasCollided == true and (block.type == "laser" or block.type == "shoot") then
                            deleteBlock(block); --if the block number has reached 0, then it is removed from screen and memory
                        else
                            hasWon = false;
                            local deltaY = blockLength; --shift each block down by 90
                            if block.y == nil then
                                print(inspect(block))
                            end
                            transition.to(block, {time = TRANSITION_TIME, x = x, y = block.y + deltaY});
                            if (block.y >= BOTTOM - (2 * FLOOR_HEIGHT) - blockLength/2) then
                                gameOver = true --occurs if blocks have transitioned at or below the floor
                            end
                        end
                    end
                end
            end
            --if hasWon is still true, then player has won
            if hasWon then
                endGame(winSound, true);
            end
            -- if gameOver is true, then player has lost
            if gameOver then
                endGame(loseSound, false);
            end
            running = false --running flag set back to false
            physics.setTimeScale(1)
        end

        local function resetBalls()
            local x, y = balls[1]:getX(), BALL_ORIGIN_Y
            for _,ball in ipairs(balls) do
                ball:transitionTo(TRANSITION_TIME, x, y) --moves all balls to position of first ball
            end
            --move the blocks to new position after TRANSITION_TIME ms
            timer.performWithDelay(TRANSITION_TIME, moveBlocks(), 1);
        end

        --Function is called when next turn (RETURN BALLS) button is pressed
        --This button will only activate if a turn is in play (running flag set to true)
        local function nextTurnButtonHandler( event )
            if (running) then
                --play menu sound
                local muted = composer.getVariable("muted");
                if (not muted) then
                    audio.play(menuSound); --play sound effect of menu selection
                end
                --set running flag to false
                running = false
                --Stop each ball
                for i=1,prevNumBalls do
                    balls[i]:getShape():setLinearVelocity( 0, 0)
                end
                --Cancel any timers
                timer.cancelAll( )
                --Move balls back to origin
                for i=1,prevNumBalls do
                    balls[i]:setX(BALL_ORIGIN_X)
                    balls[i]:setY(BALL_ORIGIN_Y)
                end
                --Call resetBalls method
                resetBalls();
            end
        end

        --This function updates a block after a collision
        --Precondition: block.type == "block"
        local function updateBlock(block)
            --block[2] - text in block. block[1] -- block itself
            block[2].text = block[2].text - 1; --decrement the number on the block by 1
            local num = tonumber(block[2].text);
            if (num == 0) then
                deleteBlock(block); --if the block number has reached 0, then it is removed from screen and memory
            else
                setBlockColor(block[1], num); --otherwise, the block color is updated to reflect it's new value
            end
        end

        local function ballCollision(self, event)
            local block = event.other; --object ball collides with
            local muted = composer.getVariable("muted");

            --CASE 1: Ball collides with a block
            if (event.phase == "began") then
                if (block.type == "block") then
                    if (not muted) then
                        audio.play(blockSound); --play sound effect of standard block collision
                    end
                    updateBlock(block);

                --CASE 2: Ball collides with laser block
                elseif (block.type == "laser" or block.type == "shoot") then
                    --Activate laser, which will reduce the health of each block horizontal/vertical to the block by 1
                    local lBlock = block[1];
                    if lBlock.orientation == "horizontal" then
                        for i = 1, LAYOUT_WIDTH do
                            local currentBlock = blocks[i][block.yPos];
                            if (currentBlock ~= nil and currentBlock.type == "block") then
                                updateBlock(currentBlock);
                            end
                        end
                    else
                        for i = 1, LAYOUT_HEIGHT do
                            local currentBlock = blocks[block.xPos][i];
                            if (currentBlock ~= nil and currentBlock.type == "block") then
                                updateBlock(currentBlock);
                            end
                        end
                    end
                    --Finally, set hasCollided flag to true
                    block.hasCollided = true;
                    --This code will ONLY run if the laser is not currently in a "shoot" animation
                    if block.type == "laser" then
                        block.type = "shoot"; --prevents laser animation from being played more than once
                        --First, play audio for laser fire
                        if (not muted) then
                            audio.play(laserSound); --play sound effect of standard block collision
                        end
                        lBlock:play(); --begin animation
                        --Set type back to laser after animation
                        timer.performWithDelay(100, function()
                            block.type = "laser"; --set type back to laser once animation has completed
                        end, 1);
                    end

                --CASE 3: Ball collides with bomb block
                elseif (block.type == "bomb") then
                    --First, get the new health of the bomb
                    --block[2] - text in bomb. block[1] -- bomb itself
                    local bombText = block[2].text;
                    local bombBlock = block[1];
                    num = tonumber(bombText) - 1;
                    --Now, check if bomb can explode or not (if heath has reached 0)
                    --Bomb can explode
                    if num == 0 then
                        --Explode the bomb
                        if (not muted) then
                            audio.play(bombSound); --play sound effect of bomb collision
                        end
                        bombBlock:play();
                        block.type = "void";
                        timer.performWithDelay(120, function()
                            --Destroy all blocks immediately surrounding the bomb block
                            local bombX, bombY = block.xPos, block.yPos;
                            for i = -1, 1 do
                                for j = -1, 1 do
                                    local xPos, yPos = i + bombX, j + bombY;
                                    --only check for blocks within the correct dimensions
                                    if (xPos <= LAYOUT_WIDTH and yPos <= LAYOUT_HEIGHT) and (xPos > 0 and yPos > 0) then
                                        local currentBlock = blocks[xPos][yPos];
                                        if (currentBlock ~= nil and (currentBlock.type == "block" or currentBlock.type == "laser")) then
                                            deleteBlock(currentBlock);
                                        end
                                    end
                                end
                            end
                            --Once 1 collision has occured between ball and bomb block, it disappears
                            deleteBlock(block);
                        end, 1);
                    --Bomb cannot explode
                    else
                        if (not muted) then
                            audio.play(bombTickSound);
                        end
                        --Update health of block
                        block[2].text = num;
                    end

                --CASE 4: Ball collides with ball orb
                elseif (block.type == "ball") then
                    if (not muted) then
                        audio.play(ballOrbSound); --play sound effect of ball orb collision
                    end
                    --Add ten balls per orb collected to the number of balls player has to work with (numBalls)
                    local newBalls = 10;
                    for i = 1, newBalls do
                        local ball = ballObj:new({id=i+numBalls});--display.newCircle(BALL_ORIGIN_X, BALL_ORIGIN_Y, ballRadius);
                        ball:spawn(BALL_ORIGIN_X, BALL_ORIGIN_Y, ballRadius);
                        table.insert(balls, ball);
                        --Insert each ball into balls table, and scene group
                        sceneGroup:insert(ball:getShape());
                    end
                --Update numBalls, and the hud message
                numBalls = numBalls + newBalls;
                ballsText.text = "Balls: " ..numBalls;
                    --Once 1 collision has occured between ball and ball orb, it disappears
                    deleteBlock(block);
                end
                --Note: Floor collision is handled later in the program
            end
        end

        local function sendBall(event)
            --Set the linear velocity of each ball
            currentBall:getShape():setLinearVelocity(vx, vy);
            if (currentBall.id + 1 <= numBalls) then
                currentBall = balls[currentBall.id + 1]; --update currentBall to next ball
            end
        end

        local function launchBalls(event)
            --Set each ball's running flag to true
            for _, ball in ipairs(balls) do
                ball.running = true;
            end
            currentBall = balls[1]; --set currentBall to the first ball
            local velocityMag = 1750; --the magnitude of the ball's velocity
            if (balls[1]:getX() == nil) then
                return
            end
            local vectorX = (event.x - balls[1]:getX()); --x-component of the vector represeting the distance between ball's origin and user release
            local vectorY = (event.y - BALL_ORIGIN_Y); --y-component of the vector represeting the distance between ball's origin and user release
            local vectorMag = math.sqrt(math.pow(vectorX, 2) + math.pow(vectorY, 2)); --finds the magnitude of vector
            vx = velocityMag * (vectorX / vectorMag); --multiply x-component of unit vector (magnitude 1) by 30
            vy = velocityMag * (vectorY / vectorMag); --multiply y-component of unit vector (magnitude 1) by 30
            timer.performWithDelay(TRANSITION_TIME / 10, sendBall, numBalls); --send all 50 balls, with a delay of TRANSITION_TIME / 10 between each shot
        end

        local function fireBalls(event)
            if (fys2d) then
                return
            end

            if (running == false and event.y < BOTTOM - FLOOR_HEIGHT- 50) then --only works if the running flag is set to false, and user released above floor
                --Create path preview for ball trajectory
                if (event.phase == "moved") then
                    -- Remove trajectory path group (to clear previous path), then re-create it
                    local ball = balls[1];
        	        display.remove(predictedPath);
        	        predictedPath = display.newGroup();
                    local predictedX, predictedY = event.x, event.y;
                    local hits = physics.rayCast(ball:getX(), ball:getY(), predictedX, predictedY, "closest");
                    local line;
                    --This will create a path from the ball to the next physical body between the player's touch and ball
                    if (hits) then
                        local obj1 = hits[1];
                        if (ball:getX() == nil) then
                            return
                        end
            	        line = display.newLine(predictedPath, ball:getX(), ball:getY(), obj1.position.x, obj1.position.y);
                    --This will create a path from the ball to the player's touch: no physical bodies are located between the two
                    else
                        if (ball:getX() == nil) then
                            return
                        end
            	        line = display.newLine(predictedPath, ball:getX(), ball:getY(), predictedX, predictedY);
                    end
                    line.strokeWidth = 5;
                    if(event.y<=100) then
                        display.remove(predictedPath);
                        return;
                    end

                elseif (event.phase == "ended") then
                    --First, remove path preview
                    display.remove(predictedPath);
                    if(event.y<=100) then
                        return
                    end
                    running = true; --set running flag to true
                    --this is for any new balls: turn into physical object, add collision, and event listener
                    --Has to be done in this section of the code due to a bug with how Solar2D functions
                    --This code should only run one time per ball!
                    for i = prevNumBalls+1, numBalls do
                        if (balls[i]:getX() == nil) then
                            return
                        end
                        --Turn each new ball into a physical body
                        balls[i]:addBody(ballCollisionFilter, ballCollision);
                    end
                    prevNumBalls = numBalls; --this ensures that the code above only runs once per ball
                    launchBalls(event); --launch balls
                    launches = launches + 1; --increment launch count: used to compute star counter
                end
            end
            return true;
        end

        local function floorCollision( event )
            if (event.phase == "began") then
                balls[event.other.pp.id]:setRunning(false)
                event.other:setLinearVelocity( 0, 0 )
                for _, ball in ipairs(balls) do
                    if (ball:getRunning() == true) then
                       return; --If any balls in the ball table are still running (haven't touched floor), break out of function
                    end
                end
                --If function is still going at this point, it means all balls have stopped, so reset balls!
                resetBalls();
            end
        end

        -- MORE SCREEN ELEMENTS --

        --Create floor
        local floor = display.newRect(CENTER_X, SCREEN_HEIGHT - (FLOOR_HEIGHT / 2), SCREEN_WIDTH, FLOOR_HEIGHT); --both wall and ceiling are rectangle objects
        floor:setFillColor(unpack(GRAY));
        physics.addBody(floor, 'static', {filter = wallCollisionFilter});
        floor.type = "floor";
        floor:addEventListener("collision", floorCollision); -- floorCollision 
        --Insert floor to scene group
        sceneGroup:insert(floor);

        --Speed button: allows user to toggle game between a normal state and a sped up state
        local speedButton = display.newImage(ffPath, SCREEN_WIDTH - 100, SCREEN_HEIGHT-75); --speed button: toggle between normal and sped up state
        local ffScaleFactor = 0.4;
        speedButton:scale(ffScaleFactor, ffScaleFactor);
        speedButton:addEventListener("tap", speedFunc);
        sceneGroup:insert(speedButton); --add button to scene group
        
        --Next turn button: allows user to skip to next turn and return balls to starting position
        local nextTurnX, nextTurnY = CENTER_X, SCREEN_HEIGHT - 75;
        local nextTurnButton =widget.newButton( {
                x = nextTurnX,
                y = nextTurnY,
                defaultFile = nextTurnPath,
                onEvent = nextTurnButtonHandler
            }
        )
        --Insert next turn button to scene group
        sceneGroup:insert(nextTurnButton);

        Runtime:addEventListener("touch", fireBalls); --touch event for fireBalls
    end

end
 
 
-- hide()
function scene:hide( event )
 
    local sceneGroup = self.view
    local phase = event.phase
 
    if ( phase == "will" ) then
        -- Code here runs when the scene is on screen (but is about to go off screen)
 
    elseif ( phase == "did" ) then
        -- Code here runs immediately after the scene goes entirely off screen
 
    end
end
 
 
-- destroy()
function scene:destroy( event )
 
    local sceneGroup = self.view
    -- Code here runs prior to the removal of scene's view
    
    for _,ball in ipairs(balls) do
        ball:delete()
    end

end
 
 
-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
-- -----------------------------------------------------------------------------------
 
return scene