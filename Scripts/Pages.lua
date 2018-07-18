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
      if i ~= "menu" and i ~= "overlay" and (element:getParent() == nil or element:getParent() == element) then
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
    menu = CreateWindow("View", 0, 0, 220, 700),
    dropList = CreateDropList(10, 30, 200, 30),
    listBox = CreateListBox(10, 60, 200, 300),
    openButton = CreateButton("View Issue", 10, 365, 200, 30),
    createButton = CreateButton("Create Issue", 10, 400, 200, 30),
    myIssuesButton = CreateButton("View My Issues", 10, 435, 200, 30),
    refreshButton = CreateButton("Refresh", 10, 470, 200, 30)
  }

  self.elements.dropList:addItem("Sort By: Nearest")

  self:formatElements()
  self:refreshViewPage()
end

function makeButton(imgName, x, y, w, h)
  newButton = CreateButton("", x, y, w, h)
  newButton:setImage("UI/" .. imgName .. ".png")
  newButton:setScaleImage(true) 
  return newButton
end

function Page:setAddProblemPage(y)
  self:destroy()

  self.elements = {
    menu = CreateWindow("Create Problem",0,0,300,305),
    overlay = CreateImage("GLOBAL/pixel.png",0,0,0,0),
    title = CreateEditBox(5,45,290,30),
    description = CreateEditBox(5,80,290,70),
    Latitude = CreateEditBox(5,155,290,30),
    Longitude = CreateEditBox(5,190,290,30),
    createButton = CreateButton("Create Problem",5,240,290,55),
    cancelButton = makeButton("x", 250,0,50,50),
    validBox = CreateText("",10,10)
  }
  self.elements.createButton:setImage("UI/subbut.jpg")
  self.elements.createButton:setScaleImage(true)

  self.elements.menu:setMovable(); self.elements.menu:setMovableBoundaries(0-280, 0, 640+280, 480+225)
  self.elements.title:setText("Title")
  self.elements.description:setText("Description"); self.elements.description:setMultiLine(true)
  self.elements.Latitude:setText("Latitude")
  self.elements.Longitude:setText("Longitude")
--  self.elements.validBox:setText("0/0 said problem valid.")

  self:formatElements()
  self.elements.cancelButton:bringToFront()
end


function Page:setViewProblemPage(y)
  self:destroy()

  self.elements = {
    menu = CreateWindow("View Problem",0,0,300,500),
    overlay = CreateImage("GLOBAL/pixel.png",0,0,0,0),
    title = CreateEditBox(5,50,290,30),
    description = CreateEditBox(5,85,290,70),
    Latitude = CreateEditBox(5,160,290,30),
    Longitude = CreateEditBox(5,195,290,30),
    cancelButton = makeButton("x", 250,0,50,50),
  }

  --self.elements.menu:setMovable();
  self.elements.menu:setMovableBoundaries(0-280, 0, 640+280, 480+225)
  self.elements.title:setText("Title")
  self.elements.description:setText("Description"); self.elements.description:setMultiLine(true)
  self.elements.Latitude:setText("Latitude")
  self.elements.Longitude:setText("Longitude")
  --script:triggerFunction("toggleVis", "Scripts/vote.lua", true)

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

function onCreated()
  pages = {}
  pages[1] = Page.new()
  pages[1]:setViewPage()
end

function onButtonPressed(button)
  if button==pages[1].elements.myIssuesButton then
    pages[1].elements.listBox:clear()

    if script:triggerFunction("getStatus", "Scripts/login.lua") then
      script:triggerFunction("ViewMyProblems", "Scripts/Database.lua", script:triggerFunction("getUserName", "Scripts/login.lua"))
    end
  end
  for i,page in pairs(pages) do
    if button == page.elements.createButton then
      if i == 1 then
        newPage = Page.new()
        table.insert(pages, newPage)
        newPage:setAddProblemPage()
      else
        script:triggerFunction("InsertProblem", "Scripts/Database.lua", page.elements.title:getText(), page.elements.description:getText(), page.elements.cityState:getText(), 0)
        if pages[1].elements.listBox:getItemCount() == 1 and pages[1].elements.listBox:getItem(0) == "No Problems Found" then pages[1].elements.listBox:clear(); end
        pages[1].elements.listBox:addItem(page.elements.title:getText())
        page:destroy()
      end
    end
    if button == page.elements.cancelButton then
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
--script:triggerFunction("getVotesAndDisplay", "Scripts/vote.lua", "0")
  end
end

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
    --pages[modalNo].elements.cityState:setText(results["Location"][1])
    --pages[modalNo].elements.validBox:setText(results["Valid"][1])
    --script:triggerFunction("updateDisplay", "Scripts/vote.lua", "0")
--results["ID"][1]

  end
end

function onLeftDoubleMouseDown(mouseId)
  if mouse:getElement(mouseId) == pages[1].elements.listBox and pages[1].elements.listBox:getSelected() >= 0 then
    onButtonPressed(pages[1].elements.openButton)
  end
end

function getPages()
  return pages
end

function getTopModal()
  return pages[operations:arraySize(pages)]
end