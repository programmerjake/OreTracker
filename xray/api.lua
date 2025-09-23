---@type table<string, string>
xray.to_xray_node_map = {}
---@type table<string, string>
xray.from_xray_node_map = {}
---@type string[]
xray.xrayable_node_list = {}

---@class XrayDefinitionFieldOverrideArgs
---@field node_name string
---@field xray_name string
---@field tiles table
---@field field_name any
---@field orig_field_value any?

---@type table<string, string | number | boolean | table | fun(args: XrayDefinitionFieldOverrideArgs): any?>
local xray_definition_field_overrides = {
    drawtype = "glasslike",
    stack_max = 1,
    sunlight_propagates = true,
    legacy_mineral = true,
    light_source = xray.light_level,
}

function xray_definition_field_overrides.groups(args)
    local groups = table.copy(args.orig_field_value or {})
    groups.not_in_creative_inventory = 1
    return groups
end

function xray_definition_field_overrides.description(args)
    return "Xray " .. tostring(args.orig_field_value)
end

function xray_definition_field_overrides.tiles(args)
    return args.tiles or { "xray_stone.png" }
end

function xray_definition_field_overrides.drop(args)
    local orig = args.orig_field_value
    if orig == "" or orig == nil then
        return args.node_name
    end
    return orig
end

---@param args XrayDefinitionFieldOverrideArgs
---@return any
local function generate_xray_definition_field(args)
    local override = xray_definition_field_overrides[args.field_name]
    if override == nil then
        if type(args.field_name) == "string" and string.sub(args.field_name, 1, 1) == "_" then
            local field_value = args.orig_field_value
            if type(field_value) == "table" then
                field_value = table.copy(field_value)
            end
            return field_value
        end
        return nil
    elseif type(override) == "function" then
        return override(args)
    else
        return override
    end
end

local function generate_xray_definition(node_name, xray_name, tiles, orig)
    local def = {}
    ---@type XrayDefinitionFieldOverrideArgs
    local args = {
        node_name = node_name,
        xray_name = xray_name,
        tiles = tiles or core.registered_nodes[xray_name].tiles,
    }
    for k, _ in pairs(xray_definition_field_overrides) do
        args.field_name = k
        args.orig_field_value = orig[k]
        def[k] = generate_xray_definition_field(args)
    end
    for k, v in pairs(orig) do
        args.field_name = k
        args.orig_field_value = v
        def[k] = generate_xray_definition_field(args)
    end
    def.name = nil
    def.type = nil
    return def
end

local old_override_item = core.override_item

function core.override_item(name, redefinition, del_fields)
    local final_name = name
    if core.registered_aliases[final_name] then
        final_name = core.registered_aliases[final_name]
    end
    local xray_name = xray.to_xray_node_map[final_name]
    if xray_name then
        -- propagate to xray node
        local xray_redefinition = {}
        local xray_del_fields = {}
        ---@type XrayDefinitionFieldOverrideArgs
        local args = {
            node_name = final_name,
            xray_name = xray_name,
            tiles = core.registered_nodes[xray_name].tiles,
        }
        for k, v in pairs(redefinition) do
            assert(k ~= "name" or k ~= "type")
            args.field_name = k
            args.orig_field_value = v
            v = generate_xray_definition_field(args)
            if v == nil then
                xray_del_fields[#xray_del_fields + 1] = k
            else
                xray_redefinition[k] = v
            end
        end
        for _, k in ipairs(del_fields or {}) do
            assert(k ~= "name" or k ~= "type")
            args.field_name = k
            args.orig_field_value = nil
            local v = generate_xray_definition_field(args)
            if v == nil then
                xray_del_fields[#xray_del_fields + 1] = k
            else
                xray_redefinition[k] = v
            end
        end
        core.log("verbose",
            "[xray] also overriding xray node: " ..
            xray_name .. "\n" .. dump({ redefinition = xray_redefinition, del_fields = xray_del_fields }))
        old_override_item(xray_name, xray_redefinition, xray_del_fields)
    elseif xray.from_xray_node_map[final_name] then
        return -- don't allow overriding xray nodes
    end
    return old_override_item(name, redefinition, del_fields)
end

---
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
    local xray_name = "xray:" .. string.gsub(name, ":", "__")
    local def = generate_xray_definition(name, xray_name, tiles or { "xray_stone.png" }, orig)
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