local function _NULL_() end
local love11 = love.getVersion() == 11
local getDPI = love11 and love.window.getDPIScale or love.window.getPixelScale
local SystemInfo = {
 versionLove = string.format("v %d.%d.%d - %s", love.getVersion()),
 isCompatible = love.isVersionCompatible("11.4"),
 os = love.system.getOS()
}
SystemInfo.isMobile =  (SystemInfo.os == "iOS" or SystemInfo.os == "Android" ) and true or false


local path = (...):gsub("%.init$", "")
--load util
local table_util = {}

-------------
---Table util
-------------

--Map 
function table_util.map(tbl, f)
  local t = {}
  for k, v in pairs(tbl) do t[k] = f(v) end
  return t
end

--filter elements of table
function table_util.filter(tbl, f)
  local t, i = {}, 1
  for _, v in ipairs(tbl) do
    if f(v) then t[i], i = v, i + 1 end
  end
  return t
end

--add elements in table
function table_util.push(tbl, ...)
  for _, v in ipairs({...}) do
    table.insert(tbl, v)
  end
end

--keys
function table_util.keys(tbl)
  local keys_tbl = {}
  for k, _ in pairs(tbl) do
    table.insert(keys_tbl, k)
  end
  return keys_tbl
end

--concat
function table_util.concat(...)
  local tbl = {}
  for _, t in ipairs({...}) do
    for _, v in ipairs(t) do
      table.insert(tbl, v)
    end
  end
  return tbl
end

-- remove
function table_util.removeAll(t)
 for i=#t,1, -1 do
  table.remove(t, i)
 end
 
 return t
end


local string_util = {}


-------------
---- string util
---------------

local pattern = '[%z\1-\127\194-\244][\128-\191]*'

--eval
 function eval(str)
  local state = 0
  local function next_string()
    state = state + 1
    if state == 1 then return "return "
    elseif state == 2 then return str end
  end
  local chunk = load(next_string)
  if not chunk then return end
  if setfenv then setfenv(chunk, {}) end
  
  local ok, res = pcall(chunk)
  if ok then return res end
end


--remove white space
function string_util.clearWhiteSpace(str)
 return command:gsub("^.-%s","", 1)
end

--remove characters not ascii
function string_util.strip(s, pat)
	 return s:gsub(pat or pattern, function (c) return #c > 1 and '' end)
end

--split string
function string_util.split(inputstr, sep)
 if sep == nil then
  sep = "%s"
 end

 local t = {}
 for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
  table.insert(t, str)
 end
 return t
end

--Check if starts width
function string_util.startsWidth(s, prefix)
	for i = 1, #prefix do
		if s:byte(i) ~= prefix:byte(i) then
			return false
		end
	end
	return true
end

--Check if ends width
function string_util.endsWidth(s, suffix)
	local len = #s
	local suffix_len = #suffix
	for i = 0, suffix_len - 1 do
		if s:byte(len - i) ~= suffix:byte(suffix_len - i) then
			return false
		end
	end
	return true
end

--string to data
function string_util.stringTo(str)
 if str == nil or str == "nil" or str == "" then return "nil"
 else return eval(str) or "nil" end
end

--args string to args data
function string_util.args(str)
 local args = string_util.split(str)
 local t = {}
 
 for i,v in ipairs(args) do
   table.insert(t, string_util.stringTo(v))
 end
 
 return t
end

--return firts word
function string_util.firtsWord(str)
 return str:match("%w+")
end

--remove/delet firts word
function string_util.removeFirtsWord(str)
 return str:gsub("^.-%s","", 1)
end

--------------
---- util ----
--------------

function format(val)
  if type(val) == "table"  then
    -- If this table has a tostring function, just use that.
    local mt = getmetatable(val)
    if mt and mt.__tostring then return tostring(val) end

    local result = "{ "

    -- First print out array-like keys, keeping track of which keys we've seen.
    local seen = {}
    for k, v in ipairs(val) do
      result = result .. tostring(v) .. ", "
      seen[k] = true
    end

    -- Now print out the reset of the keys.
    for k, v in pairs(val) do
      if seen[k] ~= true then
        result = result .. tostring(k) .. " = " .. tostring(v) .. ", "
      end
    end
    result = result .. "}"
    return result
  else
    return tostring(val)
  end
end

-- Overrideable function that is used for formatting return values.
function formatArgs(...)
  local args = {...}
  if #args == 0 then
    return "nil"
  else
    return table.concat(table_util.map(args, format), "\t")
  end
end

-- easy abb 
function insideBox(x, y, bx, by, bw, bh)
 return x >=bx and x <= bx + bw and y >= by and y <= by + bh
end

-- copy table
function deepCopy(b, a)
for k,v in pairs(a) do
    if not b[k] then b[k] = v end
end

return b
end

-----------------
---- console ----
-----------------

local console = {
 _VERSION = 1.0,
 
 --constains
 PROMPT = "> ", -- The prompt symbol.
 HORIZONTAL_MARGIN = 4 * getDPI(), -- Horizontal margin between the text and window.
 VERTICAL_MARGIN = 5 * getDPI(), -- Vertical margins between components.
 MAX_LINES = 200, -- How many lines to store in the buffer.
 HISTORY_SIZE = 100, -- How much of history to store.
 --Style console
 style = {
  background_color = {0, 0, 0, 0.8},
  text_color = {1, 1, 1, 1},
  completion_text_color = {1, 1, 1, 0.4},
  error_color = {1, 0, 0, 1},
  succeful_color = {25/255, 1, 25/255, 1},
  warning_color = {1,1,0,1},
  font_path = path .. "/AnonymicePowerline.ttf",
  font_size = 5,
  font = nil
 },

 --internal global
 --The scope in which lines in the console are executed.
 ENV = setmetatable({}, {__index = _G}),

--commmands of console
 COMMANDS = {},

--commands help
 COMMANDS_HELP = {},
 
 --settings 
 setting = {
  switchEnabled = "f1",
  switchView = "f2",
  canOpenWithInput = true
 }
}

------------
--- vars ---
------------
 --They cannot edit externally just by functions of the console itself
 
 -- Store global state for whether or not the console is enabled / disabled.
local enabled = false

--is console view mode
local view = false
 
 --Get before key , its only for android
local beforeKey = "nil"

-- if focus text input
--is important focus, because if focused the console the input text and key press is accept, and if your game has 
local focus = not SystemInfo.isMobile

-- Store the printed lines in a buffer.
local lines = {}

-- Store previously executed commands in a history buffer.
local history = {}

--console ui

--has flags fot disable or actuve some parts of console
local console_ui = {
 input = true,
 lines = true,
 background = true,
 
 --for mobile
 closeBtn = true,
 tabBtn = true,
 arrows = true,
 openBtn = false
}

--text btns
local ui = {
 closeBtn = "X",
 tabBtn = "Tab",
 arrows = {">", "<", "v", "^"}
}

 -------------------
--- Init console
--------------------

 function console.init(defaultCommands, welcomeText, settings, style)
  console.command:clear()
  
  console.setStyle(style)
  console.setSettings(setting)
  
  console.console()
  console.ENV.console = console
  
  if not defaultCommands then
   console.addComand("close", function ()
    console.close()
   end, "close console")
   
   console.addComand("quit", function ()
    love.quit()
   end, "close game")
   
   console.addComand("clear", function ()
    console.clear()
   end, "clear console")
  
   console.addComand("system", function ()
    print(([[
   System Information: 
   %s
   Os %s
    ]]):format(SystemInfo.versionLove, SystemInfo.os))
   end, "Return system info")
   
   console.addComand("commands", function (h)
    local text = "== Commands use == \n --help for view help text"
    for i,v in pairs(console.COMMANDS) do
     if i ~= "commands" then
      text = text .. ("\n" .. i .. " --help :" .. console.COMMANDS_HELP[i])
     end
    end
    
    print(text)
   end)
  end
  
  
  if not welcomeText then
  console.colorprint({
   {.15, .67, .88},
   [[

                                                       
 _____           _                               _     
| __  |___ ___ _| |___ _____ ___ ___ ___ ___ ___| |___ 
|    -| .'|   | . | . |     |  _| . |   |_ -| . | | -_|
|__|__|__,|_|_|___|___|_|_|_|___|___|_|_|___|___|_|___|
                                                       

   ]],
   {.91, .29,  .6},
   ("v.%d"):format(console._VERSION)
   })
  
  print(("Random Console runing in love %s os %s"):format(SystemInfo.versionLove, SystemInfo.os))
  end
  
  --isload message 
  if not SystemInfo.isCompatible then console.colorprint({console.style.warning_color,"Danger the version of love is not compatible with the version used by love console, it can be unstable and error prone"}) else console.colorprint({console.style.succeful_color, "Loaded correct"}) end
end

--change view mode to console mode
function console.console()
 view = false
 
 console_ui.input = true
 console_ui.background = true
 
 --is just for mobile
 if SystemInfo.isMobile then
  console_ui.closeBtn = true
  console_ui.tabBtn = true
  console_ui.arrows = true
  console_ui.openBtn = false
 end
 
 console.setFocus(false)
end

--change console mode to view mode
function console.view()
 view = true
 
 console_ui.input = false
 console_ui.background = false
 
 --is just for mobile
 if SystemInfo.isMobile then
  console_ui.closeBtn = false
  console_ui.tabBtn = false
  console_ui.arrows = false
  console_ui.openBtn = true
 end
 
 console.setFocus(false)
end
 
 -------
 -- extra functions
-------

function console.setStyle(style)
 console.style = deepCopy(style or {}, console.style)
 console.updateFont()
end

function console.setSettings(settings)
 console.setting = deepCopy(settings or {},console.setting)
end
 
----------
--- focus
----------
function console.isFocused()
 return (focus or not SystemInfo.isMobile) and enabled and console_ui.input
end

----------
-- set Focus
-- focus {bool}
----------

--is even focus if drive is pc
function console.setFocus(f)
 focus = f
 
 if SystemInfo.isMobile then 
  love.keyboard.setTextInput(focus, 0, love.graphics.getHeight() - console.VERTICAL_MARGIN  - console.style.font:getHeight() - console.VERTICAL_MARGIN, love.graphics.getWidth(), love.graphics.getHeight() - console.VERTICAL_MARGIN  - console.style.font:getHeight() - console.VERTICAL_MARGIN)
 end
end
 
----------
--- add comand
---------- 

-- id {string}, f {function}, h {help text}
function console.addComand(id, f, h)
 -- no white space not specials characters only numbers and letters
 id = string_util.strip(string_util.strip(id or "nil", '[%W]*'))
 -- remove no ISCII characters
 h = string_util.strip(h or "")
 
 console.COMMANDS[id] = f or _NULL_
 console.COMMANDS_HELP[id] = h
end


 -------------------
--- is enabled
--------------------

function console.isEnabled() return enabled end

-------------------------
-- change enabled console
-------------------------

function console.switch()
 if enabled then console.close() else console.open() end
end

----------------
-- open console
----------------

function console.open()
 enabled = true
end

----------------
-- close console
----------------

function console.close()
 enabled = false
 
 if SystemInfo.isMobile then
  love.keyboard.setTextInput(false)
 end
end

--------
-- clear All
--------

function console.clearAll()
 command:clear()
 
 --clear memory
 lines = table_util.removeAll(lines)
 history = table_util.removeAll(history)
 
 --set new table
 lines = {}
 history = {}
end

 -------------------
--- lines function
--------------------

--clear lines
function console.clear() lines = {} end

-- Print a colored text to the console. Colored text is simply represented
-- as a table of values that alternate between an {r, g, b, a} object and a
-- string value.
function console.colorprint(coloredtext)
 for i,v in ipairs(coloredtext) do
    if type(v) == "string" then coloredtext[i] = string_util.strip(v) end
 end
 
 table.insert(lines, coloredtext)
end

-- Wrap the print function and redirect it to store into the line buffer.
local normal_print = print

--set new print
_G.print = function(...)
  normal_print(...) -- Call original print function.
  local args = {...}
  local line = table.concat(table_util.map({...}, tostring), "\t")
  
  --line = string_util.strip(line) -- remove utf8 characters
  
  table_util.push(lines, line)
  
  while #lines > console.MAX_LINES do
    table.remove(lines, 1)
  end
end

 -------------------
--- history function
--------------------

function console.addHistory(command)
  table.insert(history, 1, command)
end


 -------------------
--- font function
--------------------

function console.updateFont()
  console.style.font = love.graphics.newFont(console.style.font_path, console.style.font_size * getDPI())
end

--------------------
-- Helper object that encapuslates operations on the current command.
-- curso and text
--------------------

console.command = {
  clear = function(self)
    -- Clear the current command.
    self.text = ""
    self.cursor = 0
    self.history_index = 0
    self.completion = nil
  end,
  
  insert = function(self, input)
    --Inert text at the cursor.
    input = string_util.strip(input) -- remove utf characters
    
    self.text = self.text:sub(0, self.cursor) ..
      input .. self.text:sub(self.cursor + 1)
    self.cursor = self.cursor + 1

    -- Update completion.
    self:update_completion()
  end,
  
  delete_backward = function(self)
    -- Delete the character before the cursor.
    if self.cursor > 0 then
      self.text = self.text:sub(0, self.cursor - 1) ..
        self.text:sub(self.cursor + 1)
      self.cursor = self.cursor - 1
    end

    -- Update completion.
    self:update_completion()
  end,
  
  forward_character = function(self)
    if self.completion and self.cursor == self.text:len() then
      self:complete()
    else
      self.cursor = math.min(self.cursor + 1, self.text:len())
    end
  end,
  
  backward_character = function(self)
    self.cursor = math.max(self.cursor - 1, 0)
  end,
  
  beginning_of_line = function(self) self.cursor = 0 end,
  
  end_of_line = function(self) self.cursor = self.text:len() end,
  
  forward_word = function(self)
    local word = self.text:match('%W*%w*', self.cursor + 1)
    self.cursor = math.min(self.cursor + word:len())
  end,
  
  backward_word = function(self)
    local word = self.text:reverse():match('%W*%w*', self.text:len() - self.cursor + 1)
    self.cursor = math.max(self.cursor - word:len(), 0)
  end,
  
  previous = function(self)
    -- If there is no more history, don't do anything.
    if self.history_index + 1 > #history then return end

    -- If this is the first time, then save the command in case the user
    -- navigates back to the present command.
    if self.history_index == 0 then self.saved_command = self.text end

    self.history_index = math.min(self.history_index + 1, #history)
    self.text = history[self.history_index]
    self.cursor = self.text:len()

    -- Update completion.
    self:update_completion()
  end,
  
  next = function(self)
    -- If there is no more history, don't do anything.
    if self.history_index - 1 < 0 then return end
    self.history_index = math.max(self.history_index - 1, 0)

    if self.history_index == 0 then self.text = self.saved_command
    else self.text = history[self.history_index] end
    self.cursor = self.text:len()

    -- Update completion.
    self:update_completion()
  end,

  update_completion = function(self)
    if self.text:len() > 0 then
      self.completion = console.completion(self.text)
    else
      self.completion = nil
    end
  end,
  
  --complete completion
  complete = function(self)
    if self.completion then
      self.text = self.completion
      self.cursor = self.text:len()
      self.completion = nil

      -- Update completion.
      self:update_completion()
    end
  end,
  
  --paste text
  paste = function (self)
   if love.system.getClipboardText() then
      self.text = self.text .. love.system.getClipboardText()
      self.cursor = self.text:len()
      self.completion = nil

      -- Update completion.
      self:update_completion()
   end
  end,
  
  --copy text
  copy = function (self)
   love.system.setClipboardText( self.text )
  end,
  
  --cut text
  cut = function (self)
    self:copy()
    
    self.text = ""
    self.cursor = self.text:len()
    self.completion = nil
    
    -- Update completion
    self:update_completion()
  end
  
}

---  alias 
local command = console.command


-----------------
---- console functions
-----------------

--drawing
function console.draw()
  -- Only draw the console if enabled.
  
  love.graphics.origin() --to take in account scale,translate,rotate
  
  --save previous draw settings
  local prevFont  = love.graphics.getFont()
  local prevLineW = love.graphics.getLineWidth()
  local prevLineS = love.graphics.getLineStyle()
  local prevR, prevG, prevB, prevA = love.graphics.getColor()
  local prevMode, prevAlphamode = love.graphics.getBlendMode( )
  local sx, sy, sw, sh = love.graphics.getScissor()
  
  --clear color
  love.graphics.setColor(1,1,1,1)
  
  --if not enabled not draw the console
  if enabled then 
   
   local font = console.style.font
   local w, h = love.graphics.getDimensions()
   local wraplimit = w - console.HORIZONTAL_MARGIN*2
  
  love.graphics.setScissor(0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    
  
  if console_ui.background then
  --Fill the background color.
  love.graphics.setColor(console.style.background_color)
  love.graphics.rectangle('fill', 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
  end
  
  love.graphics.setColor(console.style.text_color)
  love.graphics.setFont(font)
  
  if console_ui.lines then
  local line_start = h - console.VERTICAL_MARGIN*3 - font:getHeight()
  
  for i = #lines, 1, -1 do
    local textonly = lines[i]
    
    if type(lines[i]) == "table" then
      textonly = table.concat(table_util.filter(lines[i], function(val)
        return type(val) == "string"
      end), "")
    end
    
    local width, wrapped = font:getWrap(textonly, wraplimit)

    love.graphics.printf(
      lines[i], console.HORIZONTAL_MARGIN,
      line_start - #wrapped * font:getHeight(),
      wraplimit, "left")
    line_start = line_start - #wrapped * font:getHeight()
  end
  end
  
  -- inpur text
  if console_ui.input then
  love.graphics.setScissor( 0, h - console.VERTICAL_MARGIN - font:getHeight() - console.VERTICAL_MARGIN, w, h - console.VERTICAL_MARGIN  - font:getHeight() - console.VERTICAL_MARGIN)
  love.graphics.clear()
  love.graphics.setLineWidth(1)

  love.graphics.line(0, h - console.VERTICAL_MARGIN  - font:getHeight() - console.VERTICAL_MARGIN, w, h - console.VERTICAL_MARGIN - font:getHeight() - console.VERTICAL_MARGIN)
 
  local _, wrappedtext = font:getWrap(console.PROMPT .. command.text, wraplimit)
  
  love.graphics.printf( 
    console.PROMPT .. command.text,
    console.HORIZONTAL_MARGIN,
    love.graphics.getHeight() - console.VERTICAL_MARGIN - font:getHeight() * #wrappedtext,
    wraplimit, "left")
   
  if (love.timer.getTime() % 1 > 0.5) and console.isFocused() then
    local _, wrapped = font:getWrap(wrappedtext[#wrappedtext]:sub(0, command.cursor + console.PROMPT:len()), wraplimit)
   
    local cursorx = console.HORIZONTAL_MARGIN + font:getWidth(wrapped[#wrapped])
    
    love.graphics.line(
      cursorx,
      love.graphics.getHeight() - console.VERTICAL_MARGIN - font:getHeight(),
      cursorx,
      love.graphics.getHeight() - console.VERTICAL_MARGIN)
  end

  if command.completion ~= nil then
    local suggested = command.completion:sub(command.text:len() + 1, -1)

    love.graphics.setColor(console.style.completion_text_color)
    local autocompletex = font:getWidth(console.PROMPT .. command.text)
    
    local autocompletex, wrapped = font:getWrap(wrappedtext[#wrappedtext], wraplimit)
    
    love.graphics.printf(
      suggested,
      console.HORIZONTAL_MARGIN + autocompletex,
      love.graphics.getHeight() - console.VERTICAL_MARGIN - font:getHeight(),
      wraplimit, "left")
    
    love.graphics.setColor(console.style.text_color)
  end
  
  love.graphics.setScissor(0, 0, love.graphics.getWidth(), love.graphics.getHeight())
  end
  
  
  if console_ui.closeBtn then
   love.graphics.setLineWidth(2)
   
   local width , wrappedtext = font:getWrap(ui.closeBtn, wraplimit)
    
   love.graphics.rectangle("line",w - console.HORIZONTAL_MARGIN*3 - width, console.VERTICAL_MARGIN  - font:getHeight(), console.HORIZONTAL_MARGIN*2 + width, console.VERTICAL_MARGIN + font:getHeight() + console.VERTICAL_MARGIN, 10, 10, 100)
   
   love.graphics.printf( 
       ui.closeBtn,
       w - console.HORIZONTAL_MARGIN*2 - width,
       console.VERTICAL_MARGIN*2 - font:getHeight() * #wrappedtext,
       wraplimit, "left")
  end
  
  if console_ui.openBtn then
   love.graphics.setLineWidth(2)
   
   local width , wrappedtext = font:getWrap(console.PROMPT, wraplimit)
    
   love.graphics.rectangle("line",console.HORIZONTAL_MARGIN*2 - width,h - console.VERTICAL_MARGIN*2  - font:getHeight(), console.HORIZONTAL_MARGIN*2 + width, console.VERTICAL_MARGIN + font:getHeight() + console.VERTICAL_MARGIN, 10, 10, 100)
   
   love.graphics.printf( 
       console.PROMPT,
       console.HORIZONTAL_MARGIN*3 - width,
       h - console.VERTICAL_MARGIN - font:getHeight() * #wrappedtext,
       wraplimit, "left")
  end
  
  
  local lastBtnY = h - console.VERTICAL_MARGIN*3
  
  if console_ui.tabBtn then
   love.graphics.setLineWidth(2)
   
   local width , wrappedtext = font:getWrap(ui.tabBtn, wraplimit)
   lastBtnY = lastBtnY - console.VERTICAL_MARGIN*3 - font:getHeight() * #wrappedtext
  
   love.graphics.rectangle("line",w - console.HORIZONTAL_MARGIN*3 - width, lastBtnY, console.HORIZONTAL_MARGIN*2 + width, console.VERTICAL_MARGIN + font:getHeight() + console.VERTICAL_MARGIN, 10, 10, 100)
   
   love.graphics.printf( 
       ui.tabBtn,
       w - console.HORIZONTAL_MARGIN*2 - width,
       lastBtnY + console.VERTICAL_MARGIN*2 - font:getHeight() * #wrappedtext,
       wraplimit, "left")
  end
  
  if console_ui.arrows then 
   love.graphics.setLineWidth(2)
   
   local width , wrappedtext = font:getWrap(ui.arrows[1], wraplimit)
   lastBtnY = lastBtnY - console.VERTICAL_MARGIN*3 - font:getHeight() * #wrappedtext
  
   love.graphics.rectangle("line",w - console.HORIZONTAL_MARGIN*3 - width, lastBtnY, console.HORIZONTAL_MARGIN*2 + width, console.VERTICAL_MARGIN + font:getHeight() + console.VERTICAL_MARGIN, 10, 10, 100)
   
   love.graphics.printf( 
       ui.arrows[1],
       w - console.HORIZONTAL_MARGIN*2 - width,
       lastBtnY + console.VERTICAL_MARGIN*2 - font:getHeight() * #wrappedtext,
       wraplimit, "left")

   local width , wrappedtext = font:getWrap(ui.arrows[2], wraplimit)
   lastBtnY = lastBtnY - console.VERTICAL_MARGIN*3 - font:getHeight() * #wrappedtext
  
   love.graphics.rectangle("line",w - console.HORIZONTAL_MARGIN*3 - width, lastBtnY, console.HORIZONTAL_MARGIN*2 + width, console.VERTICAL_MARGIN + font:getHeight() + console.VERTICAL_MARGIN, 10, 10, 100)
   
   love.graphics.printf( 
       ui.arrows[2],
       w - console.HORIZONTAL_MARGIN*2 - width,
       lastBtnY + console.VERTICAL_MARGIN*2 - font:getHeight() * #wrappedtext,
       wraplimit, "left")

   local width , wrappedtext = font:getWrap(ui.arrows[3], wraplimit)
   lastBtnY = lastBtnY - console.VERTICAL_MARGIN*3 - font:getHeight() * #wrappedtext
  
   love.graphics.rectangle("line",w - console.HORIZONTAL_MARGIN*3 - width, lastBtnY, console.HORIZONTAL_MARGIN*2 + width, console.VERTICAL_MARGIN + font:getHeight() + console.VERTICAL_MARGIN, 10, 10, 100)
   
   love.graphics.printf( 
       ui.arrows[3],
       w - console.HORIZONTAL_MARGIN*2 - width,
       lastBtnY + console.VERTICAL_MARGIN*2 - font:getHeight() * #wrappedtext,
       wraplimit, "left")

   local width , wrappedtext = font:getWrap(ui.arrows[4], wraplimit)
   lastBtnY = lastBtnY - console.VERTICAL_MARGIN*3 - font:getHeight() * #wrappedtext
  
   love.graphics.rectangle("line",w - console.HORIZONTAL_MARGIN*3 - width, lastBtnY, console.HORIZONTAL_MARGIN*2 + width, console.VERTICAL_MARGIN + font:getHeight() + console.VERTICAL_MARGIN, 10, 10, 100)
   
   love.graphics.printf( 
       ui.arrows[4],
       w - console.HORIZONTAL_MARGIN*2 - width,
       lastBtnY + console.VERTICAL_MARGIN*2 - font:getHeight() * #wrappedtext,
       wraplimit, "left")
   
  end
  
  end
  -- previous drawing
  love.graphics.setFont(prevFont)
  love.graphics.setLineWidth(prevLineW)
  love.graphics.setLineStyle(prevLineS)
  love.graphics.setColor(prevR, prevG, prevB, prevA)
  love.graphics.setBlendMode(prevMode, prevAlphamode)
  love.graphics.setScissor(sx, sy, sw, sh)
end

-------------
-- completion
-------------
function console.completion(partial)
  -- Generate a list of all possible completions.
  local possible_completions = table_util.concat(table_util.keys(console.ENV), table_util.keys(console.COMMANDS), history, table_util.keys(_G))

  -- Filter out completions that don't match the currently typed text.
  possible_completions = table_util.filter(possible_completions, function(possible_completion)
    return possible_completion:len() > partial:len()
      and partial == possible_completion:sub(1, partial:len())
  end)

  -- Sort completions by length.
  table.sort(possible_completions, function(a, b)
    return a:len() < b:len()
  end)

  -- If we have at least one valid completion, return it.
  if #possible_completions > 0 then
    return possible_completions[1]
  end
end

------------------
-- execute command
------------------
function console.execute(command)
 if console.COMMANDS[string_util.firtsWord(command)] then
  console.colorprint({console.style.succeful_color,console.PROMPT .. command})
  
  local str = string_util.removeFirtsWord(command)
  local arg, i = string_util.split(str)
  
  if not ( #arg > 0 ) then str = "" end
  
  if arg[1] == "--help" then
  print(console.COMMANDS_HELP[string_util.firtsWord(command)])
  return 
  end
  
  console.COMMANDS[string_util.firtsWord(command)](unpack(string_util.args(str)))
 
  return
 end
 
  -- Reprint the command + the prompt string.
  print(console.PROMPT .. command)

  local chunk, error = load("return " .. command)
  
  if not chunk then
    if chunk ~= nil then 
     console.colorprint({console.style.error_color, "something are wrong"}) end
    chunk, error = load(command)
  end

  if chunk then
   setfenv(chunk, console.ENV)
   local values = { pcall(chunk) }
    
    if values[1] then
      table.remove(values, 1)
      print(formatArgs(unpack(values)))

      -- Bind '_' to the first returned value, and bind 'last' to a list
      -- of returned values.
      console.ENV._ = values[1]
      console.ENV.last = values
    else
      console.colorprint({console.style.error_color, values[2]})
    end
  else
    console.colorprint({console.style.error_color, error})
  end
end


----------------
--console export
----------------

function console.export(filename, onlyprint, onlypront)
 filename = filename or "export"
 local txt = ""
 for i = 1, #lines do
  local textonly = lines[i]
  
  if type(lines[i]) == "table" then
   textonly = table.concat(table_util.filter(lines[i], function(val)
     return type(val) == "string"
   end), "")
  end
 
  if onlyprint and not string_util.startsWidth(textonly, console.PROMPT) then
   txt = txt .. "\n" .. textonly
  elseif onlypront and string_util.startsWidth(textonly, console.PROMPT) then
   txt = txt .. "\n" .. textonly
  else
   txt = txt .. "\n" .. textonly
  end
 end

  love.filesystem.write(filename .. ".txt", txt)
end

----------------
-- console inputs
----------------

function console.keypressed(key, scancode, isrepeat)
  -- Use the "~" key to enable / disable the console.
  if key == console.setting.switchEnabled and console.setting.canOpenWithInput then 
    console.switch()
    console.setFocus(enabled)
    return console.isFocused()
  end

  if key == console.setting.switchView and enabled then 
    if view then console.console() else console.view() end
    
    return console.isFocused()
  end
  
    -- Ignore if the console isn't enabled.
  if not console.isFocused() then return console.isFocused() end
  
  
  local ctrl = love.keyboard.isDown("lctrl", "lgui") or (SystemInfo.isMobile and beforeKey == "lctrl")
  local shift = love.keyboard.isDown("lshift") or (SystemInfo.isMobile and beforeKey == "lshift")
  
  if key == 'backspace' then
  command:delete_backward()
  
  elseif key == "return" then
   console.addHistory(command.text)
   console.execute(command.text)
   command:clear()
    
  elseif key == "tab" then
   command:complete()
   
   
  --key functions and shortcuts
  
  
  -- curso text functions
  elseif key == "up" then command:previous()
  elseif key == "down" then command:next()
   
  elseif shift and key == "left" then command:backward_word()
  elseif shift and key == "right" then command:forward_word()
 
  elseif ctrl and key == "left" then command:beginning_of_line()
  elseif ctrl and key == "right" then command:end_of_line()
 
  elseif key == "left" then command:backward_character()
  elseif key == "right" then command:forward_character()
 
  -- shortcuts
  
  --text
  elseif key == "c" and ctrl then command:copy()
  elseif key == "v" and ctrl then command:paste()
  elseif key == "x" and ctrl then command:cut()
  
  -- clear
  elseif key == "w" and ctrl then command:clear()
   
  -- exit
  elseif key == "e" and ctrl then love.quit(0)
   
  elseif (key == "=" and shift and ctrl) or (SystemInfo.isMobile and ctrl and key == "=") then
   console.style.font_size = console.style.font_size + 1
   console.updateFont()
  elseif key == "-" and ctrl then
   console.style.font_size = math.max(console.style.font_size - 1, 1)
   console.updateFont()
  end
  
  if SystemInfo.isMobile then
   beforeKey = key
  end
  
  return console.isFocused()
end

--text input
function console.textinput(input)
 
  -- If disabled, ignore the input, otherwise insert at the cursor.
  if not console.isFocused() then return console.isFocused() end
  command:insert(input) 
  
  return console.isFocused()
end


--love.touchpressed for mobile, ONLY FOR MOBILE 
function console.press(x, y)
 if not enabled then return enabled end
 
 x = x or love.mouse.getX() y = y or love.mouse.getY()

 local font = console.style.font
 local w, h = love.graphics.getDimensions()
 local wraplimit = w - console.HORIZONTAL_MARGIN*2
 local interaction = false
 
 if console_ui.closeBtn then
  local width , wrappedtext = font:getWrap(ui.closeBtn, wraplimit)
    
  if insideBox(x, y, w - console.HORIZONTAL_MARGIN*3 - width, console.VERTICAL_MARGIN  - font:getHeight(), console.HORIZONTAL_MARGIN*2 + width, console.VERTICAL_MARGIN + font:getHeight() + console.VERTICAL_MARGIN) then
  console.close()
  interaction = true
  end
 end
 
 if console_ui.openBtn then
  local width , wrappedtext = font:getWrap(console.PROMPT, wraplimit)
    
  if insideBox(x, y, console.HORIZONTAL_MARGIN*2 - width,h - console.VERTICAL_MARGIN*2  - font:getHeight(), console.HORIZONTAL_MARGIN*2 + width, console.VERTICAL_MARGIN + font:getHeight() + console.VERTICAL_MARGIN) then
  console.console()
  interaction = true
  end
 end
 
 local lastBtnY = h - console.VERTICAL_MARGIN*3
 
 if console_ui.tabBtn then
  local width , wrappedtext = font:getWrap(ui.tabBtn, wraplimit)
  lastBtnY = lastBtnY - console.VERTICAL_MARGIN*3 - font:getHeight() * #wrappedtext
  
  if insideBox(x, y, w - console.HORIZONTAL_MARGIN*3 - width, lastBtnY, console.HORIZONTAL_MARGIN*2 + width, console.VERTICAL_MARGIN + font:getHeight() + console.VERTICAL_MARGIN) then
  command:complete()
  interaction = true
  end
 end
 
 if console_ui.arrows then
   local width , wrappedtext = font:getWrap(ui.arrows[1], wraplimit)
   lastBtnY = lastBtnY - console.VERTICAL_MARGIN*3 - font:getHeight() * #wrappedtext
   
   if insideBox(x, y, w - console.HORIZONTAL_MARGIN*3 - width, lastBtnY, console.HORIZONTAL_MARGIN*2 + width, console.VERTICAL_MARGIN + font:getHeight() + console.VERTICAL_MARGIN) then
   command:backward_character()
   interaction = true
   end
   
   local width , wrappedtext = font:getWrap(ui.arrows[2], wraplimit)
   lastBtnY = lastBtnY - console.VERTICAL_MARGIN*3 - font:getHeight() * #wrappedtext
   
   if insideBox(x, y, w - console.HORIZONTAL_MARGIN*3 - width, lastBtnY, console.HORIZONTAL_MARGIN*2 + width, console.VERTICAL_MARGIN + font:getHeight() + console.VERTICAL_MARGIN) then
   command:forward_character()
   interaction = true
   end
   
   local width , wrappedtext = font:getWrap(ui.arrows[3], wraplimit)
   lastBtnY = lastBtnY - console.VERTICAL_MARGIN*3 - font:getHeight() * #wrappedtext
   
   if insideBox(x, y, w - console.HORIZONTAL_MARGIN*3 - width, lastBtnY, console.HORIZONTAL_MARGIN*2 + width, console.VERTICAL_MARGIN + font:getHeight() + console.VERTICAL_MARGIN) then
   command:next()
   interaction = true
   end
   
   local width , wrappedtext = font:getWrap(ui.arrows[4], wraplimit)
   lastBtnY = lastBtnY - console.VERTICAL_MARGIN*3 - font:getHeight() * #wrappedtext
   
   if insideBox(x, y, w - console.HORIZONTAL_MARGIN*3 - width, lastBtnY, console.HORIZONTAL_MARGIN*2 + width, console.VERTICAL_MARGIN + font:getHeight() + console.VERTICAL_MARGIN) then
   command:previous()
   interaction = true
   end
 end
 
 if not interaction and console_ui.input and insideBox(x, y, 0, h - (console.VERTICAL_MARGIN + font:getHeight() + console.VERTICAL_MARGIN), w, h - (h - (console.VERTICAL_MARGIN + font:getHeight() + console.VERTICAL_MARGIN))) then 
  console.setFocus(true)
  interaction = true
  elseif not interaction and console_ui.input then  console.setFocus(false) end
 
  return interaction
end


-- alias in console
console.table = table_util
console.string = string_util

-- new call
setmetatable(console, { __call = function(self, ...)  self.init(...) return self end })

--end
return console
