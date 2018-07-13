function onCreated()
  topBar = CreateImage("GLOBAL/pixel.png", 200, 0, 250, 50)
  topBar:setColor(56,56,56,255)
  loginButton = makeButton("login", 200, 0, 100, 50)
  reportButton = makeButton("new_problem", 300, 0, 100, 50)
  menuButton = makeButton("menu", 400, 0, 50, 50)

  abutton = CreateButton("test", 100,100,100,100)
end

function onButtonPressed(button)
  if button == abutton then
    anotherbutton = CreateButton("it works", 400, 400, 100, 100)
  end
end

function makeButton(imgName, x, y, w, h)
  newButton = CreateButton("", x, y, w, h)
  newButton:setImage("UI/" .. imgName .. ".png")
  newButton:setScaleImage(true) 
  return newButton
end