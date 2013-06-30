-------------------------------------------------------------------------config

REMOTE = false     -- whether the script is being run remotely or locally
DIVIDER_POS = 15  -- the divider between users and chat

screen = peripheral.wrap("left")
screen.clear()

--os.loadAPI("json")

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

-----------------------------------------------------------------------printing

nickcolor = colors.gray
messagecolor = colors.white
dividercolor = colors.gray
screenx, screeny = term.getSize()
maxhistory = 50

function drawDivider()
	for y=1,screeny do
		screen.setTextColor(dividercolor)
		screen.setCursorPos(DIVIDER_POS, y)
		screen.write("|")
	end
end

chathistory = {}
function addToChatPane(nick, message)	
	table.insert(chathistory, {nick, message})
	if (#chathistory > maxhistory) then
		table.remove(chathistory, 1)
	end

	-- select the nick message pairs that fit on screen
	top_element = #chathistory - screeny + 1
	if (top_element < 1) then
		top_element = 1
	end
	bot_element = #chathistory

	-- write the nick message pairs
	screenline = 1
	for e=top_element, bot_element do
		screen.setCursorPos(DIVIDER_POS + 1, screenline)
		if screen.isColor() then
			screen.setTextColor(nickcolor)
		end
		screen.write(chathistory[e][1]..": ")
		if screen.isColor() then
			screen.setTextColor(messagecolor)
		end
		screen.write(chathistory[e][2])
		screenline = screenline + 1
	end
end

function printToUsersPane(text)
end

nextmsg = 0
function updateMessages()
	messages = fetchMessages(nextmsg, nil)
	while not (messages[tostring(nextmsg)] == nil) do
		local entry = messages[tostring(nextmsg)]
		addToChatPane(entry["nick"], entry["message"])
		nextmsg = nextmsg + 1
	end
end

function printUsers()
end

function printOps()
end

function printVoiced()
end

drawDivider()
while true do
	updateMessages()
	os.sleep(2)
end
