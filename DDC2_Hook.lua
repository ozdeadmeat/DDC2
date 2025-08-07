--[[
DDC2 Hooks v2.2o (added version variable DDC2.VERSION)
07/08/2025
By OzDeaDMeaT & EpicNinjaCheese

Notes:
> 2025/08/07 - Started switching out DCS functions for Sim functions
> 2023/12/11 - Added Server FPS counter to Status and Heartbeat data requests
> 2022/12/12 - Added BAN_LIST and MissionLoadEnd
> 2022/12/02 - ENC Added "DIALOG" dataType
			   will send message to coalition if data.dataPayload.coalition is set
			   will send message to player if data.dataPayload.playerUCID is set
			   will send message to all players if data.dataPayload.coalition and data.dataPayload.playerUCID is NOT set
			   parameters are:
			   	+ data.dataPayload.coalition <NUMBER> (-1 all, 0 spectators, 1 redfor, 2 blufor)
				+ data.dataPayload.playerUCID <STRING> (only if message to player is desired)
				+ data.dataPayload.text <STRING> (message to send inside dialog box)
				+ data.dataPayload.displayTime <NUMBER> (time dialog box will display on screen or if nil will default to 10s)
				+ data.dataPayload.clearView <BOOLEAN> (same as DCS API trigger.action.outText or if nil will default to true)
> 2021/08/03 - ENC Final iteration of TCP server included
			 - ENC replaced unitType with displayName in getPilotTable
> 2021/08/02 - ENC Implemented DDC2.POLLRATE variable to adjust TCP listen pollrate in tick resolution
			 - ENC Added status and init requests
> 2021/08/01 - ENC Streamlined RX functions by including a json check in tcp server
			 - ENC Implemented REQUEST/SEND functionality for dataType "STATUS" through sockets
> 2021/07/31 - ENC Implemented TX&RX of ingame chat to TX&RX port and new TX function with standard metadata
			 - ENC Implemented new metadata structure GLOBALLY
			 - ENC Reintroduced event logs and re-added "big pretty logo" in dcs.log
> 2021/07/30 - ENC Updated logs to new standard and included a couple useful userCallbacks
             - ENC Included log for DCS.log pointing to DDC2.log. Also included version number in log (will be referring to DDC2.log as "log" from now on)
			 - ENC Included mission file in log when mission loads file
			 - ENC Moved callbacks to onSimulationStart(), server will TX heartbeat/status later on when simulation is started
]]
---------------------------------------------------------------------------------------------------
DDC2 = {}
DDC2.HOST = "127.0.0.1" -- REPLACE WITH YOUR DCS_SERVER_STATUS HOST
DDC2.TXPORT = 6666 -- The port server_status runs on by default. change if you need to.
DDC2.RXPORT = 6667 -- Port DCS Listens on for commands from Node Red+
DDC2.POLLRATE = 64 / 2 -- Time in ticks between TCP listen polls (minimum reccomended value is 16) (servers are 64 tick/s)
DDC2.HEARTBEAT = 5 --Time between DCS to DDC2 (NodeRed) Heartbeat signal transmissions
DDC2.DEBUG = true
--DONT CHANGE ANYTHING BELOW THIS LINE
---------------------------------------------------------------------------------------------------
-- Define locals
local socket = require("socket") -- Setup Socket variable
local lfs = require('lfs') --Setup File System variable
local lastHeartbeat = 0 -- init heartbeat
local lastUpdate = 0 -- init status
local memory = {} -- Locally stored banlist, softbanlist, whitelist etc
---------------------------------------------------------------------------------------------------
DDC2.VERSION = "2.2o"
DDC2.ID = "UNINITIALIZED" -- Initial id for server on startup. It will grab the ID from DDC2 when the server starts
DDC2.LogFile = io.open(lfs.writedir()..[[Logs\DDC2.log]], "w")
DDC2.LogHeartBeat = false --Enables logging of heartbeat (For troubleshooting), leave this disabled unless you are having issues with data transmission between DCS and DDC2
DDC2.running = false
DDC2.commandPrefix = "-"
---------------------------------------------------------------------------------------------------
--FUNCTIONS--FUNCTIONS--FUNCTIONS--FUNCTIONS--FUNCTIONS--FUNCTIONS--FUNCTIONS--FUNCTIONS--FUNCTIONS
---------------------------------------------------------------------------------------------------
local function tableLen(table)
    local i = 0
	if type(table) ~= "table" then return 0 end
	for _,x in pairs(table) do
		i = i + 1
    end
	return i
end
local function findPlayerByUCID(ucid)
	local players = net.get_player_list()
	for _, id in pairs(players) do
        if net.get_player_info(id, "ucid") == ucid then
            local playerInfo = net.get_player_info(id)
			playerInfo.missionID = DCS.getUnitProperty(playerInfo.slot, DCS.UNIT_MISSION_ID)
			return playerInfo
		end
	end
end
local function formatTime(timeDelta)
    local timeStr = ""
	if timeDelta / 60 / 60 / 24 / 7 / 4/ 12 >= 1 then
		timeStr = math.floor(timeDelta / 60 / 60 / 24 / 7 / 4 / 12) .. " year"
	elseif timeDelta / 60 / 60 / 24 / 7 / 4 >= 1 then
		timeStr = math.floor(timeDelta / 60 / 60 / 24 / 7 / 4) .. " month"
	elseif timeDelta / 60 / 60 / 24 / 7 >= 1 then
		timeStr = math.floor(timeDelta / 60 / 60 / 24 / 7) .. " week"
	elseif timeDelta / 60 / 60 / 24 >= 1 then
		timeStr = math.floor(timeDelta / 60 / 60 / 24) .. " day"
	elseif timeDelta / 60 / 60 >= 1 then
		timeStr = math.floor(timeDelta / 60 / 60) .. " hour"
	elseif timeDelta / 60 >= 1 then
		timeStr = math.floor(timeDelta / 60) .. " minute"
	else
		timeStr = math.floor(timeDelta) .. " second"
    end

	if tonumber(timeStr:match("%d+")) > 1 then timeStr = timeStr .. "s" end

	return timeStr
end
local function isServer()
	return DCS.isServer() and DCS.isMultiplayer()
end
local function randString(length)
	local res = ""
	for i = 1, length do
		res = res .. string.char(math.random(97, 122))
	end
	return res
end
local function sanitize(text)
	local t = string.format("%q", text)
	return string.sub(t, 2, t:len() - 1)
end
local function tprint(tbl, indent)
    if not indent then indent = 0 end
    local toprint = string.rep(" ", indent) .. "{\r\n"
    indent = indent + 2
    for k, v in pairs(tbl) do
      toprint = toprint .. string.rep(" ", indent)
      if (type(k) == "number") then
        toprint = toprint .. "[" .. k .. "] = "
      elseif (type(k) == "string") then
        toprint = toprint  .. k ..  "= "
      end
      if (type(v) == "number") then
        toprint = toprint .. v .. ",\r\n"
      elseif (type(v) == "string") then
        toprint = toprint .. "\"" .. v .. "\",\r\n"
      elseif (type(v) == "table") then
        toprint = toprint .. tprint(v, indent + 2):match("^%s-({.*)$") .. ",\r\n"
      else
        toprint = toprint .. "\"" .. tostring(v) .. "\",\r\n"
      end
    end
    toprint = toprint .. string.rep(" ", indent-2) .. "}"
    return toprint
end
local function trim(s) -- Removes whitespace before and after string
  return (string.gsub(s, "^[%s\n]*(.-)[%s\n]*$", "%1"))
end
---------------------------------------------------------------------------------------------------
--Logging Function
function DDC2.log(str, error, echodcslog)
	if type(str) == "table" then
		if error then
			str = str[1]
		else
			str = string.format("%s:\n%s",tostring(str), tprint(str, 22))
		end
	else
		str = tostring(str) or type(str)
	end
	if error then
		if type(error) == "table" then
			error = error[1]
		end
		if type(error) == "string" then
			str = string.format("%s (%s)", str, tostring(error))
		else
			str = "ERROR: " .. str
		end
	end
	if DDC2.LogFile then
		local tmStr = os.date('%Y-%m-%d %H:%M:%S', os.time())
		DDC2.LogFile:write(string.format("%s : %s\r\n", tmStr, str))
		DDC2.LogFile:flush()
	end
	if echodcslog then log.write('DDC2', log.INFO, str) end
end
--------------------------------------------------------------------------------------------------
--Send Function
function DDC2.send(dataType, payload, dataID, initiator, port)
	if type(dataType) ~= "string" then error("dataType is not a string!") end
	if type(payload) ~= "table" then error("payload is not a table!") end
	port = port or DDC2.TXPORT
	local transmissionTBL = {
		initiator = initiator or "DCS",
		serverID = DDC2.ID,
		dataType = dataType,
		dataID = dataID or (randString(8) .. "-" .. os.time()),
		dataPayload = payload,
		timeStamp = os.time(),
	}
	local status, err = pcall(function()
		local tx_socket = socket.try(socket.connect(DDC2.HOST, port)) -- connect to the listener socket
		tx_socket:setoption("tcp-nodelay",true) -- set immediate transmission mode
		tx_socket:settimeout(0.01)
		socket.try(tx_socket:send(net.lua2json(transmissionTBL) or "{\"\"error:\"JSON is nil\"}")) --Transmission
		tx_socket:close() --Close the socket
		tx_socket = nil
	end)
	if status then
		if DDC2.DEBUG and dataType ~= "HEARTBEAT" then
			DDC2.log(string.format("Transmitted dataType '%s' on port %s", dataType, tostring(DDC2.TXPORT)))
		end
		return true
	elseif dataType ~= "HEARTBEAT" then -- added miss on heartbeat to stop repeated "couldn't connect" message in log
		DDC2.log("Couldn't connect to TX port " .. tostring(DDC2.TXPORT), err)
		-- if DDC2.DEBUG then DDC2.log(debug.traceback(1)) end
		return false
	end
end
--------------------------------------------------------------------------------------------------
--TCP Server
local function ddc2server()
    local server, err = socket.bind(DDC2.HOST, DDC2.RXPORT) -- Bind port
	if err then
		DDC2.log("Couldn't listen on port " .. tostring(DDC2.RXPORT), err)
	else
		DDC2.log("DDC2 is Listening on TCP port " .. tostring(DDC2.RXPORT))
		while 1 do
			if select(2, server:getsockname()) ~= DDC2.RXPORT then -- if listening port is not the same as the set RX port
				server:close()
				break
			end
			local ret
			server:settimeout(0) -- Disable block of main process
			local client, e = server:accept() -- Accept connection
			if e then
				if e ~= "timeout" then
					DDC2.log("Couldn't listen on port " .. tostring(DDC2.RXPORT), e)
				end
			else
				local data = client:receive() -- receive data from socket
				if data then
					local status, json = pcall(net.json2lua, data) -- convert json to table
					if status and type(json) == "table" and type(json.dataPayload) == "table" then -- if json is table
						if DDC2.DEBUG then DDC2.log(string.format("Received dataType '%s' on RX port %s", tostring(json.dataType), tostring(DDC2.RXPORT))) end
						ret = json
					else
						DDC2.log("Incorrect or incomplete data when RX on port " .. tostring(DDC2.RXPORT), true)
						if DDC2.DEBUG then
							DDC2.log(json, true)
						end
					end
				else
					DDC2.log("nil data received from DDC2 on port " .. tostring(DDC2.RXPORT), true)
				end
			end
			coroutine.yield(ret)
		end
	end
end
----------------------------------------------------------------------------------------
--Pilot Table Function
function DDC2.getPilotTable()
	local neutSlots = DCS.getAvailableSlots("neutrals") or Sim.getAvailableSlots("neutrals")
	local redSlots = DCS.getAvailableSlots("red") or Sim.getAvailableSlots("red")
	local blueSlots = DCS.getAvailableSlots("blue") or Sim.getAvailableSlots("blue")

	local playerDetailTable = {}
	for i,value in pairs(net.get_player_list()) do
		local plyr = net.get_player_info(value) or {}

		local function getData(slotList)
			for _,slot in pairs(slotList) do
				if slot.unitId == plyr.slot then
					plyr.role = slot.role
					plyr.unitType = DCS.getUnitTypeAttribute(slot.type:match("^(.+)_?.-$") or "", "DisplayName") or Sim.getUnitTypeAttribute(slot.type:match("^(.+)_?.-$") or "", "DisplayName") or false
				end
			end
		end

		if plyr.side == 0 then
			getData(neutSlots)
		elseif plyr.side == 1 then
			getData(redSlots)
		elseif plyr.side == 2 then
			getData(blueSlots)
		else
			-- Log message saying error side out of range
		end
		table.insert(playerDetailTable, plyr)
	end
	return playerDetailTable
end
function DDC2.sendPilotTable()
	local status, err = pcall(function()
		local data = {
			missionRT = DCS.getModelTime() or Sim.getModelTime(),
			playersCount = ((#net.get_player_list()) - 1), --Subtract 1 for the Server Host
			playerDetails = DDC2.getPilotTable()
		}
		DDC2.send("PILOT_TABLE", data)
		end)
	if status then
		if DDC2.DEBUG then
			DDC2.log("Transmitted pilot table on port " .. tostring(DDC2.TXPORT))
		end
	else
		DDC2.log(err, true)
		if DDC2.DEBUG then DDC2.log(debug.traceback) end
	end
end
--------------------------------------------------------------------------------------------------
--Status Function
function DDC2.getStatus()
	--Preparing Transmission Table
	local currentMission = DCS.getCurrentMission() or Sim.getCurrentMission() or {}
	local status = {
		config = cfg,
		mission = {
			missionDifficulty = DCS.getMissionOptions()['difficulty'] or Sim.getMissionOptions()['difficulty'],
			missionFile = DCS.getMissionFilename() or Sim.getMissionFilename(),
			missionName = DCS.getMissionName() or Sim.getMissionName(),
			theater = currentMission['mission']['theatre'],
			missionDate = currentMission['mission']["date"],
			missionStartTime = currentMission['mission']['start_time'] or -1,
			missionWeather = currentMission['mission']["weather"],
			missionRequiredModules = currentMission['mission']["RequiredModules"],
			isPilotControlVehicles = currentMission['mission']["groundControl"]['isPilotControlVehicles'],
			missionNonPilotRoles = currentMission['mission']["groundControl"]['roles']
		},
		playersCount = ((#net.get_player_list()) - 1), --Subtract 1 for the Server Host
		playerDetails = DDC2.getPilotTable(),
		missionRT = DCS.getModelTime() or Sim.getModelTime() or -1,
		serverFPS = LAST_SRV_FPS or 0,
		status = {
			serverName = cfg["name"],
			neutSlots = DCS.getAvailableSlots("neutrals") or Sim.getAvailableSlots("neutrals"),
			redSlots = DCS.getAvailableSlots("red") or Sim.getAvailableSlots("red"),
			blueSlots = DCS.getAvailableSlots("blue") or Sim.getAvailableSlots("blue"),
			blueSlotCount = #DCS.getAvailableSlots("blue") or #Sim.getAvailableSlots("blue"),
			redSlotCount = #DCS.getAvailableSlots("red") or #Sim.getAvailableSlots("red"),
			neutSlotCount = #DCS.getAvailableSlots("neutrals") or #Sim.getAvailableSlots("neutrals"),
			}
	}
	return status
end
--------------------------------------------------------------------------------------------------
--Action Request (From DDC2) Function
function DDC2.actionRequest(data)
	if type(data) ~= "table" then return false end
	if type(data.dataType) == "string" and data.dataType == "INIT" and type(data.dataPayload) == "table" and type(data.initiator) and data.initiator ~= "DCS" then -- if dataType is INIT
		-- INIT DATATYPE --------------------------------------------------------------------------------------------------
		if type(data.dataPayload.profilePath) == "string" and data.dataPayload.profilePath == lfs.writedir():match("(.+)\\$") then
			-- Init DDC2 server id
			if type(data.dataPayload.serverID) == "string" and data.dataPayload.serverID ~= DDC2.ID then
				if DDC2.ID == "UNINITIALIZED" then
					DDC2.ID = data.dataPayload.serverID
					DDC2.log(string.format("DDC2 server ID initialized as '%s'", tostring(DDC2.ID)))
				else
					DDC2.ID = data.dataPayload.serverID
					DDC2.log(string.format("DDC2 server ID changed to '%s'", tostring(DDC2.ID)))
				end
			end
			-- Check ports
			if type(data.dataPayload.txPort) == "number" and data.dataPayload.txPort ~= DDC2.TXPORT then
				DDC2.log("Transmit port mismatch!", true)
				DDC2.send("ERROR", {errorMsg = "DDC2 TX PORT MISMATCH!"}, data.dataID, data.initiator, tonumber(data.dataPayload.txPort))
				return false
			end
			if type(data.dataPayload.rxPort) == "number" and data.dataPayload.rxPort ~= DDC2.RXPORT then
				DDC2.log("Receive port mismatch!", true)
				DDC2.send("ERROR", {errorMsg = "DDC2 RX PORT MISMATCH!"}, data.dataID, data.initiator, tonumber(data.dataPayload.txPort))
				return false
			end
			if type(data.dataPayload.commandPrefix) == "string" and tostring(DDC2.commandPrefix) ~= data.dataPayload.commandPrefix then
				DDC2.commandPrefix = data.dataPayload.commandPrefix
				DDC2.log(string.format("DDC2 command prefix set to '%s'", tostring(DDC2.commandPrefix)))
			end
			-- DDC2.send("ERROR", {errorMsg = "TEST ERROR"}, data.dataID, data.initiator, tonumber(data.dataPayload.txPort)) -- test error
			DDC2.send("INIT", DDC2.getStatus(), data.dataID, data.initiator)
			return true
		else
			DDC2.log("DDC2 PROFILE MISMATCH!", true)
			DDC2.log("Server path set in config: " .. tostring(data.dataPayload.profilePath))
			DDC2.log("Server path set in hooks: " .. tostring(lfs.writedir()):match("(.+)\\$"))
			DDC2.send("ERROR", {errorMsg = "DDC2 PROFILE MISMATCH!"}, data.dataID, data.initiator, tonumber(data.dataPayload.txPort))
			return false
		end
	elseif type(data.dataType) == "string" and type(data.initiator) == "string" and type(data.serverID) == "string" and data.serverID == DDC2.ID then -- If metadata and dataPayload is good AND message is for the right server
        if DDC2.DEBUG and data.logTable then DDC2.log(data) end -- output entire data table to log if logTable is set in metadata and debug mode is on
		-- DBTABLES DATATYPE ------------------------------------------------------------------------------------------------
		if data.dataType == "DBTABLES" and data.initiator ~= "DCS" then
			if type(data.dataPayload.banList) == "table" then
                memory.banList = data.dataPayload.banList
				DDC2.log(string.format("Successfully updated ban list with %d entries", tableLen(memory.banList)))
                if memory.banList then memory.banList.lastUpdated = os.time() end
            end
			if type(data.dataPayload.softBanList) == "table" then
                memory.softBanList = data.dataPayload.softBanList
				DDC2.log(string.format("Successfully updated softban list with %d entries", tableLen(memory.banList)))
				if memory.softBanList then memory.softBanList.lastUpdated = os.time() end
            end
			if type(data.dataPayload.whiteList) == "table" then
                memory.whiteList = data.dataPayload.whiteList
				DDC2.log(string.format("Successfully updated whitelist with %d entries", tableLen(memory.banList)))
				if memory.whiteList then memory.whiteList.lastUpdated = os.time() end
            end
			if type(data.dataPayload.testMode) == "table" then
                memory.testMode = data.dataPayload.testMode
				DDC2.log(string.format("Successfully updated testmode list with %d entries", tableLen(memory.banList)))
				if memory.testMode then memory.testMode.lastUpdated = os.time() end
			end
        end
        -- RBAC DATATYPE ------------------------------------------------------------------------------------------------
		if data.dataType == "RBAC" and data.initiator ~= "DCS" then
			DDC2.log("Access comm message recieved on socket from DDC2")
		end
		-- STATUS DATATYPE ------------------------------------------------------------------------------------------------
		if data.dataType == "STATUS" and data.initiator ~= "DCS" then
			DDC2.send("STATUS", DDC2.getStatus(), data.dataID, data.initiator)
			DDC2.log("Status transmitted on port " .. tostring(DDC2.TXPORT))
			return true
		end
		-- CHAT DATATYPE --------------------------------------------------------------------------------------------------
		if data.dataType == "CHAT" and data.initiator ~= "DCS" and type(data.dataPayload) == "table" then -- if dataType is CHAT
			local message = string.format("%s: %s", tostring(data.dataPayload.chatName), tostring(data.dataPayload.chatMessage))
			if data.dataPayload.channel == -1 then
				net.send_chat(tostring(data.dataPayload.chatName) .. " (Discord):", true)
				net.send_chat(tostring(data.dataPayload.chatMessage), true)
			else
				for _,playerID in pairs(net.get_player_list()) do
					local side = net.get_player_info(playerID, "side")
					if side == data.dataPayload.channel then
						net.send_chat_to(tostring(data.dataPayload.chatName) .. " (Discord):", playerID)
						net.send_chat_to(tostring(data.dataPayload.chatMessage), playerID)
					end
				end
			end
			DDC2.log("Chat message received on RX port " .. tostring(DDC2.RXPORT))
			return true
		end
		-- PRIVATE CHAT DATATYPE ------------------------------------------------------------------------------------------
		if data.dataType == "PCHAT" and type(data.dataPayload) == "table" then
            net.send_chat_to(data.dataPayload.chatMessage, findPlayerByUCID(data.dataPayload.playerUCID).id);
			if DDC2.DEBUG then DDC2.log("Sent DCS API call: net.send_chat_to(%s,%s)") end
			if data.dataPayload.logMessage then
				DDC2.log(data.dataPayload.logMessage, data.dataPayload.logError);
			else
				DDC2.log("Private message recieved on RX port " .. tostring(DDC2.RXPORT));
			end
        end
		-- DIALOG DATATYPE ------------------------------------------------------------------------------------------
        if data.dataType == "DIALOG" and type(data.dataPayload) == "table" then
            local text = sanitize(data.dataPayload.text or type(data.dataPayload.text))
            local displayTime = data.dataPayload.displayTime or 10
            local clearView = data.dataPayload.clearView
            if type(clearView) ~= "boolean" then clearView = true end
            clearView = tostring(clearView)

			if type(data.dataPayload.playerUCID) == "string" then -- if playerucid was sent then dialog to player
				net.dostring_in('server', string.format("return trigger.action.outTextForUnit(%s,'%s',%s,%s);", findPlayerByUCID(data.dataPayload.playerUCID).missionID, text, displayTime, clearView))
				if DDC2.DEBUG then DDC2.log(string.format("Sent DCS API call: trigger.action.outTextForUnit(%s,'%s',%s,%s)", findPlayerByUCID(data.dataPayload.playerUCID).missionID, text, displayTime, clearView)) end
            elseif type(data.dataPayload.coalition) == "number" and data.dataPayload.coalition ~= -1 then -- If coalition was sent then dialog to coalition
				net.dostring_in('server', string.format("return trigger.action.outTextForCoalition(%s,'%s',%s,%s);", data.dataPayload.coalition, text, displayTime, clearView))
				if DDC2.DEBUG then DDC2.log(string.format("Sent DCS API call: trigger.action.outTextForCoalition(%s,'%s',%s,%s);", data.dataPayload.coalition, text, displayTime, clearView)) end
            else -- If neither of the above was passed send dialog to entire server
				net.dostring_in('server', string.format("return trigger.action.outText('%s',%s,%s);", text, displayTime, clearView))
				if DDC2.DEBUG then DDC2.log(string.format("Sent DCS API call: trigger.action.outText('%s',%s,%s)", text, displayTime, clearView)) end
            end
			if type(data.dataPayload.text) ~= "string" then
				DDC2.log("Dialog text parameter is not a string", true)
			end
        end
        -- EXEC DATATYPE ------------------------------------------------------------------------------------------
		if data.dataType == "EXEC" and type(data.dataPayload) == "table" then
            if data.dataPayload.scope == "MISSION" then
				-- TBA
            elseif data.dataPayload.scope == "SERVER" then
				-- TBA
			end
		end
	else
		if type(data.serverID) == "string" and data.serverID ~= DDC2.ID then
			if DDC2.DEBUG then DDC2.log(string.format("Ignoring data sent to DDC2 server id '%s'", data.serverID)) end
		else
			DDC2.log("Incomplete or wrong data format received!", true)
			if DDC2.DEBUG then DDC2.log(data) end
		end
	end
	return false
end
--------------------------------------------------------------------------------------------------
--Callback Functions
local callbacks = {}
--
function callbacks.onSimulationStart()
	DDC2.running = true
	DDC2.send("STATUS", DDC2.getStatus())
    DDC2.log("Status transmitted on port " .. tostring(DDC2.TXPORT))
end
--
function callbacks.onSimulationStop()
	DDC2.running = false
	DDC2.log('Simulation Stopped')
	DDC2.Log:close()
end
--
function callbacks.onMissionLoadBegin()
	DDC2.log(string.format("Server is loading mission file: '%s'", DCS.getMissionFilename():match("^.+[/\\](.+)$") or Sim.getMissionFilename():match("^.+[/\\](.+)$")))
end
--
function callbacks.onMissionLoadProgress(progress, message)
	if DDC2.DEBUG then DDC2.log(string.format("MISSION LOADING (%s): %s", tostring(progress), tostring(message))) end
end
--
function callbacks.onMissionLoadEnd()
	dofile(lfs.writedir()..[[Config\serverSettings.lua]]) --Sets cfg Variable
    DDC2.log("Server reports mission loaded...")
	
	local currentMission = DCS.getCurrentMission() or Sim.getCurrentMission()

    local data = {
        eventType = "MISSION_LOAD_END",
        missionFile = DCS.getMissionFilename() or Sim.getMissionFilename(),
        missionName = DCS.getMissionName() or Sim.getMissionName(),
        theater = currentMission.mission.theatre,
        missionDate = currentMission.mission.date,
        missionStartTime = currentMission.mission.start_time or -1,
		missionWeather = currentMission.mission.weather
    }
	
    DDC2.send("NOTIFICATION", data)
	DDC2.sendPilotTable()
end
--
function callbacks.onPlayerTryConnect(ipaddr, name, ucid, playerID)
	if not isServer() then return true end -- break execution if dcs is not running in server mode
    DDC2.log(string.format("Incoming connection [%s] from %s (%s)", tostring(playerID), tostring(ipaddr), tostring(name)))

    if type(memory.banList) == "table" and memory.banList[ucid] then
		local entry = memory.banList[ucid] -- Get ban info from banlist
		local msg
        if entry.ban_until then -- If ban has a time limit
			if entry.ban_until > os.time() then -- if ban time is not up yet
				msg = string.format("You are banned from this server!\n\nREASON: %s\n\nYour ban will finish in %s ", tostring(entry.reason), formatTime(entry.ban_until - os.time()))
            else -- ban time is up
				msg = string.format("Your ban on this server has finished!\n\nREASON: %s\n\nPlease follow the server rules\nYou may now enter the server", tostring(entry.reason))
                -- Send message to node_red to remove ban from banlist
				DDC2.log(string.format("Player '%s' ban is over. Removing from ban list", name))
			end
        else -- Player is banned without a time limit (permabanned)
			if entry.reason then 
                msg = string.format("You are permanently banned from this server!\n\nREASON: %s ", tostring(entry.reason))
            else
				msg = "You are permanently banned from this server!"
			end
        end
        return false, msg -- Tell DCS API to block connection
    else
		DDC2.log("Ban list is not initialised!", true)
	end

	if type(memory.whiteList) == "table" then
        if memory.whiteList[ucid] then
			-- time limited whitelist code
        else
			DDC2.log(string.format("Player %s with UCID %s connection [%d] rejected. Reason: WHITELIST_NO_MATCH", tostring(name), tostring(ucid), tostring(playerID)))
			return false, tostring(memory.whiteList[ucid]) or "You are not whitelisted on this server"
        end
    end

	if type(memory.testMode) == "table" then
		if memory.testMode[ucid] then
            DDC2.log(string.format("Allowed player %s connection [%d] through testmode block", name, playerID))
        else
			return false, tostring(memory.testMode.blockMessage) or "This server is currently undergoing maintenance. Please try connecting a little later"
		end
	end
end
--
function callbacks.onPlayerTrySendChat(playerID, msg, all)
	local playerDetails = net.get_player_info(playerID);

	if string.match(msg, "^" .. tostring(DDC2.commandPrefix)) then -- If chat was a command (started with prefix)
		local command = string.match(msg, "^!(.-)%s") or string.gsub(msg, tostring(DDC2.commandPrefix), "");
		local params = string.match(msg, "%s(.*)$");

		-- Lowercase command please

		if command == "acclink" then
			-- ACCLINK command 		--------------------------------------------------------------------------------------------------
			if params and params:len() > 0 then
				DDC2.send("COMMAND", { type = "ACCLINK", otp = trim(params), playerUCID = playerDetails.ucid, raw = msg });
				DDC2.log(string.format("Player '%s' with UCID '%s' triggered command '%sacclink'", playerDetails.name, playerDetails.ucid, tostring(DDC2.commandPrefix)))
			else
				net.send_chat_to("Syntax Error!: Please enter a link code", playerID);
			end
		else
			-- Command not found 	--------------------------------------------------------------------------------------------------
			net.send_chat_to("ERROR: The command '" .. tostring(command) .. "' does not exist", playerID);
		end
		return "";
	else
		-- Chat loopback to discord
		-- Needs a rework
		if playerID ~= net.get_server_id() then
			local playerDetails = net.get_player_info(playerID)
			local status, err = pcall(function()
				local channel = playerDetails.side
				if all == -1 then
					channel = -1
				end
				local payload = {
					playerUCID = playerDetails.ucid,
					chatName = playerDetails.name,
					chatMessage = msg,
					channel = channel,
				}
				DDC2.send("CHAT", payload)
			end)
			if status then
				if DDC2.DEBUG then
					DDC2.log("Chat message sent to TX port " .. DDC2.TXPORT .. "!" )
				end
			else
				DDC2.log(err, true)
				if DDC2.DEBUG then DDC2.log(debug.traceback) end
			end
		end
	end
end
--
local tick = 0
local lastcheck = 0
SRV_FPS         = 0  --FPS COUNTER GLOBAL VARIABLE
LAST_SRV_FPS    = 0  --LAST REPORTED SERVER FPS
function callbacks.onSimulationFrame()
	SRV_FPS = SRV_FPS + 1
	tick = tick + 1
	if (tick == 1) or (tick >= lastcheck + DDC2.POLLRATE) then
		if coroutine.status(DDC2.rxServer) == "dead" then
			DDC2.rxServer = coroutine.create(ddc2server) -- if tcp server crashed then restart it
		end
		DDC2.actionRequest(select(2, coroutine.resume(DDC2.rxServer))) -- listen for 1 tick on RX Port and action request if data received
	end

	if DDC2.running then
		local curTime = os.time()
		if curTime >= lastHeartbeat + DDC2.HEARTBEAT then
			LAST_SRV_FPS = math.floor(SRV_FPS / DDC2.HEARTBEAT)
			SRV_FPS = 0
			lastHeartbeat = curTime
			xpcall(function()
				DDC2.send("HEARTBEAT", {
					missionRT = DCS.getModelTime() or Sim.getModelTime() or -1,
					serverFPS = LAST_SRV_FPS or 0
					}) -- TX HEARTBEAT
			end, function(err)
				DDC2.log(err, true)
				if DDC2.DEBUG then DDC2.log(debug.traceback()) end
			end)
		end
	end
end
--------------------------------------------------------------------------------------------------
--OnGameEvent Function
local ffdb = {}
function callbacks.onGameEvent(eventName, arg1,arg2,arg3,arg4,arg5,arg6,arg7)
	xpcall(function()
		local function getUnitInfo(unitID)
			if unitID == nil then return false end
			local info = net.get_player_info(unitID)
			if info then
				for _,slot in pairs(DCS.getAvailableSlots((function() if info.side == 1 then return "red" elseif info.side == 2 then return "blue" else return "neutrals" end end)())) do
					if slot.unitId == info.slot then
						info.role = slot.role
						info.roleABR = info.role:match("%u")
						info.unitType = DCS.getUnitTypeAttribute(slot.type or "", "DisplayName") or Sim.getUnitTypeAttribute(slot.type or "", "DisplayName")
						break
					end
				end
				info.isAi = false
			else
				info = {
					id = DCS.getUnitProperty(unitID, DCS.UNIT_MISSION_ID),
					name = DCS.getUnitProperty(unitID, DCS.UNIT_NAME),
					callsign = DCS.getUnitProperty(unitID, DCS.UNIT_CALLSIGN),
					side = DCS.getUnitProperty(unitID, DCS.UNIT_COALITION),
					unitType = DCS.getUnitTypeAttribute(DCS.getUnitProperty(unitID, DCS.UNIT_TYPE) or "", "DisplayName"),
					role = "AI",
					roleABR = "AI",
					isAi = true,
				}
			end
			return info
		end

		local eventTable
		if eventName == "friendly_fire" then -- arg1 = bullyPlayerID, arg2 = weaponName, arg3 = victimPlayerID
			local killerUCID = net.get_player_info(arg1, "ucid")
			local victimUCID = net.get_player_info(arg3, "ucid")
			if killerUCID and victimUCID then -- If it was player on player frat
				if ffdb[killerUCID .. victimUCID] == nil or os.time() >= ffdb[killerUCID .. victimUCID] + 5 then
					eventTable = {
						killerInfo = getUnitInfo(arg1),
						weaponName = arg2,
						victimInfo = getUnitInfo(arg3)
					}
					ffdb[killerUCID .. victimUCID] = os.time()
				end
			end
		end
		--
		if eventName == "mission_end" then -- arg1 = winner, arg2 = msg
			eventTable = {
				winner = arg1,
				msg = arg2
			}
			ffdb = {} -- clear friendly fire data
		end
		--
		if eventName == "kill" then -- arg1 = killerPlayerID, arg2 = killerUnitType, arg3 = killerSide, arg4 = victimPlayerID, arg5 = victimUnitType, arg6 = victimSide, arg7 = weaponName
			eventTable = {
				killerInfo = getUnitInfo(arg1),
				killerUnitType = arg2,
				killerSide = arg3,
				victimInfo = getUnitInfo(arg4),
				victimUnitType = arg5,
				victimSide = arg6,
				weaponName = arg7 or "VICIOUS RHETORIC",
			}
		end
		--
		if eventName == "self_kill" then -- arg1 = playerID
			eventTable = {
				playerInfo = getUnitInfo(arg1)
			}
		end
		--
		if eventName == "change_slot" then -- arg1 = playerID, arg2 = slotID, arg3 = prevSide
			if net.get_player_info(arg1) then
				eventTable = {
					playerInfo = getUnitInfo(arg1),
					slotID = arg2,
					prevSide = arg3,
				}
				DDC2.sendPilotTable()
			end
		end
		--
		if eventName == "connect" then -- arg1 = playerID, arg2 = name
			eventTable = {
				playerInfo = getUnitInfo(arg1),
				name = arg2
			}
			DDC2.sendPilotTable()
		end
		--
		if eventName == "disconnect" then -- arg1 = playerID, arg2 = name, arg3 = playerSide, arg4 = reason_code
			eventTable = {
				-- playerInfo = net.get_player_info(playerID),
				name = arg2,
				playerSide = arg3,
				reason_code = arg4
			}
			DDC2.sendPilotTable()
		end
		--
		if eventName == "crash" then -- arg1 = playerID, arg2 = unit_missionID
			eventTable = {
				playerInfo = getUnitInfo(arg1),
				unit_missionID = arg2,
				unitType = DCS.getUnitType(arg2) or Sim.getUnitType(arg2)
			}
		end
		--
		if eventName == "eject" then -- arg1 = playerID, arg2 = unit_missionID
			eventTable = {
				playerInfo = getUnitInfo(arg1),
				unit_missionID = arg2,
				unitType = DCS.getUnitType(arg2) or Sim.getUnitType(arg2)
			}
		end
		--
		if eventName == "takeoff" then -- arg1 = playerID, arg2 = unit_missionID, arg3 = aridromeName
			eventTable = {
				playerInfo = getUnitInfo(arg1),
				unit_missionID = arg2,
				unitType = DCS.getUnitType(arg2) or Sim.getUnitType(arg2),
				airdromeName = arg3
			}
		end
		--
		if eventName == "landing" then -- arg1 = playerID, arg2 = unit_missionID, arg3 = airdromeName
			eventTable = {
				playerInfo = getUnitInfo(arg1),
				unit_missionID = arg2,
				unitType = DCS.getUnitType(arg2) or Sim.getUnitType(arg2),
				airdromeName = arg3
			}
		end
		--
		if eventName == "pilot_death" then -- arg1 = playerID, arg2 = unit_missionID
			eventTable = {
				playerInfo = getUnitInfo(arg1),
				unit_missionID = arg2,
				unitType = DCS.getUnitType(arg2) or Sim.getUnitType(arg2)
			}
		end
		--
		if type(eventTable) == "table" then
			eventTable.eventType = eventName
			DDC2.send("NOTIFICATION", eventTable)
			if DDC2.DEBUG then
				DDC2.log("EVENT - " .. net.lua2json(eventTable))
			else
				DDC2.log(string.format("EVENT - %s transmitted", tostring(net.lua2json(eventName))))
			end
		end
	end, function(err)
		DDC2.log(err, true)
		if DDC2.DEBUG then DDC2.log(debug.traceback()) end
	end)
end
--------------------------------------------------------------------------------------------------
DDC2.log("--------------------------------------------------------------------------------------------------", false, true)
DDC2.log("DDDDDDDDDDDDD             DDDDDDDDDDDDD                     CCCCCCCCCCCCC      222222222222222    ", false, true)
DDC2.log("D::::::::::::DDD          D::::::::::::DDD               CCC::::::::::::C     2:::::::::::::::22  ", false, true)
DDC2.log("D:::::::::::::::DD        D:::::::::::::::DD           CC:::::::::::::::C     2::::::222222:::::2 ", false, true)
DDC2.log("DDD:::::DDDDD:::::D       DDD:::::DDDDD:::::D         C:::::CCCCCCCC::::C     2222222     2:::::2 ", false, true)
DDC2.log("  D:::::D    D:::::D        D:::::D    D:::::D       C:::::C       CCCCCC                 2:::::2 ", false, true)
DDC2.log("  D:::::D     D:::::D       D:::::D     D:::::D     C:::::C                               2:::::2 ", false, true)
DDC2.log("  D:::::D     D:::::D       D:::::D     D:::::D     C:::::C                            2222::::2  ", false, true)
DDC2.log("  D:::::D     D:::::D       D:::::D     D:::::D     C:::::C                       22222::::::22   ", false, true)
DDC2.log("  D:::::D     D:::::D       D:::::D     D:::::D     C:::::C                     22::::::::222     ", false, true)
DDC2.log("  D:::::D     D:::::D       D:::::D     D:::::D     C:::::C                    2:::::22222        ", false, true)
DDC2.log("  D:::::D     D:::::D       D:::::D     D:::::D     C:::::C                   2:::::2             ", false, true)
DDC2.log("  D:::::D    D:::::D        D:::::D    D:::::D       C:::::C       CCCCCC     2:::::2             ", false, true)
DDC2.log("DDD:::::DDDDD:::::D       DDD:::::DDDDD:::::D         C:::::CCCCCCCC::::C     2:::::2       222222", false, true)
DDC2.log("D:::::::::::::::DD        D:::::::::::::::DD           CC:::::::::::::::C     2::::::2222222:::::2", false, true)
DDC2.log("D::::::::::::DDD          D::::::::::::DDD               CCC::::::::::::C     2::::::::::::::::::2", false, true)
DDC2.log("DDDDDDDDDDDDD             DDDDDDDDDDDDD                     CCCCCCCCCCCCC     22222222222222222222", false, true)
DDC2.log("--------------------------------------------------------------------------------------------------", false, true)
--------------------------------------------------------------------------------------------------
-- INIT DDC2
DCS.setUserCallbacks(callbacks) -- register callbacks with DCS
DDC2.rxServer = coroutine.create(ddc2server) -- init coroutine for TCP server
coroutine.resume(DDC2.rxServer) -- Init tcp server
dofile(lfs.writedir()..[[Config\serverSettings.lua]]) --Sets cfg Variable
DDC2.log("DDC2 ready to transmit data to TCP port " .. DDC2.TXPORT)
DDC2.send("INIT", {}) -- Send init request to node red
--------------------------------------------------------------------------------------------------
-- INIT LOG MESSAGES
DDC2.log(string.format("DDC2 v%s Initialized!", DDC2.VERSION)) -- Init log message DDC2.log
if DDC2.DEBUG then DDC2.log("Debug mode is enabled") end -- Debug mode enabled log message
log.write("DDC2", log.INFO, string.format("v%s Initialized! Log output is: '%sLogs\\DDC2.log'", DDC2.VERSION, lfs.writedir())) -- Send init message to DCS.log
--------------------------------------------------------------------------------------------------