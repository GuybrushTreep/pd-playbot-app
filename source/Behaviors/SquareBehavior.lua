-- SquareBehavior.lua
--turn in square pattern

local SquareBehavior = {}

function SquareBehavior:new()
    local behavior = {}
    setmetatable(behavior, self)
    self.__index = self
    behavior.scene = nil
    return behavior
end

function SquareBehavior:setScene(scene)
    self.scene = scene
end

function SquareBehavior:setup(stateMachine)
    local self = self -- Capture self for closures

    -- Initial state to start the square pattern
    stateMachine:addState(
        "squareStart",
        { {
            animation = { path = "Assets/Images/Faces/Turn_90_Right", options = { delay = 33.333, loop = false } },
            sound = nil
        } },
        { { state = "squareForward", weight = 1 } },
        "a/turn_90_Right.txt",
        {
            {
                condition = function()
                    return self.scene:edgeDetected()
                end,
                nextState = "edge"
            },
            {
                condition = function()
                    return self.scene:robotColliding()
                end,
                nextState = "collide"
            }
        }
    )

    -- Forward movement state
    stateMachine:addState(
        "squareForward",
        { {
            animation = { path = "Assets/Images/Faces/Forward_Medium", options = { delay = 33.333, loop = false } },
            sound = nil
        } },
        { { state = "squareStart", weight = 1 } },
        "a/forward_Medium.txt",
        {
            {
                condition = function()
                    return self.scene:edgeDetected()
                end,
                nextState = "edge"
            },
            {
                condition = function()
                    return self.scene:robotColliding()
                end,
                nextState = "collide"
            }
        }
    )

    -- Edge detection handling state
    stateMachine:addState(
        "edge",
        { {
            animation = { path = "Assets/Images/Faces/Edge_01", options = { delay = 33.333, loop = false } },
            sound = nil
        } },
        { { state = "squareStart", weight = 1 } },
        "a/Edge_01.txt"
    )

    -- Collision handling state
    stateMachine:addState(
        "collide",
        { {
            animation = { path = "Assets/Images/Faces/Collide_01", options = { delay = 33.333, loop = false } },
            sound = "Assets/sounds/Collide_01"
        } },
        { { state = "squareStart", weight = 1 } },
        "a/Collide_01.txt"
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

return SquareBehavior
