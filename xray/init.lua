-- https://rubenwardy.com/minetest_modding_book/en/map/environment.html#finding-nodes

-- A public API
xray = {}

xray.S = core.get_translator("xray")
xray.modpath = core.get_modpath("xray")
xray.p_stats = {}

-- Settings
-- Do not set detect_range to a very high number it may cause extreme loads when there are multiple players with this range
-- Recommended range is 6 blocks
xray.detect_range = 6 -- Range in blocks
-- 0 or negative is instantaneous updates (Which greatly impacts the server/client)
-- Recommended rate is once every 0.1 second.
-- this is actually a period, not a frequency, but keep the name for backwards compatibility.
xray.scan_frequency = 0.1 -- Rate to scan -- value is number of seconds between scans.
-- Light level that xray nodes emit (Max is 14 min is 0)
-- Recommended light_level is 4. (Provides enough light to use the mod, might need to use torches if you want it lighter, or adjust here)
xray.light_level = 4 -- From 0-14

local hud_elem_type_k = "hud_elem_type"
if core.features.hud_def_type_field then
    hud_elem_type_k = "type"
end

-- Make our api
dofile(xray.modpath .. "/api.lua")
dofile(xray.modpath .. "/register.lua")

-- Now register with minetest to actually do something

local time_till_next_scan = 0
core.register_globalstep(function(dtime)
    time_till_next_scan = time_till_next_scan - dtime
    if time_till_next_scan <= 0 then
        xray.clear_player_online_marks()
        for _, player in ipairs(core.get_connected_players()) do
            xray.add_or_update_online_player(player:get_player_name())
        end
        xray.remove_players_without_online_mark()
        time_till_next_scan = xray.scan_frequency
    end
end)

core.register_on_joinplayer(function(player, laston)
    xray.add_or_update_online_player(player:get_player_name())
end)

core.register_on_leaveplayer(function(player, timeout)
    xray.remove_players(player:get_player_name())
end)

-- cleanup on shutdown
core.register_on_shutdown(function()
    xray.clear_player_online_marks()
    xray.remove_players_without_online_mark()
end)

-- A priv for players so they can't abuse this power
core.register_privilege("xray", {
    description = "Oretracker Xray Priv",
    give_to_singleplayer = true -- Also given to those with server priv
})

core.register_chatcommand("xray", {
    privs = {
        shout = true,
        xray = true -- Require our xray
    },
    func = function(name, param)
        if xray.get_player_hud(name) ~= nil then
            xray.remove_players(name)
            return
        end
        local state = xray.online_player_states[name]
        local player = core.get_player_by_name(name)
        if state and player then
            state.hud = player:hud_add({
                [hud_elem_type_k] = "text",
                position = {x = 0.9, y = 0.9},
                offset = {x = 0.0, y = 0.0},
                text = " XRAY ",
                number = 0x00e100, -- 0, 225, 0 (RGB)
                alignment = {x = 0.0, y = 0.0},
                scale = {x = 100.0, y = 100.0}
            })
            xray.add_or_update_online_player(name)
        end
    end,
})

-- nodes names which should be ignored despite being in some biome
xray.ignore_set = {
    ["air"] = true,
}
core.register_on_mods_loaded(function()
    local nodes_to_register = {
        ["mapgen_desert_stone"] = true,
        ["mapgen_stone"] = true,
        ["underch:afualite"] = true,
        ["underch:amphibolite"] = true,
        ["underch:andesite"] = true,
        ["underch:aplite"] = true,
        ["underch:basalt"] = true,
        ["underch:dark_vindesite"] = true,
        ["underch:diorite"] = true,
        ["underch:dolomite"] = true,
        ["underch:emutite"] = true,
        ["underch:gabbro"] = true,
        ["underch:gneiss"] = true,
        ["underch:granite"] = true,
        ["underch:green_slimestone"] = true,
        ["underch:hektorite"] = true,
        ["underch:limestone"] = true,
        ["underch:marble"] = true,
        ["underch:omphyrite"] = true,
        ["underch:pegmatite"] = true,
        ["underch:peridotite"] = true,
        ["underch:phonolite"] = true,
        ["underch:phylite"] = true,
        ["underch:purple_slimestone"] = true,
        ["underch:quartzite"] = true,
        ["underch:red_slimestone"] = true,
        ["underch:schist"] = true,
        ["underch:sichamine"] = true,
        ["underch:slate"] = true,
        ["underch:vindesite"] = true,
    }
    for _, biome in pairs(core.registered_biomes) do
        if biome.node_stone then
            nodes_to_register[biome.node_stone] = true
        end
    end
    for node, _ in pairs(nodes_to_register) do
        if core.registered_aliases[node] then
            node = core.registered_aliases[node]
        end
        if core.registered_nodes[node] and not xray.ignore_set[node] then
            xray.register_xrayable_node(node)
        end
    end
    local result = "Xrayable nodes:\n"
    for _, name in ipairs(xray.xrayable_node_list) do
        local xray_name = xray.to_xray_node_map[name]
        local xray_def = core.registered_nodes[xray_name]
        local tiles = xray_def.tiles
        local tiles_is_empty = true
        local tiles_is_default = false
        for k, v in pairs(tiles) do
            if k == 1 and v == "xray_stone.png" and tiles_is_empty then
                tiles_is_default = true
            else
                tiles_is_empty = false
                tiles_is_default = false
                break
            end
            tiles_is_empty = false
        end
        local tiles_str = ""
        if not tiles_is_default then
            tiles_str = ", " .. dump(tiles)
        end
        local item = string.format("xray.register_xrayable_node(\"%s\"%s)\n", name, tiles_str)
        result = result .. item
    end
    core.log("action", "[oretracker-xray] Found " .. #xray.xrayable_node_list .. " nodes configured.")
    core.log("action", "[oretracker-xray] " .. result)
    core.register_lbm({
        label = "replace xray nodes with original nodes",
        name = ":xray:replace_xray_with_original",
        nodenames = xray.xrayable_node_list,
        run_at_every_load = true,
        action = function (pos, node, dtime_s)
            node.name = xray.from_xray_node_map[node.name]
            if node.name then
                print("lbm: "..pos.." "..node.name)
                core.swap_node(pos, node)
            end
        end
    })
end)
