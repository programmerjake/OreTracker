
-- https://rubenwardy.com/minetest_modding_book/en/map/environment.html#finding-nodes

-- A public API
orehud = {}

orehud.S = core.get_translator("orehud")
orehud.modpath = core.get_modpath("orehud")
orehud.store = {}
orehud.p_stats = {}

-- Settings
-- Do not set detect_range to a very high number it may cause extreme loads when there are multiple players with this range
-- Recommended range is 8 blocks
orehud.detect_range = 8 -- Range in blocks
-- The prefered fastest is 1 second, 0 or negative is instantanious updates (Which greatly impacts the server/client)
-- Recommended default is 3 seconds.
orehud.scan_frequency = 3 -- Frequency in seconds

-- This attempts to detect the gamemode
-- check mcl_core:stone first, since x_farming registers default:stone as an alias
if core.registered_nodes["mcl_core:stone"] then
    -- Attempt to determine if it's MCL5 or MCL2
    if not core.registered_nodes["mcl_deepslate:deepslate"] then
        orehud.gamemode = "MCL2"
    else
        orehud.gamemode = "MCL5"
    end
elseif core.registered_nodes["default:stone"] then
    orehud.gamemode = "MTG"
elseif core.registered_nodes["nc_terrain:stone"] then
    orehud.gamemode = "NC"
else
    orehud.gamemode = "N/A"
end

core.log("action", "[oretracker-orehud] Detected game " .. orehud.gamemode .. ".")

-- a list of what ore names we want to follow
orehud.ores = {}
-- a map from ore names to the corresponding ore colors, also used to prevent duplicates in orehud.ores
orehud.ore_colors = {}
-- ore names which should be ignored despite being in registered_ores
orehud.ignore_set = {
    ["air"] = true,
    ["aom_soil:dirt_with_grass"] = true,
    ["aom_soil:dirt"] = true,
    ["aom_soil:forest_grass"] = true,
    ["aom_soil:grass_variant_1"] = true,
    ["aom_soil:grass_variant_2"] = true,
    ["aom_soil:grass_variant_3"] = true,
    ["aom_soil:gravel"] = true,
    ["aom_stone:bedrock"] = true,
    ["aom_stone:cobble_moss_1"] = true,
    ["aom_stone:cobble_moss_2"] = true,
    ["aom_stone:cobble"] = true,
    ["aom_stone:granite"] = true,
    ["aom_stone:limestone"] = true,
    ["aom_stone:stone"] = true,
    ["default:clay"] = true,
    ["default:dirt"] = true,
    ["default:gravel"] = true,
    ["default:lava_source"] = true,
    ["default:silver_sand"] = true,
    ["df_underworld_items:glowstone"] = true,
    ["dorwinion:dorwinion"] = true,
    ["ethereal:sandy"] = true,
    ["everness:bone"] = true,
    ["everness:coral_desert_stone"] = true,
    ["everness:coral_dirt"] = true,
    ["everness:coral_sand"] = true,
    ["everness:crystal_dirt"] = true,
    ["everness:crystal_sand"] = true,
    ["everness:cursed_dirt"] = true,
    ["everness:cursed_mud"] = true,
    ["everness:cursed_sand"] = true,
    ["everness:mineral_stone"] = true,
    ["everness:sulfur_stone"] = true,
    ["lootchests_default:barrel_marker"] = true,
    ["lootchests_default:ocean_chest_marker"] = true,
    ["lootchests_default:stone_chest_marker"] = true,
    ["lootchests_magic_materials:rune_chest_marker"] = true,
    ["mcl_blackstone:blackstone"] = true,
    ["mcl_core:andesite"] = true,
    ["mcl_core:clay"] = true,
    ["mcl_core:coarse_dirt"] = true,
    ["mcl_core:diorite"] = true,
    ["mcl_core:dirt"] = true,
    ["mcl_core:granite"] = true,
    ["mcl_core:gravel"] = true,
    ["mcl_core:lava_source"] = true,
    ["mcl_core:redsand"] = true,
    ["mcl_core:redsandstone"] = true,
    ["mcl_core:water_source"] = true,
    ["mcl_deepslate:deepslate"] = true,
    ["mcl_deepslate:tuff"] = true,
    ["mcl_nether:magma"] = true,
    ["mcl_nether:nether_lava_source"] = true,
    ["mcl_nether:soul_sand"] = true,
    ["nc_concrete:sandstone"] = true,
    ["nc_rabbits:rabbit_hole"] = true,
    ["nc_terrain:gravel"] = true,
    ["nc_terrain:lava_source"] = true,
    ["nc_terrain:sand"] = true,
    ["nc_tree:humus"] = true,
    ["nether:glowstone"] = true,
    ["nether:lava_crust"] = true,
    ["nether:sand"] = true,
    ["nssb:boum_morentir"] = true,
    ["nssb:fall_morentir"] = true,
    ["nssb:morelentir"] = true,
    ["nssb:morentir"] = true,
    ["nssb:morlote"] = true,
    ["nssb:mornar"] = true,
    ["nssb:morvilya"] = true,
    ["nssm:ant_dirt"] = true,
    ["nssm:modders_block"] = true,
    ["nssm:morwa_statue"] = true,
    ["nssm:web"] = true,
    ["wc_coal:anthracite"] = true,
    ["wc_coal:bituminite"] = true,
    ["wc_coal:lignite"] = true,
    ["wc_fossil:methane"] = true,
    ["wc_fossil:oil_source"] = true,
    ["wc_naturae:mossy_dirt"] = true,
    ["wc_naturae:muck"] = true,
    ["wc_pottery:dirt_with_clay"] = true,
    ["wc_pottery:sand_with_clay"] = true,
}
dofile(orehud.modpath .. "/api.lua")

orehud.add_ores = function ()
    local ignore_worklist = {}
    for name, _ in pairs(orehud.ignore_set) do
        ignore_worklist[#ignore_worklist + 1] = name
    end
    local i = 1
    while i <= #ignore_worklist do
        local name = ignore_worklist[i]
        local alias = core.registered_aliases[name]
        if alias ~= nil then
            if orehud.ignore_set[alias] == nil then
                ignore_worklist[#ignore_worklist + 1] = alias
            end
            orehud.ignore_set[alias] = true
        end
        i = i + 1
    end
    for _, item in pairs(core.registered_ores) do
        if type(item.ore) == "string" and item.ore_type ~= "stratum" and item.ore_type ~= "sheet" then
            if orehud.ignore_set[item.ore] == nil then
                orehud.add_ore(item.ore)
            end
        end
    end
    local extra_ores = {
        "catrealm_ores:silver_ore",
        "catrealm_ores:tuxzite_ore",
        "caverealms:glow_amethyst_ore",
        "caverealms:glow_emerald_ore",
        "caverealms:glow_ore",
        "caverealms:glow_ruby_ore",
        "df_mapitems:glow_ruby_ore",
        "lootchests_default:barrel",
        "lootchests_default:basket",
        "lootchests_default:ocean_chest",
        "lootchests_default:stone_chest",
        "lootchests_default:urn",
        "lootchests_magic_materials:rune_chest",
        "lootchests_magic_materials:rune_urn",
        "nc_cats:ore_1",
        "nc_cats:ore_2",
        "nc_cats:ore_3",
        "nc_cats:ore_4",
        "nc_cats:ore_5",
        "nc_cats:ore_6",
        "nc_cats:ore_7",
        "nc_lode:ore_1",
        "nc_lode:ore_2",
        "nc_lode:ore_3",
        "nc_lode:ore_4",
        "nc_lode:ore_5",
        "nc_lode:ore_6",
        "nc_lode:ore_7",
        "nc_lux:stone_1",
        "nc_lux:stone_2",
        "nc_lux:stone_3",
        "nc_lux:stone_4",
        "nc_lux:stone_5",
        "nc_lux:stone_6",
        "nc_lux:stone_7",
        "nssb:life_energy_ore",
        "nssb:moranga",
        "technic:mineral_sulfur",
    }
    for _, name in ipairs(extra_ores) do
        if core.registered_nodes[name] then
            orehud.add_ore(name)
        end
    end
end

core.after(0, function()
    orehud.add_ores()
    local result = "Ores and colors:\n"
    local line = ""
    for i, v in ipairs(orehud.ores) do
        local item = string.format("[\"%s\"] = #%06x, ", v, orehud.ore_colors[v])
        if true or #line + #item >= 80 and line ~= "" then
            result = result .. line .. "\n"
            line = ""
        end
        line = line .. item
    end
    core.log("action", "[oretracker-orehud] Found " .. #orehud.ores .. " ores configured.")
    core.log("action", "[oretracker-orehud] " .. result .. line)
end)

-- Itterates an area of nodes for "ores", then adds a waypoint at that nodes position for that "ore".
orehud.check_player = function(player)
    local p = player
    if not core.is_player(p) then
        p = core.get_player_by_name(p)
    end
    local pos = p:get_pos()
    local pname = p:get_player_name()
    local p1 = vector.subtract(pos, {x = orehud.detect_range, y = orehud.detect_range, z = orehud.detect_range})
    local p2 = vector.add(pos, {x = orehud.detect_range, y = orehud.detect_range, z = orehud.detect_range})
    local area = core.find_nodes_in_area(p1, p2, orehud.ores)
    for i=1, #area do
        local node = core.get_node_or_nil(area[i])
        if node == nil then
            core.log("action", "[oretracker-orehud] Failed to obtain node at " .. core.pos_to_string(area[1], 1) .. ".")
        else
            local delta = vector.subtract(area[i], pos)
            local distance = (delta.x*delta.x) + (delta.y*delta.y) + (delta.z*delta.z)
            if distance <= orehud.detect_range*orehud.detect_range then
                distance = string.format("%.0f", math.sqrt(distance))
                local block = "?"
                local def = core.registered_nodes[node.name] or nil
                if def ~= nil then
                    block = def.short_description or def.description
                end
                if block == "?" then
                    core.log("action",
                        "[oretracker-orehud] Found '" ..
                        node.name ..
                        "' at " .. core.pos_to_string(area[i], 1) .. " which is " .. distance ..
                        " away from '" .. pname .. ".")
                    block = node.name
                end
                -- Make a waypoint with the nodes name
                orehud.add_pos(pname, area[i], block, orehud.ore_colors[node.name])
            end
        end
    end
end

-- Now register with minetest to actually do something

local interval = 0
core.register_globalstep(function(dtime)
    interval = interval - dtime
    if interval <= 0 then
        for _, player in ipairs(core.get_connected_players()) do
            local p = player
            if not core.is_player(p) then
                p = core.get_player_by_name(p)
            end
            -- I need to clean up the player's ore waypoints added by the latter code
            orehud.clear_pos(p:get_player_name())
            if orehud.p_stats[p:get_player_name()] then
                -- Only run if that player wants to run
                orehud.check_player(p)
            end
        end
        interval = orehud.scan_frequency
    end
end)

core.register_on_joinplayer(function(player, laston)
    orehud.p_stats[player:get_player_name()] = nil
end)

core.register_on_leaveplayer(function(player, timeout)
    local indx = 0
    local found = false
    for pname, val in ipairs(orehud.p_stats) do
        if pname == player:get_player_name() then
            found = true
            break
        end
        indx = indx + 1
    end
    if found then
        player:hud_remove(orehud.p_stats(orehud.p_stats[player:get_player_name()]))
        table.remove(orehud.p_stats, indx)
    end
end)

-- A priv for those to use this power
core.register_privilege("orehud", {
    description = "Oretracker Orehud Priv",
    give_to_singleplayer = true -- Also given to those with server priv
})

core.register_chatcommand("orehud", {
    privs = {
        shout = true,
        orehud = true -- Require our own priv
    },
    func = function(name, param)
        if orehud.p_stats[name] then
            local p = core.get_player_by_name(name)
            if p ~= nil then
                p:hud_remove(orehud.p_stats[name])
                orehud.p_stats[name] = nil
            end
        else
            local p = core.get_player_by_name(name)
            if p ~= nil then
                orehud.p_stats[name] = p:hud_add({
                    hud_elem_type = "text",
                    position = {x = 0.9, y = 0.87},
                    offset = {x = 0.0, y = 0.0},
                    text = "OREHUD",
                    number = 0x00e100, -- 0, 225, 0 (RGB)
                    alignment = {x = 0.0, y = 0.0},
                    scale = {x = 100.0, y = 100.0}
                })
            end
        end
    end,
})
