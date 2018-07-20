function onCreated()
  pages= script:triggerFunction("getPages", "Scripts/Pages.lua")
  
  loginButton = pages[1].elements.loginButton
  script:triggerFunction("onButtonPressed", "Scripts/Pages.lua", loginButton)

  registerMenuUnBox = script:getValue("unEditBox", "Scripts/login.lua")
  registerMenuUnBox:setText("user1")
  --loginMenuLoginButton = script:getValue("registerButton", "Scripts/login.lua")
end