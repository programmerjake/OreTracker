
-- https://rubenwardy.com/minetest_modding_book/en/map/environment.html#finding-nodes

-- A public API
orehud = {}

orehud.S = minetest.get_translator("orehud")
orehud.modpath = minetest.get_modpath("orehud")
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
if not minetest.registered_nodes["default:stone"] then
    if not minetest.registered_nodes["mcl_core:stone"] then
        if minetest.registered_nodes["nc_terrain:stone"] then
            orehud.gamemode = "NC"
        else
            orehud.gamemode = "N/A"
        end
    else
        orehud.gamemode = "MCL"
        -- Attempt to determine if it's MCL5 or MCL2
        if not minetest.registered_nodes["mcl_deepslate:deepslate"] then
            orehud.gamemode = "MCL2"
        else
            orehud.gamemode = "MCL5"
        end
    end
else
    orehud.gamemode = "MTG"
end

minetest.log("action", "[oretracker-orehud] Detected game "..orehud.gamemode..".")

-- Form a container to track what ores we want to follow
orehud.ores = {}
orehud.ores_set = {}
orehud.ignore_set = {
    ["air"] = true,
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
}
dofile(orehud.modpath .. "/api.lua")

--[[
-- Use api to assign ores we know/should be caring about
if orehud.gamemode == "MCL2" or orehud.gamemode == "MCL5" then
    orehud.add_ore("mcl_core:stone_with_coal")
    orehud.add_ore("mcl_core:stone_with_iron")
    orehud.add_ore("mcl_core:stone_with_gold")
    orehud.add_ore("mcl_core:stone_with_redstone")
    orehud.add_ore("mcl_core:stone_with_redstone_lit")
    orehud.add_ore("mcl_core:stone_with_lapis")
    orehud.add_ore("mcl_core:stone_with_emerald")
    orehud.add_ore("mcl_core:stone_with_diamond")
    orehud.add_ore("mcl_nether:quartz_ore") -- This fails on MCL2 :S (LOL, I didn't realize my test suite was MCL2, I though it was MCL5)
--    orehud.add_ore("mcl_nether:glowstone") -- By default this is disabled as glowstone isn't a "ore", but just uncomment this line to get it too
end

if orehud.gamemode == "MCL5" then
    orehud.add_ore("mcl_copper:stone_with_copper")
    orehud.add_ore("mcl_nether:ancient_debris")
    orehud.add_ore("mcl_nether_gold:nether_gold_ore")
    -- Deepslate ores now included
    orehud.add_ore("mcl_deepslate:deepslate_with_iron")
    orehud.add_ore("mcl_deepslate:deepslate_with_coal")
    orehud.add_ore("mcl_deepslate:deepslate_with_gold")
    orehud.add_ore("mcl_deepslate:deepslate_with_emerald")
    orehud.add_ore("mcl_deepslate:deepslate_with_diamond")
    orehud.add_ore("mcl_deepslate:deepslate_with_lapis")
    orehud.add_ore("mcl_deepslate:deepslate_with_redstone")
end

if orehud.gamemode == "MTG" then
    orehud.add_ore("default:stone_with_coal")
    orehud.add_ore("default:stone_with_iron")
    orehud.add_ore("default:stone_with_gold")
    orehud.add_ore("default:stone_with_copper")
    orehud.add_ore("default:stone_with_tin")
    orehud.add_ore("default:stone_with_mese")
    orehud.add_ore("default:stone_with_diamond")
end

if orehud.gamemode == "NC" then
    orehud.add_ore("nc_lode:ore")
end
]]

orehud.add_ores = function ()
    for _, item in pairs(minetest.registered_ores) do
        if type(item.ore) == "string" and item.ore_type ~= "stratum" and item.ore_type ~= "sheet" then
            if orehud.ignore_set[item.ore] == nil then
                orehud.add_ore(item.ore)
            end
        end
    end
end

minetest.register_on_mods_loaded(function()
    orehud.add_ores()
    local size = 0
    local result = "Ores: "
    for i, v in ipairs(orehud.ores) do
        result = result..v.." "
        size = size + 1
    end
    minetest.log("action", "[oretracker-orehud] Found "..size.." ores configured.")
    minetest.log("action", "[oretracker-orehud] "..result)
end)

-- Itterates an area of nodes for "ores", then adds a waypoint at that nodes position for that "ore".
orehud.check_player = function(player)
    local p = player
    if not minetest.is_player(p) then
        p = minetest.get_player_by_name(p)
    end
    local pos = p:get_pos()
    local pname = p:get_player_name()
    local p1 = vector.subtract(pos, {x = orehud.detect_range, y = orehud.detect_range, z = orehud.detect_range})
    local p2 = vector.add(pos, {x = orehud.detect_range, y = orehud.detect_range, z = orehud.detect_range})
    local area = minetest.find_nodes_in_area(p1, p2, orehud.ores)
    for i=1, #area do
        local node = minetest.get_node_or_nil(area[i])
        if node == nil then
            minetest.log("action", "[oretracker-orehud] Failed to obtain node at "..minetest.pos_to_string(area[1], 1)..".")
        else
            local delta = vector.subtract(area[i], pos)
            local distance = (delta.x*delta.x) + (delta.y*delta.y) + (delta.z*delta.z)
            if distance <= orehud.detect_range*orehud.detect_range then
                distance = string.format("%.0f", math.sqrt(distance))
                local block = "?"
                local color = 0xffffff
		local def = minetest.registered_nodes[node.name] or nil
		color = 0xc8c84b
                --[[if string.find(node.name, "coal") then
                    block = "Coa"
                    color = 0xc8c8c8
                elseif string.find(node.name, "iron") then
                    block = "Iro"
                    color = 0xaf644b
                elseif string.find(node.name, "gold") then
                    block = "Gol"
                    color = 0xc8c84b
                elseif string.find(node.name, "mese") then
                    block = "Mes"
                    color = 0xffff4b
                elseif string.find(node.name, "diamond") then
                    block = "Dia"
                    color = 0x4bfafa
                elseif string.find(node.name, "quartz") then
                    block = "Qua"
                    color = 0xc8c8c8
                elseif string.find(node.name, "copper") then
                    block = "Cop"
                    color = 0xc86400
                elseif string.find(node.name, "tin") then
                    block = "Tin"
                    color = 0xc8c8c8
                elseif string.find(node.name, "debris") then
                    block = "Deb"
                    color = 0xaa644b
                elseif string.find(node.name, "lapis") then
                    block = "Lap"
                    color = 0x4b4bc8
                elseif string.find(node.name, "redstone") then
                    block = "Red"
                    color = 0xc81919
                elseif string.find(node.name, "glowstone") then
                    block = "Glo"
                    color = 0xffff4b
                elseif string.find(node.name, "lode") then -- nc_lode:ore
                    block = "Lode"
                    color = 0xaf644b
                end
		]]
                if def ~= nil then
                    block = def.short_description or def.description
                end
                if block == "?" then
                    minetest.log("action", "[oretracker-orehud] Found '"..node.name.."' at "..minetest.pos_to_string(area[i], 1).." which is "..distance.." away from '"..pname..".")
                    block = node.name
                end
                -- Make a waypoint with the nodes name
                orehud.add_pos(pname, area[i], block, color)
            end
        end
    end
end

-- Now register with minetest to actually do something

local interval = 0
minetest.register_globalstep(function(dtime)
    interval = interval - dtime
    if interval <= 0 then
        for _, player in ipairs(minetest.get_connected_players()) do
            local p = player
            if not minetest.is_player(p) then
                p = minetest.get_player_by_name(p)
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

minetest.register_on_joinplayer(function(player, laston)
    orehud.p_stats[player:get_player_name()] = nil
end)

minetest.register_on_leaveplayer(function(player, timeout)
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
minetest.register_privilege("orehud", {
    description = "Oretracker Orehud Priv",
    give_to_singleplayer = true -- Also given to those with server priv
})

minetest.register_chatcommand("orehud", {
    privs = {
        shout = true,
        orehud = true -- Require our own priv
    },
    func = function(name, param)
        if orehud.p_stats[name] then
            local p = minetest.get_player_by_name(name)
            if p ~= nil then
                p:hud_remove(orehud.p_stats[name])
                orehud.p_stats[name] = nil
            end
        else
            local p = minetest.get_player_by_name(name)
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
