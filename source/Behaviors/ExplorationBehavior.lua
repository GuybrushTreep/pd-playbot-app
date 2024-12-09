-- ExplorationBehavior.lua

local ExplorationBehavior = {}

function ExplorationBehavior:new()
    local behavior = {}
    setmetatable(behavior, self)
    self.__index = self
    behavior.scene = nil
    return behavior
end

function ExplorationBehavior:setScene(scene)
    self.scene = scene
end

function ExplorationBehavior:setup(stateMachine)
    -- Define states
    stateMachine:addState(
        "introStart",
        { {
            animation = { path = "Assets/Images/Faces/Intro_Start", options = { delay = 33.333, loop = false } },
            sound = "Assets/sounds/Intro_Start.wav"
        } },
        { { state = "introLoop", weight = 1 } },
        "c/"
    )

    stateMachine:addState(
        "introLoop",
        { {
            animation = { path = "Assets/Images/Faces/Intro_Loop", options = { delay = 33.333, loop = true } },
            sound = "Assets/sounds/Intro_Loop.wav"
        } },
        { { state = "introStop", weight = 1 } },
        "c/",
        {
            {
                condition = function() return self.scene:robotConnected() end,
                nextState = "introStop"
            }
        }
    )

    stateMachine:addState(
        "introStop",
        { {
            animation = { path = "Assets/Images/Faces/Intro_Stop", options = { delay = 33.333, loop = false } },
            sound = "Assets/sounds/Intro_Stop.wav"
        } },
        { { state = "idle", weight = 1 } },
        "a/intro_Stop.txt"
    )

    stateMachine:addState(
        "collide",
        { {
            animation = { path = "Assets/Images/Faces/Collide_01", options = { delay = 33.333, loop = false } },
            sound = "Assets/sounds/Collide_01"
        } },
        {
            { state = "idle",          weight = 0.1 },
            { state = "turn_90_Right", weight = 1 },
            { state = "turn_90_Left",  weight = 1 }
        },
        "a/Collide_01.txt",
        {
            { condition = function() return self.scene:edgeDetected() end, nextState = "edge" }
        }
    )

    stateMachine:addState(
        "forward_Medium",
        { {
            animation = { path = "Assets/Images/Faces/Forward_Medium", options = { delay = 33.333, loop = false } },
            sound = nil
        } },
        {
            { state = "idle",           weight = 0.35 },
            { state = "turn_90_Right",  weight = 0.8 },
            { state = "forward_Medium", weight = 0.5 },
            { state = "turn_90_Left",   weight = 0.8 }
        },
        "a/forward_Medium.txt",
        {
            { condition = function() return self.scene:edgeDetected() end,   nextState = "edge" },
            { condition = function() return self.scene:robotColliding() end, nextState = "collide" }
        }
    )

    stateMachine:addState(
        "turn_90_Right",
        { {
            animation = { path = "Assets/Images/Faces/Turn_90_Right", options = { delay = 33.333, loop = false } },
            sound = nil
        } },
        {
            { state = "idle",           weight = 0.5 },
            { state = "turn_90_Right",  weight = 0.7 },
            { state = "forward_Medium", weight = 0.7 },
            { state = "turn_90_Left",   weight = 0.7 }
        },
        "a/turn_90_Right.txt",
        {
            { condition = function() return self.scene:edgeDetected() end,   nextState = "edge" },
            { condition = function() return self.scene:robotColliding() end, nextState = "collide" }
        }
    )

    stateMachine:addState(
        "turn_45_Right",
        { {
            animation = { path = "Assets/Images/Faces/Turn_90_Right", options = { delay = 33.333, loop = false } },
            sound = nil
        } },
        {
            { state = "idle",           weight = 0.5 },
            { state = "turn_90_Right",  weight = 0.7 },
            { state = "forward_Medium", weight = 0.7 },
            { state = "turn_90_Left",   weight = 0.7 }

        },
        "a/turn_45_Right.txt",
        {
            { condition = function() return self.scene:edgeDetected() end,   nextState = "edge" },
            { condition = function() return self.scene:robotColliding() end, nextState = "collide" }
        }
    )

    stateMachine:addState(
        "turn_90_Left",
        { {
            animation = { path = "Assets/Images/Faces/Turn_90_Left", options = { delay = 33.333, loop = false } },
            sound = nil
        } },
        {
            { state = "idle",           weight = 0.5 },
            { state = "forward_Medium", weight = 0.7 },
            { state = "forward_Medium", weight = 0.7 },
            { state = "turn_90_Right",  weight = 0.5 }

        },
        "a/turn_90_Left.txt",
        {
            { condition = function() return self.scene:edgeDetected() end,   nextState = "edge" },
            { condition = function() return self.scene:robotColliding() end, nextState = "collide" }
        }
    )

    stateMachine:addState(
        "turn_45_Left",
        { {
            animation = { path = "Assets/Images/Faces/Turn_90_Left", options = { delay = 33.333, loop = false } },
            sound = nil
        } },
        {
            { state = "idle",           weight = 0.5 },
            { state = "forward_Medium", weight = 0.7 },
            { state = "turn_90_Right",  weight = 0.35 },
            { state = "turn_90_Left",   weight = 0.35 }

        },
        "a/turn_45_Left.txt",
        {
            { condition = function() return self.scene:edgeDetected() end,   nextState = "edge" },
            { condition = function() return self.scene:robotColliding() end, nextState = "collide" }
        }
    )

    stateMachine:addState(
        "sleeping",
        { {
            animation = { path = "Assets/Images/Faces/Sleeping", options = { delay = 33.333, loop = true } },
            sound = "Assets/sounds/Snoring"
        } },
        { { state = "wakeUp", weight = 1 } },
        "a/sleeping.txt",
        {
            { condition = function() return self.scene:detectTapOrBump() end, nextState = "wakeUp" },
            { condition = function() return self.scene:edgeDetected() end,    nextState = "edge" },
            { condition = function() return self.scene:robotColliding() end,  nextState = "collide" },
            { condition = function() return self.scene:chargeConnected() end, nextState = "ChargeON" }
        }
    )

    stateMachine:addState(
        "wakeUp",
        { {
            animation = { path = "Assets/Images/Faces/WakeUp", options = { delay = 33.333, loop = false } },
            sound = "Assets/sounds/WakeUp"
        } },
        { { state = "idle", weight = 1 } },
        "a/wakeUp.txt",
        {
            { condition = function() return self.scene:edgeDetected() end,    nextState = "edge" },
            { condition = function() return self.scene:robotColliding() end,  nextState = "collide" },
            { condition = function() return self.scene:chargeConnected() end, nextState = "ChargeON" }
        }
    )

    stateMachine:addState(
        "ChargeON",
        { {
            animation = { path = "Assets/Images/Faces/Charge_ON", options = { delay = 33.333, loop = false } },
            sound = "Assets/sounds/ChargeON"
        } },
        { { state = "idle", weight = 1 } },
        "c/"
    )

    stateMachine:addState(
        "idle",
        { {
            animation = { path = "Assets/Images/Faces/Idle_01", options = { delay = 33.333, loop = false } },
            sound = nil
        },
            {
                animation = { path = "Assets/Images/Faces/Idle_02", options = { delay = 33.333, loop = false } },
                sound = nil
            } },
        {
            { state = "idle",           weight = 0.25 },
            { state = "forward_Medium", weight = 0.7 },
            { state = "turn_90_Right",  weight = 0.5 },
            { state = "turn_90_Left",   weight = 0.5 }

        },
        "c/",
        {
            { condition = function() return self.scene:edgeDetected() end,                     nextState = "edge" },
            { condition = function() return playdate.buttonJustPressed(playdate.kButtonA) end, nextState = "sleeping" },
            { condition = function() return self.scene:robotColliding() end,                   nextState = "collide" },
            { condition = function() return self.scene:chargeConnected() end,                  nextState = "ChargeON" }
        }
    )

    stateMachine:addState(
        "edge",
        { {
            animation = { path = "Assets/Images/Faces/Edge_01", options = { delay = 33.333, loop = false } },
            sound = "Assets/sounds/Edge"
        } },
        { { state = "idle",         weight = 0.5 },
            { state = "forward_Medium", weight = 0.8 } },
        "a/Edge_01.txt"
    )
    stateMachine:addState(
        "lowBattery",
        { {
            animation = { path = "Assets/Images/Faces/LowBat", options = { delay = 33.333, loop = false } },
            sound = nil
        } },
        { { state = "idle", weight = 1 } },
        "c/",
        {
            {
                condition = function()
                    return self.scene:chargeConnected()
                end,
                nextState = "ChargeON"
            }
        }
    )

    stateMachine:addState(
        "criticalBattery",
        { {
            animation = { path = "Assets/Images/Faces/CriticalBattery", options = { delay = 33.333, loop = false } },
            sound = nil
        } },
        { { state = "sleeping", weight = 1 } },
        "c/",
        {
            {
                condition = function()
                    return self.scene:chargeConnected()
                end,
                nextState = "ChargeON"
            }
        }
    )
end

return ExplorationBehavior
