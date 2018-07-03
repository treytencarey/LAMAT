function onCreated()
  topBar = CreateImage("UI/black_box.png", 200, 0, 250, 50)
  loginButton = makeButton("login", 200, 0, 100, 50)
  reportButton = makeButton("new_problem", 300, 0, 100, 50)
  menuButton = makeButton("menu", 400, 0, 50, 50)
end

function makeButton(imgName, x, y, w, h)
  newButton = CreateButton("", x, y, w, h)
  newButton:setImage("UI/" .. imgName .. ".png")
  newButton:setScaleImage(true) 
  return newButton
end