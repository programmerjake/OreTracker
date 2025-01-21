
-- Adds an "ore" node to track, only if that node actually is a valid node
orehud.add_ore = function(orename, color)
    assert(type(orename) == "string", "ore name must be a string")
    if not minetest.registered_nodes[orename] then
        minetest.log("action", "[oretracker-orehud] Failed to add '" .. orename .. "' as it is a unregistered node.")
        return
    end
    if color == nil then
        color = orehud.default_ore_color(orename)
    end
    assert(type(color) == "number" and math.floor(color) == color, "ore color must be an integer")
    assert(0 <= color and color <= 0xffffff, "ore color must be an integer in [0, 0xffffff]")
    if orehud.ore_colors[orename] == nil then
        table.insert(orehud.ores, orename)
    end
    orehud.ore_colors[orename] = color
end

orehud.default_ore_colors = {
    { pat = "coal",               color = 0xc8c8c8 },
    { pat = "gas_seep",           color = 0xc8c8c8 },
    { pat = "iron",               color = 0xa65417 },
    { pat = "gold",               color = 0xe9de00 },
    { pat = "mese",               color = 0xffff4b },
    { pat = "diamond",            color = 0x97f1f2 },
    { pat = "quartz",             color = 0xf7f7f9 },
    { pat = "copper",             color = 0xc86400 },
    { pat = "tin",                color = 0xc8c8c8 },
    { pat = "silver",             color = 0xd8e3e3 },
    { pat = "lapis",              color = 0x4b4bc8 },
    { pat = "mithril",            color = 0x002bb9 },
    { pat = "redstone",           color = 0xc81919 },
    { pat = "glowstone",          color = 0xffff4b },
    { pat = "lode",               color = 0xaf644b },
    { pat = "ruby",               color = 0xd42249 },
    { pat = "amethyst",           color = 0xaa3bce },
    { pat = "emerald",            color = 0x44c039 },
    { pat = "glow_ore",           color = 0x9ec8da },
    { pat = "etherium",           color = 0xb2c4ec },
    { pat = "egerum",             color = 0x3c6989 },
    { pat = "februm",             color = 0x6931d0 },
    { pat = "lead",               color = 0xadadb3 },
    { pat = "chromium",           color = 0xd7dbdf },
    { pat = "uranium",            color = 0x01d956 },
    { pat = "zinc",               color = 0x8dc0cc },
    { pat = "sulfur",             color = 0xd8cf01 },
    { pat = "inferium",           color = 0x049955 },
    { pat = "prosperity_essence", color = 0xb2d4d4 },
    { pat = "life_energy",        color = 0x2ff8fd },
    { pat = "moranga",            color = 0x0011e0 },
    { pat = "essence_ore",        color = 0x1dad00 },
    { pat = "baborium",           color = 0xe71d0d },
    { pat = "bauxite",            color = 0xc44325 },
    { pat = "ceramic_sh[ae]rd",   color = 0xb55126 },
    { pat = "pyrite",             color = 0xcdaf51 },
    { pat = "barrel",             color = 0x8c613b },
    { pat = "basket",             color = 0xb6955d },
    { pat = "[:_]stone_chest",    color = 0x3f3f3f },
    { pat = "rune_chest",         color = 0x30363c },
    { pat = "rune_urn",           color = 0x5e656e },
    { pat = "[:_]chest",          color = 0xb18a53 },
    { pat = "[:_]urn",            color = 0xab834a },
    { pat = "debris",             color = 0xaa644b },
}

function orehud.default_ore_color(orename)
    assert(type(orename) == "string", "ore name must be a string")
    for _, color_and_name in ipairs(orehud.default_ore_colors) do
        if string.find(orename, color_and_name.pat) then
            return color_and_name.color
        end
    end
    return 0xffffff
end

-- Adds a waypoint to the given player's HUD, given title and color
orehud.add_pos = function(pname, pos, title, color)
    if not title then
        title = minetest.pos_to_string(pos)
    end
    local player = minetest.get_player_by_name(pname)
    local wps = orehud.store[pname] or {}
    if not color then
        color = 0xffffff
    end
    table.insert(wps,
        player:hud_add({
            hud_elem_type = "waypoint",
            name = title,
            text = "m",
            number = color,
            world_pos = pos
        })
    )
    orehud.store[pname] = wps
end

-- Clears all waypoints from the given player's HUD
orehud.clear_pos = function(pname)
    local player = minetest.get_player_by_name(pname)
    local wps = orehud.store[pname] or {}
    for i, v in ipairs(wps) do
        player:hud_remove(v)
    end
    orehud.store[pname] = {}
end