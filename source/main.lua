import 'libraries/noble/Noble'
import 'libraries/animatedImage'
import 'Modules/ResourceManager'
import 'Scenes/PlayGround'
import 'Scenes/Menu'
import 'Scenes/Sensor'
import 'Scenes/Modes'

playdate.setCollectsGarbage(true)
playdate.graphics.sprite.setAlwaysRedraw(true)
playdate.display.setRefreshRate(30)
--Noble.showFPS = false
--playdate.setNewlinePrinted(true)
Noble.new(PlayGround, 0.35, Noble.Transition.MetroNexus)
