-- MessageHandler.lua
import "CoreLibs/object"
import "Libraries/Noble/libraries/Signal"

class("MessageHandler").extends()

function MessageHandler:init()
    -- No need to create a new Signal instance
end

function MessageHandler:add(scene, callback)
    Signal:add("message", scene, callback)
end

function MessageHandler:remove(scene)
    Signal:remove("message", scene)
end

function playdate.serialMessageReceived(message)
    MessageHandler:dispatch(message)
end

function MessageHandler:dispatch(message)
    Signal:dispatch("message", message)
end

-- Create a singleton instance
MessageHandler = MessageHandler()

return MessageHandler
