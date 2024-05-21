-- Author: omltcat
-- Version: 0.1

-- DCS Hook (GUI) environment admin functions
HookAdmin = {}

HookAdmin.tempBanList = {}
HookAdmin.frameCounter = 0
HookAdmin.timeStart = DCS.getRealTime()
HookAdmin.fps = 0

function HookAdmin.getPlayerList()
    local ids = net.get_player_list()
    table.sort(ids)
    local players = {}
    for _, id in ipairs(ids) do
        table.insert(players, net.get_player_info(id))
    end
    return players
end

function HookAdmin.getPlayerListID()
    local ids = net.get_player_list()
    local players = {}
    for _, id in ipairs(ids) do
        players[net.get_player_info(id, 'name')] = id
    end
    return players
end

function HookAdmin.kickName(name)
    local players = HookAdmin.getPlayerListID()
    if players[name] then
        net.kick(players[name])
    end
end

function HookAdmin.banName(name)
    local players = HookAdmin.getPlayerListID()
    if players[name] then
        local ucid = net.get_player_info(players[name], 'ucid')
        HookAdmin.tempBanList[ucid] = true
        net.kick(players[name])
    end
end

function HookAdmin.onPlayerTryConnect(addr, ucid, name, id)
    if HookAdmin.tempBanList[ucid] then
        net.kick(id)
    end
end

---@param text string
---@param displayTime number
---@param clearview boolean
function HookAdmin.outText(text, displayTime, clearview)
    if DCS.getPause() then return false end
    return net.dostring_in('mission', string.format([[a_do_script('trigger.action.outText("%s", %s, %s)')]], text, displayTime or 10, tostring(clearview)))
end

function HookAdmin:healthCheck()
    return DCS.getModelTime()
end

function HookAdmin.onSimulationFrame()
    HookAdmin.frameCounter = HookAdmin.frameCounter + 1
    -- if HookAdmin.frameCounter >= 300 then
    --     HookAdmin.frameCounter = 0
    --     local timeEnd = DCS.getRealTime()
    --     HookAdmin.fps = 300 / (timeEnd - HookAdmin.timeStart)
    --     HookAdmin.timeStart = timeEnd
    -- end
end

DCS.setUserCallbacks(HookAdmin)

_G.HookAdmin = HookAdmin
_G.FIDDLE_LOG_LEVEL = 2
