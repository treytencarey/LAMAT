function NewRatioBar(x, y, w, h)
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
  end
  
  function self:ToggleVis(nv)
    self.negBar:setVisible(nv)
    self.posBar:setVisible(nv)
  end

  function self:setParent(parent)
    parent:addElement(self.negBar)
    parent:addElement(self.posBar)
  end

  function self:removeParent(parent)
    parent:removeElement(self.negBar)
    parent:removeElement(self.posBar)
  end

 return self

end

function NewButton(restImg, x, y, w, h)
  local self = {}

  self.restImg = "UI/" .. restImg .. ".png"
  self.pressedImg = "UI/" .. restImg .. "_pressed.png"
  self.pressed = false

  self.btn = CreateButton("", x, y, w, h)
  self.btn:setImage(self.restImg)
  self.btn:setScaleImage(true) 

  function self:Toggle()
    self.pressed = not self.pressed
    if self.pressed then
      self.btn:setImage(self.pressedImg)
    else
      self.btn:setImage(self.restImg)
    end
  end

  function self:Reset()
    if self.pressed then
      self:Toggle()
    end
  end
  
  function self:ToggleVis(newVis)
    self.btn:setVisible(newVis)
  end

  return self

end

function onCreated()
  ratioBar = NewRatioBar(55, 255, 190, 25)
  upBtn = NewButton("thumbs_up", ratioBar.x,ratioBar.y+50,100,100)
  downBtn = NewButton("thumbs_down", ratioBar.x+100,upBtn.btn:getY(),100,100)
  scoreBox = CreateEditBox( ratioBar.x, ratioBar.y+ratioBar.h, 190, 25)
  loggedin = false
  
  --probEdit = CreateEditBox(450, 25, 100, 25)
  --displayBtn = CreateButton("Load problem",450, 50, 190, 25)
  testBox = CreateListBox(ratioBar.x, ratioBar.y-25, 190, 50)
  --voteBar = script:triggerFunction("NewRatioBar", "Scripts/RatioBar.lua", "voteBar", 450, 300, 200, 25)
  

  probID = "0"
  --getStatus
  --getUserName
  updateProbAndAcc("0")

  upVotes = "0"
  allVotes = "0"

  --probEdit:setText("ProblemID")
  scoreBox:setText("Score output: ")
  
  toggleVis(false)
  
end

function snapToWindow()
  upBtn.btn:bringToFront()
  downBtn.btn:bringToFront()
  ratioBar.negBar:bringToFront()
  ratioBar.posBar:bringToFront()
  scoreBox:bringToFront()
  testBox:bringToFront()
  
  --[[
  upBtn.btn:center()
  downBtn.btn:center()
  ratioBar.negBar:bringToFront()
  ratioBar.posBar:bringToFront()
  scoreBox:center()
  testBox:center()
  --]]
end

function toggleVis(show)
  if ratioBar.posBar:getParent() == ratioBar.posBar then show = false; end
  if loggedin then
    upBtn:ToggleVis(show)
    downBtn:ToggleVis(show)
  else
    upBtn:ToggleVis(false)
    downBtn:ToggleVis(false)
  end
  ratioBar:ToggleVis(show)
  scoreBox:setVisible(show)
  testBox:setVisible(show)
  
  if show then
    if loggedin then
      upBtn:Reset()
  downBtn:Reset()
end
ratioBar:UpdateRatio(1)
scoreBox:setText("Loading...")
  end
  
end

function updateScoreBox()
  rat = 0
  scoreBox:setText("Score output: " .. upVotes .. "/" .. allVotes)
  if allVotes ~= "0" then
    rat = tonumber(upVotes)/tonumber(allVotes)
  end
  return rat
end

function updateProbAndAcc(pID)
  if script:triggerFunction("getStatus", "Scripts/login.lua") then
 loggedin = true
    acc = script:triggerFunction("getUserName", "Scripts/login.lua")
    testBox:addItem("Logged in as " .. acc)
  else
    loggedin = false
    acc = ""
    testBox:addItem("Not logged in!")
    testBox:addItem("Please login to vote")
  end
    
    --probID = probEdit:getText()
probID = pID
  
end

function setParent(parent)
  ratioBar:setParent(parent)
  parent:addElement(upBtn.btn)
  parent:addElement(downBtn.btn)
  parent:addElement(scoreBox)
  parent:addElement(testBox)
end

function removeParent(parent)
  ratioBar:removeParent(parent)
  parent:removeElement(upBtn.btn)
  parent:removeElement(downBtn.btn)
  parent:removeElement(scoreBox)
  parent:removeElement(testBox)
end

function getVotesAndDisplay(pID)
  testBox:clear()
  updateProbAndAcc(pID)
  server:getSQL("database/database.db", "select Account, Title from Problem where ID = " .. probID, "displayproblem")
  --server:getSQL("database/database.db", "select Upvote from Vote where ProblemID = " .. probID, "displayvotes")
  server:getSQL("database/database.db", "select count(Upvote) from Vote where Upvote = 1 and ProblemID = " .. probID, "updateupvotes")
  server:getSQL("database/database.db", "select count(Upvote) from Vote where Upvote <> 0 and ProblemID = " .. probID, "updatetotalvotesandratio")
  server:getSQL("database/database.db", "select Upvote from Vote where ProblemID = " .. probID .. " and Account = '" .. acc .. "'", "updatevotebutton")
end

function onButtonPressed(button)
  p = ""
  if button == upBtn.btn then
    upBtn:Toggle()
    if downBtn.pressed then
      downBtn:Toggle()
    end
    if upBtn.pressed then
      p = "pressed"
    else
      p = "rest"
    end
    updateProbAndAcc(probID)
    server:getSQL("database/database.db", "select count(Upvote) from Vote where Account = '" .. acc .. "' and ProblemID = " .. probID, "addvotepos" .. p)

  elseif button == downBtn.btn then
    downBtn:Toggle()
    if upBtn.pressed then
      upBtn:Toggle()
    end
    if downBtn.pressed then
      p = "pressed"
    else
      p = "rest"
    end
    updateProbAndAcc(probID)
    server:getSQL("database/database.db", "select count(Upvote) from Vote where Account = '" .. acc .. "' and ProblemID = " .. probID, "addvoteneg" .. p)

  --elseif button == displayBtn then
    --getVotesAndDisplay()
  end
end

function returnSingle(results)
    for column,vals in pairs(results) do
      for i,val in pairs(vals) do
        return  val
      end
    end
end

function onSQLReceived(results, id)
--[[
  if id == "displayproblem" or id == "displayvotes" then
    testBox:addItem(id)
    for k,v in pairs(results) do
      for i,m in pairs(results[k]) do
        testBox:addItem("  " .. tostring(m))
      end
    end 
--]]
   
  if id == "updateupvotes" then
    upVotes = returnSingle(results)

  elseif id == "updatetotalvotesandratio" then
    allVotes = returnSingle(results)
    newRatio = updateScoreBox()
    ratioBar:UpdateRatio(newRatio)
    --script:triggerFunction("UpdateRatioBar", "Scripts/RatioBar.lua", "voteBar", 450, 300, 200, 25)

  elseif id == "updatevotebutton" then 
    upBtn:Reset()
    downBtn:Reset()

    vote = returnSingle(results)
    if vote == "1" then
      upBtn:Toggle()
    elseif vote == "-1" then
      downBtn:Toggle()
    end

  elseif string.find(id, "addvote") ~= nil then
    --"addvote" + ("pos"/"neg" for either thumbs up or down button) + ("pressed"/"rest" depending is corresponding button was pressed or released)
    votemsg = string.sub(id, 8)
    btn = string.sub(votemsg, 1, 3)
    state = string.sub(votemsg, 4)
    vote = 0
    if btn == "pos" then
      if state == "pressed" then
        vote = "1"
      end
    elseif btn == "neg" then
      if state == "pressed" then
        vote = "-1"
      end
    end
    testBox:addItem("vote: " .. vote)
    exists = returnSingle(results)
    if exists == '0' then
      server:getSQL("database/database.db", "insert into Vote(Account, Upvote, ProblemID) values ('" .. acc .. "', " .. vote .. ", '" .. probID .. "')", "insertvote")
    else
      server:getSQL("database/database.db", "update Vote set Upvote=" .. vote .. " where Account = '" .. acc .. "' and ProblemID=" .. probID, "updatevote")
    end
    testBox:addItem("id: " .. id)
    testBox:addItem("vote: " .. vote)

  elseif id == "updatevote" then
    --testBox:addItem("UPDATED!")
    getVotesAndDisplay(probID)

  elseif id == "insertvote" then
    --testBox:addItem("INSERTED!")
    getVotesAndDisplay(probID)
  end

end