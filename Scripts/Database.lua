Database = {}
function Database.new(dbFile)
  local self = {}
  self.dbFile = dbFile
  setmetatable(self, {__index = Database})
  return self
end

function Database:CreateProblemsTable()
  -- Removed. I did this in DB Browser instead.
end

function Database:InsertProblem(Title, Category, Description, Latitude, Longitude)
  server:getSQL(self.dbFile,
    "insert into Problems ( Account, Title, Category, Description, Latitude, Longitude) values ('" .. myAccount .. "', '" .. Title .. "', '" .. Category .. "','" .. Description .. "', '" .. Latitude  .. "','" .. Longitude .. "');"
  )
end

function Database:GetAllProblems()
  server:getSQL(self.dbFile,
    "select Title from Problems",
    "allProblems"
  )
end

function Database:ViewProblem(Title, page)
  server:getSQL(self.dbFile,
    "select * from Problems where Title='" .. Title .. "';",
    "viewProblem" .. tostring(page)
  )
end

function GetAllProblems()
  db:GetAllProblems()
end

function ViewProblem(Title, page)
  db:ViewProblem(Title, page)
end

function getAccount(userName, reason)
  server:getSQL(self.dbFile,
  "SELECT Account, Password FROM Account WHERE Account='" .. userName .. "';",
  reason
  )
end

function InsertProblem(Title, Category, Description, Latitude, Longitude)
  db:InsertProblem(Title, Category, Description, Latitude, Longitude)
end

function onCreated()
  myAccount = self:getAccount()

  db = Database.new("database/database.db")
  db:CreateProblemsTable()
  db:GetAllProblems()
end