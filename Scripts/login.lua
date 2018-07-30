local Login = {}
function Login.new()
  local loginElements = {}
  loginElements.usr = "Guest"
  loginElements.pass = ""
  loginElements.status = false
  setmetatable(loginElements, {__index = Login})
  return loginElements
end

function Login:login(userName, pass )
  self.usr = userName
  self.pass = pass
  statusText:setText("")
  script:triggerFunction("getUserAccount", "Scripts/Database.lua", userName, "Login")
  if getStatus() == true then 
    statusText:setText("Signed in")
  else 
    -- This should probably be somewhere else.
    --[[if getStatus() == false then 
      statusText:setText("Login Error")  
    end--]]
  end
end
function Login:logOut()
  self.usr = "Guest"
  self.status = false
end

function Login:register(userName, pass)
  self.usr = userName
  self.pass = pass 

  script:triggerFunction("getUserAccount", "Scripts/Database.lua", userName, "regCheck")
end
-- =================== Beginning of get and set functions =======================
function Login:getUserName()
  return self.usr
end

function Login:getPassword()
  return self.pass
end

function Login:getStatus()
  return self.status
end

function Login:setUserName(un)
  self.usr = un
end

function Login:setPassword(pass)
  self.password = pass
end

function Login:setStatus(stat)
  self.status = stat
  script:triggerFunction("updateAccess", "Scripts/Pages.lua")
end
-- ==================== Non Object Functions to Access Account =====================
function getUserName()
  if user == nil then
    return nil
  end
  return user:getUserName()
end

function getStatus()
  return user:getStatus()
end

function setStatus(status)
  user:setStatus(status)
end
-- ==================== Beginning of event handlers =============================
function onCreated()
  user = Login.new()

  overlay = CreateImage("GLOBAL/pixel.png", 0, 0, 640, 480)
  overlay:setColor(155,155,155,190)
  window = CreateWindow("Login", 10, 10, 250, 170)
  window:setMovable(true); window:setMovableBoundaries(0-window:getWidth()+40, 0, 640+window:getWidth()-40, 480+window:getHeight()-40)
  window:center()

  loginBG = CreateImage("GLOBAL/pixel.png", 0, 0, 250, 120)
  barBG = CreateImage("GLOBAL/pixel.png", 0, 120, 250, 50)
  userLbl = CreateText("Username", 25, 10, 75, 25)
  passLbl = CreateText("Password", 25, 60, 75, 25)
  unEditBox = CreateEditBox(25, 25, 170, 25)
  pwEditBox = CreateEditBox(25, 75, 170, 25)
  pwEditBox:setPasswordBox(true)
  loginButton = makeButton("ok", 5, 115, 100, 50)
  registerButton = makeButton("register", 95, 115, 100, 50)
  cancelButton = makeButton("x", 200, 115, 50, 50)
  --logginginLbl = CreateText("Logging in...", 10, 170, 100, 25)
 statusText = CreateText("",10, 15)

  window:addElement(barBG)
  window:addElement(loginBG)
  window:addElement(userLbl)
  window:addElement(passLbl)
  --window:addElement(logginginLbl)
  window:addElement(statusText)
  window:addElement(unEditBox)
  window:addElement(pwEditBox)
  window:addElement(loginButton)
  window:addElement(registerButton)
  window:addElement(cancelButton)
  window:hide()
  overlay:hide()
  
  --logginginLbl:setVisible(false)
  
  loginBG:setColor(56,56,56,255)
  barBG:setColor(100,100,100,255)
  userLbl:setColor(255,255,255,255)
  passLbl:setColor(255,255,255,255)
  --logginginLbl:setColor(255,255,255,255)
  
  unEditBox:setTabOrder(0)
  pwEditBox:setTabOrder(1)
  loginButton:setTabOrder(2)
  registerButton:setTabOrder(3)

  --user:login("admin","pass")
  --statusText:setText( user:getUserName() )
end

function onSQLReceived(results, id)
  if id == "Login" then
    if operations:arraySize(results) == 0 then
      user:setUserName( "Guest" )
      user:setPassword( "" )
    else
      -- compare retrieved values to entered values
      if user:getUserName() == results["Account"][1] and user:getPassword() == results["Password"][1] then
        -- logged in status is true and account is set, return true
        user:setPassword("")
        user:setStatus(true)
        onButtonPressed(cancelButton)
      else
        -- failed, reset values and return false
        user:setUserName("Guest")
        user:setPassword("")
        user:setStatus(false)
      end
    end
  elseif id == "regCheck" then

    if operations:arraySize(results) ~= 0 then
      errorWindow = CreateWindow("Signup Error", 10, 120, 100, 100)
      regErrButton = CreateButton("Close", 30, 60, 40, 20)
      regErrText = CreateText("Account Already Taken", 15, 20)
      
      errorWindow:addElement(regErrButton)
      errorWindow:addElement(regErrText)
      errorWindow:bringToFront()
    else
      script:triggerFunction("createAccount", "Scripts/Database.lua", user:getUserName(), user:getPassword())
      user:setStatus(true)
    end
  end 

  unEditBox:setText("")
  pwEditBox:setText("")
  -- statusText:setText(user:getUserName())
end

function onButtonPressed(button)
  if button == loginButton then
    if unEditBox:getText() == "" or pwEditBox:getText() == "" then
      -- do nothing
    else
      user:login( unEditBox:getText(), pwEditBox:getText() )
      -- statusText:setText(user:getUserName() )
  --logginginLbl:setVisible(true)
    end
  elseif button == cancelButton then
    unEditBox:setText("")
    pwEditBox:setText("")
    window:hide()
    overlay:hide()
  elseif button == registerButton then
    if unEditBox:getText() == "" or pwEditBox:getText() == "" then
      unEditBox:setText("")
      pwEditBox:setText("")
    else
      user:register( unEditBox:getText(), pwEditBox:getText() )
    end
  elseif button == regErrButton then
    errorWindow:remove()
  end

  --statusText:setText(user:getUserName())
end

--~~~~~~~~~~~~~~~~~Button functions~~~~~~~~~~~~~~~~~
function makeButton(imgName, x, y, w, h)
  newButton = CreateButton("", x, y, w, h)
  newButton:setImage("UI/" .. imgName .. ".png")
  newButton:setScaleImage(true) 
  return newButton
end
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~