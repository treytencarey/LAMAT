--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~Pin~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function NewPin(id, lat, long)
  local self = {}

  self.id = id
  self.lat = lat
  self.long = long
  
  self.pin = CreateImage("UI/pin.png",0,0,30,30)
  
  function self:updateLocation(screeny, screenx)
    self.pin:setX(screenx - self.pin:getWidth() / 2)
self.pin:setY(screeny - self.pin:getHeight())
  end

  return self
end

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~Map~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

function NewMap()
  local self = {}

  --default map size
  --default max crop coords
  --lat/long boundaries
  self.x, self.y, self.w, self.h = 185, 100, 270, 250
  self.maxCropX, self.maxCropY = 0, 0
  self.westLong, self.eastLong, self.southLat, self.northLat = -96.0625, -95.75, 41.1875, 41.344
  
  --mouse click/release coords
  --click/release crop values
  --crop coords
  self.xi, self.yi, self.xf, self.yf = 0, 0, 0 ,0
  self.cxi, self.cyi = 0, 0

  --pins
  self.pins = {}
  
  --zoom
  self.zoom = 1
  self.zoomBtn = CreateButton("Zoom",100,100,50,50)
  
  --map image
  self.map = CreateImage("Map/omaha_zoom1.png", self.x, self.y, self.w, self.h)
  self.map:crop(170, 700, self.w, self.h)
  self.map:setScaleImage(false)
  self.map:setClipped(true)
  self.map:setMovable(false)
  
  function self:PopulateFromDB(category)
  
    for i,v in pairs(self.pins) do
  self.pins[i].pin:remove()
  self.pins[i]=nil
end
  
    if category == nil then
  server:getSQL("database/database.db", "select ID, Latitude, Longitude from Problem", "getallpins")
else
      server:getSQL("database/database.db", "select ID, Latitude, Longitude from Problem where Category = " .. category, "getallpins")
end
  end
  
  function self:getPressedPin(mausu)
    local elem = mouse:getElement(mausu)

for pid, prob in pairs(self.pins) do
  if self.pins[pid].pin == elem then
    return self.pins[pid]
  end
end

  end

  function self:updateMaxCrop()
    self.maxCropX = self.map:getImageWidth() - self.w
    self.maxCropY = self.map:getImageHeight() - self.h
  end
  
  function self:gpsToScreen(lat, long)
    local cropx, cropy, trash1, trash2 = self.map:getCrop()
    local longDif = self.westLong - self.eastLong
local longOff = self.westLong - long
local latDif = self.northLat - self.southLat
local latOff = self.northLat - lat
local screenx = self.x - cropx + self.map:getImageWidth() * (longOff / longDif)
local screeny = self.y - cropy + self.map:getImageHeight() * (latOff / latDif)
    return screenx, screeny
  end
  
  function self:AddPin(id, lat, long)
    local newPin = NewPin(id,lat,long)
local screeny, screenx = self:gpsToScreen(lat, long)
newPin:updateLocation(screenx, screeny)
    table.insert(self.pins, id, newPin)
  end
  
  function self:UpdatePinLocations()
    cursorBox:clear()
    for pid, prob in pairs(self.pins) do
  local p = self.pins[pid]
  local screeny, screenx = self:gpsToScreen(p.lat, p.long)
  p:updateLocation(screenx, screeny)
  p.pin:bringToFront()
  cursorBox:addItem(pid .. ": " .. screenx .. ", " .. screeny)
    end
  end

  function self:Pan(pos)
local difx = mouse:getX(pos) - self.xi
local dify = mouse:getY(pos) - self.yi
local panx = self.cxi - difx
local pany = self.cyi - dify

--bound x
if panx < 0 then
  panx = 0
elseif panx > self.maxCropX then
  panx = self.maxCropX
end

--bound y
if pany < 0 then
  pany = 0
elseif pany > self.maxCropY then
  pany = self.maxCropY
end

self.map:crop(panx, pany, self.w, self.h)
  end
  
  function self:Zoom(z)
    self.zoom = z
    self.map:setImage("Map/omaha_zoom" .. self.zoom .. ".png")
self.map:setScaleImage(false)
  end
  
  
  function self:setPressXY(mID)
    self.xi = mouse:getX(mID)
self.yi = mouse:getY(mID)
self.cxi, self.cyi = map.map:getCrop()
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

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~On created~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function onCreated()
  map = NewMap()
  mDown = false
  mDrag = false
  cropBox = CreateListBox(0,300,75,300)
  mapBox = CreateListBox(75,300,75,300)
  cursorBox = CreateListBox(500,300,300,300)
  map:PopulateFromDB()
  --map:AddPin(2,41.2,-96)
  --map:AddPin(106,200,200)
  --map:AddPin(4,41.259635,-96.023949)
end

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~Static functions~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function refreshMap(category)
  map:PopulateFromDB(category)
end

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~Mouse functions~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function onLeftMouseDown(md)
  if mouse:getElement(md) == map.map then
    mDown = true
    map:setPressXY(md)
    map:updateMaxCrop()
  end
end

function onLeftMouseUp(mu)
  mDown = false
  map:setReleaseXY(mu)
  if mDrag ~= true then
local elem = map:getPressedPin(mu)
if elem ~= nil then
  cursorBox:addItem(elem.id)
  script:triggerFunction("displayProblem", "Scripts/Pages.lua", elem.id)
end
  end
  mDrag = false
end

function onMouseMoved(mm)
  if mDown then
    mDrag = true
    map:Pan(mm)
map:UpdatePinLocations()
    updateBoxes(mm)
  end
  
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


--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~Misc functions~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function setParent(parent)
  map:setParent(parent)
end

function updateBoxes(mID)
  cropBox:clear()
  mapBox:clear()

  cropBox:addItem("Crop")
  x,y,w,h = map.map:getCrop()
  cropBox:addItem("x: " .. x)
  cropBox:addItem("y: " .. y)
  cropBox:addItem("w: " .. w)
  cropBox:addItem("h: " .. h)
  cropBox:addItem("X: " .. map.maxCropX)
  cropBox:addItem("Y: " .. map.maxCropY)

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

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~Server functions~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function onSQLReceived(results, id)
  cursorBox:addItem(id)
  if id == "getallpins" then
    local pid = 0
    local lat = 0
    local long = 0
    for i,val in pairs(results["ID"]) do
  pid = tonumber(results["ID"][i])
  lat = tonumber(results["Latitude"][i])
  long = tonumber(results["Longitude"][i])
      map:AddPin(pid, lat, long)
    end
  end
end