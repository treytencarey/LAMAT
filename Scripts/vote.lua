function NewRatioBar(x, y, w, h)
  local self = {}

  self.percent = .5
  self.x = x
  self.y = y
  self.w = w
  self.h = h
  self.negBar = CreateImage("UI/red_box.png", x, y, w, h)
  self.posBar = CreateImage("UI/green_box.png", x, y, w, h)
  
  function self:UpdateRatio(r)
    self.posBar:setWidth(self.w * r)
    self.percent = r
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

  return self

end

function onCreated()
  upBtn = NewButton("thumbs_up", 450,350,100,100)
  downBtn = NewButton("thumbs_down", 550,350,100,100)

  probEdit = CreateEditBox(450, 25, 100, 25)
  accEdit = CreateEditBox(550, 25, 100, 25)
  displayBtn = CreateButton("Display problem (fill in Account first!!!!!!)",450, 50, 190, 25)
  testBox = CreateListBox(450, 75, 190, 175)
  ratioBar = NewRatioBar(450, 300, 200, 25)
  scoreBox = CreateEditBox( 450, 325, 190, 25)

  --ratioBar:UpdateRatio(.5)
  probID = "0"
  acc = ""
  upVotes = "0"
  allVotes = "0"

  probEdit:setText("ProblemID")
  accEdit:setText("Account")
  scoreBox:setText("Score output: ")
end

function updateScoreBox()
  num = 0
  scoreBox:setText("Score output: " .. upVotes .. "/" .. allVotes)
  if allVotes ~= "0" then
    num = tonumber(upVotes)/tonumber(allVotes)
  end
  return num
end

function updateProbAndAcc()
    acc = accEdit:getText()
    probID = probEdit:getText()
end

function updateProblemDisplay()
    updateProbAndAcc()
    testBox:clear()
    server:getSQL("database/database.db", "select Account, Title from Problem where ID = " .. probID, "displayproblem")
    server:getSQL("database/database.db", "select Upvote from Vote where ProblemID = " .. probID, "displayvotes")
    server:getSQL("database/database.db", "select count(Upvote) from Vote where Upvote = 1 and ProblemID = " .. probID, "upvotes")
    server:getSQL("database/database.db", "select count(Upvote) from Vote where Upvote <> 0 and ProblemID = " .. probID, "totalvotes")
    server:getSQL("database/database.db", "select Upvote from Vote where ProblemID = " .. probID .. " and Account = '" .. acc .. "'", "checkvote")
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
    server:getSQL("database/database.db", "select count(Upvote) from Vote where Account = '" .. acc .. "' and ProblemID = " .. probID, "addvoteneg" .. p)

  elseif button == displayBtn then
    updateProblemDisplay()
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
  if id == "displayproblem" or id == "displayvotes" then
    testBox:addItem(id)
    for k,v in pairs(results) do
      --testBox:addItem(tostring(k))
      for i,m in pairs(results[k]) do
        testBox:addItem("  " .. tostring(m))
      end
    end 
   
  elseif id == "upvotes" then
    upVotes = returnSingle(results)

  elseif id == "totalvotes" then
    allVotes = returnSingle(results)
    newRatio = updateScoreBox()
    ratioBar:UpdateRatio(newRatio)

  elseif id == "checkvote" then 
    upBtn:Reset()
    downBtn:Reset()

    vote = returnSingle(results)
    if vote == "1" then
      upBtn:Toggle()
    elseif vote == "-1" then
      downBtn:Toggle()
    end

  elseif string.find(id, "addvote") ~= nil then
    --addvote+(pos/neg for either thumbs up or down button) + (pressed/rest depending is corresponding button was pressed or released)
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
    testBox:addItem("UPDATED!")
    updateProblemDisplay()

  elseif id == "insertvote" then
    testBox:addItem("INSERTED!")
    updateProblemDisplay()
  end

end