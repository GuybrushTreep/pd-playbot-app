import "CoreLibs/object"
import 'libraries/animatedImage'
import 'Modules/ResourceManager'


class('StateMachine').extends()

-- Initialize the StateMachine
-- @param debug: boolean, enable debug printing if true
-- @param states: table, stores all states with their properties
-- @param currentState: string, the name of the current active state
-- @param currentAnimIndex: number, index of the current animation in the active state
-- @param lowercaseStateMap: table, maps lowercase state names to their original case
-- @param animationCompleted: boolean, indicates if the current animation has completed
-- @param lastFrame: number, stores the last processed animation frame for loop detection
-- @param activeStateMessage: string, stores the message associated with the current active state
-- @param stateMessageMap: table, maps trigger messages to their corresponding states
-- @param interruptRequested: boolean, indicates if an interrupt to another state has been requested
-- @param interruptToState: string, stores the name of the state to interrupt to, if requested
-- @param behaviors: table, stores all behaviors with their properties
-- @param currentBehavior: string, the name of the current active behavior
function StateMachine:init(debug)
    StateMachine.super.init(self)
    self.states = {}
    self.currentState = nil
    self.currentAnimIndex = 1
    self.lowercaseStateMap = {}
    self.animationCompleted = false
    self.debug = debug or false
    self.lastFrame = 0
    self.activeStateMessage = nil
    self.stateMessageMap = {}
    self.interruptRequested = false
    self.interruptToState = nil
    self.behaviors = {}
    self.currentBehavior = nil
    self.resources = {} -- To keep track of loaded resources
end

-- Add a new behavior to the state machine
-- @param name: string, identifier for the behavior
-- @param behaviorModule: table, the module containing the behavior's setup function
-- @param initialState: string, the initial state for this behavior
function StateMachine:addBehavior(name, behaviorModule, initialState)
    self.behaviors[name] = {
        module = behaviorModule,
        initialState = initialState
    }
end

-- Set the current behavior of the state machine
-- @param name: string, the name of the behavior to set
function StateMachine:setBehavior(name)
    local behavior = self.behaviors[name]
    if not behavior then
        return self:debugPrint("Behavior not found: " .. name)
    end

    self.currentBehavior = name
    self.states = {}
    self.currentState = nil
    behavior.module:setup(self)

    local initialState = behavior.initialState and self.states[behavior.initialState] and behavior.initialState or
        next(self.states)
    if initialState then
        self:setState(initialState)
    else
        self:debugPrint("Error: No states defined for behavior " .. name)
    end
    self:debugPrint("Behavior set to: " .. name)
end

function StateMachine:getCurrentBehavior()
    return self.currentBehavior
end

-- Print debug messages if debug mode is enabled
-- @param message: string, the debug message to print
function StateMachine:debugPrint(message)
    if self.debug then
        print("// " .. message)
    end
end

-- Add a new state to the state machine
-- @param name: string, identifier for the state
-- @param animSoundPairs: table, animation and sound pairs for the state
-- @param nextState: string or table, the next state(s) to transition to
-- @param teensyCommand: string, command to send to Teensy when entering this state
-- @param conditionalTransitions: table, optional conditional transitions
function StateMachine:addState(name, animSoundPairs, nextState, teensyCommand, conditionalTransitions)
    self.states[name] = {
        animSoundPairs = animSoundPairs,
        nextState = nextState,
        teensyCommand = teensyCommand,
        conditionalTransitions = conditionalTransitions or {}
    }

    self.lowercaseStateMap[name:lower()] = name
end

-- Set the current state of the state machine
-- @param name: string, the name of the state to set
function StateMachine:setState(name)
    -- Get actual state name from case-insensitive map
    local actualName = self.lowercaseStateMap[name:lower()] or name

    -- Verify state exists
    if not self.states[actualName] then
        self:debugPrint("Error: Invalid state - " .. actualName)
        return
    end

    -- First, clean up previous state
    if self.currentState then
        self:unloadStateResources(self.currentState)
    end

    -- Update state machine properties
    self.currentState = actualName
    -- Choose a random animation index if multiple animations exist
    if self.states[actualName].animSoundPairs and #self.states[actualName].animSoundPairs > 1 then
        self.currentAnimIndex = math.random(1, #self.states[actualName].animSoundPairs)
    else
        self.currentAnimIndex = 1
    end
    self.animationCompleted = false
    self.lastFrame = 0

    -- Preload resources asynchronously
    self:loadStateResources(actualName)

    -- Send Teensy command and start animation together
    if self.states[actualName].teensyCommand then
        print(self.states[actualName].teensyCommand)
        self:restartAnimation()
    end

    self:debugPrint("State transitioned to: " .. actualName .. " with animation " .. self.currentAnimIndex)
end

-- Load resources (animations and sounds) for a given state
-- Resources are stored in self.resources with unique names based on state and index
-- @param stateName: string, name of the state to load resources for
function StateMachine:loadStateResources(stateName)
    local state = self.states[stateName]
    if state then
        -- Iterate through all animation/sound pairs in the state
        for i, pair in ipairs(state.animSoundPairs) do
            -- Create unique identifiers for animation and sound resources
            local animName = stateName .. "_anim_" .. i
            local soundName = stateName .. "_sound_" .. i

            -- Load animation if present in the pair
            if pair.animation then
                self.resources[animName] = ResourceManager:loadAnimation(animName, pair.animation.path,
                    pair.animation.options)
            end

            -- Load sound if present in the pair
            if pair.sound then
                self.resources[soundName] = ResourceManager:loadSound(soundName, pair.sound)
            end
        end
    end
end

-- Unload resources (animations and sounds) for a given state to free memory
-- Removes resources from self.resources and calls ResourceManager unload methods
-- @param stateName: string, name of the state to unload resources for
function StateMachine:unloadStateResources(stateName)
    local state = self.states[stateName]
    if state then
        -- Iterate through all animation/sound pairs in the state
        for i, _ in ipairs(state.animSoundPairs) do
            -- Get unique identifiers used when loading
            local animName = stateName .. "_anim_" .. i
            local soundName = stateName .. "_sound_" .. i

            -- Unload animation and sound resources
            ResourceManager:unloadAnimation(animName)
            ResourceManager:unloadSound(soundName)

            -- Remove references from resources table
            self.resources[animName] = nil
            self.resources[soundName] = nil
        end
    end
end

-- Restart the animation for the current state
function StateMachine:restartAnimation()
    local state = self.states[self.currentState]
    if state and state.animSoundPairs[self.currentAnimIndex] then
        local animName = self.currentState .. "_anim_" .. self.currentAnimIndex
        local soundName = self.currentState .. "_sound_" .. self.currentAnimIndex
        local animation = self.resources[animName]
        local sound = self.resources[soundName]

        if animation then
            animation:reset()
            animation:setPaused(false)
        else
            self:debugPrint("Warning: Animation not loaded for state: " .. self.currentState)
        end

        if sound then
            sound:play()
        end
    end
end

-- Send the Teensy command associated with the current state
function StateMachine:sendTeensyCommand()
    local state = self.states[self.currentState]
    if state and state.teensyCommand then
        print(state.teensyCommand)
    end
end

-- Get the next state based on weighted random selection
-- @param currentState: string, the current state
-- @return string, the next state
function StateMachine:getWeightedRandomNextState(currentState)
    local state = self.states[currentState]
    if not state or not state.nextState then
        return nil
    end

    if type(state.nextState) ~= "table" then
        return state.nextState
    end

    local totalWeight = 0
    for _, stateInfo in ipairs(state.nextState) do
        totalWeight = totalWeight + (stateInfo.weight or 1)
    end

    local randomValue = math.random() * totalWeight
    local currentWeight = 0

    for _, stateInfo in ipairs(state.nextState) do
        currentWeight = currentWeight + (stateInfo.weight or 1)
        if randomValue <= currentWeight then
            return stateInfo.state
        end
    end

    return state.nextState[#state.nextState].state
end

-- Handle incoming messages and trigger state changes if applicable
-- @param message: string, the incoming message
-- @return boolean, true if the message triggered a state change, false otherwise
function StateMachine:handleMessage(message)
    local targetState = self.stateMessageMap[message]
    if targetState and (self.currentState ~= targetState or self.animationCompleted) then
        self.activeStateMessage = message
        self:setState(targetState)
        return true
    end
    return false
end

function StateMachine:update()
    local state = self.states[self.currentState]
    if not state then
        self:debugPrint("No current state")
        return
    end

    self:debugPrint("Current state: " .. self.currentState)

    local currentPair = state.animSoundPairs[self.currentAnimIndex]
    if not currentPair then
        self:debugPrint("No current animation pair")
        return
    end

    -- Check for conditional transitions
    for _, transition in ipairs(state.conditionalTransitions) do
        if transition.condition() then
            self:debugPrint("Conditional transition triggered to " .. transition.nextState)
            self:setState(transition.nextState)
            return
        end
    end

    local animName = self.currentState .. "_anim_" .. self.currentAnimIndex
    local soundName = self.currentState .. "_sound_" .. self.currentAnimIndex
    local animation = self.resources[animName]
    local sound = self.resources[soundName]

    if animation then
        if not animation:getPaused() then
            local currentFrame = animation:getFrame()

            if currentFrame < self.lastFrame then
                self:sendTeensyCommand()
                self:debugPrint("Animation loop complete, sending Teensy command")

                if sound then
                    sound:play()
                    self:debugPrint("Replaying sound for state: " .. self.currentState)
                end
            end

            self.lastFrame = currentFrame

            if animation:isComplete() then
                self:debugPrint("Animation complete for state: " .. self.currentState)
                if animation:getShouldLoop() then
                    animation:reset()
                else
                    self.animationCompleted = true
                end
            end
        end

        if self.animationCompleted and state.nextState then
            self:transitionToNextState()
        end
    else
        self:debugPrint("No animation found for state: " .. self.currentState)
    end
end

-- Stop the current sound playing for the state
function StateMachine:stopCurrentSound()
    local state = self.states[self.currentState]
    if state and state.animSoundPairs[self.currentAnimIndex] then
        local pair = state.animSoundPairs[self.currentAnimIndex]
        if pair.sound then
            pair.sound:stop()
        end
    end
end

-- Transition to the next state
function StateMachine:transitionToNextState()
    local nextState = self:getWeightedRandomNextState(self.currentState)
    if nextState then
        self:setState(nextState)
    else
        self:debugPrint("No next state defined for " .. self.currentState)
    end
    self.activeStateMessage = nil
end

-- Transition to a specific state
-- @param nextState: string, the name of the state to transition to
function StateMachine:transitionToState(nextState)
    self:stopCurrentSound()
    if self.states[nextState] then
        self:debugPrint("Transitioning from " .. self.currentState .. " to " .. nextState)
        self:setState(nextState)
    else
        self:debugPrint("Invalid next state: " .. nextState)
    end
end

-- Draw the current state's animation
-- @param x: number, x-coordinate for drawing
-- @param y: number, y-coordinate for drawing
function StateMachine:draw(x, y)
    local state = self.states[self.currentState]
    if not state then return end

    local animName = self.currentState .. "_anim_" .. self.currentAnimIndex
    local animation = self.resources[animName]
    if animation then
        animation:draw(x, y)
    end
end

-- Set the debug mode
-- @param debug: boolean, enable or disable debug mode
function StateMachine:setDebug(debug)
    self.debug = debug
end

-- Request an interrupt to transition to a specific state
-- @param nextState: string, the name of the state to interrupt to
function StateMachine:interruptToState(nextState)
    self.interruptRequested = true
    self.interruptToState = nextState
    self:debugPrint("Interrupt requested to state: " .. nextState)
end

-- Perform the requested interrupt
function StateMachine:performInterrupt()
    if self.interruptToState then
        self:debugPrint("Performing interrupt to state: " .. self.interruptToState)
        self:transitionToState(self.interruptToState)
        self.interruptRequested = false
        self.interruptToState = nil
    else
        self:debugPrint("Interrupt requested but no target state specified")
    end
end
