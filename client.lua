-------------------------------------------------------------------------config

REMOTE = false     -- whether the script is being run remotely or locally
DIVIDER_POS = 15  -- the divider between users and chat

monitor = peripheral.wrap("left")
monitor.clear()
monitor.setCursorPos(1,1)

os.loadAPI("json")

------------------------------------------------------------------http requests

if REMOTE then
	domain = "http://ftbirc.no-ip.biz:5000"
else
	domain = "http://127.0.0.1:5000"
end

MESSAGES_URL = domain.."/messages"
USERS_URL = domain.."/users"
OPS_URL = domain.."/ops"
VOICED_URL = domain.."/voiced"

function decodeJsonFrom(url)
	local h = http.get(url)
	local str = h.readAll()
	local messages = json.decode(str)
	return messages
end

-- Fetch any range of chat messages. Either argument can be nil for no limit.
function fetchMessages(first, last)
	local pre = {"?", "&"}
	local param1 = ""
	local param2 = ""
	if not first then
		param1 = pre[1].."start"
		table.remove(pre, 1)
	end
	if not last then
		param2 = pre[1].."end"
		table.remove(pre, 1)
	end

	local url = MESSAGES_URL..param1..param2
	return decodeJsonFrom(url)
end

function fetchUsers()
	return decodeJsonFrom(USERS_URL)
end

function fetchOps()
	return decodeJsonFrom(OPS_URL)
end

function fetchVoiced()
	return decodeJsonFrom(VOICED_URL)
end

--------------------------------------------------------------------------stuff

dividercolor = colors.white

function drawDivider(screen)
	local screenwidth, screenheight = screen.getSize()
	for y=1,screenheight do
		screen.setTextColor(dividercolor)
		screen.setCursorPos(DIVIDER_POS, y)
		screen.write("|")
	end
end

----------------------------------------------------------------------chat pane
ChatPane = {}
ChatPane.__index = ChatPane

function ChatPane.create(screen)
	local self = {}
	setmetatable(self, ChatPane)
	
	self.screen = screen
	self.maxhistory = 50

	local screenwidth, screenheight = self.screen.getSize()
	self.left = DIVIDER_POS + 2
	self.right = screenwidth
	self.top = 1
	self.bot = screenheight
	self.height = self.bot - self.top + 1
	self.width = self.right - self.left + 1

	-- The history is everything written to the chat diced up into
	-- characters and mashed together.
	-- It's a sequence of {["char"], ["color"]}
	self.history = {}
	
	return self
end

-- Get cursor position relative to this
function ChatPane:getCursorPos()
	local x, y = self.screen.getCursorPos()
	x = x - self.left + 1
	y = y - self.top + 1
	return x, y
end

function ChatPane:setCursorPos(x, y)
	local setx = self.left + x - 1
	local sety = self.top + y - 1
	self.screen.setCursorPos(setx, sety)
end

-- incomplete
function ChatPane:position(left, right, top, bot)
	self.left = left
	self.right = right
	self.top = top
	self.bot = bot
	-- update drawing
end

-- Write to the chat pane. Accepts \n characters. Color arg is optional.
function ChatPane:write(text, color)
	color = color or colors.white
	for i=1,#text do
		local ch = string.sub(text, i, i)
		local pair = {["char"]=ch, ["color"]=color}
		table.insert(self.history, pair)
	end
	self:draw()
end

function ChatPane:newLine()
	local x, y = self:getCursorPos()
	self:setCursorPos(1, y+1)
end

-- Draw the text word wrapped to the screen.
function ChatPane:draw()
	-- We only want to write the lines that fit on the screen.  So the
	-- output is stored in a buffer and the bottom portion of it is sliced
	-- off and displayed.
	--
	-- It is indexed by buffer[y[x["char" or "color"]]]
	local buffer = {{}}
	local buff_left = 1
	local buff_right = self.width
	local buff_top = 1

	local buff_x = buff_left
	local buff_y = buff_top
	
	for i=1,#self.history do
		local el = self.history[i]
		if el["char"] == "\n" then
			-- clear the rest of the line and move to next line
			local blank = {["char"]=" ", ["color"]=colors.white}
			for x=buff_x,buff_right do
				buffer[buff_y][x] = blank
			end
			buff_x, buff_y = buff_left, buff_y+1
			buffer[buff_y] = {}
		else
			if buff_x <= buff_right then
				-- write next character
				buffer[buff_y][buff_x] = el
				buff_x = buff_x + 1
			else
				-- no more space, write on the next line
				buff_x, buff_y = buff_left, buff_y+1
				buffer[buff_y] = {}
				buffer[buff_y][buff_x] = el
				buff_x = buff_x + 1
			end
		end
	end

	-- Make sure the last line has blank characters at the end
	local blank = {["char"]=" ", ["color"]=colors.white}
	for x=buff_x, buff_right do
		buffer[buff_y][x] = blank
	end

	-- Actually write the text to the screen
	self:setCursorPos(1,1)
	local startread = #buffer - self.height + 1
	if startread < 1 then
		startread = 1
	end
	for linenum=startread,#buffer do
		line = buffer[linenum]
		for letternum=1,#line do
			letter = line[letternum]
			ch = letter["char"]
			col = letter["color"]
			if self.screen.isColor() then
				self.screen.setTextColor(col)
			end
			self.screen.write(ch)
		end
		if linenum ~= #buffer then
			self:newLine()
		end
	end
end

----------------------------------------------------------------------user pane


---------------------------------------------------------------------other shit

function printToUsersPane(text)
end

nextmsg = 0
function updateMessages(c)
	messages = fetchMessages(nextmsg, nil)
	while not (messages[tostring(nextmsg)] == nil) do
		local entry = messages[tostring(nextmsg)]
		local nicktext, nickcol = entry["nick"]..": ", colors.gray
		local msgtext, msgcol = entry["message"], colors.white
		c:write("\n"..nicktext, nickcol)
		c:write(msgtext, msgcol)
		nextmsg = nextmsg + 1
	end
end

function printUsers()
end

function printOps()
end

function printVoiced()
end

drawDivider(monitor)
c = ChatPane.create(monitor)
while true do
	updateMessages(c)
	os.sleep(2)
end
