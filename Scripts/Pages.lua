local Page = {}
local MISC, MAINT, HAZARD, AESTH, ALL = 0, 1, 2, 3, 4
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
    menu = CreateImage("GLOBAL/pixel.png", 0, 0, 270, 700),

    loginButton = makeButton("login", 155, 25, 100, 50),
    logoutButton = makeButton("logout", 155, 25, 100, 50),
credits = CreateImage("UI/credits_style3.png", 10, 25, 100, 50),

    proFilter = CreateDropList(10, 75, 250, 25),

createButton = makeButton("new_problem", 25, 100, 100, 50),
    myIssuesButton = makeButton("my_probs", 145, 100, 100, 50),

    probBG = CreateImage("GLOBAL/pixel.png", 10, 320, 250, 130),
    listBox = CreateListBox(10, 320, 250, 130),
    openButton = CreateButton("View Selected Problem", 10, 460, 200, 30),
refreshButton = makeButton("refresh", 210, 450, 50, 50)
  }
  --self.elements.dropList:addItem("Sort By: Nearest")
  self.elements.proFilter:addItem("Filter By: Misc")
  self.elements.proFilter:addItem("Filter By: Maintanence")
  self.elements.proFilter:addItem("Filter By: Hazard")
  self.elements.proFilter:addItem("Filter By: Aesthetic")
  self.elements.proFilter:addItem("Filter By: All")
  self.elements.proFilter:setSelected(ALL)

  self.elements.menu:setColor(56,56,56,255)
  self.elements.probBG:setColor(100,100,100,255)
  self:formatElements()
  self:refreshViewPage()

  updateAccess()
  self.elements.proFilter:bringToFront()
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
    category = CreateDropList(5, 15, 100, 20),
    createButton = CreateButton("Create Problem",5,240,290,55),
    cancelButton = makeButton("x", 250,0,50,50)
  }
  self.elements.createButton:setImage("UI/subbut.jpg")
  self.elements.createButton:setScaleImage(true)

  self.elements.menu:setMovable(); self.elements.menu:setMovableBoundaries(0-280, 0, 640+280, 480+225)
  self.elements.title:setText("Title")
  self.elements.description:setText("Description"); self.elements.description:setMultiLine(true)
  self.elements.latitude:setText("Latitude")
  self.elements.longitude:setText("Longitude")

  self.elements.category:addItem("Maintanence")
  self.elements.category:addItem("Hazard")
  self.elements.category:addItem("Aesthetic")
  self.elements.category:addItem("Misc")
  self.elements.category:setSelected(3)

  self:formatElements()
  self.elements.cancelButton:bringToFront()
end


function Page:setViewProblemPage(y)
  self:destroy()

  self.elements = {
    menu = CreateWindow("View Problem",0,100,270,325),
    overlay = CreateImage("GLOBAL/pixel.png",0,0,0,0),
bg = CreateImage("GLOBAL/pixel.png",0,0,270,375),
barBG = CreateImage("GLOBAL/pixel.png", 0, 275, 270, 50),
descBG = CreateImage("GLOBAL/pixel.png", 0, 50, 270, 100),
--titleLbl = CreateText("Title:",5,20,50,30),
    title = CreateText("Title",0,20,270,30),
    description = CreateEditBox(10,60,250,90),
latlong = CreateText("", 10,150,250,30),
    --latitude = CreateEditBox(10,190,122.5,30),
    --longitude = CreateEditBox(137.5,190,122.5,30),
    cancelButton = makeButton("x", 220,270,50,50),
    updateButton = CreateButton("Edit Description", 10, 270,120,50)
  }

  self.elements.bg:setColor(60,60,60,255)
  self.elements.barBG:setColor(50,50,50,255)
  self.elements.descBG:setColor(230,230,230,255)
  --self.elements.titleLbl:setColor(255,255,255,255)
  
  self.elements.menu:setMovable();
  self.elements.menu:setMovableBoundaries(0-280, 0, 640+280, 480+225)
  self.elements.title:setTextAlignment("center")
  self.elements.title:setColor(255,255,255,255)
  --self.elements.title:setText("Title")
  --self.elements.description:setText("Description")
  self.elements.description:setMultiLine(true)
  self.elements.description:setWordWrap(true)
  self.elements.description:setTextAlignment("left", "upper")
  self.elements.latlong:setColor(255,255,255,255)
  --self.elements.latitude:setText("Latitude")
  --self.elements.longitude:setText("Longitude")

  self:formatElements()
  
  self.elements.barBG:bringToFront()
  self.elements.descBG:bringToFront()
  --self.elements.titleLbl:bringToFront()
  self.elements.title:bringToFront()
  self.elements.description:bringToFront()
  self.elements.latlong:bringToFront()
  --self.elements.latitude:bringToFront()
  --self.elements.longitude:bringToFront()
  self.elements.cancelButton:bringToFront()
self.elements.updateButton:bringToFront()
  script:triggerFunction("setParent", "Scripts/vote.lua", self.elements.menu)

end

function Page:destroy()
  for i,element in pairs(self.elements) do
    element:remove()
  end
  self.elements = {}
end

function Page:refreshViewPage()
  self.elements.listBox:clear()
  
  local selected = self.elements.proFilter:getSelected()
  if selected == ALL then
    script:triggerFunction("GetAllProblems", "Scripts/Database.lua")
  else
    script:triggerFunction("GetProblemsByCategory", "Scripts/Database.lua", selected)
  end

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
 
if button == pages[1].elements.logoutButton then
  script:triggerFunction("setStatus", "Scripts/login.lua", false)
end

     for i,page in pairs(pages) do
    if button == page.elements.createButton then
      if i == 1 then
        newPage = Page.new()
        table.insert(pages, newPage)
        newPage:setAddProblemPage()
      else
        local selected = page.elements.category:getSelected()
        local category = 0
        if selected == 0 then
          category = MAINT
        elseif selected == 1 then
          category = HAZARD
        elseif selected == 2 then
          category = AESTH
        elseif selected == 3 then
          category = MISC
        end

        script:triggerFunction("InsertProblem", "Scripts/Database.lua", page.elements.title:getText(), category, page.elements.description:getText(), page.elements.longitude:getText(), page.elements.latitude:getText())
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
  if button == getTopModal().elements.updateButton then
        script:triggerFunction("UpdateProblem", "Scripts/Database.lua", getTopModal().elements.title:getText(), getTopModal().elements.description:getText())
        getTopModal():destroy()
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
------------------Element Events----------------------------
function onElementFocusGained(elem)
  if elem == pages[1].elements.proFilter then
    pages[1]:refreshViewPage()
  end
end

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

function onSQLReceived(results, id)
  if id == "allProblems" or id == "CategoricalProb" then
    if operations:arraySize(results) == 0 then
      pages[1].elements.listBox:clear()
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
    --pages[modalNo].elements.longitude:setText(results["Longitude"][1])
    --pages[modalNo].elements.latitude:setText(results["Latitude"][1])
pages[modalNo].elements.latlong:setText("Located at " .. results["Latitude"][1] .. ", " .. results["Longitude"][1])
  end
end

function getPages()
  return pages
end

function getTopModal()
  return pages[operations:arraySize(pages)]
end