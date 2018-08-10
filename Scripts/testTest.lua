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

  local testName = "Test #" .. tostring(testNo-1)
  testViewProblem(listBoxHasItem(pages[1].elements.listBox, testName))

  return testName
end

function onCreated()
  onTest = -1
end

function appendTestOutput(cont)
  fileCont = ""
  if operations:fileExists("outputTest.txt") then
    fileCont = operations:readFile("outputTest.txt")
  end
  fileCont = fileCont .. cont .. "\n"
  operations:writeFile("outputTest.txt", fileCont)
end

function main()
  if onTest == 1 then

    operations:writeFile("outputTest.txt", "") -- Clear the test output
    testLogin()
    time = game:getTime()
    onTest = onTest+1

  elseif onTest == 2 then

    loginStatus = script:triggerFunction("getStatus", "Scripts/login.lua")
    if loginStatus == true then
      appendTestOutput("Login test successful!")
      testProbTitle = testCreateProblem()
      time = game:getTime()
      onTest = onTest+1
    elseif time < game:getTime() - 10000 then -- Took longer than 10 seconds to log in. Failed.
      appendTestOutput("Login test failed.")
      onTest = -1 -- Stop testing. Failed.
    end

  elseif onTest == 3 then

    topModal = script:triggerFunction("getTopModal", "Scripts/Pages.lua")
    if topModal ~= nil and topModal.elements.title:getText() == testProbTitle then
      appendTestOutput("Create problem successful!")
      appendTestOutput("View problem successful!")
      onTest = onTest+1
    elseif time < game:getTime()-10000 then -- Took longer than 10 seconds to create and view problem. Failed.
      appendTestOutput("Create problem failed.")
      appendTestOutput("View problem failed.")
      onTest = -1 -- Stop testing. Failed.
    end

  end
end