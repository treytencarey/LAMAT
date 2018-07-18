--[[
function New(x, y, w, h)
  local self = {}

  self.percent = .5
  self.x = x
  self.y = y
  self.w = w
  self.h = h
  self.negBar = CreateImage("GLOBAL/pixel.png", x, y, w, h)
  self.negBar:setColor(224, 68, 37, 255)
  self.posBar = CreateImage("GLOBAL/pixel.png", x, y, w, h)
  self.posBar:setColor(131, 218, 45, 255)
  
  function self:UpdateRatio(r)
    self.posBar:setWidth(self.w * r)
    self.percent = r
    self.posBar:setColor(0, 0, 0, 255)
self.posBar:setColor(0, 0, 0, 255)
  end

  return self

end

--====================Workaround functions=======================

function onCreated()
  ratiobars = {}
end

function NewRatioBar(name, x, y, w, h)
  ratiobars[name] = New(x,y,w,h)
end

function UpdateRatioBar(name, r)
  ratiobars[name]:UpdateRatio(r)
end
--]]


--[[
  myAccount = self:getAccount()
  db = Database.new("database/database.db")
  db:CreateProblemsTable()
  db:GetAllProblems()
--]]