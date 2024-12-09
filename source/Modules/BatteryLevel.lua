-- BatteryLevel.lua
-- A Playdate sprite class that visualizes battery level using a graphical indicator
local alertLevel
local gfx <const> = playdate.graphics

class('BatteryLevel').extends(gfx.sprite)
-- Load battery background images for normal and charging states

local batteryBg = gfx.image.new("Assets/Images/UI/Battery_bg")
local batteryBgCharge = gfx.image.new("Assets/Images/UI/Battery_bg_Charging")
local batLevel = 0
-- Animation sequence for battery icon entrance, NOT IMPLEMENTED !
local enterSequence = Sequence.new():from(-10):sleep(2.5):to(2, 2, Ease.outBounce):callback(function() end)

-- Initialize battery sprite with default values
function BatteryLevel:init()
    self.isCharging = false
    self:setSize(26, 13)
    --self.setImage(batteryBg)
    self:setCenter(0, 0)
end

-- Draw method called every frame to render battery indicator
function BatteryLevel:draw()
    gfx.setColor(gfx.kColorWhite)
    -- Fill battery level bar proportional to current charge
    gfx.fillRect(2, 2, BatteryLevel:remap(batLevel, 0, 100, 0, 20), 9)
    -- Draw appropriate background based on charging state
    if self.isCharging == false then
        batteryBg:draw(0, 0)
    else
        batteryBgCharge:draw(0, 0)
    end
end

function BatteryLevel:setAlertLevel(level)
    alertLevel = level
end

function BatteryLevel:getAlertLevel()
    return alertLevel
end

-- Update battery level with validation for invalid inputs
function BatteryLevel:setBatteryLevel(level)
    if level == nil or type(level) ~= "number" or level ~= level then
        -- Handle nil, non-number or NaN inputs
        batLevel = 0 -- Default to empty
    else
        batLevel = level
    end
end

-- Update charging state indicator
function BatteryLevel:setChargingState(isCharging)
    self.isCharging = isCharging
end

-- Utility function to map value from one range to another
function BatteryLevel:remap(val, in_min, in_max, out_min, out_max)
    return (val - in_min) * (out_max - out_min) / (in_max - in_min) + out_min
end

-- Reset and restart entrance animation sequence, NOT IMPLEMENTED !
function BatteryLevel:enter()
    enterSequence = Sequence.new():from(-10):sleep(2.5):to(2, 2, Ease.outBounce):callback(function() end)
end
