os.loadAPI("json")

------------------------------------------------------------------http requests

REMOTE = false     -- whether the script is being run remotely or locally
if REMOTE then
	domain = "http://ftbirc.no-ip.biz:5000"
else
	domain = "http://127.0.0.1:5000"
end

MESSAGES_URL = domain.."/messages"
USERS_URL = domain.."/users"
OPS_URL = domain.."/ops"
HALFOPS_URL = domain.."/halfops"
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

function fetchOps()
	return decodeJsonFrom(OPS_URL)
end

function fetchHalfOps()
	return decodeJsonFrom(HALFOPS_URL)
end

function fetchVoiced()
	return decodeJsonFrom(VOICED_URL)
end

function fetchUsers()
	return decodeJsonFrom(USERS_URL)
end


-- Return a table where the keys are converted to numbers
-- @param tbl the table indexed by strings starting at ["0"]
function stringKeysToNum(tbl)
	ret = {}
	local nextidx = 0
	
	while not (tbl[tostring(nextidx)] == nil) do
		local val = tbl[tostring(nextidx)]
		table.insert(ret, val)
		nextidx = nextidx + 1
	end

	return ret
end

-- Fetches the ranks from the web server and removes duplicate nicks by only
-- placing each nick in its highest rank.
-- @return the ops, halfops, voiced, and users
function getRanks()
	local ops = fetchOps()
	local halfops = fetchHalfOps()
	local voiced = fetchVoiced()
	local users = fetchUsers()

	ops = stringKeysToNum(ops)
	halfops = stringKeysToNum(halfops)
	voiced = stringKeysToNum(voiced)
	users = stringKeysToNum(users)

	-- Only put the rank in the output if it didn't show up in a previous
	-- category.
	local input = {ops, halfops, voiced, users}
	local output = {{}, {}, {}, {}}
	local alreadyseen = {}
	for rankidx, rank in ipairs(input) do
		for nickidx, nick in ipairs(rank) do
			repeated = false
			for seenidx, seen in ipairs(alreadyseen) do
				if nick == seen then
					repeated = true
				end
			end
			if not repeated then
				table.insert(output[rankidx], nick)
				table.insert(alreadyseen, nick)
			end
		end
	end
	
	return output[1], output[2], output[3], output[4]
end

------------------------------------------------------------------------divider

function drawDivider(screen, position, color)
	local screenwidth, screenheight = screen.getSize()
	for y=1,screenheight do
		screen.setTextColor(color)
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
	-- It is indexed by buffer[y][x]["char" or "color"]
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

-- UserPane draws the IRC users by rank: ops, halfops, voiced and users. The
-- ranks are treated as mutually exclusive so only add a user to one rank each
-- to avoid duplicates.
UserPane = {}
UserPane.__index = UserPane
function UserPane.create(screen)
	local self = {}
	setmetatable(self,UserPane)

	self.screen = screen
	local screenwidth, screenheight = self.screen.getSize()

	self.left = 1
	self.right = DIVIDER_POS - 2
	self.top = 1
	self.bot = screenheight
	self.height = self.bot - self.top + 1
	self.width = self.right - self.left + 1

	self.ops = {}
	self.halfops = {}
	self.voiced = {}
	self.users = {}

	return self
end

-- Set the users and redraw
-- @param nicks the sequence of nicks
function UserPane:setUsers(nicks)
	self.users = nicks
	self:draw()
end

-- Set the ops and redraw
-- @param nicks the sequence of nicks
function UserPane:setOps(nicks)
	self.ops = nicks
	self:draw()
end

-- Set the halfops and redraw
-- @param nicks the sequence of nicks
function UserPane:setHalfOps(nicks)
	self.halfops = nicks
	self:draw()
end

-- Set the voiced and redraw
-- @param voiced the sequence of nicks
function UserPane:setVoiced(nicks)
	self.voiced = nicks
	self:draw()
end

-- Draw the nicks, ops and users
function UserPane:draw()
	self.screen.setCursorPos(self.left,self.top)

	groups={
		{self.ops, "@"},
		{self.halfops, "%"},
		{self.voiced, "+"},
		{self.users, ""}
	}

	line = 1
	for idx, val in ipairs(groups) do
		local users = val[1]
		local prefix = val[2]
		for idx, user in ipairs(users) do
			self.screen.write(prefix..user)
			line = line + 1
			self.screen.setCursorPos(self.left, line)
		end
	end
end

----------------------------------------------------------------------main code


nextmsg = 0
function update(c, u)
	local messages = fetchMessages(nextmsg, nil)
	local ops, halfops, voiced, users = getRanks()
	u:setOps(ops)
	u:setHalfOps(halfops)
	u:setVoiced(voiced)
	u:setUsers(users)

	while not (messages[tostring(nextmsg)] == nil) do
		local entry = messages[tostring(nextmsg)]
		local nicktext, nickcol = entry["nick"]..": ", colors.gray
		local msgtext, msgcol = entry["message"], colors.white
		c:write("\n"..nicktext, nickcol)
		c:write(msgtext, msgcol)
		nextmsg = nextmsg + 1
	end
end

function main()
	local monitor = peripheral.wrap("left")

	monitor.clear()
	monitor.setCursorPos(1,1)
	
	drawDivider(monitor, 15, colors.white)
	c = ChatPane.create(monitor)
	u = UserPane.create(monitor)
	
	while true do
		update(c, u)
		os.sleep(2)
	end
end

main()
