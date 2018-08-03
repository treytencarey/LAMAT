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
function Database:UpdateProblem(Title,Description)
  loggedIn = script:triggerFunction("getStatus", "Scripts/login.lua")
  if loggedIn == nil or loggedIn == false then return; end
  userName = script:triggerFunction("getUserName", "Scripts/login.lua")

  Title = formatLiterals(Title)
  Description = formatLiterals(Description)

  server:getSQL(self.dbFile,
    "update Problem SET Description= '" .. Description .. "' WHERE ACCOUNT = '" .. userName .. "' AND Title = '" .. Title .. "';"
  )
end
function Database:InsertProblem(Title, Category, Description, Latitude, Longitude)
  loggedIn = script:triggerFunction("getStatus", "Scripts/login.lua")
  if loggedIn == nil or loggedIn == false then return; end
  userName = script:triggerFunction("getUserName", "Scripts/login.lua")

  Title = formatLiterals(Title)
  Category = formatLiterals(Category)
  Description = formatLiterals(Description)
  Latitude = formatLiterals(Latitude)
  Longitude = formatLiterals(Longitude)

  server:getSQL(self.dbFile,
    "insert into Problem ( Account, Title, Category, Description, Latitude, Longitude) values ('" .. userName .. "', '" .. Title .. "', '" .. Category .. "','" .. Description .. "', '" .. Latitude  .. "','" .. Longitude .. "');"
  )
end

function Database:GetAllProblems()
  server:getSQL(self.dbFile,
    "select Title from Problem",
    "allProblems"
  )
end

function Database:GetProblemsByCategory(cat)
  cat = formatLiterals(cat)

  server:getSQL(self.dbFile,
    "select Title from Problem where Category=" .. cat .. ";",
    "CategoricalProb"
  )
end

function Database:ViewProblem(Title, page)
  Title = formatLiterals(Title)

  server:getSQL(self.dbFile,
    "select * from Problem where Title='" .. Title .. "';",
    "viewProblem" .. tostring(page)
  )
end

function Database:ViewMyProblems(UserId)
  UserId = formatLiterals(UserId)

  server:getSQL(self.dbFile,
    "select Title from Problem where Account='" .. UserId .. "';",
    "allProblems" 
  )
end

function Database:createAccount(userName, pass)
  userName = formatLiterals(userName)
  pass = formatLiterals(pass)

  server:getSQL(self.dbFile,
    "insert into Account (Account, Password) values ('" .. userName .. "', '" .. pass .. "');"
  )
end

function Database:getUserAccount(userName, reason)
  userName = formatLiterals(userName)

  server:getSQL(self.dbFile,
  "SELECT Account, Password FROM Account WHERE Account='" .. userName .. "';",
  reason
  )
end

function getUserAccount(userName, reason)
  db:getUserAccount(userName, reason)
end

function GetAllProblems()
  db:GetAllProblems()
end

function GetProblemsByCategory(cat)
  db:GetProblemsByCategory(cat)
end

function ViewMyProblems(UserId)
  db:ViewMyProblems(UserId)
end

function ViewProblem(Title, page)
  db:ViewProblem(Title, page)
end
function UpdateProblem(Title, Description)
  db:UpdateProblem(Title, Description)
end
function createAccount(userName, pass)
  db:createAccount(userName, pass)
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

function formatLiterals(str)
  str = str:gsub("'", "''")
  return str
end