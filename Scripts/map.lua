function NewPin(id, lat, long)
  local self = {}

  self.id = id
  self.lat = lat
  self.long = long
  
  self.pin = CreateImage("UI/pin.png", 0,0,30,30)

  return self
end

function NewMap()
  local self = {}

  --default map size
  self.x = 185
  self.y = 100
  self.w = 270
  self.h = 250
  
  --mouse values
  self.xi = 0
  self.yi = 0
  self.xf = 0
  self.yf = 0
  
  --crop values
  self.cxi = 0
  self.cyi = 0
  self.cwi = 0
  self.chi = 0

  self.zoom = 1
  
  self.zoomBtn = CreateButton("Zoom",100,100,50,50)
  
  self.map = CreateImage("Map/omaha_zoom1.png", self.x, self.y, self.w, self.h)
  self.map:crop(640, 320, self.w, self.h)
  self.map:setScaleImage(false)
  
  self.map:setClipped(true)
  self.map:setMovable(false)

  function self:Pan(pos)
self.difx = mouse:getX(pos) - self.xi
self.dify = mouse:getY(pos) - self.yi
self.map:crop(self.cxi - self.difx, self.cyi - self.dify, self.w, self.h)
  end
  
  function self:Zoom(z)
    self.zoom = z
    self.map:setImage("Map/omaha_zoom" .. self.zoom .. ".png")
self.map:setScaleImage(false)
  end
  
  
  function self:hovering(mID)
    return mouse:inRect(self.x, self.y, self.w, self.h, true, mID)
--return false
  end
  
  function self:setPressXY(mID)
    self.xi = mouse:getX(mID)
self.yi = mouse:getY(mID)
self.cxi, self.cyi, self.cxf, self.cyf = map.map:getCrop()
  end

  function self:setReleaseXY(mID)
    self.xf = mouse:getX(mID)
self.yf = mouse:getY(mID)
  end
  
  function self:setParent(parent)
    parent:addElement(self.map)
self.map:bringToFront()
  end
  
  return self
  
end

function onCreated()
  map = NewMap()
  mDown = false
  mDrag = false
  --cropBox = CreateListBox(0,300,75,300)
  --mapBox = CreateListBox(75,300,75,300)
  --cursorBox = CreateListBox(500,300,75,300)
  pin1 = NewPin(1, 6, 9)
end

function onLeftMouseDown(md)
  --if mouse:getElement(md) == map.map then
  if map:hovering(md) then
    mDown = true
    map:setPressXY(md)
  end
end

function onLeftMouseUp(mu)
  mDown = false
  map:setReleaseXY(mu)
end

function onMouseMoved(mm)
  if mDown then
    mDrag = true
    map:Pan(mm)
  end
  --updateBoxes(mm)
  
end

function onButtonPressed(button)
  if button == map.zoomBtn then
    if map.zoom == 0 then
  map:Zoom(1)
else
  map:Zoom(0)
end
  end
end

function setParent(parent)
  map:setParent(parent)
end

function updateBoxes(mID)
  cropBox:clear()
  mapBox:clear()
  --cursorBox:clear()
  
  --cursorBox:addItem("Cursor")
  --cursorBox:addItem("x: " .. mouse:getX(mID))
  --cursorBox:addItem("y: " .. mouse:getY(mID))

  cropBox:addItem("Crop")
  x,y,w,h = map.map:getCrop()
  cropBox:addItem("x: " .. x)
  cropBox:addItem("y: " .. y)
  cropBox:addItem("w: " .. w)
  cropBox:addItem("h: " .. h)

  mapBox:addItem("Map")
  a = map.map:getX()
  b = map.map:getY()
  c = map.map:getWidth()
  d = map.map:getHeight()
  mapBox:addItem("x: " .. a)
  mapBox:addItem("y: " .. b)
  mapBox:addItem("w: " .. c)
  mapBox:addItem("h: " .. d)

  mapBox:bringToFront()
  cropBox:bringToFront()
end