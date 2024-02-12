--[[

    [vUtils]
    by -v
    Discord @viNclinedv
    
]]--

local vUtils_VERSION = "1.0"
local vUtils_LUA_NAME = "vUtils.lua"
local vUtils_REPO_BASE_URL = "https://raw.githubusercontent.com/viNclinedv/vUtils/main/"
local vUtils_REPO_SCRIPT_PATH = vUtils_REPO_BASE_URL .. vUtils_LUA_NAME

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
local function check_for_update()
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
    print("Local version: " .. vUtils_VERSION .. ", Remote version: " .. remote_version)
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
check_for_update()

local vUtils = {
    Combo_key = 1,
    Clear_key = 3,
    Harass_key = 4,
    Flee_key = 5,
    debug = nil,
}

--Control Print Statements
function vUtils.Prints(str)
    if vUtils.debug == 1 then print(str) end
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

return vUtils
