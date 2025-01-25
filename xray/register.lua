---@type string
local game_mode
if not minetest.registered_nodes["default:stone"] then
    if not minetest.registered_nodes["mcl_core:stone"] then
        if not minetest.registered_nodes["nc_terrain:stone"] then
            game_mode = "N/A"
        else
            game_mode = "NC"
        end
    else
        -- Attempt to determine if it's MCL5 or MCL2
        if not minetest.registered_nodes["mcl_deepslate:deepslate"] then
            game_mode = "MCL2"
        else
            game_mode = "MCL5"
        end
    end
else
    game_mode = "MTG"
end

---@param old_xray_alias string
---@param name string
---@param tiles table?
---@return string
local function register_xrayable_node_and_alias(old_xray_alias, name, tiles)
    local xray_name = xray.register_xrayable_node(name, tiles)
    if xray_name then
        minetest.register_alias(old_xray_alias, xray_name)
    end
    return xray_name
end

-- MTG
if game_mode == "MTG" then
    register_xrayable_node_and_alias("xray:mtg_stone", "default:stone")
    register_xrayable_node_and_alias("xray:mtg_dstone", "default:desert_stone")
    register_xrayable_node_and_alias("xray:mtg_sstone", "default:sandstone")
    register_xrayable_node_and_alias("xray:mtg_dsstone", "default:desert_sandstone")
    register_xrayable_node_and_alias("xray:mtg_ssstone", "default:silver_sandstone")
end

-- MCL (2 and 5)
if game_mode == "MCL2" or game_mode == "MCL5" then
    register_xrayable_node_and_alias("xray:mcl_stone", "mcl_core:stone")
    register_xrayable_node_and_alias("xray:mcl_granite", "mcl_core:granite")
    register_xrayable_node_and_alias("xray:mcl_andesite", "mcl_core:andesite")
    register_xrayable_node_and_alias("xray:mcl_diorite", "mcl_core:diorite")
    register_xrayable_node_and_alias("xray:mcl_sstone", "mcl_core:sandstone")
    register_xrayable_node_and_alias("xray:mcl_rsstone", "mcl_core:redsandstone")
end

-- MCL (5 only)
if game_mode == "MCL5" then
    register_xrayable_node_and_alias("xray:mcl_bstone", "mcl_blackstone:blackstone", {"xray_dark.png"})
    register_xrayable_node_and_alias("xray:mcl_basalt", "mcl_blackstone:basalt", {"xray_dark.png"})
    register_xrayable_node_and_alias("xray:mcl_netherrack", "mcl_nether:netherrack", {"xray_nether.png"})
    register_xrayable_node_and_alias("xray:mcl_deepslate", "mcl_deepslate:deepslate", {"xray_dark.png"})
end

if game_mode == "NC" then
    register_xrayable_node_and_alias("xray:nc_stone", "nc_terrain:stone")
    for i = 1, nodecore.hard_stone_strata do
        register_xrayable_node_and_alias("xray:nc_hard_stone_" .. i, "nc_terrain:hard_stone_" .. i)
    end
end
