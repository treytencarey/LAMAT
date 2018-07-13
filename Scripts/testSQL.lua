function onCreated()
  testBox = CreateListBox(10, 10, 200, 300)
  editBox = CreateEditBox(10, 320, 50, 20)
  submitButton = CreateButton("Submit", 10, 350, 50, 20)
end

function onButtonPressed(button)
  if button == submitButton then
    server:getSQL("database/database.db", "select * from Problem where account='" .. editBox:getText() .. "'", "testID")
  end
end

function onSQLReceived(results, id)
  if id == "testID" then
    for k,v in pairs(results) do
      testBox:addItem(tostring(k))
      for i,m in pairs(results[k]) do
        testBox:addItem("  " .. tostring(m))
      end
    end
  end
end