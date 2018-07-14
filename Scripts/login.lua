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
  script:triggerFunction("getUserAccount", "Scripts/Database.lua", userName, "Login")

  -- compare retrieved values to entered values
  if self.usr == userName and self.password == pass then
    -- logged in status is true and account is set, return true
    self.status = true
    return true
  else
    -- failed, reset values and return false
    -- self.usr = "Guest"
    self.password = ""
    self.status = false
    return false
  end
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

function Login:getStatus()
  return self.status
end

function Login:setUserName(un)
  self.usr = un
end

function Login:setPassword(pass)
  self.password = pass
end
-- ==================== Beginning of event handlers =============================
function onCreated()
  user = Login.new()

  window = CreateWindow("Login", 10, 10, 200, 100)
  unEditBox = CreateEditBox(10, 15, 170, 20)
  pwEditBox = CreateEditBox(10, 37, 170, 20)
  loginButton = CreateButton("Login", 10, 60, 60, 20)
  statusText = CreateText("Test", 0, 82)

  window:addElement(unEditBox)
  window:addElement(pwEditBox)
  window:addElement(loginButton)
  window:addElement(statusText)

  user:login("admin","pass")
end

function onSQLRecieved(results, id)
  user:setUserName( "SQL Test" )

  if id == "Login" then
    statusText:setText( user:getUserName() )
    if operations:arraySize(results) == 0 then
      user:setUserName( results["Account"][1]  )
      user:setPassword( "" )
    else
      user:setUserName( results["Account"][1] )
      user:setPassword( results["Password"][1] )
    end
  end
end

function onButtonPressed(button)
end