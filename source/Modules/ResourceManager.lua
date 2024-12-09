-- ResourceManager.lua
-- Handles loading and unloading of animation/sound resources
-- Uses caching to avoid reloading duplicate resources
ResourceManager = {
    animations = {}, -- Cache for loaded animations
    sounds = {}      -- Cache for loaded sounds
}

-- Load an animation with caching mechanism
-- @param name: string, unique identifier for the animation
-- @param path: string, file path to the animation
-- @param options: table, animation options (delay, loop, etc)
-- @return AnimatedImage|nil The loaded animation or nil if failed
function ResourceManager:loadAnimation(name, path, options)
    if not self.animations[name] then
        local success, result = pcall(function()
            return AnimatedImage.new(path, options)
        end)
        if success then
            self.animations[name] = result
        else
            return nil
        end
    end
    return self.animations[name]
end

-- Unload an animation and force garbage collection
-- @param name: string, identifier of animation to unload
function ResourceManager:unloadAnimation(name)
    self.animations[name] = nil
    collectgarbage()
end

-- Load a sound with caching mechanism
-- @param name: string, unique identifier for the sound
-- @param path: string, file path to the sound file
-- @return SamplePlayer|nil The loaded sound or nil if failed
function ResourceManager:loadSound(name, path)
    if not self.sounds[name] then
        if path then
            local success, result = pcall(function()
                return playdate.sound.sampleplayer.new(path)
            end)
            if success then
                self.sounds[name] = result
            else
                return nil
            end
        else
            return nil
        end
    end
    return self.sounds[name]
end

-- Unload a sound and force garbage collection
-- @param name: string, identifier of sound to unload
function ResourceManager:unloadSound(name)
    self.sounds[name] = nil
    collectgarbage()
end
