--[[ \class Database
-- \brief The database.
--]]

--[[
-- \brief Create a new database.
--
--   Create a database object which performs SQL on the given database file, dbFile, located in the server.
-- \mod Database(string dbFile)
-- \param The location of the file which contains SQL data on the server.
-- \return The new database object.
--]]
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

--[[
-- \brief Updates a problem's description by title.
-- \mod void UpdateProblem(string Title, string Description)
-- \param The title of the problem to update.
-- \param The new description of the problem.
--]]
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

--[[
-- \brief Creates a new problem.
-- \mod void InsertProblem(string Title, int Category, string Description, double Latitude, double Longitude
-- \param The title of the new problem.
-- \param The category of the new problem.
-- \param The description of the new problem.
-- \param The latitude location of the new problem.
-- \param The longitude location of the new problem.
--]]
function Database:InsertProblem(Title, Category, Description, Latitude, Longitude)

  --CreateButton("before command is sent", 0,0, 100,100)
  loggedIn = script:triggerFunction("getStatus", "Scripts/login.lua")
  if loggedIn == nil or loggedIn == false then return; end
  userName = script:triggerFunction("getUserName", "Scripts/login.lua")

  --CreateButton("middle of command", 0,0, 100,100)
  Title = formatLiterals(Title)
  --CreateButton("title fine", 0,0, 100,100)
  Category = Category .. ""
  Category = formatLiterals(Category)
  --Category = "1"
  --CreateButton("category fine", 0,0, 100,100)
  Description = formatLiterals(Description)
  --CreateButton("description fine", 0,0, 100,100)
  Latitude = formatLiterals(Latitude)
  Longitude = formatLiterals(Longitude)
  
  cmd = "insert into Problem ( Account, Title, Category, Description, Latitude, Longitude) values ('"
  cmd = cmd .. userName
  cmd = cmd .. "', '"
  cmd = cmd .. Title
  cmd = cmd .. "', '"
  cmd = cmd .. Category
  cmd = cmd .. "','"
  cmd = cmd .. Description
  cmd = cmd .. "', '"
  cmd = cmd .. Latitude
  cmd = cmd .. "','"
  cmd = cmd .. Longitude
  cmd = cmd .. "');"

  --CreateButton("before command", 0,0, 100,100)
  server:getSQL(self.dbFile, cmd, "submitproblem")
  
  --yee = CreateEditBox(0,0, 200, 50)
  --yee:setText(cmd)
end

--[[
-- \brief Requests a list of all problem titles, by title, from the server.
--
--    Gets a list of all problem titles from the server and triggers the function onSQLReceived() with the results of the SQL and an ID of "allProblems"
-- \mod void GetAllProblems()
--]]
function Database:GetAllProblems()
  server:getSQL(self.dbFile,
    "select Title from Problem",
    "allProblems"
  )
end

--[[
-- \brief Requests a list of all problem titles, by category, from the server.
--
--    Gets a list of all problems by category from the server and triggers the function onSQLReceived() with the results of the SQL and an ID of "CategoricalProb"
-- \mod void GetAllProblemsByCategory(int cat)
-- \param The category of the problems to get.
--]]
function Database:GetProblemsByCategory(cat)
  cat = formatLiterals(cat)

  server:getSQL(self.dbFile,
    "select Title from Problem where Category=" .. cat .. ";",
    "CategoricalProb"
  )
end

--[[
-- \brief Requests a list of all problems, by title, from the server.
--
--    Gets a list of all problems, including all of their data, from the server and triggers the function onSQLReceived() with the results of the SQL and an ID of "viewProblem" with the page (modal) number to display the information on.
-- \mod void ViewProblem(string Title, int page)
-- \param The title of the problem to view.
-- \param The modal page number to view the problem on.
--]]
function Database:ViewProblem(Title, page)
  Title = formatLiterals(Title)

  server:getSQL(self.dbFile,
    "select * from Problem where Title='" .. Title .. "';",
    "viewProblem" .. tostring(page)
  )
end

--[[
-- \brief Requests a list of all problem titles, by user id, from the server.
--
--    Gets a list of all problem titles from the server created by the user id and triggers the function onSQLReceived() with the results of the SQL and an ID of "allProblems"
-- \mod void ViewMyProblems(string UserId)
-- \param The ID (account) of the user.
--]]
function Database:ViewMyProblems(UserId)
  UserId = formatLiterals(UserId)

  server:getSQL(self.dbFile,
    "select Title from Problem where Account='" .. UserId .. "';",
    "allProblems" 
  )
end

--[[
-- \brief Creates a new account.
-- \mod void createAccount(string userName, string pass)
-- \param The new account's user name.
-- \param The new account's password.
--]]
function Database:createAccount(userName, pass)
  userName = formatLiterals(userName)
  pass = formatLiterals(pass)

  server:getSQL(self.dbFile,
    "insert into Account (Account, Password) values ('" .. userName .. "', '" .. pass .. "');"
  )
end

--[[
-- \brief Requests an account's information, by user name, from the server.
--
--    Gets an account's information from the server and triggers the function onSQLReceived() with the results of the SQL and an ID of the given reason.
-- \mod void GetAllProblems(string userName, string reason)
-- \param The username of the account.
-- \param The ID of the SQL to trigger the onSQLReceived() function with.
--]]
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