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

function Login:Register()
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

  window = CreateWindow("Login", 10, 10, 200, 100)
  unEditBox = CreateEditBox(10, 15, 170, 20)
  pwEditBox = CreateEditBox(10, 37, 170, 20)
  loginButton = CreateButton("Login", 10, 60, 60, 20)
  cancelButton = CreateButton("Cancel", 73, 60, 60, 20)
  -- statusText = CreateText("Test", 0, 82)

  window:addElement(unEditBox)
  window:addElement(pwEditBox)
  window:addElement(loginButton)
  window:addElement(statusText)
  window:addElement(cancelButton)
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
  end 
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
  end
end