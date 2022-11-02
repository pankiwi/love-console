--isn't necessary for the console is your
love.keyboard.setKeyRepeat(true)

function love.load()
 --require and  load console
 console = require "randomconsole"()

--is a tiny code
 rectangle = {
   x = 100, y = 100,
   width = 100, height = 100,
   r = 1, g = 1, b = 1,
   velx = 10, vely = 10
   }
   
--open the console
 console.open()
end

function love.update(dt)
 --tiny code
 local windowWidth, windowHeight = love.graphics.getDimensions()
	
 rectangle.x = rectangle.x + rectangle.velx
 rectangle.y = rectangle.y + rectangle.vely
 
 if rectangle.x  <= 0 then rectangle.x = 0 rectangle.velx = -rectangle.velx print(windowWidth, windowHeight, rectangle.x) end 
 if rectangle.x + rectangle.width >= windowWidth then rectangle.x = windowWidth - rectangle.width  rectangle.velx = -rectangle.velx print(windowWidth, windowHeight, rectangle.x) end
 
 if rectangle.y  <= 0 then rectangle.y = 0 rectangle.vely = -rectangle.vely print(windowWidth, windowHeight, rectangle.x) end
 if rectangle.y + rectangle.height >= windowHeight then rectangle.yend = windowHeight - rectangle.height  rectangle.vely =  -rectangle.vely print(windowWidth, windowHeight, rectangle.x) end
end

function love.draw()
 --a tiny code
  love.graphics.setColor(rectangle.r, rectangle.g, rectangle.b, 1)
  love.graphics.rectangle("fill", rectangle.x, rectangle.y,
    rectangle.width, rectangle.height)
  
  --draw the console
  console.draw()
end

--is necessary for mobile for pc is not matter
function love.touchreleased(id, x, y) 
 console.press(x, y)
end

--is necessary
function love.keypressed(key, scancode, isrepeat)
 console.keypressed(key, scancode, isrepeat)
end

--is necessary
function love.textinput(text)
 console.textinput(text)
end
