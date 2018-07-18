function onCreated()
  if game:isStatic() then
    script:remove(script:thisName())
    return
  end
  gitFuncs = {}
  game:loadScripts("GLOBAL/Scripts/scriptOpen.lua")

  gitOpenButton = CreateButton("Push Changes to Git?"); gitOpenButton:hide()

  overlay = CreateImage("GLOBAL/pixel.png", 0, 0, 640, 480)
  overlay:setColor(255,255,255,100)
  overlay:hide()

  modal = CreateWindow("Push to Git Repository", 0, 0, 300, 245); modal:center()
  modalClose = CreateButton("Close", 5, modal:getHeight()-40, modal:getWidth()-10, 30); modal:addElement(modalClose)

  modalPages = {
    { emailBox = CreateEditBox(5, 30, modal:getWidth()-10, 30),
      userBox = CreateEditBox(5, 65, modal:getWidth()-10, 30),
      passwordBox = CreateEditBox(5, 100, modal:getWidth()-10, 30),
      nextButton = CreateButton("Next", 5, modalClose:getY()-35, modalClose:getWidth(), modalClose:getHeight())
    },
    { gitEditBox = CreateEditBox(5,30,modal:getWidth()-10,modalClose:getY()-70),
      pushButton = CreateButton("Send Git Commands",5,modalClose:getY()-35,modalClose:getWidth(),modalClose:getHeight())
    },
    { gitEditBox = CreateEditBox(5,30,modal:getWidth()-10,modalClose:getY()-35)
    }
  }
  modalPages[1].passwordBox:setPasswordBox(true)
  modalPages[2].gitEditBox:setMultiLine(true)
  modalPages[3].gitEditBox:setMultiLine(true)

  inPage = 1
  for k,page in pairs(modalPages) do
    for i,elem in pairs(page) do
      modal:addElement(elem)
      if k > 1 then elem:hide();
      else
        if operations:fileExists("gitInfo") then
          if i == "emailBox" then elem:setText(tostring(operations:getVar("gitInfo", "email"))) end
          if i == "userBox" then elem:setText(tostring(operations:getVar("gitInfo", "user"))) end
          if i == "passwordBox" then elem:setText(tostring(operations:getVar("gitInfo", "pass"))) end
        else
          if i == "emailBox" then elem:setText("GitHub Email") elseif i == "userBox" then elem:setText("GitHub Username") elseif i == "passwordBox" then elem:setText("GitHub Password") end
        end
      end
    end
  end

  modal:hide()
end

function setModalPage(pageNo)
  for i,elem in pairs(modalPages[inPage]) do
    elem:hide()
  end
  for i,elem in pairs(modalPages[pageNo]) do
    elem:show()
  end
  inPage = pageNo

  openScript = script:getValue("openScript","GLOBAL/Scripts/scriptOpen.lua")

  if inPage == 2 then
    modalPages[2].gitEditBox:setText(
      "git config --global user.email \"" .. modalPages[1].emailBox:getText() .. "\"\n" ..
      "git config --global user.name \"" .. modalPages[1].userBox:getText() .. "\"\n" ..
      "git init\n" ..
      "git add " .. openScript:sub( 8 + self:getWorld():len() + 1, openScript:len()) .. "\n" ..
      "git commit -m \"ENTER MESSAGE HERE\"\n" ..
      "git remote add origin https://" .. modalPages[1].userBox:getText() .. ":" .. modalPages[1].passwordBox:getText() .. "@github.com/treytencarey/LAMAT\n" ..
      "git push origin master"
    )
  end
end

function onCommand(cmd, cmdStr)
  if cmd == "ping" and cmdStr == "git" then
    modalPages[3].gitEditBox:setText( modalPages[3].gitEditBox:getText() .. gitFuncs[1] .. "\n")
    server:sendGit(gitFuncs[1]);
    table.remove(gitFuncs, 1)
    if operations:arraySize(gitFuncs) > 0 then
      server:ping("git")
    end
  end
end

function main()
  if callbackRes == nil then
    callbackRes = script:triggerFunction("addButtonCallbackScript", "GLOBAL/Scripts/scriptOpen.lua", script:thisName(), "onButtonPressed")
  end
end

function doRanPressed()
  scriptOpenMenu = script:getValue("scriptOpenMenu", "GLOBAL/Scripts/scriptOpen.lua")
  gitOpenButton:setRect(scriptOpenMenu:getX(), scriptOpenMenu:getY()+scriptOpenMenu:getHeight(), scriptOpenMenu:getWidth(), 30)
  gitOpenButton:show()
  gitOpenButton:bringToFront()
end

function doClosePressed()
  gitOpenButton:hide()
end

function onButtonPressed(button)
  if button == script:getValue("scriptOpenRun", "GLOBAL/Scripts/scriptOpen.lua") then
    doRanPressed()
  end
  if button == script:getValue("scriptOpenClose", "GLOBAL/Scripts/scriptOpen.lua") then
    doClosePressed()
  end
  if button == gitOpenButton then
    overlay:show(); overlay:bringToFront()
    modal:show(); modal:bringToFront()
  end
  if button == modalClose then
    overlay:hide(); modal:hide()
    setModalPage(1)
  end
  if button == modalPages[1].nextButton then
    operations:writeFile("gitInfo", "email = " .. modalPages[1].emailBox:getText() .. ";\nuser = " .. modalPages[1].userBox:getText() .. ";\npass = " .. modalPages[1].passwordBox:getText() .. ";\n")
    setModalPage(2)
  end
  if button == modalPages[2].pushButton then
    cmds = operations:getTokens(modalPages[2].gitEditBox:getText(), "\n")
    for i=0, operations:arraySize(cmds)-1 do
      table.insert(gitFuncs, cmds[i])
    end
    server:sendGit(gitFuncs[1]); table.remove(gitFuncs, 1); server:ping("git")

    modalPages[3].gitEditBox:clear()
    modalPages[3].gitEditBox:setText( "Tasks sent so far:\n" .. cmds[0] .. "\n" )
    setModalPage(3);
  end
end