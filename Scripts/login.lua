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

  script:triggerFunction("getUserAccount", "Scripts/Database.lua", userName, "Login")
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
end

-- ==================== Beginning of event handlers =============================
function onCreated()
  user = Login.new()

  window = CreateWindow("Login", 10, 10, 200, 105)
  unEditBox = CreateEditBox(10, 15, 170, 20)
  pwEditBox = CreateEditBox(10, 37, 170, 20)
  loginButton = CreateButton("Login", 10, 60, 60, 20)
  cancelButton = CreateButton("Cancel", 73, 60, 60, 20)
  registerButton = CreateButton("Register", 10, 83, 60, 20)
  -- statusText = CreateText("Test", 0, 82)

  window:addElement(unEditBox)
  window:addElement(pwEditBox)
  window:addElement(loginButton)
  window:addElement(statusText)
  window:addElement(cancelButton)
  window:addElement(registerButton)
  window:hide()

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
    end
  elseif button == cancelButton then
    unEditBox:setText("")
    pwEditBox:setText("")
    window:hide()
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