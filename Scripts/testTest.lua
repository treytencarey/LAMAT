function testLogin()
  loginButton = script:triggerFunction("getPages", "Scripts/Pages.lua")
  if loginButton == nil then return; end
  loginButton = loginButton[1].elements.loginButton
  script:triggerFunction("onButtonPressed", "Scripts/Pages.lua", loginButton)

  loginMenuUnBox = script:getValue("unEditBox", "Scripts/login.lua")
  loginMenuUnBox:setText("admin")
  loginMenuPwBox = script:getValue("pwEditBox", "Scripts/login.lua")
  loginMenuPwBox:setText("pass")

  loginMenuLoginButton = script:getValue("loginButton", "Scripts/login.lua")
  script:triggerFunction("onButtonPressed", "Scripts/login.lua", loginMenuLoginButton)
end

function testViewProblem(itemNo)
  itemNo = itemNo or 0
  pages = script:triggerFunction("getPages", "Scripts/Pages.lua")

  viewButton = pages[1].elements.openButton
  listBox = pages[1].elements.listBox
  listBox:setSelected(itemNo)
  script:triggerFunction("onButtonPressed", "Scripts/Pages.lua", viewButton)
end

function listBoxHasItem(listBox, str)
  for i=0, listBox:getItemCount()-1 do
    if listBox:getItem(i) == str then return i; end
  end
  return -1
end

function testCreateProblem()
  pages = script:triggerFunction("getPages", "Scripts/Pages.lua")
  if pages == nil then return; end
  submitButton = pages[1].elements.createButton
  script:triggerFunction("onButtonPressed", "Scripts/Pages.lua", submitButton)

  modal = script:triggerFunction("getTopModal", "Scripts/Pages.lua")
  if modal == nil then return; end

  testNo = 1
  while listBoxHasItem(pages[1].elements.listBox, "Test #" .. tostring(testNo)) >= 0 do
    testNo = testNo+1
  end

  modal.elements.title:setText("Test #" .. tostring(testNo))
  modal.elements.description:setText("This was created by the test script.")
  modal.elements.latitude:setText("0")
  modal.elements.longitude:setText("0")
  script:triggerFunction("onButtonPressed", "Scripts/Pages.lua", modal.elements.createButton)

  testViewProblem(listBoxHasItem(pages[1].elements.listBox, "Test #" .. tostring(testNo-1)))
end

function onCreated()
  --testLogin()

  testCreateProblem()
end