--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~Pin~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function NewPin(id, tit, lat, long)
  local self = {}

  self.id = id
  self.tit = tit
  self.lat = lat
  self.long = long
  
  self.pin = CreateButton("",0,0,32,32)
  self.pin:setScaled(false)
  self.pin:setImage("UI/pin.png")
  
  self.title = CreateText("", 0,0,50,20)
  self.title:setScaled(false)
  self.title:setWordWrap(false)
  
  function self:updateLocation(screeny, screenx)
    self.pin:setX(screenx - self.pin:getWidth() / 2)
    self.pin:setY(screeny - self.pin:getHeight())
    self.title:setX(screenx - self.title:getTextWidth() / 2)
    self.title:setY(screeny)
  end
  
  function self:setVisible(visible)
    self.pin:setVisible(visible)
    self.title:setVisible(visible)
  end
  
  function self:setPreviewTitle(title)
    local shortTitle = title
    if string.len(title) > 15 then
      shortTitle = string.sub(title,1,12) .. "..."
    end
    self.title:setText(shortTitle)
self.title:setWidth(self.title:getTextWidth())
  end
  
  function self:remove()
    self.pin:remove()
    self.title:remove()
  end
  
  self:setPreviewTitle(self.tit)

  return self
end

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~Map~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

function NewMap()
  local self = {}

  --default map size
  --default max crop coords
  --lat/long boundaries
  self.x, self.y, self.w, self.h = 185, 65, 270, 250
  self.maxCropX, self.maxCropY = 0, 0
  self.westLong, self.eastLong, self.southLat, self.northLat = -96.0625, -95.75, 41.1875, 41.344
  
  --mouse click/release coords
  --click/release crop values
  --crop coords
  self.xi, self.yi, self.xf, self.yf = 0, 0, 0 ,0
  self.cxi, self.cyi = 0, 0

  --pins
  self.pins = {}
  self.pinDropped = false
  self.droppedPin = CreateImage("UI/tack.png", 0, 0, 90, 45)
  self.droppedPin:setScaled(false)
  self.dpLat, self.dpLong = -95.9, 41.25
  
  --zoom
  self.zoom = 1
  self.zoomBtn = CreateButton("Zoom",400,75,50,50)

  --parent
  self.parent = CreateListBox(self.x, self.y, self.w, self.h)
  
  --map image
  self.map = CreateImage("Map/omaha_zoom1.png", self.x, self.y, self.w, self.h)
  self.map:crop(170, 700, self.parent:getWidth(true), self.parent:getHeight(true))
  self.map:setScaleImage(false)
  self.map:setClipped(true)
  self.map:setMovable(false)
  self.map:addElement(self.droppedPin)
  
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~Map front-end functions~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  function self:PopulateFromDB(myProblems, category)
  
    for i,v in pairs(self.pins) do
      self.pins[i]:remove()
      self.pins[i]=nil
    end

    local cmd = "select ID, Title, Latitude, Longitude from Problem"
    local usr = script:triggerFunction("getUserName", "Scripts/login.lua")
    local arg1 = myProblems == true
    local arg2 = category ~= nil
  
    if arg1 or arg2 then
      cmd = cmd .. " where "
  
      if arg1 then
        cmd = cmd .. "Account = '" .. usr .. "'"
      end
  
      if arg1 and arg2 then
        cmd = cmd .. " and "
      end
  
      if arg2 then
        cmd = cmd .. "Category = " .. category
      end
    end

    --server:getSQL("database/database.db", "select ID, Title, Latitude, Longitude from Problem where Category = " .. category, "getallpins")
    server:getSQL("database/database.db", cmd, "getallpins")

  end
  
  function self:AddPin(id, tit, lat, long)
  --Sticks a pin on the map and adds it to the pins table.
    local newPin = NewPin(id,tit,lat,long)
    self.map:addElement(newPin.pin)
self.map:addElement(newPin.title)
    local screeny, screenx = self:gpsToScreen(lat, long)
    newPin:updateLocation(screenx, screeny)
    table.insert(self.pins, id, newPin)
  end
  
  function self:UpdatePinLocations()
  --Moves all the pins to match up with the newly dragged-to location.

    for pid, prob in pairs(self.pins) do
      local p = self.pins[pid]
      local screeny, screenx = self:gpsToScreen(p.lat, p.long)
      --Exact location the pin is stuck to
      local ppx = p.pin:getX() + p.pin:getWidth() / 2
      local ppy = p.pin:getY() + p.pin:getHeight()
      p:updateLocation(screenx, screeny)
      --[[p:setVisible(ppx > self.x and
        ppx < (self.x + self.w) and
        ppy > self.y and
        ppy < (self.y + self.h)
      )--]]
      --p.pin:bringToFront()

    end
    --Update dropped pin
    local dpy, dpx = self:gpsToScreen(self.dpLat, self.dpLong)
    --self.droppedPin:bringToFront()
    self.droppedPin:setX(dpy)
    self.droppedPin:setY(dpx)
  end

  function self:Pan(screenx, screeny)
  --Moves the map within its bounds to the mouse.
    local difx = screenx - self.xi
    local dify = screeny - self.yi
    local panx = self.cxi - difx
    local pany = self.cyi - dify

    --bound x
    panx, pany = self:getInBounds(panx, pany)

    self:crop(panx, pany)
  end
  
  function self:Zoom(z)
  --Swaps map images.
    self.zoom = z

    --center of map
    local xCenter = self.x + self.w/2
    local yCenter = self.y + self.h/2
    --before center's gps
    local lati, longi = self:screenToGps(xCenter, yCenter)
    self.map:setImage("Map/omaha_zoom" .. self.zoom .. ".png")
    self.map:setScaleImage(false)
    self:updateMaxCrop()
    --now get it as screenspace after zoom
    local xi, yi = self:gpsToScreen(lati, longi)
    --center of map
    local xDif = xi - xCenter
    local yDif = yi - yCenter

    local cropxi, cropyi = self.map:getCrop()
    local cropxf, cropyf = self:getInBounds(cropxi + xDif, cropyi + yDif)
    self:crop(cropxf, cropyf)

    self:UpdatePinLocations()
  end
  
  function self:Display()
  --Brings map and pins to front. Also calls function in Pages to bring the buttons on top of the map to the top.
    self.map:bringToFront()
    self.droppedPin:bringToFront()
    self.zoomBtn:bringToFront()
    script:triggerFunction("displayMapButtons", "Scripts/Pages.lua")
    self:UpdatePinLocations()
  end
  
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~Map back-end functions~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  function self:getInBounds(screenx, screeny)
    local inx, iny = screenx, screeny
    if inx < 0 then
      inx = 0
    elseif inx > self.maxCropX then
      inx = self.maxCropX
    end

    --bound y
    if iny < 0 then
      iny = 0
    elseif iny > self.maxCropY then
      iny = self.maxCropY
    end
    return inx, iny
  end

  function self:hovering(mID)
    return mouse:getElement(mID) == self.map
  end

  function self:getSpan()
  --Returns the span of latitude and longitude
    local longDif = self.westLong - self.eastLong
    local latDif = self.northLat - self.southLat
    return longDif, latDif
  end

  function self:screenToGps(screenx, screeny)
    local cropx, cropy = self.map:getCrop()
local winScaleX, winScaleY = game:getWindowScale()
    local imgRatioX = (screenx + cropx - self.map:getX() * winScaleX) / self.map:getImageWidth()
    local imgRatioY = (screeny + cropy - self.map:getY() * winScaleY) / self.map:getImageHeight()
    local longDif, latDif = self:getSpan()
    local long = self.westLong - longDif * imgRatioX
    local lat = self.northLat - latDif * imgRatioY
    return lat, long
  end
  
  function self:gpsToScreen(lat, long)
  --Returns the screen position for the given lat/long.
    local cropx, cropy = self.map:getCrop()
    local longDif, latDif = self:getSpan()
    local longOff = self.westLong - long
    local latOff = self.northLat - lat
    local screenx =  - cropx + self.map:getImageWidth() * (longOff / longDif)
    local screeny =  - cropy + self.map:getImageHeight() * (latOff / latDif)
    return screenx, screeny
  end

  function self:getPressedPin(mausu)
  --Called when left mouse if released, returns the pin that was pressed.
    local elem = mouse:getElement(mausu)

    for pid, prob in pairs(self.pins) do
       if self.pins[pid].pin == elem then
         return self.pins[pid]
      end
    end
  end

  function self:crop(x, y)
    self.map:crop(x, y, self.parent:getWidth(true), self.parent:getHeight(true))
  end

  function self:updateMaxCrop()
  --Updates the boundaries that the map can be panned to. Should be called when zooming / switching map images.
    self.maxCropX = self.map:getImageWidth() - self.w
    self.maxCropY = self.map:getImageHeight() - self.h
  end
  
  function self:setPressXY(mID)
  --Sets initial mouse and crop coordinates when mouse is pressed.
    self.xi = mouse:getX(mID)
    self.yi = mouse:getY(mID)
    self.cxi, self.cyi = map.map:getCrop()
  end

  function self:setReleaseXY(mID)
  --Sets final mouse coordinates when mouse is released.
    self.xf = mouse:getX(mID)
    self.yf = mouse:getY(mID)
  end
  
  return self
end

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~On created~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function onCreated()
  map = NewMap()
  mDown = false
  mDrag = false
  map:PopulateFromDB()
  map:Display()
  --map:AddPin(2,41.2,-96)
  --map:AddPin(106,200,200)
  --map:AddPin(4,41.259635,-96.023949)
end

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~Static functions~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function refreshMap(myProblems, category)
  map:PopulateFromDB(myProblems, category)
end

function droppedPinLat()
  return map.dpLat
end

function droppedPinLong()
  return map.dpLong
end

function display()
  map:Display()
end

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~Mouse functions~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function onLeftMouseDown(md)
  --if mouse:getElement(md) == map.map then
  if map:hovering(md) then
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
      script:triggerFunction("displayProblem", "Scripts/Pages.lua", elem.id)
    elseif mouse:getElement(mu) == map.map or mouse:getElement(mu) == map.droppedPin then
      map.dpLat, map.dpLong = map:screenToGps(mouse:getX(mu), mouse:getY(mu))
      --Update dropped pin
      local dpy, dpx = map:gpsToScreen(map.dpLat, map.dpLong)
      --map.droppedPin:bringToFront()
      map.droppedPin:setX(dpy)
      map.droppedPin:setY(dpx)
    end
  end
  mDrag = false
end

function onMouseMoved(mm)
  if mDown then
    mDrag = true
    map:Pan(mouse:getX(mm), mouse:getY(mm))
    map:UpdatePinLocations()
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

function onWindowResize()
  map:crop(map.map:getX(), map.map:getY())
  map:UpdatePinLocations()
end

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~Server functions~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function onSQLReceived(results, id)
  if id == "getallpins" then
    local pid = 0
    local tit = ""
    local lat = 0
    local long = 0
    for i,val in pairs(results["ID"]) do
      pid = tonumber(results["ID"][i])
      tit = results["Title"][i]
      lat = tonumber(results["Latitude"][i])
      long = tonumber(results["Longitude"][i])
      map:AddPin(pid, tit, lat, long)
    end
  end
end