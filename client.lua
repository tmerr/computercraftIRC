-------------------------------------------------------------------------config



--os.loadAPI("json")

------------------------------------------------------------------http requests

MESSAGES_URL = "http://ftbirc.no-ip.biz:5000/messages"
USERS_URL = "http://ftbirc.no-ip.biz:5000/users"
OPS_URL = "http://ftbirc.no-ip.biz:5000/ops"
VOICED_URL = "http://ftbirc.no-ip.biz:5000/voiced"

function decodeJsonFrom(url)
	local h = http.get(url)
	local str = h.readAll()
	local messages = json.decode(str)
	return messages
end

function getMessages()
	return decodeJsonFrom(MESSAGES_URL)
end

function getUsers()
	return decodeJsonFrom(USERS_URL)
end

function getOps()
	return decodeJsonFrom(OPS_URL)
end

function getVoiced()
	return decodeJsonFrom(VOICED_URL)
end

-----------------------------------------------------------------------printing

function writeToUsersPane()
end

function writeToChatPane()	
end

function printMessages()
	messages = getMessages()
	local i = 0
	while not (messages[tostring(i)] == nil) do
		local entry = obj[tostring(i)]
		print(entry["nick"]..": "..entry["message"])
		i = i + 1
	end
end

function printUsers()
end

function printOps()
end

function printVoiced()
end
