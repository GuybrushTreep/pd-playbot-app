-- StaticBehavior.lua

local StaticBehavior = {}

function StaticBehavior:new()
    local behavior = {}
    setmetatable(behavior, self)
    self.__index = self
    behavior.scene = nil
    return behavior
end

function StaticBehavior:setScene(scene)
    self.scene = scene
end

function StaticBehavior:setup(stateMachine)
    local self = self -- Capture 'self' for use in closures

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
        "a/Start.txt"
    )


    stateMachine:addState(
        "idle",
        { {
            animation = { path = "Assets/Images/Faces/Idle_01", options = { delay = 33.333, loop = false } },
            sound = "Assets/sounds/Idle_01"
        } }, -- animSoundPairs table ends here
        {
            { state = "idle",   weight = 0.5 },
            { state = "idle2",  weight = 1 },
            { state = "blink1", weight = 1 },
            { state = "idle4",  weight = 1 },
            { state = "idle3",  weight = 1 },
            { state = "idle5",  weight = 1 },
            { state = "idle6",  weight = 1 }
        },               -- nextState transitions
        "a/idle_01.txt", -- teensyCommand
        {                -- conditionalTransitions
            {
                condition = function()
                    return playdate.buttonJustPressed(playdate.kButtonA)
                end,
                nextState = "sleeping"
            },
            {
                condition = function()
                    return self.scene:chargeConnected()
                end,
                nextState = "ChargeON"
            },
            { condition = function() return self.scene:crankStateChanged() end, nextState = "lookAtCrank" },
            { condition = function() return self.scene:crankStarted() end,      nextState = "crankTurn" },
            { condition = function() return self.scene:robotColliding() end,    nextState = "collide2" }
        }
    )


    stateMachine:addState(
        "idle2",
        { {
            animation = { path = "Assets/Images/Faces/Idle_02", options = { delay = 33.333, loop = false } },
            sound = "Assets/sounds/Idle_02"
        } }, -- animSoundPairs est une table de paires animation/son
        {
            { state = "idle",   weight = 1 },
            { state = "idle2",  weight = 1 },
            { state = "blink1", weight = 1 },
            { state = "idle4",  weight = 1 },
            { state = "idle3",  weight = 1 },
            { state = "idle5",  weight = 1 },
            { state = "idle6",  weight = 1 }
        },               -- nextState est une table de transitions possibles
        "a/idle_02.txt", -- teensyCommand
        {                -- conditionalTransitions
            {
                condition = function()
                    return playdate.buttonJustPressed(playdate.kButtonA)
                end,
                nextState = "sleeping"
            },
            {
                condition = function()
                    return self.scene:chargeConnected()
                end,
                nextState = "ChargeON"
            },
            { condition = function() return self.scene:crankStateChanged() end, nextState = "lookAtCrank" },
            { condition = function() return self.scene:crankStarted() end,      nextState = "crankTurn" },
            { condition = function() return self.scene:robotColliding() end,    nextState = "collide2" }
        }
    )

    stateMachine:addState(
        "idle3",
        { {
            animation = { path = "Assets/Images/Faces/Idle_03", options = { delay = 33.333, loop = false } },
            sound = "Assets/sounds/Idle_03"
        } }, -- animSoundPairs est une table de paires animation/son
        {
            { state = "idle",   weight = 1 },
            { state = "idle2",  weight = 1 },
            { state = "blink1", weight = 1 },
            { state = "idle4",  weight = 1 },
            { state = "idle3",  weight = 1 },
            { state = "idle5",  weight = 1 },
            { state = "idle6",  weight = 1 }
        },    -- nextState est une table de transitions possibles
        "c/", -- teensyCommand
        {     -- conditionalTransitions
            {
                condition = function()
                    return playdate.buttonJustPressed(playdate.kButtonA)
                end,
                nextState = "sleeping"
            },
            {
                condition = function()
                    return self.scene:chargeConnected()
                end,
                nextState = "ChargeON"
            },
            { condition = function() return self.scene:crankStateChanged() end, nextState = "lookAtCrank" },
            { condition = function() return self.scene:crankStarted() end,      nextState = "crankTurn" },
            { condition = function() return self.scene:robotColliding() end,    nextState = "collide2" }


        }
    )
    stateMachine:addState(
        "idle4",
        { {
            animation = { path = "Assets/Images/Faces/Idle_04", options = { delay = 33.333, loop = false } },
            sound = "Assets/sounds/Idle_03"
        } }, -- animSoundPairs est une table de paires animation/son
        {
            { state = "idle",   weight = 1 },
            { state = "idle2",  weight = 1 },
            { state = "blink1", weight = 1 },
            { state = "idle4",  weight = 1 },
            { state = "idle3",  weight = 1 },
            { state = "idle5",  weight = 1 },
            { state = "idle6",  weight = 1 }
        },               -- nextState est une table de transitions possibles
        "a/idle_04.txt", -- teensyCommand
        {                -- conditionalTransitions
            {
                condition = function()
                    return playdate.buttonJustPressed(playdate.kButtonA)
                end,
                nextState = "sleeping"
            },
            {
                condition = function()
                    return self.scene:chargeConnected()
                end,
                nextState = "ChargeON"
            },
            { condition = function() return self.scene:crankStateChanged() end, nextState = "lookAtCrank" },
            { condition = function() return self.scene:crankStarted() end,      nextState = "crankTurn" },
            { condition = function() return self.scene:robotColliding() end,    nextState = "collide2" }


        }
    )
    stateMachine:addState(
        "idle5",
        { {
            animation = { path = "Assets/Images/Faces/Idle_05", options = { delay = 33.333, loop = false } },
            sound = nil
        } }, -- animSoundPairs est une table de paires animation/son
        {
            { state = "idle",   weight = 1 },
            { state = "idle2",  weight = 1 },
            { state = "blink1", weight = 1 },
            { state = "idle4",  weight = 1 },
            { state = "idle3",  weight = 1 },
            { state = "idle5",  weight = 1 },
            { state = "idle6",  weight = 1 }
        },               -- nextState est une table de transitions possibles
        "a/idle_05.txt", -- teensyCommand
        {                -- conditionalTransitions
            {
                condition = function()
                    return playdate.buttonJustPressed(playdate.kButtonA)
                end,
                nextState = "sleeping"
            },
            {
                condition = function()
                    return self.scene:chargeConnected()
                end,
                nextState = "ChargeON"
            },
            { condition = function() return self.scene:crankStateChanged() end, nextState = "lookAtCrank" },
            { condition = function() return self.scene:crankStarted() end,      nextState = "crankTurn" },
            { condition = function() return self.scene:robotColliding() end,    nextState = "collide2" }


        }
    )
    stateMachine:addState(
        "idle6",
        { {
            animation = { path = "Assets/Images/Faces/Idle_06", options = { delay = 33.333, loop = false } },
            sound = nil
        } }, -- animSoundPairs est une table de paires animation/son
        {
            { state = "idle",   weight = 1 },
            { state = "idle2",  weight = 1 },
            { state = "blink1", weight = 1 },
            { state = "idle4",  weight = 1 },
            { state = "idle5",  weight = 1 }
        },               -- nextState est une table de transitions possibles
        "a/idle_06.txt", -- teensyCommand
        {                -- conditionalTransitions
            {
                condition = function()
                    return playdate.buttonJustPressed(playdate.kButtonA)
                end,
                nextState = "sleeping"
            },
            {
                condition = function()
                    return self.scene:chargeConnected()
                end,
                nextState = "ChargeON"
            },
            { condition = function() return self.scene:crankStateChanged() end, nextState = "lookAtCrank" },
            { condition = function() return self.scene:crankStarted() end,      nextState = "crankTurn" },
            { condition = function() return self.scene:robotColliding() end,    nextState = "collide2" }


        }
    )
    stateMachine:addState(
        "collide2",
        { {
            animation = { path = "Assets/Images/Faces/Collide_02", options = { delay = 33.333, loop = false } },
            sound = "Assets/sounds/Collide_01"
        } },
        {
            { state = "idle",   weight = 1 },
            { state = "idle2",  weight = 1 },
            { state = "blink1", weight = 1 },
            { state = "idle4",  weight = 1 },
            { state = "idle3",  weight = 1 },
            { state = "idle5",  weight = 1 },
            { state = "idle6",  weight = 1 }

        },
        "a/Collide_02.txt",
        {
            { condition = function() return self.scene:crankStateChanged() end, nextState = "lookAtCrank" },
            { condition = function() return self.scene:crankStarted() end,      nextState = "crankTurn" },

        }
    )
    stateMachine:addState(
        "blink1",
        { {
            animation = { path = "Assets/Images/Faces/Blink_01", options = { delay = 33.333, loop = false } },
            sound = "Assets/sounds/Blink_01.wav"
        } }, -- animSoundPairs est une table de paires animation/son
        {
            { state = "idle",   weight = 1 },
            { state = "idle2",  weight = 1 },
            { state = "blink1", weight = 1 },
            { state = "idle4",  weight = 1 },
            { state = "idle3",  weight = 1 },
            { state = "idle5",  weight = 1 },
            { state = "idle6",  weight = 1 }
        },                -- nextState est une table de transitions possibles
        "a/blink_01.txt", -- teensyCommand
        {                 -- conditionalTransitions
            {
                condition = function()
                    return playdate.buttonJustPressed(playdate.kButtonA)
                end,
                nextState = "sleeping"
            },
            {
                condition = function()
                    return self.scene:chargeConnected()
                end,
                nextState = "ChargeON"
            },
            { condition = function() return self.scene:crankStateChanged() end, nextState = "lookAtCrank" },
            { condition = function() return self.scene:crankStarted() end,      nextState = "crankTurn" },
            { condition = function() return self.scene:robotColliding() end,    nextState = "collide2" }
        }
    )
    stateMachine:addState(
        "fallAsleep",
        { {
            animation = { path = "Assets/Images/Faces/FallAsleep", options = { delay = 33.333, loop = false } },
            sound = "Assets/sounds/Snoring.wav"
        } },
        { { state = "sleeping", weight = 1 } },
        "a/fallAsleep.txt",
        {
            {
                condition = function()
                    return self.scene:detectTapOrBump()
                end,
                nextState = "wakeUp"
            },
            { condition = function() return self.scene:chargeConnected() end, nextState = "ChargeON" },
            { condition = function() return self.scene:robotColliding() end,  nextState = "wakeUp" }

        }
    )
    stateMachine:addState(
        "sleeping",
        { {
            animation = { path = "Assets/Images/Faces/Sleeping", options = { delay = 33.333, loop = true } },
            sound = "Assets/sounds/Snoring.wav"
        } },
        { { state = "sleeping", weight = 1 } },
        "c/",
        {
            {
                condition = function()
                    return self.scene:detectTapOrBump()
                end,
                nextState = "wakeUp"
            },
            { condition = function() return self.scene:chargeConnected() end,   nextState = "ChargeON" },
            { condition = function() return self.scene:detectLoudSound() end,   nextState = "wakeUp" },
            { condition = function() return self.scene:crankStateChanged() end, nextState = "wakeUp" },
            { condition = function() return self.scene:crankStarted() end,      nextState = "wakeUp" },
            { condition = function() return self.scene:robotColliding() end,    nextState = "wakeUp" }

        }
    )

    stateMachine:addState(
        "crankStart",
        { {
            animation = { path = "Assets/Images/Faces/CrankStart", options = { delay = 33.333, loop = false } },
            sound = nil
        } },
        { { state = "crankTurn", weight = 1 } },
        "c/"

    )

    stateMachine:addState(
        "crankTurn",
        { {
            animation = { path = "Assets/Images/Faces/CrankTurn", options = { delay = 33.333, loop = true } },
            sound = nil
        } },
        { { state = "crankTurn", weight = 1 } },
        "x/",
        {
            {
                condition = function()
                    local stopped = self.scene:crankStopped()

                    return stopped
                end,
                nextState = "idle3"
            },
        }
    )

    stateMachine:addState(
        "turnOnPlace",
        { {
            animation = { path = "Assets/Images/Faces/CrankTurn", options = { delay = 33.333, loop = true } },
            sound = nil
        } },
        { { state = "idle", weight = 1 } },
        "c/",
        {
            {
                condition = function()
                    return self.scene.rotationCompleted -- nouveau flag à ajouter
                end,
                nextState = "idle"
            }
        }
    )

    stateMachine:addState(
        "ChargeON",
        { {
            animation = { path = "Assets/Images/Faces/Plug", options = { delay = 33.333, loop = false } },
            sound = "Assets/sounds/ChargeON.wav"
        } },
        { { state = "idle", weight = 1 } },
        "c/"
    )

    stateMachine:addState(
        "wakeUp",
        { {
            animation = { path = "Assets/Images/Faces/WakeUp", options = { delay = 33.333, loop = false } },
            sound = "Assets/sounds/WakeUp.wav"
        } },
        { { state = "idle", weight = 1 } },
        "a/wakeUp.txt",
        {
            {
                condition = function()
                    self.scene:restartInactivityTimer() -- Restart timer when waking up
                    return false
                end,
                nextState = "idle"
            }
        }
    )

    stateMachine:addState(
        "lookAtCrank",
        { {
            animation = { path = "Assets/Images/Faces/LookAtCrank", options = { delay = 33.333, loop = false } },
            sound = "Assets/sounds/WakeUp.wav"
        } },
        { { state = "idle", weight = 1 } },
        "a/LookAtCrank.txt"
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

return StaticBehavior
