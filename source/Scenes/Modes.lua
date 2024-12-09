-- Modes.lua
-- Menu interface for selecting robot behaviors
local pd <const> = playdate
local gfx <const> = pd.graphics

class("Modes").extends(NobleScene)

function Modes:init()
    Modes.super.init(self)

    -- Create menu with available behaviors
    self.menuItems = Noble.Menu.new(
        true,
        Noble.Text.ALIGN_CENTER,
        false,
        gfx.kColorBlack,
        4, 6,
        Noble.Text.FONT_MEDIUM
    )

    -- Get behaviors from PlayGround's StateMachine
    local playground = PlayGround()
    if playground.stateMachine and playground.stateMachine.behaviors then
        -- Add each behavior as a menu item
        for behaviorName, _ in pairs(playground.stateMachine.behaviors) do
            self.menuItems:addItem(behaviorName:gsub("^%l", string.upper), function()
                Noble.transition(PlayGround)
                PlayGround.nextBehavior = behaviorName
            end)
        end
    end

    self.menuItems:select(1)

    -- Input handling
    self.inputHandler = {
        upButtonDown = function()
            self.menuItems:selectPrevious()
        end,
        downButtonDown = function()
            self.menuItems:selectNext()
        end,
        AButtonDown = function()
            self.menuItems:click()
        end,
        BButtonDown = function()
            Noble.transition(Menu)
        end
    }
end

function Modes:enter()
    Modes.super.enter(self)
    self.menuItems:activate()
end

function Modes:drawBackground()
    Modes.super.drawBackground(self)
    local titleFont = playdate.graphics.font.new("font/Asheville-Sans-14-Bold")
    gfx.setFont(titleFont)
    gfx.drawTextAligned("SELECT MODE", 200, 40, kTextAlignment.center)
    self.menuItems:draw(200, 120)
end
