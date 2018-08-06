--[[ \class Page
-- \brief Creates a page UI that can display information.
--]]

local Page = {}
local MISC, MAINT, HAZARD, AESTH, ALL = 0, 1, 2, 3, 4
--[[
-- \brief Creates a new page object.
-- \mod Page()
-- \return A new page object.
--]]
function Page.new()
  local o = {}
  o.currPage=""
  o.refreshingView = false
  o.elements = {}
  setmetatable(o, {__index = Page})
  return o
end

--[[
-- \brief Formats the page's children if needed, so they are properly styled.
-- \mod void formationElements()
--]]
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

--[[
-- \brief Sets the page as a view [list of] problems page.
--
--    Creates elements and formats them onto the page to view a list of all problems and buttons like logging in, refreshing the list, etc.
-- \mod void setViewPage()
--]]
function Page:setViewPage()
  self:destroy()

  self.elements = {
    menu = CreateImage("GLOBAL/pixel.png", 0, 0, 270, 700),

    loginButton = makeButton("login", 155, 25, 100, 50),
    logoutButton = makeButton("logout", 155, 25, 100, 50),
    credits = CreateImage("UI/credits_style3.png", 10, 25, 100, 50),

    createButton = makeButton("new_problem", 25, 425, 100, 50),
    myIssuesButton = makeButton("my_probs", 145, 425, 100, 50),

    probBG = CreateImage("GLOBAL/pixel.png", 10, 350, 250, 140),
    listBox = CreateListBox(10, 380, 250, 70),
    openButton = CreateButton("View Selected Problem", 10, 460, 200, 30),

    proFilter = CreateDropList(10, 350, 200, 25),
    refreshButton = makeButton("refresh", 215, 350, 50, 50)
  }
  self.elements.proFilter:addItem("Filter By: Misc")
  self.elements.proFilter:addItem("Filter By: Maintanence")
  self.elements.proFilter:addItem("Filter By: Hazard")
  self.elements.proFilter:addItem("Filter By: Aesthetic")
  self.elements.proFilter:addItem("Filter By: All")
  self.elements.proFilter:setSelected(ALL)
  
--~~~~~~~HIDING LIST OF PROBLEMS AND VIEW BUTTON!!!!!!!!!!!!!!!! IT'S STILL THERE JUST HIDDEN~~~~~~~~~~~~~~~~~~~~~~~
  self.elements.probBG:setVisible(false)
  self.elements.listBox:setVisible(false)
  self.elements.openButton:setVisible(false)

  self.elements.menu:setColor(56,56,56,255)
  self.elements.probBG:setColor(100,100,100,255)
  self:formatElements()
  self:refreshViewPage()

  updateAccess()
  self.elements.proFilter:bringToFront()
  self.elements.createButton:bringToFront()
  self.elements.refreshButton:bringToFront()
  self.elements.myIssuesButton:bringToFront()
  
  --script:triggerFunction("setParent", "Scripts/map.lua", self.elements.menu)
    self.elements.listBox:bringToFront()
end

--[[
-- \brief Sets the page as a create new problem page.
--
--    Creates elements and formats them onto the page to add a new problem.
-- \mod void setAddProblemPage()
--]]
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
  local lat = script:triggerFunction("droppedPinLat", "Scripts/map.lua")
  local long = script:triggerFunction("droppedPinLong", "Scripts/map.lua")
  self.elements.latitude:setText(string.format("%.8f", lat))
  self.elements.longitude:setText(string.format("%.8f", long))

  self.elements.category:addItem("Maintanence")
  self.elements.category:addItem("Hazard")
  self.elements.category:addItem("Aesthetic")
  self.elements.category:addItem("Misc")
  self.elements.category:setSelected(3)
  
  --script:triggerFunction("setParent", "Scripts/map.lua", self.elements.menu)

  self:formatElements()
  self.elements.cancelButton:bringToFront()
end

--[[
-- \brief Sets the view problem page's description, if it is a view problem page.
--
--    Sets the view problem page's description and attaches a scrollbar if the description exceeds the page's description size.
--    If the description is updated to a smaller size, the scrollbar is removed if able.
-- \mod void setViewProblemDescription(string description)
-- \param The new description of the problem to view.
--]]
function Page:setViewProblemDescription(descr)
  self.elements.description:setText(descr);
  
  if self.elements.descriptionScrollBar == nil then return; end
  
  if self.elements.descriptionScrollBar:isVisible() == false and self.elements.description:getTextHeight() > self.elements.descBG:getHeight() then
    self.elements.description:setWidth(self.elements.description:getWidth() - self.elements.descriptionScrollBar:getWidth())
    self.elements.description:setTextAlignment("left", "upper")
    self.elements.descriptionScrollBar:setMax(self.elements.description:getTextHeight() - self.elements.descriptionScrollBar:getHeight())
    self.elements.descriptionScrollBar:show()
    self.elements.description:setHeight(self.elements.description:getTextHeight())
  elseif self.elements.descriptionScrollBar:isVisible() and self.elements.description:getTextHeight() <= self.elements.descBG:getHeight() then
    self.elements.description:setWidth(self.elements.description:getWidth() + self.elements.descriptionScrollBar:getWidth())
    self.elements.description:setTextAlignment("left", "center")
    self.elements.descriptionScrollBar:hide()
  else
    self.elements.description:setTextAlignment("left", "center")
  end
end

--[[
-- \brief Sets whether or not the problem is editable, if the page is a view problem page.
--
--    Sets whether or not the problem is editable on a view problem page. If it is, we make the description field an editbox. Otherwise, the description field becomes text that cannot be modified.
-- \mod void setViewProblemEditable(bool editable)
-- \param Whether or not the view problem is editable.
--]]
function Page:setViewProblemEditable(editable)
  if editable == nil then editable = true; end

  if self.elements.description ~= nil then
    self.elements.description:remove()
  end
  if self.elements.descriptionScrollBar ~= nil then
    self.elements.descriptionScrollBar:remove()
    self.elements.descriptionScrollBar = nil
  end

  if editable then
    self.elements.description = CreateEditBox(0,50,270,100);
    self.elements.description:setMultiLine(true)
    self.elements.description:setWordWrap(true)
    self.elements.menu:addElement(self.elements.description)
  else
    self.elements.description = CreateText("",0,0,270,100);
    self.elements.descriptionScrollBar = CreateScrollBar(false,0,0,15,100); self.elements.descriptionScrollBar:setX(self.elements.description:getWidth() - self.elements.descriptionScrollBar:getWidth()); self.elements.descriptionScrollBar:hide()
    self.elements.descBG:addElement(self.elements.descriptionScrollBar)
    self.elements.descBG:addElement(self.elements.description)
  end
end

--[[
-- \brief Sets the page as a view problem page.
--
--    Creates elements and formats them onto the page to view a problem.
-- \mod void setViewProblemPage()
--]]
function Page:setViewProblemPage(y)
  self:destroy()

  self.elements = {
    menu = CreateImage("GLOBAL/pixel.png",0,0,270,325),
    overlay = CreateImage("GLOBAL/pixel.png",0,0,0,0),
    barBG = CreateImage("GLOBAL/pixel.png", 0, 275, 270, 50),
    descBG = CreateImage("GLOBAL/pixel.png", 0, 50, 270, 100),
    title = CreateText("Title",0,20,270,30),
    -- description has moved to setViewProblemEditable()
    latlong = CreateText("", 10,150,250,30),
    cancelButton = makeButton("x", 220,270,50,50),
    updateButton = CreateButton("Edit Description", 10, 270,120,50)
  }

  self:formatElements()
  self:setViewProblemEditable(false)

  self.elements.menu:setColor(60,60,60,255)
  self.elements.barBG:setColor(50,50,50,255)
  self.elements.descBG:setColor(230,230,230,255)
  
  self.elements.menu:setMovable();
  self.elements.menu:setMovableBoundaries(0-self.elements.menu:getWidth()+40, 0, 640+self.elements.menu:getWidth()-40, 480+self.elements.menu:getHeight()-40)
  self.elements.title:setTextAlignment("center")
  self.elements.title:setColor(255,255,255,255)
  self.elements.latlong:setColor(255,255,255,255)

  self.elements.barBG:bringToFront()
  self.elements.descBG:bringToFront()
  self.elements.title:bringToFront()
  self.elements.description:bringToFront()
  self.elements.latlong:bringToFront()
  self.elements.cancelButton:bringToFront()
  self.elements.updateButton:bringToFront()
  script:triggerFunction("setParent", "Scripts/vote.lua", self.elements.menu)
end

--[[
-- \brief Destroys the page, removing all of it's elements.
-- \mod void destroy()
--]]
function Page:destroy()
  script:triggerFunction("removeParent", "Scripts/vote.lua", self.elements.menu)
  script:triggerFunction("toggleVis", "Scripts/vote.lua", false)

  for i,element in pairs(self.elements) do
    element:remove()
  end
  self.elements = {}
end

--[[
-- \brief Refreshes the view problems page based on the selected category.
-- \mod void refreshViewPage()
--]]
function Page:refreshViewPage()
  self.elements.listBox:clear()
  
  local selected = self.elements.proFilter:getSelected()
  if selected == ALL then
    script:triggerFunction("GetAllProblems", "Scripts/Database.lua")
    script:triggerFunction("refreshMap", "Scripts/map.lua", false)
  else
    script:triggerFunction("GetProblemsByCategory", "Scripts/Database.lua", selected)
    script:triggerFunction("refreshMap", "Scripts/map.lua", false, selected)
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
  script:triggerFunction("Display", "Scripts/map.lua")
  if button==pages[1].elements.myIssuesButton then
    pages[1].elements.listBox:clear()
local selected = pages[1].elements.proFilter:getSelected()
    if script:triggerFunction("getStatus", "Scripts/login.lua") then
      script:triggerFunction("ViewMyProblems", "Scripts/Database.lua", script:triggerFunction("getUserName", "Scripts/login.lua"))
  if selected == ALL then
        script:triggerFunction("refreshMap", "Scripts/map.lua", true)
  else
    script:triggerFunction("refreshMap", "Scripts/map.lua", true, selected)
  end
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

--CreateButton(page.elements.title:getText() .. "," .. category .. "," .. page.elements.description:getText() .. "," .. page.elements.latitude:getText() .. "," .. page.elements.longitude:getText(), 0, 0, 400, 400)
        script:triggerFunction("InsertProblem", "Scripts/Database.lua", page.elements.title:getText(), category, page.elements.description:getText(), page.elements.latitude:getText(), page.elements.longitude:getText())
        if pages[1].elements.listBox:getItemCount() == 1 and pages[1].elements.listBox:getItem(0) == "No Problems Found" then pages[1].elements.listBox:clear(); end
        pages[1].elements.listBox:addItem(page.elements.title:getText())
        page:destroy()
      end
    end

    if button == page.elements.cancelButton then
      page:destroy()
    end 

    if button == page.elements.refreshButton then
      pages[1].elements.listBox:clear()
      pages[1]:refreshViewPage()
    end

    if button == page.elements.updateButton then
        script:triggerFunction("UpdateProblem", "Scripts/Database.lua", page.elements.title:getText(), page.elements.description:getText())
        page:destroy()
    end
  end
  if button == pages[1].elements.openButton and pages[1].elements.listBox:getSelected() >= 0 then
    
script:triggerFunction("ViewProblem", "Scripts/Database.lua", pages[1].elements.listBox:getSelectedName(), operations:arraySize(pages)+1)
    newPage = Page.new()
    newPage:setViewProblemPage()
    table.insert(pages, newPage)
    script:triggerFunction("toggleVis", "Scripts/vote.lua", true)
    script:triggerFunction("snapToWindow", "Scripts/vote.lua")

--displayProblem(pages[1].elements.listBox:getSelectedName())
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

function displayProblem(pid)
  server:getSQL("database/database.db", "select Title from Problem where ID = " .. pid, "gettitlefromid")
end

function displayProblemFromTitle(title)
  script:triggerFunction("ViewProblem", "Scripts/Database.lua", title, operations:arraySize(pages)+1)
  newPage = Page.new()
  newPage:setViewProblemPage()
  table.insert(pages, newPage)
  script:triggerFunction("toggleVis", "Scripts/vote.lua", true)
  script:triggerFunction("snapToWindow", "Scripts/vote.lua")
end

function onLeftDoubleMouseDown(mouseId)
  if mouse:getElement(mouseId) == pages[1].elements.listBox and pages[1].elements.listBox:getSelected() >= 0 then
    onButtonPressed(pages[1].elements.openButton)
  end
end

function onLeftMouseDown(mouseID)
  lastPressed = mouse:getElement(mouseID)
  togglePress(lastPressed, true)
end

function onLeftMouseUp(mouseID)
  togglePress(lastPressed, false)
end

--~~~~~~~~~~~~~~~~~~~~Called by outide~~~~~~~~~~~~~~~~~~~~~~~~~
function displayMapButtons()
  --CreateButton("it was called at least",0,0,100,100)
  pages[1].elements.createButton:bringToFront()
  pages[1].elements.myIssuesButton:bringToFront()
  --CreateButton("YOOOOOO!!!",0,0,100,100)
end

function refreshPinsInSelectedCategory()
--Called by Pages' sqlReceived from Database's InsertProblem after problem is successfully submitted and uploaded to DB.
  local selected = pages[1].elements.proFilter:getSelected()
  if selected == ALL then
    --CreateButton("ALL!",0,0,100,100)
    --script:triggerFunction("GetAllProblems", "Scripts/Database.lua")
    script:triggerFunction("refreshMap", "Scripts/map.lua", false)
  else
    --CreateButton("NOT ALL!",0,0,100,100)
    --script:triggerFunction("GetProblemsByCategory", "Scripts/Database.lua", selected)
    script:triggerFunction("refreshMap", "Scripts/map.lua", false, selected)
  end
end

------------------Element Events----------------------------

function onElementFocusGained(elem)
  if elem == pages[1].elements.proFilter then
    pages[1]:refreshViewPage()
  end
end

function onScrollBarChanged(scrollBar, lastVal)
  for i,page in pairs(pages) do
    if scrollBar == page.elements.descriptionScrollBar then
      page.elements.description:setY(page.elements.description:getY() - (scrollBar:getValue() - lastVal))
    end
  end
end

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

function onSQLReceived(results, id)
  if id == "gettitlefromid" then
    displayProblemFromTitle(results["Title"][1])
  elseif id == "submitproblem" then
    refreshPinsInSelectedCategory()
  end

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
    pages[modalNo].elements.latlong:setText("Located at " .. results["Latitude"][1] .. ", " .. results["Longitude"][1])

    local acctStatus = script:triggerFunction("getStatus", "Scripts/login.lua")
    if acctStatus == true then
      local account = script:triggerFunction("getUserName", "Scripts/login.lua")
      if account ~= nil then
        if account == results["Account"][1] then
          pages[modalNo]:setViewProblemEditable()
        end
      end
    end
    pages[modalNo]:setViewProblemDescription(results["Description"][1])
  end
end

function getPages()
  return pages
end

function getTopModal()
  return pages[operations:arraySize(pages)]
end