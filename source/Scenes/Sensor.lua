import 'Modules/BatteryLevel'
import 'Modules/MessageHandler'
class("Sensor").extends(NobleScene)

Sensor.sensorData = {
    IRright = 0,
    IRLeft = 0,
    TofFront = 0,
    TofBack = 0,
    EncRight = 0,
    EncLeft = 0,
    Light = 0,
    BatteryVoltage = 0,
    IsCharging = false,
    TotalDistance = 0
}

function Sensor:init()
    Sensor.super.init(self)
    MessageHandler:add(self, self.handleMessage)
    self.batt = BatteryLevel()
    self.batt:moveTo(373, 2)
    self.batt:add()



    self.timer = playdate.timer.keyRepeatTimerWithDelay(500, 500, function()
        print("d")
    end)
end

function Sensor:enter()
    Sensor.super.enter(self)
    self.timer:start()
end

function Sensor:exit()
    Sensor.super.exit(self)
    self.timer:remove()
    MessageHandler:remove(self)
end

function Sensor:update()
    Sensor.super.update(self)
    -- No need for explicit redraw here
end

function Sensor:drawBackground()
    Sensor.super.drawBackground(self)

    playdate.graphics.setFont(playdate.graphics.font.new("font/Asheville-Sans-14-Bold"))

    local categories = {
        { "IR Sensors",    { "IRright", "IRLeft" } },
        { "TOF Sensors",   { "TofFront", "TofBack" } },
        { "Encoders",      { "EncRight", "EncLeft" } },
        { "Distance",      { "TotalDistance" } }, -- Added new category
        { "Other Sensors", { "Light" } },         -- Moved TotalDistance to its own category
        { "Battery",       { "BatteryVoltage", "IsCharging" } }
    }

    local x = 20
    local y = 20
    local columnWidth = 200

    for _, category in ipairs(categories) do
        local categoryName, sensors = category[1], category[2]

        playdate.graphics.drawText(categoryName .. ":", x, y)
        y += 20

        for _, sensor in ipairs(sensors) do
            local value = Sensor.sensorData[sensor]
            local displayValue = value

            if sensor == "IsCharging" then
                displayValue = value and "Yes" or "No"
            elseif sensor == "TotalDistance" then
                displayValue = string.format("%.2f m", value) -- Format distance with meters
            elseif type(value) == "number" then
                displayValue = string.format("%.2f", value)
            end

            playdate.graphics.drawText("  " .. sensor .. ": " .. tostring(displayValue), x, y)
            y += 20
        end

        if y > 200 then
            x += columnWidth
            y = 20
        else
            y += 10
        end
    end
end

function Sensor:handleMessage(key, message)
    local val = string.sub(message, 1, 1)

    if val == "d" then
        local values = {}
        for value in string.gmatch(message, "[^/]+") do
            table.insert(values, value)
        end

        if #values == 11 then -- Updated size check
            Sensor.sensorData.IRright = tonumber(values[2]) or 0
            Sensor.sensorData.IRLeft = tonumber(values[3]) or 0
            Sensor.sensorData.TofFront = tonumber(values[4]) or 0
            Sensor.sensorData.TofBack = tonumber(values[5]) or 0
            Sensor.sensorData.EncRight = tonumber(values[6]) or 0
            Sensor.sensorData.EncLeft = tonumber(values[7]) or 0
            Sensor.sensorData.Light = tonumber(values[8]) or 0
            Sensor.sensorData.BatteryVoltage = tonumber(values[9]) or 0
            Sensor.sensorData.IsCharging = (tonumber(values[10]) == 1)
            Sensor.sensorData.TotalDistance = tonumber(values[11]) or 0
        end
    end
end

Sensor.inputHandler = {
    BButtonDown = function()
        Noble.transition(Menu)
    end
}
