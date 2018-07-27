local Page = {}
function Page.new()
  local o = {}
  o.currPage=""
  o.refreshingView = false
  o.elements = {}
  setmetatable(o, {__index = Page})
  return o
end

function Page:formatElements()
  if self.elements.menu ~= nil then
    if self.elements.overlay ~= nil then
      self.elements.overlay:setWidth(640)
      self.elements.overlay:setHeight(480)
      self.elements.overlay:setColor(255,255,255,100)
      self.elements.overlay:bringToFront()
      self.elements.menu:bringToFront()
    end
    self.elements.menu:center()
  
    for i,element in pairs(self.elements) do
      if i ~= "menu"  and i ~= "overlay" and (element:getParent() == nil or element:getParent() == element) then
        self.elements.menu:addElement(element)
        if self == pages[1] then
          element:setY( element:getY()+88 )
        end
      end
    end
  end
end

function Page:setViewPage()
  self:destroy()

  self.elements = {
    menu = CreateImage("GLOBAL/pixel.png", 0, 0, 250, 700),

    loginButton = makeButton("login", 140, 25, 100, 50),
    logoutButton = makeButton("logout", 140, 25, 100, 50),
    probBG = CreateImage("GLOBAL/pixel.png", 10, 75, 230, 225),
    probLabel = CreateText("Problems:", 10, 75, 230, 25),
    listBox = CreateListBox(10, 100, 230, 200),

    createButton = makeButton("new_problem", 10, 350, 100, 50),
    refreshButton = makeButton("refresh", 100, 350, 50, 50),
    myIssuesButton = makeButton("my_probs", 140, 350, 100, 50),
    openButton = CreateButton("View Selected Problem", 10, 310, 230, 30),
    credits = CreateImage("UI/credits_style3.png", 25, 390, 200, 100)
  }
  --self.elements.dropList:addItem("Sort By: Nearest")
  self.elements.menu:setColor(56,56,56,255)
  self.elements.probBG:setColor(249,249,249,255)
  self:formatElements()
  self:refreshViewPage()

  updateAccess()
  self.elements.createButton:bringToFront()
  self.elements.refreshButton:bringToFront()
  self.elements.myIssuesButton:bringToFront()
end

function Page:setAddProblemPage(y)
  self:destroy()

  self.elements = {
    menu = CreateWindow("Create Problem",0,0,300,305),
    overlay = CreateImage("GLOBAL/pixel.png",0,0,0,0),
    title = CreateEditBox(5,45,290,30),
    description = CreateEditBox(5,80,290,70),
    latitude = CreateEditBox(5,155,290,30),
    longitude = CreateEditBox(5,190,290,30),
    createButton = CreateButton("Create Problem",5,240,290,55),
    cancelButton = makeButton("x", 250,0,50,50),
  }
  self.elements.createButton:setImage("UI/subbut.jpg")
  self.elements.createButton:setScaleImage(true)

  self.elements.menu:setMovable(); self.elements.menu:setMovableBoundaries(0-280, 0, 640+280, 480+225)
  self.elements.title:setText("Title")
  self.elements.description:setText("Description"); self.elements.description:setMultiLine(true)
  self.elements.latitude:setText("Latitude")
  self.elements.longitude:setText("Longitude")

  self:formatElements()
  self.elements.cancelButton:bringToFront()
end


function Page:setViewProblemPage(y)
  self:destroy()

  self.elements = {
    menu = CreateWindow("View Problem",0,100,300,410),
    overlay = CreateImage("GLOBAL/pixel.png",0,0,0,0),
    title = CreateEditBox(5,50,290,30),
    description = CreateEditBox(5,85,290,70),
    latitude = CreateEditBox(5,160,290,30),
    longitude = CreateEditBox(5,195,290,30),
    cancelButton = makeButton("x", 250,0,50,50)
  }

  self.elements.menu:setMovable();
  self.elements.menu:setMovableBoundaries(0-280, 0, 640+280, 480+225)
  self.elements.title:setText("Title")
  self.elements.description:setText("Description"); self.elements.description:setMultiLine(true)
  self.elements.latitude:setText("Latitude")
  self.elements.longitude:setText("Longitude")
  script:triggerFunction("setParent", "Scripts/vote.lua", self.elements.menu)

  self:formatElements()
  self.elements.cancelButton:bringToFront()
end

function Page:destroy()
  for i,element in pairs(self.elements) do
    element:remove()
  end
  self.elements = {}
end

function Page:refreshViewPage()
  self.elements.listBox:clear()
  script:triggerFunction("GetAllProblems", "Scripts/Database.lua")
end

--~~~~~~~~~~~~~~~~~Login functionality~~~~~~~~~~~~~~
function updateAccess()
--shows/hides submit problem button based on whether user is logged in or not
  loggedin = false
  status = script:triggerFunction("getStatus", "Scripts/login.lua")
  if status == true then
    loggedin = true
  end
  pages[1].elements.createButton:setVisible(loggedin)
  pages[1].elements.myIssuesButton:setVisible(loggedin)
 if status == true then
 pages[1].elements.loginButton:setVisible(false)
 pages[1].elements.logoutButton:setVisible(true)
else
 pages[1].elements.loginButton:setVisible(true)
 pages[1].elements.logoutButton:setVisible(false)
end
end

--~~~~~~~~~~~~~~~~~Button functions~~~~~~~~~~~~~~~~~
function makeButton(imgName, x, y, w, h)
  local newButton = CreateButton("", x, y, w, h)
  newButton:setImage("UI/" .. imgName .. ".png")
  newButton:setScaleImage(true) 
  return newButton
end

function togglePress(btn, press)

  if btn:getElementType() ~= "CreateButton" then
    return true
  end

  img = btn:getImage()
  newImg = nil
  if img == "" then
    --default button
return true
  elseif press then
    newImg = string.sub(img, 1, -5) .. "_pressed.png"
  else
    newImg = string.gsub(img, "_pressed", "")
  end
  btn:setImage(newImg)
end
--~~~~~~~~~~~~~~~~~On created~~~~~~~~~~~~~~~~~~~~~~~~

function onCreated()
  if pages ~= nil and pages[1] ~= nil then
    pages[1]:destroy()
  end
  pages = {}
  pages[1] = Page.new()
  pages[1]:setViewPage()
  --ref to last button pressed so its img can be changed when pressed/released
  lastPressed = nil
  updateAccess()
end

--~~~~~~~~~~~~~~~~~Mouse functions~~~~~~~~~~~~~~~~~
function onButtonPressed(button)
  if button==pages[1].elements.myIssuesButton then
    pages[1].elements.listBox:clear()
    if script:triggerFunction("getStatus", "Scripts/login.lua") then
      script:triggerFunction("ViewMyProblems", "Scripts/Database.lua", script:triggerFunction("getUserName", "Scripts/login.lua"))
    end
  end
  if button == page.elements.logoutButton then
     script:triggerFunction("setStatus", "Scripts/login.lua", false) 
 end
  
     for i,page in pairs(pages) do
    if button == page.elements.createButton then
      if i == 1 then
        newPage = Page.new()
        table.insert(pages, newPage)
        newPage:setAddProblemPage()
      else
        script:triggerFunction("InsertProblem", "Scripts/Database.lua", page.elements.title:getText(), 0, page.elements.description:getText(), page.elements.longitude:getText(), page.elements.latitude:getText())
        if pages[1].elements.listBox:getItemCount() == 1 and pages[1].elements.listBox:getItem(0) == "No Problems Found" then pages[1].elements.listBox:clear(); end
        pages[1].elements.listBox:addItem(page.elements.title:getText())
        page:destroy()
      end
    end
    if button == page.elements.cancelButton then
      script:triggerFunction("removeParent", "Scripts/vote.lua", getTopModal().elements.menu)
      script:triggerFunction("toggleVis", "Scripts/vote.lua", false)
      page:destroy()
    end 

    if button == page.elements.refreshButton then
      pages[1].elements.listBox:clear()
      pages[1]:refreshViewPage()
    end
  end
  if button == pages[1].elements.openButton and pages[1].elements.listBox:getSelected() >= 0 then
    script:triggerFunction("ViewProblem", "Scripts/Database.lua", pages[1].elements.listBox:getSelectedName(), operations:arraySize(pages)+1)
    newPage = Page.new()
    newPage:setViewProblemPage()
    table.insert(pages, newPage)
    script:triggerFunction("toggleVis", "Scripts/vote.lua", true)
    script:triggerFunction("snapToWindow", "Scripts/vote.lua")
  end
  if button == pages[1].elements.loginButton then
    window = script:getValue("window", "Scripts/login.lua")
    window:show()
    overlay = script:getValue("overlay", "Scripts/login.lua")
    overlay:show()
    overlay:bringToFront()
    window:bringToFront()
  end
end

function onLeftDoubleMouseDown(mouseId)
  if mouse:getElement(mouseId) == pages[1].elements.listBox and pages[1].elements.listBox:getSelected() >= 0 then
    onButtonPressed(pages[1].elements.openButton)
  end
end

function onLeftMouseDown(mouseID)
  lastPressed = mouse:getElement(mouseID)
  togglePress(lastPressed, true)
  --[[
  if mouse:getElement(mouseID) == pages[1].elements.listBox and pages[1].elements.listBox:getSelected() >= 0 then
    onButtonPressed(pages[1].elements.openButton)
  end
  --]]
end

function onLeftMouseUp(mouseID)
  togglePress(lastPressed, false)
end
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

function onSQLReceived(results, id)
  if id == "allProblems" then
    if operations:arraySize(results) == 0 then
      pages[1].elements.listBox:addItem("No Problems Found")
    else
      pages[1].elements.listBox:clear()
      for i,val in pairs(results["Title"]) do
        pages[1].elements.listBox:addItem(val)
      end
    end
  end
  if id:find("viewProblem") == 1 then
    modalNo = id:sub(12, id:len())+0
    script:triggerFunction("getVotesAndDisplay", "Scripts/vote.lua", results["ID"][1])
    --call toggleVis again to show up/down buttons if logged in
    script:triggerFunction("toggleVis", "Scripts/vote.lua", true)
    
    pages[modalNo].elements.title:setText(results["Title"][1])
    pages[modalNo].elements.description:setText(results["Description"][1])
    pages[modalNo].elements.longitude:setText(results["Longitude"][1])
    pages[modalNo].elements.latitude:setText(results["Latitude"][1])
  end
end

function getPages()
  return pages
end

function getTopModal()
  return pages[operations:arraySize(pages)]
end