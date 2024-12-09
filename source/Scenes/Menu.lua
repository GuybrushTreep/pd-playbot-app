local pd <const> = playdate
local gfx <const> = pd.graphics

class("Menu").extends(NobleScene)

function Menu:init()
    Menu.super.init(self)

    self.menuItems = Noble.Menu.new(
        true,                    -- Activer le menu
        Noble.Text.ALIGN_CENTER, -- Centrer le texte
        false,                   -- Pas de localisation
        gfx.kColorBlack,         -- Couleur du texte
        4, 6,                    -- Padding
        Noble.Text.large   -- Police
    )

    self.menuItems:addItem("Modes", function() Noble.transition(Modes, 0.35, Noble.Transition.MetroNexus) end)
    self.menuItems:addItem("Sensors", function() Noble.transition(Sensor, 0.35, Noble.Transition.MetroNexus) end)


    -- Sélectionner le premier élément en utilisant select
    self.menuItems:select(1)

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
            Noble.transition(PlayGround)
        end
    }
end

function Menu:enter()
    Menu.super.enter(self)
    -- Assurez-vous que le menu est activé lors de l'entrée dans la scène
    self.menuItems:activate()
end

function Menu:start()
    Menu.super.start(self)
end

function Menu:update()
    Menu.super.update(self)
end

function Menu:drawBackground()
    Menu.super.drawBackground(self)

    local titleFont = playdate.graphics.font.new("font/Asheville-Sans-14-Bold")
    gfx.setFont(titleFont)
    gfx.drawTextAligned("MAIN MENU", 200, 40, kTextAlignment.center)

    self.menuItems:draw(200, 120)
end

function Menu:exit()
    Menu.super.exit(self)
end

function Menu:finish()
    Menu.super.finish(self)
end

function Menu:pause()
    Menu.super.pause(self)
end

function Menu:resume()
    Menu.super.resume(self)
    -- Réactivez le menu lors de la reprise de la scène
    self.menuItems:activate()
end

return Menu
