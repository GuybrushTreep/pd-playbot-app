--
-- SceneTemplate.lua
--
-- Use this as a starting point for your game's scenes.
-- Copy this file to your root "scenes" directory,
-- and rename it.
--

-- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
-- !!! Rename "SceneTemplate" to your scene's name in these first three lines. !!!
-- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
import 'Modules/BatteryLevel'
import 'Modules/StateMachine'
import 'Modules/MessageHandler'

local ExplorationBehavior = import 'Behaviors/ExplorationBehavior'
local StaticBehavior = import 'Behaviors/StaticBehavior'
local SquareBehavior = import 'Behaviors/SquareBehavior'
local TrailerBehavior = import 'Behaviors/TrailerBehavior'
local gfx <const> = playdate.graphics
Intro = {}

class("PlayGround").extends(NobleScene)
local scene = PlayGround
local msg = ""

local play = false
local batteryTimer = nil
local isCharging = false
local showLog = false
local batt = BatteryLevel()
local bumpTreshold = 1.8
local isSleeping = true
local isEdgeDetected = false
local isRobotConnected = false
local isRobotColliding = false
local isChargeConnected = false

local crankRotation = 0
local crankTurns = 0
local isCrankMoving = false
local crankStopTimer = nil
local isCrankStartDetected = false
-- Audio threshold detection
local threshold = 0.25 -- Adjust between 0.0 and 1.0
local isListening = false
-- Inactivity detection

local INACTIVITY_TIMEOUT = 3 * 60 * 1000 -- 1 minutes in milliseconds

-- Load crank sound at initialization
local crankSound = playdate.sound.sampleplayer.new("Assets/sounds/ChargeON")
local crankTick = playdate.sound.sampleplayer.new("Assets/sounds/FishingRod_03")
-- Base pitch configuration
local basePitch = 0.8
local pitchIncrement = 0.2 -- Pitch increase per turn
local maxPitch = 3.0       -- Maximum pitch allowed
local getCrankTicks <const> = playdate.getCrankTicks
local charging = false
local menu = playdate.getSystemMenu()
-- This is the background color of this scene.
scene.backgroundColor = Graphics.kColorBlack

-- This runs when your scene's object is created, which is the
-- first thing that happens when transitining away from another scene.
function scene:init()
    scene.super.init(self)
    MessageHandler:add(self, self.handleMessage)
    self.stateMachine = StateMachine(false)

    self:initInputHandler()
    -- Add behaviors
    local explorationBehavior = ExplorationBehavior:new()
    local staticBehavior = StaticBehavior:new()
    local squareBehavior = SquareBehavior:new()
    local trailerBehavior = TrailerBehavior:new()
    explorationBehavior:setScene(self)
    staticBehavior:setScene(self)
    squareBehavior:setScene(self)
    self.stateMachine:addBehavior("exploration", explorationBehavior, "introStart")
    self.stateMachine:addBehavior("square", squareBehavior, "squareStart")
    self.stateMachine:addBehavior("static", staticBehavior, "introStart")
    self.stateMachine:addBehavior("trailerBehavior", trailerBehavior, "idle1")
    -- Set initial behavior
    self.stateMachine:setBehavior("static")

    self.crankRotation = 0
    self.crankTurns = 0
    self.crankDirection = 0
    self.rotationSinceLastTurn = 0
    self.isCrankMoving = false
    self.crankStopTimer = nil
    self.lastCrankState = playdate.isCrankDocked()
    batt:add()
    batt:moveTo(373, 2)
    scene:initMicrophoneDetection()
    self.connectionTimer = playdate.timer.new(5000, function()
        if not isRobotConnected then
            print("v")
        end
    end)
    self.connectionTimer.repeats = true
    self.inactivityTimer = playdate.timer.new(INACTIVITY_TIMEOUT, function()
        if self.stateMachine and self.stateMachine.currentState ~= "sleeping" then
            self.stateMachine:setState("fallAsleep")
        end
    end)

    menu:removeAllMenuItems()
    --menu:removeMenuItem("Options")
    menu:addMenuItem("Options", function()
        Noble.transition(Menu, 0.35, Noble.Transition.MetroNexus)
    end)
end

-- When transitioning from another scene, this runs as soon as this
-- scene needs to be visible (this moment depends on which transition type is used).
function scene:enter()
    scene.super.enter(self)
    -- Your code here
    batteryTimer = playdate.timer.performAfterDelay(2000, function() scene:getBatteryLevel() end) -- check battery level every 5 secondes
    batteryTimer.repeats = true
    playdate.startAccelerometer()
end

-- This runs once a transition from another scene is complete.
function scene:start()
    scene.super.start(self)
    -- Your code here
    if scene.nextBehavior then
        self:changeBehavior(scene.nextBehavior)
        scene.nextBehavior = nil -- Clear it after use
    end
end

-- This runs once per frame.
function scene:update()
    scene.super.update(self)
    -- Your code here
    self.stateMachine:update()



    if isCrankMoving and crankStopTimer and crankStopTimer.timeLeft == 0 then
        self:crankStopped()
    end
end

function scene:restartInactivityTimer()
    if self.inactivityTimer then
        self.inactivityTimer:remove()
    end
    self.inactivityTimer = playdate.timer.new(INACTIVITY_TIMEOUT, function()
        if self.stateMachine and self.stateMachine.currentState ~= "sleeping" then
            self.stateMachine:setState("fallAsleep")
        end
    end)
end

function scene:initMicrophoneDetection()
    -- startListening returns two values that we need to capture
    local success, source = playdate.sound.micinput.startListening("device")

    if success then
        isListening = true
        print("Microphone initialized from: " .. source)
    else
        print("Failed to initialize microphone")
        return false
    end

    -- Test if we're really listening
    local currentSource = playdate.sound.micinput.getSource()
    if currentSource then
        print("Confirmed microphone source: " .. currentSource)
    end

    return success
end

function PlayGround:handleMessage(key, message)
    -- Store the full message
    msg = message
    -- Extract the first character of the message
    local val = string.sub(msg, 1, 1)

    -- Process different types of messages
    if val == "b" then -- Battery values
        local values = {}
        for value in string.gmatch(msg, "[^/]+") do
            table.insert(values, value)
        end

        if #values >= 5 then
            local batPercent = tonumber(values[2])
            local batVolt = tonumber(values[3])
            local isCharging = tonumber(values[4]) == 1
            local alertLevel = tonumber(values[5])

            -- Store previous alert level for comparison
            local previousAlertLevel = batt:getAlertLevel()

            -- Update battery info
            batt:setBatteryLevel(batPercent)
            batt:setChargingState(isCharging)
            batt:setAlertLevel(alertLevel)

            -- Only change state if alert level has changed
            if alertLevel ~= previousAlertLevel then
                if alertLevel == 2 then
                    self.stateMachine:setState("criticalBattery")
                elseif alertLevel == 1 then
                    self.stateMachine:setState("lowBattery")
                end
            end
        end
    elseif val == "e" then -- Edge detection
        local edgeType = tonumber(string.sub(msg, 3))
        isEdgeDetected = true
    elseif val == "s" then -- Robot connection
        isRobotConnected = true
        self.connectionTimer:remove()
        scene:getBatteryLevel()
    elseif val == "w" then -- Collision detection
        isRobotColliding = true
    elseif val == "l" then -- Light sensor
        local lightLevel = tonumber(string.sub(msg, 3))
        isInDarkness = (lightLevel == 0)
    elseif val == "p" then -- Power charge detected
        -- Get the charging state value after the "/"
        local chargingVal = tonumber(string.sub(message, 3))
        isChargeConnected = true
        charging = (chargingVal == 1)
    else

    end
end

-- This runs once per frame, and is meant for drawing code.
function scene:drawBackground()
    scene.super.drawBackground(self)
    self.stateMachine:draw(0, 0)
    -- batt:draw()
    if showLog then
        gfx.setColor(gfx.kColorWhite)
        gfx.fillRect(0, 0, 200, 30)
        gfx.drawText(msg, 10, 10)
    end
end

-- This runs as as soon as a transition to another scene begins.
function scene:exit()
    -- Clean up message handling and timers
    MessageHandler:remove(self)
    batteryTimer:remove()
    self.connectionTimer:remove()

    -- Stop microphone if active
    if isListening then
        playdate.sound.micinput.stopListening()
        isListening = false
    end

    -- Clear inactivity timer
    if self.inactivityTimer then
        self.inactivityTimer:remove()
    end

    -- Reset state variables
    isRobotConnected = false
    isEdgeDetected = false
    isRobotColliding = false
    isChargeConnected = false
    isInDarkness = false
    isSleeping = true

    -- Reset crank variables
    crankRotation = 0
    crankTurns = 0
    isCrankMoving = false
    if crankStopTimer then
        crankStopTimer:remove()
    end
    crankStopTimer = nil
    isCrankStartDetected = false

    -- Stop accelerometer
    playdate.stopAccelerometer()

    -- Clear menu items
    menu:removeAllMenuItems()
end

-- This runs once a transition to another scene completes.
function scene:finish()
    scene.super.finish(self)
    -- Your code here
end

function scene:pause()
    scene.super.pause(self)
    -- Your code here
    print("x") -- 'x' command for stopping animations
end

function scene:resume()
    scene.super.resume(self)
    -- Reset all stimulus flags when returning to game
    isEdgeDetected = false
    isRobotColliding = false
    isInDarkness = false
    isChargeConnected = false

    -- Reset crank-related states if needed
    isCrankMoving = false
    isCrankStartDetected = false

    -- Request fresh battery status
    self:getBatteryLevel()

    -- Restart inactivity timer
    if self.inactivityTimer then
        self:restartInactivityTimer()
    end
end

function scene:getBatteryLevel()
    --msg = ""
    print("b") --Send b char to ask teensy about battery level
end

function scene:getPowerStatus()
    local power = playdate.getPowerStatus()
    --printTable(power)
    return power.charging
    --isCharging
end

function scene:edgeDetected()
    if isEdgeDetected then
        isEdgeDetected = false
        return true
    else
        return false
    end
end

function scene:robotConnected()
    if isRobotConnected then
        isRobotConnected = false
        scene:getBatteryLevel()
        return true
    else
        return false
    end
end

function scene:robotColliding()
    if isRobotColliding then
        isRobotColliding = false
        return true
    else
        return false
    end
end

function scene:chargeConnected()
    if isChargeConnected then
        isChargeConnected = false
        batt:setChargingState(charging)
        return true
    else
        batt:setChargingState(charging)
        return false
    end
end

--function to detect loud sound
function scene:detectLoudSound()
    if not isListening then
        return false
    end

    local level = playdate.sound.micinput.getLevel()
    -- Debug current level
    print("Mic level: " .. tostring(level))
    if level > threshold then
        if inactivityTimer then
            --inactivityTimer:reset()
        end
        return true
    end
end

-- Function to detect a tap or bump
function scene:detectTapOrBump()
    -- Read the accelerometer values with nil check
    local x, y, z = playdate.readAccelerometer()

    -- Guard against nil accelerometer values
    if not x or not y or not z then
        return false
    end

    -- Subtract gravity from the z-axis acceleration
    z = z - 1

    -- Calculate the magnitude of the acceleration
    local magnitude = math.sqrt(x * x + y * y + z * z)

    -- Check if the magnitude exceeds the threshold
    if magnitude > bumpTreshold then
        if self.inactivityTimer then
            self:restartInactivityTimer()
        end
        return true -- A tap or bump detected
    end
    return false
end

function scene:crankStateChanged()
    local isDocked = playdate.isCrankDocked()
    if isDocked ~= self.lastCrankState then
        self.lastCrankState = isDocked
        if self.inactivityTimer then
            self:restartInactivityTimer()
        end
        return true
    end
    return false
end

function PlayGround:crankStarted()
    -- Reset detection when crank is not moving
    if not self.isCrankMoving then
        isCrankStartDetected = false

        return false
    end

    -- Detect start of movement
    if not isCrankStartDetected and self.isCrankMoving then
        isCrankStartDetected = true
        if self.inactivityTimer then
            self:restartInactivityTimer()
        end
        return true
    end
    return false
end

function PlayGround:crankStopped()
    if self.crankStopTimer and self.crankStopTimer.timeLeft == 0 then
        if self.crankTurns > 0 then
            -- Send data to Teensy and enter rotation state
            print("t/" .. self.crankTurns .. "/" .. self.crankDirection)
            self.rotationCompleted = false -- Add this flag
            self.stateMachine:setState("turnOnPlace")
        end
        -- Reset all variables
        self.crankRotation = 0
        self.crankTurns = 0
        self.crankDirection = 0
        self.isCrankMoving = false
        if self.crankStopTimer then
            self.crankStopTimer:remove()
        end
        self.crankStopTimer = nil
        return true
    end
    return false
end

function scene:changeBehavior(newBehaviorName)
    if self.stateMachine.behaviors[newBehaviorName] then
        -- Nettoyage de l'ancien behavior si nécessaire
        if self.stateMachine.currentBehavior then
            -- Effectuer toute opération de nettoyage nécessaire
        end

        -- Changer de behavior
        self.stateMachine:setBehavior(newBehaviorName)

        -- Réinitialiser toute variable d'état spécifique au behavior si nécessaire
        -- self.someStateVariable = initialValue
    else
        --print("Error: Behavior '" .. newBehaviorName .. "' not found")
    end
end

-- Define the inputHander for this scene here, or use a previously defined inputHandler.

-- scene.inputHandler = someOtherInputHandler
-- OR
function PlayGround:initInputHandler()
    local scene = self -- Capture 'self' pour l'utiliser dans les closures

    self.inputHandler = {
        -- A button
        AButtonDown = function()
            -- Votre code ici
        end,
        AButtonHold = function()
            -- Votre code ici
        end,
        AButtonHeld = function()
            -- Votre code ici
        end,
        AButtonUp = function()
            -- Votre code ici
        end,

        -- B button
        BButtonDown = function()
            scene:changeBehavior("square")
        end,
        BButtonHeld = function()
            -- Votre code ici
        end,
        BButtonHold = function()
            -- Votre code ici
        end,
        BButtonUp = function()
            -- Votre code ici
        end,


        -- Crank handler
        cranked = function(change, acceleratedChange)
            -- Add threshold for direction change to avoid accidental resets
            local DIRECTION_CHANGE_THRESHOLD = 20

            -- Handle direction change only if significant movement in opposite direction
            if (change > 0 and scene.crankRotation < -DIRECTION_CHANGE_THRESHOLD) or
                (change < 0 and scene.crankRotation > DIRECTION_CHANGE_THRESHOLD) then
                scene.crankRotation = 0
                scene.crankTurns = 0
            end

            -- Accumulate rotation
            scene.crankRotation = scene.crankRotation + change

            -- Play tick sound on movement
            if math.abs(getCrankTicks(28)) > 0 then
                local randomPitch = 0.94 + (math.random(0, 560) / 1000)
                randomPitch = math.min(randomPitch, 1.5)
                crankTick:play(1, randomPitch)
                scene.isCrankMoving = true
            end

            -- Calculate turns consistently
            local previousTurns = scene.crankTurns
            if scene.crankRotation > 0 then
                scene.crankTurns = math.floor(scene.crankRotation / 360)
            else
                scene.crankTurns = math.floor(math.abs(scene.crankRotation) / 360)
            end

            -- Update direction only when actively turning
            if math.abs(change) > 0 then
                scene.crankDirection = change > 0 and 1 or -1
            end

            -- Play sound on complete turn
            if scene.crankTurns > previousTurns then
                if crankSound then
                    local currentPitch = math.min(basePitch + (scene.crankTurns * pitchIncrement), maxPitch)
                    crankSound:setRate(currentPitch)
                    crankSound:play(1)
                end
            end

            -- Reset stop timer
            if scene.crankStopTimer then
                scene.crankStopTimer:remove()
            end
            scene.crankStopTimer = playdate.timer.new(500)
        end,

        crankDocked = function()
            -- Votre code ici
        end,
        crankUndocked = function()
            -- Votre code ici
        end
    }
end
