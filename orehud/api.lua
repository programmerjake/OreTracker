
-- Adds an "ore" node to track, only if that node actually is a valid node
orehud.add_ore = function(orename)
    if minetest.registered_nodes[orename] then
        if orehud.ores_set[orename] == nil then
            orehud.ores_set[orename] = true
            table.insert(orehud.ores, orename)
        end
    else
        minetest.log("action", "[oretracker-orehud] Failed to add '"..orename.."' as it is a unregistered node.")
    end
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