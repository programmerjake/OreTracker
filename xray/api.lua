---@type table<string, string>
xray.to_xray_node_map = {}
---@type table<string, string>
xray.from_xray_node_map = {}
---@type string[]
xray.xrayable_node_list = {}

---@param name string
---@param tiles table?
---@return string?
function xray.register_xrayable_node(name, tiles)
    if core.registered_aliases[name] then
        name = core.registered_aliases[name]
    end
    assert(xray.from_xray_node_map[name] == nil, "can't register_xrayable_node on an xray node: " .. name)
    if xray.to_xray_node_map[name] then
        return xray.to_xray_node_map[name]
    end
    local orig = core.registered_nodes[name]
    if not orig then
        core.log("action", "[oretracker-xray] Failed to add '" .. name .. "' as it is a unregistered node.")
        return nil
    end
    orig = table.copy(orig)
    groups = table.copy(orig.groups or {})
    groups.not_in_creative_inventory = 1
    local xray_name = "xray:" .. string.gsub(name, ":", "__")
    local def = {
        description = xray.S("Xray Stone"),
        tiles = tiles or { "xray_stone.png" },
        groups = groups,
        drop = orig.drop,
        drawtype = "glasslike",
        stack_max = 1,
        sunlight_propagates = true,
        legacy_mineral = true,
        light_source = xray.light_level,
        sounds = orig.sounds,
    }
    if def.drop == "" or def.drop == nil then
        def.drop = name
    end
    for k, v in pairs(orig) do
        if type(k) == "string" and string.sub(k, 1, 1) == "_" then
            if type(v) == "table" then
                v = table.copy(v)
            end
            def[k] = v
        end
    end
    core.register_node(":" .. xray_name, def)
    table.insert(xray.xrayable_node_list, name)
    xray.to_xray_node_map[name] = xray_name
    xray.from_xray_node_map[xray_name] = name
    return xray_name
end

---@type table<integer, table<integer, table<integer, integer>>>
xray.node_reference_counts = {}

---@param x integer
---@param y integer
---@param z integer
---@return integer
function xray.get_node_reference_count(x, y, z)
    local t3 = xray.node_reference_counts
    local t2 = t3[x]
    if t2 then
        local t1 = t2[y]
        if t1 then
            return t1[z] or 0
        end
    end
    return 0
end

---@param x integer
---@param y integer
---@param z integer
---@param count integer
function xray.set_node_reference_count(x, y, z, count)
    local t3 = xray.node_reference_counts
    local t2 = t3[x]
    if not t2 then
        if count == 0 then return end
        t2 = {}
        t3[x] = t2
    end
    local t1 = t2[y]
    if not t1 then
        if count == 0 then return end
        t1 = {}
        t2[y] = t1
    end
    if count == 0 then
        t1[z] = nil
        if not next(t1) then
            t2[y] = nil
        end
        if not next(t2) then
            t3[x] = nil
        end
    else
        t1[z] = count
    end
    return 0
end

---@param pos vector
---@param inc_amount integer?
function xray.inc_node_reference_count(pos, inc_amount)
    inc_amount = inc_amount or 1
    local old_count = xray.get_node_reference_count(pos.x, pos.y, pos.z)
    local new_count = math.max(0, old_count + inc_amount)
    xray.set_node_reference_count(pos.x, pos.y, pos.z, new_count)
    local node = core.get_node_or_nil(pos)
    if not node then return end
    if new_count ~= 0 then
        -- convert any newly-placed xrayable nodes too, not just if old_count == 0
        node.name = xray.to_xray_node_map[node.name]
    else
        node.name = xray.from_xray_node_map[node.name]
    end
    if node.name then
        core.swap_node(pos, node)
    end
end

---@param center vector
---@param radius number
---@param inc_amount integer?
function xray.inc_node_reference_counts_in_sphere(center, radius, inc_amount)
    local pos = vector.copy(center)
    local floor_radius = math.floor(radius)
    local radius_squared = radius * radius
    for dx = -floor_radius, floor_radius do
        pos.x = center.x + dx
        for dy = -floor_radius, floor_radius do
            pos.y = center.y + dy
            for dz = -floor_radius, floor_radius do
                pos.z = center.z + dz
                if dx * dx + dy * dy + dz * dz < radius_squared then
                    xray.inc_node_reference_count(pos, inc_amount)
                end
            end
        end
    end
end

---@class vector
---@field x number
---@field y number
---@field z number

---@class OnlinePlayerState
---@field online_mark boolean
---@field last_pos vector?
---@field hud number?

---@type table<string, OnlinePlayerState>
xray.online_player_states = {}

function xray.clear_player_online_marks()
    for _, online_player_state in pairs(xray.online_player_states) do
        online_player_state.online_mark = false
    end
end

---@param player_names string[]|string
function xray.remove_players(player_names)
    if type(player_names) ~= "table" then
        player_names = {player_names}
    end
    for _, player_name in ipairs(player_names) do
        local state = xray.online_player_states[player_name]
        if state then
            xray.online_player_states[player_name] = nil
            if state.hud then
                local player = core.get_player_by_name(player_name)
                if player then
                    player:hud_remove(state.hud)
                end
            end
            if state.last_pos then
                xray.inc_node_reference_counts_in_sphere(state.last_pos, xray.detect_range, -1)
            end
        end
    end
end

function xray.remove_players_without_online_mark()
    local remove_list = {}
    for player_name, online_player_state in pairs(xray.online_player_states) do
        if not online_player_state.online_mark then
            remove_list[#remove_list + 1] = player_name
        end
    end
    xray.remove_players(remove_list)
end

---@param player_name string
function xray.add_or_update_online_player(player_name)
    local player = core.get_player_by_name(player_name)
    if not player then
        return
    end
    local pos = player:get_pos()
    if not pos then
        return
    end
    pos = vector.round(pos)
    local state = xray.online_player_states[player_name]
    if not state then
        state = {
            online_mark = true,
        }
        xray.online_player_states[player_name] = state
    end
    state.online_mark = true
    if state.hud then
        xray.inc_node_reference_counts_in_sphere(pos, xray.detect_range, 1)
    else
        pos = nil
    end
    if state.last_pos then
        xray.inc_node_reference_counts_in_sphere(state.last_pos, xray.detect_range, -1)
    end
    state.last_pos = pos
end

---@param player_name string
---@return integer?
function xray.get_player_hud(player_name)
    local state = xray.online_player_states[player_name]
    if not state then
        return nil
    end
    return state.hud
end