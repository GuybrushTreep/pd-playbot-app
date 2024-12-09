Menu = {}
class("Menu").extends(NobleScene)
local scene = Menu

scene.backgroundColor = Graphics.kColorWhite

local menuItems = nil

function scene:init()
	scene.super.init(self)

	menuItems = Noble.Menu.new(
		true,                          -- Activer le menu
		Noble.Text.ALIGN_CENTER,       -- Centrer le texte
		false,                         -- Pas de localisation
		playdate.graphics.kColorBlack, -- Couleur du texte
		4, 6,                          -- Padding
		Noble.Text.FONT_MEDIUM         -- Police
	)

	menuItems:addItem("Mode", function() Noble.transition(ModeScene) end)
	menuItems:addItem("Sensors", function() Noble.transition(SensorsScene) end)
	menuItems:addItem("Options", function() Noble.transition(OptionsScene) end)
end

function scene:enter()
	scene.super.enter(self)
	-- Votre code ici si nécessaire
end

function scene:start()
	scene.super.start(self)
	-- Votre code ici si nécessaire
end

function scene:update()
	scene.super.update(self)
	-- Votre code ici si nécessaire
end

function scene:drawBackground()
	scene.super.drawBackground(self)

	playdate.graphics.setFont(Noble.Text.FONT_LARGE)
	playdate.graphics.drawTextAligned("MAIN MENU", 200, 40, kTextAlignment.center)

	menuItems:draw(200, 120)
end

function scene:exit()
	scene.super.exit(self)
	-- Votre code ici si nécessaire
end

function scene:finish()
	scene.super.finish(self)
	-- Votre code ici si nécessaire
end

function scene:pause()
	scene.super.pause(self)
	-- Votre code ici si nécessaire
end

function scene:resume()
	scene.super.resume(self)
	-- Votre code ici si nécessaire
end

scene.inputHandler = {
	upButtonDown = function()
		menuItems:selectPrevious()
	end,

	downButtonDown = function()
		menuItems:selectNext()
	end,

	AButtonDown = function()
		menuItems:click()
	end
}
