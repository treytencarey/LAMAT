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

function Page:setAddProblemPage(y)
  self:destroy()

  self.elements = {
    menu = CreateWindow("Create Problem",0,0,300,245),
    overlay = CreateImage("GLOBAL/pixel.png",0,0,0,0),
    title = CreateEditBox(5,20,290,30),
    description = CreateEditBox(5,55,290,70),
    cityState = CreateEditBox(5,130,290,30),
    createButton = CreateButton("Create Problem",5,165,290,30),
    cancelButton = CreateButton("Cancel",5,200,290,30)
  }

  self.elements.menu:setMovable(); self.elements.menu:setMovableBoundaries(0-280, 0, 640+280, 480+225)
  self.elements.title:setText("Title")
  self.elements.description:setText("Description"); self.elements.description:setMultiLine(true)
  self.elements.cityState:setText("City, State")

  self:formatElements()
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
  for i,page in pairs(pages) do
    if button == page.elements.createButton then
      if i == 1 then
        newPage = Page.new()
        table.insert(pages, newPage)
        newPage:setAddProblemPage()
      else
        script:triggerFunction("InsertProblem", "Scripts/Database.lua", page.elements.title:getText(), page.elements.description:getText(), page.elements.cityState:getText())
        if pages[1].elements.listBox:getItemCount() == 1 and pages[1].elements.listBox:getItem(0) == "No Problems Found" then pages[1].elements.listBox:clear(); end
        pages[1].elements.listBox:addItem(page.elements.title:getText())
        page:destroy()
      end
    end
    if button == page.elements.cancelButton then
      page:destroy()
    end
    if button == page.elements.refreshButton then
      pages[1]:refreshViewPage()
    end
  end
  if button == pages[1].elements.openButton and pages[1].elements.listBox:getSelected() >= 0 then
    script:triggerFunction("ViewProblem", "Scripts/Database.lua", pages[1].elements.listBox:getSelectedName(), operations:arraySize(pages)+1)
    newPage = Page.new()
    newPage:setAddProblemPage()
    table.insert(pages, newPage)
  end
end

function onSQLReceived(results, id)
  if id == "allProblems" and pages[1].elements.listBox:getItemCount() == 0 then
    if operations:arraySize(results) == 0 then
      pages[1].elements.listBox:addItem("No Problems Found")
    else
      for i,val in pairs(results["Title"]) do
        pages[1].elements.listBox:addItem(val)
      end
    end
  end
  if id:find("viewProblem") == 1 then
    modalNo = id:sub(12, id:len())+0
    pages[modalNo].elements.title:setText(results["Title"][1])
    pages[modalNo].elements.description:setText(results["Description"][1])
    pages[modalNo].elements.cityState:setText(results["Location"][1])
  end
end

function onLeftDoubleMouseDown(mouseId)
  if mouse:getElement(mouseId) == pages[1].elements.listBox and pages[1].elements.listBox:getSelected() >= 0 then
    onButtonPressed(pages[1].elements.openButton)
  end
end