
-- MTG
if xray.gamemode == "MTG" then
    minetest.register_node("xray:mtg_stone", {
        description = xray.S("Xray Stone"),
        tiles = {"xray_stone.png"},
        groups = {cracky = 3, stone = 1},
        drop = "default:cobble",
        drawtype = "glasslike",
        sunlight_propagates = true,
        legacy_mineral = true,
        light_source = xray.light_level,
        sounds = default.node_sound_stone_defaults(),
    })
    minetest.register_node("xray:mtg_dstone", {
        description = xray.S("Xray Stone"),
        tiles = {"xray_stone.png"},
        groups = {cracky = 3, stone = 1},
        drop = "default:desert_cobble",
        drawtype = "glasslike",
        sunlight_propagates = true,
        legacy_mineral = true,
        light_source = xray.light_level,
        sounds = default.node_sound_stone_defaults(),
    })
    minetest.register_node("xray:mtg_sstone", {
        description = xray.S("Xray Stone"),
        tiles = {"xray_stone.png"},
        groups = {cracky = 3, stone = 1},
        drop = "default:sandstone",
        drawtype = "glasslike",
        sunlight_propagates = true,
        legacy_mineral = true,
        light_source = xray.light_level,
        sounds = default.node_sound_stone_defaults(),
    })
    minetest.register_node("xray:mtg_dsstone", {
        description = xray.S("Xray Stone"),
        tiles = {"xray_stone.png"},
        groups = {cracky = 3, stone = 1},
        drop = "default:desert_sandstone",
        drawtype = "glasslike",
        sunlight_propagates = true,
        legacy_mineral = true,
        light_source = xray.light_level,
        sounds = default.node_sound_stone_defaults(),
    })
    minetest.register_node("xray:mtg_ssstone", {
        description = xray.S("Xray Stone"),
        tiles = {"xray_stone.png"},
        groups = {cracky = 3, stone = 1},
        drop = "default:silver_sandstone",
        drawtype = "glasslike",
        sunlight_propagates = true,
        legacy_mineral = true,
        light_source = xray.light_level,
        sounds = default.node_sound_stone_defaults(),
    })
end

-- MCL (2 and 5)
if xray.gamemode == "MCL2" or xray.gamemode == "MCL5" then
    minetest.register_node("xray:mcl_stone", {
        description = xray.S("Xray Stone"),
        _doc_items_longdesc = xray.S("An Invisible block"),
        _doc_items_hidden = true,
        tiles = {"xray_stone.png"},
        is_ground_content = true,
        stack_max = 1,
        groups = {pickaxey=1, stone=1, building_block=1, material_stone=1},
        drawtype = "glasslike",
        sunlight_propagates = true,
        light_source = xray.light_level,
        drop = 'mcl_core:cobble',
        sounds = mcl_sounds.node_sound_stone_defaults(),
        _mcl_blast_resistance = 6,
        _mcl_hardness = 1.5,
        _mcl_silk_touch_drop = false,
    })
    minetest.register_node("xray:mcl_granite", {
        description = xray.S("Xray Stone"),
        _doc_items_longdesc = xray.S("An Invisible block"),
        _doc_items_hidden = true,
        tiles = {"xray_stone.png"},
        is_ground_content = true,
        stack_max = 1,
        groups = {pickaxey=1, stone=1, building_block=1, material_stone=1},
        drawtype = "glasslike",
        sunlight_propagates = true,
        light_source = xray.light_level,
        drop = 'mcl_core:granite',
        sounds = mcl_sounds.node_sound_stone_defaults(),
        _mcl_blast_resistance = 6,
        _mcl_hardness = 1.5,
        _mcl_silk_touch_drop = false,
    })
    minetest.register_node("xray:mcl_andesite", {
        description = xray.S("Xray Stone"),
        _doc_items_longdesc = xray.S("An Invisible block"),
        _doc_items_hidden = true,
        tiles = {"xray_stone.png"},
        is_ground_content = true,
        stack_max = 1,
        groups = {pickaxey=1, stone=1, building_block=1, material_stone=1},
        drawtype = "glasslike",
        sunlight_propagates = true,
        light_source = xray.light_level,
        drop = 'mcl_core:andesite',
        sounds = mcl_sounds.node_sound_stone_defaults(),
        _mcl_blast_resistance = 6,
        _mcl_hardness = 1.5,
        _mcl_silk_touch_drop = false,
    })
    minetest.register_node("xray:mcl_diorite", {
        description = xray.S("Xray Stone"),
        _doc_items_longdesc = xray.S("An Invisible block"),
        _doc_items_hidden = true,
        tiles = {"xray_stone.png"},
        is_ground_content = true,
        light_source = xray.light_level,
        stack_max = 1,
        groups = {pickaxey=1, stone=1, building_block=1, material_stone=1},
        drawtype = "glasslike",
        sunlight_propagates = true,
        drop = 'mcl_core:diorite',
        sounds = mcl_sounds.node_sound_stone_defaults(),
        _mcl_blast_resistance = 6,
        _mcl_hardness = 1.5,
        _mcl_silk_touch_drop = false,
    })
    minetest.register_node("xray:mcl_sstone", {
        description = xray.S("Xray Stone"),
        _doc_items_hidden = true,
        _doc_items_longdesc = xray.S("An Invisible block"),
        tiles = {"xray_stone.png"},
        is_ground_content = true,
        light_source = xray.light_level,
        stack_max = 1,
        groups = {pickaxey=1, sandstone=1, normal_sandstone=1, building_block=1, material_stone=1},
        drawtype = "glasslike",
        sunlight_propagates = true,
        drop = 'mcl_core:sandstone',
        sounds = mcl_sounds.node_sound_stone_defaults(),
        _mcl_blast_resistance = 0.8,
        _mcl_hardness = 0.8,
        _mcl_silk_touch_drop = false,
    })
    minetest.register_node("xray:mcl_rsstone", {
        description = xray.S("Xray Stone"),
        _doc_items_hidden = true,
        _doc_items_longdesc = xray.S("An Invisible block"),
        tiles = {"xray_stone.png"},
        is_ground_content = true,
        light_source = xray.light_level,
        stack_max = 1,
        groups = {pickaxey=1, sandstone=1, normal_sandstone=1, building_block=1, material_stone=1},
        drawtype = "glasslike",
        sunlight_propagates = true,
        drop = 'mcl_core:redsandstone',
        sounds = mcl_sounds.node_sound_stone_defaults(),
        _mcl_blast_resistance = 0.8,
        _mcl_hardness = 0.8,
        _mcl_silk_touch_drop = false,
    })
end

-- MCL (5 only)
if xray.gamemode == "MCL5" then
    minetest.register_node("xray:mcl_bstone", {
        description = xray.S("Xray Stone"),
        _doc_items_hidden = true,
        tiles = {"xray_dark.png"},
        light_source = xray.light_level,
        sounds = mcl_sounds.node_sound_stone_defaults(),
        is_ground_content = true,
        stack_max = 1,
        groups = {cracky = 3, pickaxey=2, material_stone=1},
        drawtype = "glasslike",
        sunlight_propagates = true,
        drop = 'mcl_blackstone:blackstone',
        _mcl_blast_resistance = 2,
        _mcl_hardness = 2,
        _mcl_silk_touch_drop = false,
    })
    minetest.register_node("xray:mcl_basalt", {
        description = xray.S("Xray Stone"),
        _doc_items_hidden = true,
        tiles = {"xray_dark.png"},
        light_source = xray.light_level,
        sounds = mcl_sounds.node_sound_stone_defaults(),
        drawtype = "glasslike",
        sunlight_propagates = true,
        is_ground_content = true,
        stack_max = 1,
        groups = {cracky = 3, pickaxey=2, material_stone=1},
        drop = 'mcl_blackstone:basalt',
        _mcl_blast_resistance = 2,
        _mcl_hardness = 2,
        _mcl_silk_touch_drop = false,
    })
    minetest.register_node("xray:mcl_netherrack", {
        description = xray.S("Xray Stone"),
        _doc_items_hidden = true,
        light_source = xray.light_level,
        _doc_items_longdesc = xray.S("An Invisible block"),
        stack_max = 1,
        tiles = {"xray_nether.png"},
        is_ground_content = true,
        groups = {pickaxey=1, building_block=1, material_stone=1},
        drawtype = "glasslike",
        sunlight_propagates = true,
        drop = 'mcl_nether:netherrack',
        sounds = mcl_sounds.node_sound_stone_defaults(),
        _mcl_blast_resistance = 0.4,
        _mcl_hardness = 0.4,
        _mcl_silk_touch_drop = false,
    })
    minetest.register_node("xray:mcl_deepslate", {
        description = xray.S("Xray Stone"),
        _doc_items_longdesc = xray.S("An Invisible block"),
        _doc_items_hidden = true,
        light_source = xray.light_level,
        tiles = { "xray_dark.png" },
        paramtype2 = "facedir",
        is_ground_content = true,
        drawtype = "glasslike",
        sunlight_propagates = true,
        stack_max = 1,
        groups = { pickaxey = 1, stone = 1, building_block = 1, material_stone = 1 },
        drop = "mcl_deepslate:deepslate_cobbled",
        sounds = mcl_sounds.node_sound_stone_defaults(),
        _mcl_blast_resistance = 6,
        _mcl_hardness = 3,
        _mcl_silk_touch_drop = false,
    })
end

if xray.gamemode == "NC" then
    local function register_nc_stone(name, drop)
        local base = minetest.registered_nodes[drop]
        if type(base) ~= "table" then
            error("can't find base node: "..drop)
        end
        minetest.register_node(name, {
            description = xray.S("Xray Stone"),
            tiles = { "xray_stone.png" },
            groups = table.copy(base.groups),
            drop = drop,
            drawtype = "glasslike",
            sunlight_propagates = true,
            legacy_mineral = true,
            light_source = xray.light_level,
            sounds = nodecore.sounds("nc_terrain_stony")
        })
    end
    register_nc_stone("xray:nc_stone", "nc_terrain:stone")
    for i = 1, nodecore.hard_stone_strata do
        register_nc_stone("xray:nc_hard_stone_" .. i, "nc_terrain:hard_stone_" .. i)
    end
end
