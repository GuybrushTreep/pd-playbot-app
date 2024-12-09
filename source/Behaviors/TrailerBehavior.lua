-- TrailerBehavior.lua

local TrailerBehavior = {}

function TrailerBehavior:new()
    local behavior = {}
    setmetatable(behavior, self)
    self.__index = self
    behavior.scene = nil
    return behavior
end

function TrailerBehavior:setScene(scene)
    self.scene = scene
end

function TrailerBehavior:setup(stateMachine)
    local self = self -- Capture 'self' for use in closures

    stateMachine:addState(
        "idle1",
        { {
            animation = { path = "Assets/Images/Faces/Idle_01", options = { delay = 33.333, loop = false } },
            sound = "Assets/sounds/Idle_01"
        } }, -- animSoundPairs table ends here
        {
            { state = "forward_Medium", weight = 0.5 }

        },               -- nextState transitions
        "a/idle_01.txt", -- teensyCommand
        {                -- conditionalTransitions

        }

    )

    stateMachine:addState(
        "forward_Medium",
        { {
            animation = { path = "Assets/Images/Faces/Forward_Medium", options = { delay = 33.333, loop = false } },
            sound = nil
        } },
        {

            { state = "turn_90_Left", weight = 0.8 }
        },
        "a/forward_Medium.txt",
        {

        }
    )
    stateMachine:addState(
        "turn_90_Left",
        { {
            animation = { path = "Assets/Images/Faces/Turn_90_Left", options = { delay = 33.333, loop = false } },
            sound = nil
        } },
        {
            { state = "idle1", weight = 0.5 },


        },
        "a/turn_90_Left.txt",
        {

        }
    )
end

return TrailerBehavior
