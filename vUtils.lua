--[[

    [vUtils]
    by -v
    Discord @viNclinedv
    
]]--

local vUtils_VERSION = "1.3"
local vUtils_LUA_NAME = "vUtils.lua"
local vUtils_REPO_BASE_URL = "https://raw.githubusercontent.com/viNclinedv/vUtils/main/"
local vUtils_REPO_SCRIPT_PATH = vUtils_REPO_BASE_URL .. vUtils_LUA_NAME
local skipUpdate = false

local function fetch_url(url)
        local handle = io.popen("curl -s -H 'Cache-Control: no-cache' " .. url)
        if not handle then
            print("Failed to fetch URL: " .. url)
            return nil
        end
        local content = handle:read("*a")
        handle:close()
        return content
end
local function replace_current_file_with_latest_version(latest_version_script)
    if skipUpdate == true then print("Skipping Update for vUtils") end

    if skipUpdate == false then
        local resources_path = cheat:get_resource_path()
        local current_file_path = resources_path:gsub("resources$", "lua\\lib\\" .. vUtils_LUA_NAME)
        local file, errorMessage = io.open(current_file_path, "w")
        if not file then
            print("Failed to open the current file for writing. Error: ", errorMessage)
            return false
        end
        file:write(latest_version_script)
        file:close()
        return true
    end
end
local function check_for_update()
    if skipUpdate == true then print("Skipping Update for vUtils") end

    if skipUpdate == false then
        local latest_script_content = fetch_url(vUtils_REPO_SCRIPT_PATH)
        if not latest_script_content then
            print("Failed to fetch [vUtils] for update check.")
            return
        end
        local remote_version = latest_script_content:match('local vUtils_VERSION = "(%d+%.%d+)"')
        if not remote_version then
            print("Failed to extract version from the latest [vUtils] content.")
            return
        end
        print("Local [vUtils] version: " .. vUtils_VERSION .. ", Remote [vUtils] version: " .. remote_version)
        if remote_version and remote_version > vUtils_VERSION then
            print("Updating from version " .. vUtils_VERSION .. " to " .. remote_version)
            if replace_current_file_with_latest_version(latest_script_content) then
                print("Update successful. Please reload [vUtils].")
            else
                print("Failed to update [vUtils].")
            end
        else
            print("You are running the latest version of [vUtils].")
        end
    end
end
check_for_update()



local vUtils = {
    Combo_key = 1,
    Clear_key = 3,
    Harass_key = 4,
    Flee_key = 5,
    debug = nil,
    currentColor = {},

}

function vUtils.menu() 
    local Script_name = "vUtils"
    local test_navigation = menu.get_main_window():push_navigation(Script_name, 100000)
    local my_nav = menu.get_main_window():find_navigation(Script_name)

    local draw_sect = my_nav:add_section("ColorShift Selection")
    local color_config = g_config:add_int(0, "ColorShift Selection")
    

    local color_select = draw_sect:select("ColorShift Selection", color_config, {
        "Rainbow", --index 0
        "Flame",--index 1
        "Ocean",--index 2
        "Nature",--index 3
      })

      function vUtils.updateCurrentColor()
        local colorIndex = color_config:get_int() -- Assuming get_int() fetches the current selection index
        if colorIndex == 0 then
            vUtils.currentColor = vUtils.RainbowColor()
        elseif colorIndex == 1 then
            vUtils.currentColor = vUtils.FlameColor()
        elseif colorIndex == 2 then
            vUtils.currentColor = vUtils.OceanColor()
        elseif colorIndex == 3 then
            vUtils.currentColor = vUtils.NatureColor()
        else
            -- Default case, could log an error or set a default color
            vUtils.currentColor = {r = 255, g = 255, b = 255, a = 255} -- Setting to white as a default
        end
    end

    -- It's important to initially update the color to reflect the default or initial selection
    vUtils.updateCurrentColor()

end






--Control Print Statements
function vUtils.Prints(str)
    if vUtils.debug == 1 then print(str) end
end




--RGB ColorShift
function vUtils.RainbowColor()
    local time = g_time
    local frequency = 1.2

    local r = math.sin(frequency * time + 0) * 127 + 128
    local g = math.sin(frequency * time + 2 * math.pi / 3) * 127 + 128
    local b = math.sin(frequency * time + 4 * math.pi / 3) * 127 + 128

    return {r = math.floor(r), g = math.floor(g), b = math.floor(b), a = 255}
end

--Flame ColorShift
function vUtils.FlameColor()
    local time = g_time
    local speed = 1.8
    local adjustedTime = time * speed
    math.randomseed(time)

    local colors = {
        {255, 69, 0, 255}, -- Fiery Sunset
        {255, 165, 0, 230}, -- Golden Blaze
        {178, 34, 34, 200}, -- Crimson Ember
        {105, 105, 105, 150}, -- Smoky Slate
        {255, 140, 0, 210}, -- Amber Burst
        {255, 99, 71, 190} -- Coral Flame
    }

    local colorChangeRate = 6
    local colorIndex = math.floor((adjustedTime % colorChangeRate) + 1)
    local nextColorIndex = (colorIndex % #colors) + 1

    local blendFactor = adjustedTime % 1
    local r = colors[colorIndex][1] * (1 - blendFactor) + colors[nextColorIndex][1] * blendFactor
    local g = colors[colorIndex][2] * (1 - blendFactor) + colors[nextColorIndex][2] * blendFactor
    local b = colors[colorIndex][3] * (1 - blendFactor) + colors[nextColorIndex][3] * blendFactor
    local a = colors[colorIndex][4] * (1 - blendFactor) + colors[nextColorIndex][4] * blendFactor

    return {r = math.floor(r), g = math.floor(g), b = math.floor(b), a = math.floor(a)}
end


--Ocean Color Shift
function vUtils.OceanColor()
    local time = g_time
    local frequency = 1.0
    
    local colors = {
        {0, 105, 148, 255}, -- Ocean Depths
        {11, 96, 176, 255}, -- Midnight Wave
        {240, 237, 207, 255}, -- Ivory Mist
        {53, 89, 224, 255}, -- Sapphire Dream
        {38, 80, 115, 255}, -- Dusk Blue
        {241, 240, 232, 255}, -- Pearl Whisper
        {23, 107, 135, 255}, -- Azure Breeze
        {56, 135, 190, 255} -- Cerulean Sky
    }
    
    local colorNoise = math.sin(frequency * time) * 0.5 + 0.5
    
    local colorIndex = math.floor(colorNoise * (#colors - 1)) + 1
    local nextColorIndex = (colorIndex % #colors) + 1
    local blendFactor = colorNoise * (#colors - 1) - math.floor(colorNoise * (#colors - 1))
    
    local r = colors[colorIndex][1] * (1 - blendFactor) + colors[nextColorIndex][1] * blendFactor
    local g = colors[colorIndex][2] * (1 - blendFactor) + colors[nextColorIndex][2] * blendFactor
    local b = colors[colorIndex][3] * (1 - blendFactor) + colors[nextColorIndex][3] * blendFactor
    local a = colors[colorIndex][4] * (1 - blendFactor) + colors[nextColorIndex][4] * blendFactor
    
    return {r = math.floor(r), g = math.floor(g), b = math.floor(b), a = math.floor(a)}
end

--Nature ColorShift
function vUtils.NatureColor()
    local time = g_time
    local frequency = 1.0
    
    local colors = {
        {255, 192, 203, 255}, -- Pink
        {124, 252, 0, 255}, -- Lime Green
        {17, 112, 20, 255}, --Light Emerald
        {255, 255, 0, 255}, -- Yellow
        {255, 160, 122, 255}, -- Light Salmon
    }
    
    local colorNoise = math.sin(frequency * time) * 0.5 + 0.5
    
    local colorIndex = math.floor(colorNoise * (#colors - 1)) + 1
    local nextColorIndex = (colorIndex % #colors) + 1
    local blendFactor = colorNoise * (#colors - 1) - math.floor(colorNoise * (#colors - 1))
    
    local r = colors[colorIndex][1] * (1 - blendFactor) + colors[nextColorIndex][1] * blendFactor
    local g = colors[colorIndex][2] * (1 - blendFactor) + colors[nextColorIndex][2] * blendFactor
    local b = colors[colorIndex][3] * (1 - blendFactor) + colors[nextColorIndex][3] * blendFactor
    local a = colors[colorIndex][4] * (1 - blendFactor) + colors[nextColorIndex][4] * blendFactor
    
    return {r = math.floor(r), g = math.floor(g), b = math.floor(b), a = math.floor(a)}
end


function vUtils.createEnemiesList()
    return features.entity_list:get_enemies()
end

function vUtils.createEnemyMinionsList()
    return features.entity_list:get_enemy_minions()
end

function vUtils.getTargetMr(target)
    return 100 / (target.total_mr + 100)
end

function vUtils.getTargetArmor(target)
    return 100 / (target.total_armor + 100)
end

function vUtils.getDistance(from, to)
    return from:dist_to(to)
end

function vUtils.refreshSpells(
    spells)
    for spellKey, spellData in pairs(spells) do
        if type(spellData) == "table" and spellData.spellSlot then
            local spellSlot = g_local:get_spell_book():get_spell_slot(spellData.spellSlot)
            if spellSlot then
                spells[spellKey].Level = spellSlot.level
                spells[spellKey].spell = spellSlot
            end
        end
    end
end

function vUtils.isSpellReady(spells, spellKey)
    return spells[spellKey].spell:is_ready()
end

function vUtils.haveEnoughMana(spells, spellKey)
    local spell = spells[spellKey]
    local manaCost = spell.manaCost

    if type(manaCost) == "table" then
        local level = spell.Level or spell.spell.level
        manaCost = manaCost[level]
    end
    if type(manaCost) == "function" then
        manaCost = manaCost()
    end
    if type(manaCost) == "number" then
        return g_local.mana >= manaCost
    else
        return false
    end
end

function vUtils.canCast(spells, spellKey)
    vUtils.refreshSpells(spells)
    return vUtils.isSpellReady(spells, spellKey) and vUtils.haveEnoughMana(spells, spellKey)
end

function vUtils.isSpellInRange(spells, spellKey, target)
    return target.position:dist_to(g_local.position) <= spells[spellKey].Range
end

function vUtils.MinionInLine(spells, spellKey, position)
    return features.prediction:minion_in_line(g_local.position, position, spells[spellKey].Width)
end

function vUtils.predPosition(spells, spellKey, target)
    local spell = spells[spellKey]
    return features.prediction:predict(
        target.index,
        spell.Range,
        spell.Speed,
        spell.Width,
        spell.CastTime,
        g_local.position
    )
end

-- # Enemies Around Target
function vUtils.NumEnemiesInRangeTarget(range)
    local target = features.target_selector:get_default_target()
    local numAround = 0
    for _, entity in pairs(features.entity_list:get_enemies()) do
        if
            entity ~= nil and not entity:is_invisible() and entity:is_alive() and
                entity.position:dist_to(target.position) <= range
         then
            numAround = numAround + 1
        end
    end
    return numAround
end

-- # Enemies In Range
function vUtils.NumEnemiesInRange(range)
    local numAround = 0
    for _,entity in pairs(features.entity_list:get_enemies()) do
        if  entity ~= nil and not entity:is_invisible() and entity:is_alive() and entity.position:dist_to(g_local.position) <= range  then
            numAround = numAround + 1
        end
    end
    return numAround
end

-- # Enemies Near Given Position
function vUtils.enemiesNearPosition(range, position)
    local numAround = 0
    for _, entity in pairs(features.entity_list:get_enemies()) do
        if entity ~= nil and entity.position:dist_to(position) <= range then
            numAround = numAround + 1
        end
    end
    return numAround
end

-- # Allies Around Local   
function vUtils.NumAlliesInRange(range)
    local numAround = 0
    for _, ally in pairs(features.entity_list:get_allies()) do
        if ally ~= nil and ally:is_alive() and ally.position:dist_to(g_local.position) <= range then
            numAround = numAround + 1
        end
    end
    return numAround
end


function vUtils.Vec3_Rotate(center, point, angle)
    angle = angle * (math.pi/180)
    local rotatedX = math.cos(angle) * (point.x - center.x) - math.sin(angle) * (point.z - center.z) + center.x
    local rotatedZ = math.sin(angle) * (point.x - center.x) + math.cos(angle) * (point.z - center.z) + center.z
    return vec3:new(rotatedX, point.y ,rotatedZ)
end

function vUtils.Rectangle_Polygon(start_pos, target_pos, width, range)
    local pol = {}  
    local temp = vUtils.Vec3_Extend(start_pos,target_pos, width/2)
    pol[1] = vUtils.Vec3_Rotate(start_pos,temp,90)
    pol[2] = vUtils.Vec3_Rotate(start_pos,temp,-90)
    temp = vUtils.Vec3_Extend(target_pos,start_pos, range)
    local temp2 = vUtils.Vec3_Extend(temp,target_pos, width/2)
    pol[3] = vUtils.Vec3_Rotate(temp,temp2,90)
    pol[4] = vUtils.Vec3_Rotate(temp,temp2,-90)
    return pol
end

function vUtils.Vec3_Extend(a,b, dist) 
    local distance = a:dist_to(b) 
    local offset = dist / distance 
    local dir = vec3:new((a.x - b.x), b.y, (a.z - b.z)) 
    local newPos = vec3:new((a.x + dir.x*offset), b.y, (a.z + dir.z*offset)) 
    return newPos end

function vUtils.isInsidePolygon(point, polygon)
    local oddNodes = false
    local j = #polygon
    for i = 1, j do
        if (polygon[i].z < point.z and polygon[j].z >= point.z or polygon[j].z < point.z and polygon[i].z >= point.z) then
            if (polygon[i].x + ( point.z - polygon[i].z ) / (polygon[j].z - polygon[i].z) * (polygon[j].x - polygon[i].x) < point.x) then
                oddNodes = not oddNodes;
            end
        end
        j = i;
    end
    return oddNodes
end

function vUtils.getEnimiesHitBy(poly)
    local n = 0
    for _,entity in pairs(features.entity_list:get_enemies()) do
        if entity ~= nil and not entity:is_invisible() and entity:is_alive() then
            local inside = vUtils.isInsidePolygon(entity.position, poly)
            if inside then
                n = n + 1
            end
        end
    end
    return n
end



return vUtils