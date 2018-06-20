Database = {}
function Database.new(dbFile)
  local self = {}
  self.dbFile = dbFile
  setmetatable(self, {__index = Database})
  return self
end

function Database:CreateProblemsTable()
  server:getSQL(self.dbFile,
    "create table Problems ( Account varchar(30), Title varchar(20), Description varchar(250), Location varchar(30) );"
  )
end

function Database:InsertProblem(Title, Description, Location)
  server:getSQL(self.dbFile,
    "insert into Problems ( Account, Title, Description, Location ) values ('" .. myAccount .. "', '" .. Title .. "', '" .. Description .. "', '" .. Location .. "');"
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

function InsertProblem(Title, Description, Location)
  db:InsertProblem(Title, Description, Location)
end

function onCreated()
  myAccount = self:getAccount()

  db = Database.new("database/problems.db")
  db:CreateProblemsTable()
  db:GetAllProblems()
end