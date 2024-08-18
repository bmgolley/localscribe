
---@diagnostic disable: duplicate-doc-alias
local last_player_color  ---@type PlayerColor
local unitTag = 'uuid_'..unitData.uuid  ---@type string
local unitModelTags = {unitTag, 'lsModel'}  ---@type string[]
local attachedTag = unitTag..'_attached'
local isAttachingUnit = false

---@alias BaseSize { x: integer, z: integer }

---Is Num0 key held
local modifierKeyHeld = false

local scriptingFunctions

-- measuringCircles = {}
isCurrentlyCheckingCoherency = false
local hasBuiltUI = false
-- local previousHighlightColor = nil
local MM_TO_INCH = 0.0393701
local MEASURING_RING_Y_OFFSET = 0.17
local VALID_BASE_SIZES_IN_MM = {
    {x = 25, z = 25},
    {x = 28, z = 28},
    {x = 30, z = 30},
    {x = 32, z = 32},
    {x = 40, z = 40},
    {x = 50, z = 50},
    {x = 55, z = 55},
    {x = 60, z = 60},
    {x = 65, z = 65},
    {x = 80, z = 80},
    {x = 90, z = 90},
    {x = 100, z = 100},
    {x = 130, z = 130},
    {x = 160, z = 160},
    {x = 25, z = 75},
    {x = 75, z = 25},
    {x = 35.5, z = 60},
    {x = 60, z = 35.5},
    {x = 40, z = 95},
    {x = 95, z = 40},
    {x = 52, z = 90},
    {x = 90, z = 52},
    {x = 70, z = 105},
    {x = 105, z = 70},
    {x = 92, z = 120},
    {x = 120, z = 92},
    {x = 95, z = 150},
    {x = 150, z = 95},
    {x = 109, z = 170},
    {x = 170, z = 109}
}
---@enum WoundColor
local WOUNDCOLOR = {
    healthy = '00ff33', --00ff16
    belowStarting = '80ff99', --8bff00 bbff00
    -- belowStarting = '8bff00',
    belowHalf = 'ffee00', --ffca00
    -- belowHalf = 'ffca00',
    damaged = 'ffaa00', --ff7900
    -- damaged = 'ff7900',
    dead = 'ff0000'
}
local dataCardHeight = 300
-- starting to calculate height of the dataCard: keywords and each section is
-- 40px by default (will add row heights later), spacing adds 30 between each,
-- and I want 10 extra pixels at the bottom for a total of 60+30+40+30+40+30+40+10 = 260 (+10 for unknown reason) (70 for keywords)
local uiTemplates = {
    abilities = [[<Row color="${rowParity}" dontUseTableRowBackground="true" preferredHeight="80">
                    <Cell><Text resizeTextForBestFit="true" resizeTextMinSize="6" resizeTextMaxSize="20" preferredHeight="20" fontStyle="Bold" alignment="MiddleCenter">${name}</Text></Cell>
                    <Cell><Text fontStyle="Normal" resizeTextForBestFit="true" resizeTextMinSize="6" resizeTextMaxSize="20" alignment="MiddleCenter">${desc}</Text></Cell>
                </Row>]],
    models10e = [[ <Row color="${rowParity}" dontUseTableRowBackground="true" preferredHeight="60">
                    <Cell><Text resizeTextForBestFit="true" resizeTextMinSize="6" resizeTextMaxSize="20" preferredHeight="20" fontStyle="Bold" alignment="MiddleCenter">${name}</Text></Cell>
                    <Cell><Text fontStyle="Normal" fontSize="18" alignment="MiddleCenter">${m}</Text></Cell>
                    <Cell><Text fontStyle="Normal" fontSize="18" alignment="MiddleCenter">${t}</Text></Cell>
                    <Cell><Text fontStyle="Normal" fontSize="18" alignment="MiddleCenter">${sv}</Text></Cell>
                    <Cell><Text fontStyle="Normal" fontSize="18" alignment="MiddleCenter">${w}</Text></Cell>
                    <Cell><Text fontStyle="Normal" fontSize="18" alignment="MiddleCenter">${ld}</Text></Cell>
                    <Cell><Text fontStyle="Normal" fontSize="18" alignment="MiddleCenter">${oc}</Text></Cell>
                </Row>]],
    weapons10e = [[ <Row color="${rowParity}" dontUseTableRowBackground="true" preferredHeight="60">
                    <Cell><Text resizeTextForBestFit="true" resizeTextMinSize="6" resizeTextMaxSize="20" preferredHeight="20" fontStyle="Bold" alignment="MiddleCenter">${name}</Text></Cell>
                    <Cell><Text fontStyle="Normal" resizeTextForBestFit="true" resizeTextMinSize="6" resizeTextMaxSize="20" alignment="MiddleCenter">${range}</Text></Cell>
                    <Cell><Text fontStyle="Normal" fontSize="18" alignment="MiddleCenter">${a}</Text></Cell>
                    <Cell><Text fontStyle="Normal" fontSize="18" alignment="MiddleCenter">${bsws}</Text></Cell>
                    <Cell><Text fontStyle="Normal" fontSize="18" alignment="MiddleCenter">${s}</Text></Cell>
                    <Cell><Text fontStyle="Normal" fontSize="18" alignment="MiddleCenter">${ap}</Text></Cell>
                    <Cell><Text fontStyle="Normal" fontSize="18" alignment="MiddleCenter">${d}</Text></Cell>
                    <Cell><Text fontStyle="Normal" resizeTextForBestFit="true" resizeTextMinSize="6" resizeTextMaxSize="20" alignment="MiddleCenter">${abilities}</Text></Cell>
                </Row>]],
    agenda = [[ <HorizontalLayout childForceExpandWidth="false" childForceExpandHeight="false" childAlignment="MiddleLeft">
                    <Text fontStyle="Normal" fontSize="24" alignment="MiddleCenter" flexibleWidth="1">${counterName}</Text>
                    <HorizontalLayout childForceExpandWidth="false" childForceExpandHeight="false" childAlignment="MiddleLeft" spacing="5">
                        <Button transition="None" preferredHeight="24" preferredWidth="24" padding="3 3 3 3" resizeTextForBestFit="true" textAlignment="MiddleCenter" onClick="${guid}/decrementTallyCounter(${counterName})">-</Button>
                        <Text fontStyle="Bold" fontSize="26" color="#000000" id="${counterID}">${counterValue}</Text>
                        <Button transition="None" preferredHeight="24" preferredWidth="24" padding="3 3 3 3" resizeTextForBestFit="true" textAlignment="MiddleCenter" onClick="${guid}/incrementTallyCounter(${counterName})">+</Button>
                    </HorizontalLayout>
                </HorizontalLayout>]],
    -- this is here and not in xml because we have to provide the guid, otherwise it will try and run on Global
    buttons = [[<Button padding="3 3 3 3" preferredHeight="20" preferredWidth="${width}" color="#BB2222" onClick="${guid}/highlightUnit(Red)"></Button>
    <Button padding="3 3 3 3" preferredHeight="20" preferredWidth="${width}" color="#22BB22" onClick="${guid}/highlightUnit(Green)"></Button>
    <Button padding="3 3 3 3" preferredHeight="20" preferredWidth="${width}" color="#2222BB" onClick="${guid}/highlightUnit(Blue)"></Button>
    <Button padding="3 3 3 3" preferredHeight="20" preferredWidth="${width}" color="#BB22BB" onClick="${guid}/highlightUnit(Purple)"></Button>
    <Button padding="3 3 3 3" preferredHeight="20" preferredWidth="${width}" color="#DDDD22" onClick="${guid}/highlightUnit(Yellow)"></Button>
    <Button padding="3 3 3 3" preferredHeight="20" preferredWidth="${width}" color="#FFFFFF" onClick="${guid}/highlightUnit(White)"></Button>
    <Button padding="3 3 3 3" preferredHeight="20" preferredWidth="${width}" color="#DD6633" onClick="${guid}/highlightUnit(Orange)"></Button>
    <Button padding="3 3 3 3" preferredHeight="20" preferredWidth="${width}" color="#29D9D9" onClick="${guid}/highlightUnit(Teal)"></Button>
    <Button padding="3 3 3 3" preferredHeight="20" preferredWidth="${width}" color="#DD77CC" onClick="${guid}/highlightUnit(Pink)"></Button>
    <Button padding="3 3 3 3" preferredHeight="20" preferredWidth="${width}" color="#BBBBBB" onClick="${guid}/highlightUnit"></Button>]] --unhighlightUnit
}
local HIGHLIGHTCOLORS = {'Green', 'Blue', 'Purple', 'Yellow', 'White', 'Orange', 'Teal', 'Pink'}  ---@type PlayerColor[]
local idxHighlightColor = 0  ---@type integer
local AGENDA_MANAGER_TAG_PATTERN = 'am_(.+)'
local crusadeCardData = {
    toggles = {
        ccBlooded = false,
        ccBattleHardened = false,
        ccHeroic = false,
        ccLegendary = false
    },
    fields = {
        ccUnitName = '',
        ccBattlefieldRole = '',
        ccCrusadeFaction = '',
        ccSelectableKeywords = '',
        ccUnitType = '',
        ccEquipment = '',
        ccPsychicPowers = '',
        ccWarlordTrait = '',
        ccRelic = '',
        ccOtherUpgrades = '',
        ccBattleHonors = '',
        ccBattleScars = ''
    },
    counters= {
        pl = 0,
        xp = 0,
        cl = 0,
        totalKills = 0,
        played = 0,
        survived = 0
    }
}


---@diagnostic disable: duplicate-doc-field, duplicate-set-field
---@class TableObject<T>: { [integer]: T }
local TableObject = {}
---@generic T
---@param o T[]?
---@return TableObject<T>
function TableObject:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end
TableObject.concat = table.concat
TableObject.insert = table.insert
TableObject.remove = table.remove
TableObject.sort = table.sort
---@return integer
function TableObject:len()
    local i = 0
    for _ in pairs(self) do
        i = i + 1
    end
    return i
end
function TableObject:find(obj)
    for i, value in ipairs(self) do
        if value == obj then
            return i
        end
    end
    return -1
end

---@generic K, V
---@param self TableObject<K, V>
---@param obj any
---@return K?
function TableObject:findkey(obj)
    for key, value in pairs(self) do
        if value == obj then
            return key
        end
    end
    return nil
end

function TableObject:contains(obj)
    return self:find(obj) > 0
end
---@param ... any[]
function TableObject:extend(...)
    for _, obj in ipairs(...) do
        self:insert(obj)
    end
end
function TableObject:copy()
    function clone(orig)
        local copy
        if type(orig) == 'table' then
            copy = {}
            for orig_key, orig_value in next, orig, nil do
                copy[clone(orig_key)] = clone(orig_value)
            end
            setmetatable(copy, getmetatable(orig))
        else -- number, string, boolean, etc
            copy = orig
        end
        return copy
    end
    new = clone(self)
    return new
end
---@diagnostic enable: duplicate-doc-field, duplicate-set-field


--[[ EVENT HANDLERS ]]--

function onLoad(savedState)
    if not self.hasTag("leaderModel") then return end -- prevents firing on objects we don't want firing

    local hasLoaded = self.getVar("hasLoaded")
    if hasLoaded == nil or not hasLoaded then
        local decodedState = savedState == nil and nil or JSON.decode(savedState)

        if decodedState ~= nil and loadDecodedState ~= nil then
            loadDecodedState(decodedState)
        elseif loadDefaultValues ~= nil then
            loadDefaultValues()
        end

        setContextMenuItemsForUnit()

        --Wait.frames(function () buildUI() end, 2)

        for _, model in ipairs(getObjectsWithTag(unitTag)) do
            model.setVar("hasLoaded", true)
        end
    end
end

function onSave()
    if not self.hasTag('leaderModel') then return end -- prevents firing on objects we don't want firing
    if getCrusadeCardSaveData ~= nil then
        return JSON.encode(getCrusadeCardSaveData())
    end
end

---@param index integer
---@param player_color PlayerColor
function onScriptingButtonDown(index, player_color)
    if not self.hasTag('leaderModel') then return end -- prevents firing on objects we don't want firing
    if index == 10 then
        modifierKeyHeld = true
        return
    end
    local player = Player[player_color]  ---@type Player
    local hoveredObject = player.getHoverObject()

    -- if the hovered object has a matching unitID, then it is part of this model's unit and thus is a valid target
    local isHoveringValidTarget = hoveredObject and hoveredObject.hasTag('lsModel') and hoveredObject.hasTag(unitTag)

    if isHoveringValidTarget then
        local is_secondary = modifierKeyHeld and 2 or 1
        scriptingFunctions[index][is_secondary](player_color, hoveredObject)
    end
    -- if isHoveringValidTarget then scriptingFunctions[index](playerColor, hoveredObject, player) end
end

---@param index integer
---@param player_color PlayerColor
function onScriptingButtonUp(index, player_color)
    if not self.hasTag('leaderModel') then return end -- prevents firing on objects we don't want firing
    if index == 10 then
        modifierKeyHeld = false
    end
end


---@param player_color PlayerColor
---@param dropped_object object
function onObjectDrop(player_color, dropped_object)
    if not self.hasTag("leaderModel") then return end -- prevents firing on objects we don't want firing
    if isCurrentlyCheckingCoherency and
            dropped_object ~= nil and
            unitData ~= nil and
            dropped_object.hasTag(unitTag) then
        dropped_object.setLock(true)
        -- wait a frame for locking to cancel momentum
        Wait.frames(function ()
            dropped_object.setLock(false)
            highlightCoherency()
        end, 1)
    end
end

function onObjectRotate(object, spin, flip, playerColor, oldSpin, oldFlip)
    if not self.hasTag("leaderModel") then return end -- prevents firing on objects we don't want firing
    if isCurrentlyCheckingCoherency and
        flip ~= oldFlip and  -- update on model flip
        object.hasTag(unitTag) then
        -- wait for a bit, otherwise the model will still be considered face down when its flipped face up and vice versa
        Wait.time(|| highlightCoherency(), 0.3)
    end
end

---@param player player
---@param action integer
---@param targets object[]
function onPlayerAction(player, action, targets)
    if not self.hasTag("leaderModel") then return end -- prevents firing on objects we don't want firing

    if action == Player.Action.Paste then
        for _, object in ipairs(targets) do
            if object.hasTag(unitTag) and object.hasTag("leaderModel") then
                object.setLuaScript("")
                object.removeTag("leaderModel")
            end
        end
    elseif action == Player.Action.Delete then
        for _, object in ipairs(targets) do
            if object == self then
                local modelsInUnit = getObjectsWithTag(unitTag)
                local modelsInUnitNotBeingDeleted = filter(modelsInUnit, |model| not includes(targets, model))
                if #modelsInUnitNotBeingDeleted > 1 then
                    local newLeader = modelsInUnitNotBeingDeleted[1]
                    updateEventHandlers(newLeader.getGUID())
                    Wait.frames(function ()
                        newLeader.setLuaScript(self.getLuaScript())
                        newLeader.UI.setXml(self.UI.getXml())
                        newLeader.addTag("leaderModel")
                    end, 2)
                    if loadCrusadeCard ~= nil then
                        Wait.frames(|| newLeader.call("loadCrusadeCard", crusadeCardData), 2)
                    end
                    self.removeTag("leaderModel")
                end
            end
        end
    elseif action == Player.Action.Select then
        success, result = pcall(attachUnit, player.color, targets[#targets])
        if not success then
            isAttachingUnit = false
            error(result)
        end
    end
end

function onObjectSpawn(object)
    if not self.hasTag("leaderModel") then return end -- prevents firing on objects we don't want firing
    if object ~= self and object.hasTag("leaderModel") and object.hasTag(unitTag) then
        object.removeTag("leaderModel")
        object.setLuaScript("")
    end
end

---@param player_color PlayerColor
---@param picked_up_object object
function onObjectPickUp(player_color, picked_up_object)
    if player_color ~= last_player_color or
        not self.hasTag("leaderModel") or
        not isAttachingUnit then return
    else
        success, result = pcall(attachUnit, player_color, picked_up_object)
        if not success then
            isAttachingUnit = false
            error(result)
        end
    end
end


--[[ SCRIPTING FUNCTION DEFINITIONS ]]--

---Increase/decrease model wound count by given amount.
---@param mod integer Modifier
---@param target Object Target model
---@param absolute? bool
function changeModelWoundCount(mod, target, absolute)
    local name = target.getName()
    local prevWoundsStr, maxWoundsStr = name:match('(%d+)/(%d+)')
    if not prevWoundsStr then return end
    local prevWounds = tonumber(prevWoundsStr)  --[[@as integer]]
    local maxWounds = tonumber(maxWoundsStr)  --[[@as integer]]
    local newWounds  ---@type integer
    if not absolute then
        newWounds = prevWounds + mod
    elseif mod == -1 then
        newWounds = maxWounds
    else
        newWounds = mod
    end
    newWounds = math.max(math.min(newWounds, maxWounds), 0)
    local newName = name:gsub('%d+/%d+', newWounds..'/'..maxWounds, 1)
    local tooltip  ---@type string
    local newColor  ---@type WoundColor
    if newWounds == 0 then
        newColor = WOUNDCOLOR.dead
        if maxWounds > 1 then
            tooltip = target.getDescription()
            tooltip = tooltip:gsub('%['..WOUNDCOLOR.damaged..'%]([BW]S:%s*%d%+)%[%-%]', '%1')
            target.setDescription(tooltip)
        end
        if isCurrentlyCheckingCoherency and prevWounds then
            Wait.time(|| highlightCoherency(), 0.3)
        end
    else
        local damaged ---@type boolean
        local woundFraction = newWounds/maxWounds
        if maxWounds > 1 then
            local damagedCutoffStr  ---@type string
            for _, ability in ipairs(unitData.abilities) do
                if ability.name == 'Core' then
                    damagedCutoffStr = ability.desc:match('Damaged: %d+%-(%d+)')
                    break
                end
            end
            if damagedCutoffStr ~= nil then
                local damagedCutoff = tonumber(damagedCutoffStr)  --[[@as integer]]
                damaged = newWounds <= damagedCutoff
                tooltip = target.getDescription()
                if damaged and (prevWounds > damagedCutoff or prevWounds == 0) then
                    tooltip = tooltip:gsub('[BW]S:%s*%d%+', '['..WOUNDCOLOR.damaged..']%1[-]')
                elseif not damaged and prevWounds <= damagedCutoff then
                    tooltip = tooltip:gsub('%['..WOUNDCOLOR.damaged..'%]([BW]S:%s*%d%+)%[%-%]', '%1')
                end
                target.setDescription(tooltip)
            else
                damaged = newWounds == 1 or woundFraction < 0.25
            end
        else
            damaged = false
        end

        if damaged then
            newColor = WOUNDCOLOR.damaged
        elseif woundFraction < 0.5 then
            newColor = WOUNDCOLOR.belowHalf
        elseif newWounds < maxWounds then
            newColor = WOUNDCOLOR.belowStarting
        else
            newColor = WOUNDCOLOR.healthy
        end
        if isCurrentlyCheckingCoherency and not prevWounds then
            Wait.time(|| highlightCoherency(), 0.3)
        end
    end
    newName = newName:gsub("^%[%w+%]", '['..newColor..']', 1)
    target.setName(newName)
end

---@param wounds integer
function setUnitWounds(wounds)
    local coherency_checking = isCurrentlyCheckingCoherency
    isCurrentlyCheckingCoherency = false
    for _, model in ipairs(getObjectsWithAllTags(unitModelTags)) do
        changeModelWoundCount(wounds, model, true)
    end
    isCurrentlyCheckingCoherency = coherency_checking
    if isCurrentlyCheckingCoherency then
        Wait.time(|| highlightCoherency(), 0.3)
    end
end


---@param player_color PlayerColor
---@param target object
function toggleRectangularMeasuring(player_color, target)
    local isRectangular = target.hasTag("rectangularMeasuring")

    if not isRectangular then
        target.addTag("rectangularMeasuring")
        broadcastToColor("Model set to rectangular measuring", player_color, player_color)
    else
        target.removeTag("rectangularMeasuring")
        broadcastToColor("Model set to round measuring", player_color, player_color)
    end
    changeMeasurementCircle(0, target, nil, true)
end

---@param reversed? bool
function cycleColor(reversed)
    local mod = reversed and -1 or 1
    idxHighlightColor = idxHighlightColor + mod
    if idxHighlightColor > #HIGHLIGHTCOLORS then
        idxHighlightColor = 0
    elseif idxHighlightColor < 0 then
        idxHighlightColor = #HIGHLIGHTCOLORS
    end
    if idxHighlightColor > 0 then
        local highlightColor = HIGHLIGHTCOLORS[idxHighlightColor]
        highlightUnit(nil, highlightColor)
        highlightAttachedModels(highlightColor)
    else
        highlightUnit()
        highlightAttachedModels()
    end
end


---@param player_color PlayerColor
---@param target object
function attachUnit(player_color, target)
    if player_color ~= last_player_color or
        not self.hasTag('leaderModel') or
        not isAttachingUnit then return
    elseif not target.hasTag('lsModel') then
        broadcastToColor('Invalid selection', player_color, player_color)
        isAttachingUnit = false
        return
    elseif target.hasTag(unitTag) then
        broadcastToColor('Cannot attach a unit to itself', player_color, player_color)
        isAttachingUnit = false
        return
    end
    local leaderModel = target.hasTag('leaderModel') and target or getModelUnitLeader(target)
    local targetData = leaderModel.getTable('unitData')  ---@type UnitData
    local otherUUID = 'uuid_'..targetData.uuid
    local modelsInUnit = getObjectsWithAllTags(unitModelTags)
    local isSingleModel = unitData.isSingleModel or (#modelsInUnit == 1)
    local otherModels = getObjectsWithAllTags{otherUUID, 'lsModel'}
    local isSingleAttached = targetData.isSingleModel or (#otherModels == 1)
    local otherUnitName = targetData.unitDecorativeName
    local highlightColor = target.getVar('currentHighlightColor')  ---@type color
    ---@cast otherUUID string
    if target.hasTag(attachedTag) then
        for _, model in ipairs(otherModels) do
            model.removeTag(attachedTag)
            if isCurrentlyCheckingCoherency then
                if highlightColor then
                    model.highlightOn(highlightColor)
                    model.setVar('currentHighlightColor', highlightColor)
                else
                    model.highlightOff()
                    model.setVar('currentHighlightColor', nil)
                end
            end
        end
        for _, model in ipairs(modelsInUnit) do
            model.removeTag(otherUUID..'_attached')
        end
        if isSingleAttached and not isAttached(target) then
            target.call('setContextMenuItemsForUnit', true)
        end
        if isSingleModel and not isAttached(self) then
            self.clearContextMenu()
            self.addContextMenuItem('Attach/Detach Unit \u{00BB}', toggleAttachDetach)
        end
        broadcastToColor(('Detached %s from %s'):format(unitData.unitDecorativeName, otherUnitName), player_color, player_color)
    else
        for _, model in ipairs(otherModels) do
            model.addTag(attachedTag)
        end
        for _, model in ipairs(modelsInUnit) do
            model.addTag(otherUUID..'_attached')
        end
        if isSingleAttached then
            target.call('setContextMenuItemsForUnit', true)
        end
        if isSingleModel then
            self.clearContextMenu()
            self.addContextMenuItem('Toggle Coherency \u{2713}', toggleCoherencyChecking)
            self.addContextMenuItem('Attach/Detach Unit \u{00BB}', toggleAttachDetach)
        end
        broadcastToColor(('Attached %s to %s'):format(unitData.unitDecorativeName, otherUnitName), player_color, player_color)
    end
    if isCurrentlyCheckingCoherency then
        Wait.time(|| highlightCoherency(), 0.3)
    end
    isAttachingUnit = false
end

---Check if the model is attached to any other units.
---@param object Object
---@return boolean
function isAttached(object)
    for _, tag in ipairs(object.getTags()) do
        if tag:find('_attached$') then
            return true
        end
    end
    return false
end


function getAttachedUUIDs()
    local attachedUUIDs = {}  ---@type { [string]: true }

    ---@param uuid string
    function populateUUIDs(uuid)
        local attachedLeaders = getObjectsWithAllTags{'uuid_'..uuid..'_attached', 'leaderModel'}
        local modelData
        for _, model in ipairs(attachedLeaders) do
            if model == self then
                goto continue
            end
            modelData = model.getTable('unitData')  ---@type UnitData
            if not attachedUUIDs[modelData.uuid] then
                attachedUUIDs[modelData.uuid] = true
                populateUUIDs(modelData.uuid)
            end
            ::continue::
        end
        local leader = getObjectsWithAllTags{'uuid_'..uuid, 'leaderModel'}[1]
        if not leader then return end
        for _, tag in ipairs(leader.getTags()) do
            local a_uuid = tag:match('^uuid_('..('%x'):rep(8)..')_attached$')  ---@type string?
            if a_uuid and a_uuid ~= unitData.uuid and not attachedUUIDs[a_uuid] then
                attachedUUIDs[a_uuid] = true
                populateUUIDs(a_uuid)
            end
        end
    end
    populateUUIDs(unitData.uuid)
    -- _printTable(attachedUUIDs)
    local uuids = {}  ---@type string[]
    for uuid in pairs(attachedUUIDs) do
        uuids[#uuids+1] = uuid
    end
    return uuids
end


---@return object[]
function getAttachedLeaders()
    uuids = getAttachedUUIDs()
    local leaders = TableObject:new()
    for _, uuid in ipairs(uuids) do
        leaders:extend(getObjectsWithAllTags{'uuid_'..uuid, 'lsModel', 'leaderModel'})
    end
    return leaders
end

function getAllAttachedModels()
    uuids = getAttachedUUIDs()
    local attachedModels = TableObject:new()
    for _, uuid in ipairs(uuids) do
        attachedModels:extend(getObjectsWithAllTags{'uuid_'..uuid, 'lsModel'})
    end
    return attachedModels
end


---@param model object
---@return object
function getModelUnitLeader(model)
    local tags = model.getTable('unitLeaderTags')  ---@type string[]
    if not tags then
        updateModelTables(model)
        tags = model.getTable('unitLeaderTags')  ---@type string[]
    end
    local leader = getObjectsWithAllTags(tags)[1]
    return leader
end


---@param model object
---@return bool
function updateModelTables(model)
    local model_uuid_tag  ---@type string
    for _, tag in ipairs(model.getTags()) do
        if tag:match('^uuid_'..('%x'):rep(8)..'$') then
            model_uuid_tag = tag
        end
    end
    if model_uuid_tag then
        local unitLeaderTags = {model_uuid_tag, 'lsModel', 'leaderModel'}
        local unit = getObjectsWithAllTags{model_uuid_tag, 'lsModel'}
        for _, unit_model in ipairs(unit) do
            unit_model.setTable('unitLeaderTags', unitLeaderTags)
        end
        return true
    else
        return false
    end
end



--[[ UI UTILITY FUNCTIONS ]]--
---@param playerColor PlayerColor
---@param cardName string
function showCard(playerColor, cardName)
    local timeToWait = 0

    if not hasBuiltUI then
        buildUI()
        hasBuiltUI = true
        timeToWait = 2
    end

    -- wait in case ui needs to update
    Wait.frames(function ()
        local globalUI = UI.getXmlTable()
        local selfUI = self.UI.getXmlTable()
        local formattedCardName = "ymc-"..cardName.."-"..unitData.uuid.."-"..playerColor  ---@type string
        local shownYet = false

        -- yes, I know we go through the table twice, I don't like it
        for _, element in ipairs(globalUI) do
            recursivelyCleanElement(element)

            if element.attributes.id == formattedCardName then
                shownYet = true

                if element.attributes.visibility ~= playerColor or not element.attributes.active then
                    element.attributes.visibility = playerColor
                    element.attributes.active = true
                end
            end
        end

        if not shownYet then
            local cardToShow = filter(selfUI[1].children, |child| child.attributes.id == cardName)[1]  ---@type UITable
            cardToShow.attributes.id = formattedCardName
            cardToShow.attributes.visibility = playerColor
            cardToShow.attributes.active = true

            recursivelyCleanElement(cardToShow)
            table.insert(globalUI, cardToShow)
        end
        UI.setXmlTable(globalUI)
    end, timeToWait)
end


---@param player Player|PlayerColor
---@param card string
function hideCard(player, card)
    local playerColor = player.color or player
    if not (playerColor:find("^%w+$")) then playerColor = "Grey" end

    local formattedCardName = table.concat({'ymc', card, unitData.uuid, playerColor}, '-')

    UI.setAttribute(formattedCardName, "visibility", "None")
    UI.setAttribute(formattedCardName, "active", false)

    Wait.time(function()
        local currentUI = UI.getXmlTable()
        local foundVisibleCard = false

        for _, element in ipairs(currentUI) do
            if element.attributes and
                element.attributes.id and
                (element.attributes.id:find("^ymc-")) and -- if we find a card
                element.attributes.visibility and
                element.attributes.visibility ~= "" and
                element.attributes.visibility ~= "None" then
                    foundVisibleCard = true
                    break
            end

            recursivelyCleanElement(element)
        end

        if not foundVisibleCard then return end

        currentUI = filter(currentUI, |element| element.attributes.id == nil or (element.attributes.id:find("^ymc-")) == nil)
        if #currentUI > 1 then
            UI.setXmlTable(currentUI)
        end

    end, 0.11)
end

---@param playerColor PlayerColor
---@param card string
function toggleCard(playerColor, card)
    if not playerColor:find("^%w+$") then playerColor = "Grey" end

    local formattedCardName = table.concat({'ymc', card, unitData.uuid, playerColor}, '-')
    local attrs = UI.getAttributes(formattedCardName)  ---@type { active: bool, visibility: string? }
    if attrs and (attrs.active and (attrs.visibility and attrs.visibility ~= '' and attrs.visibility ~= 'None')) then
        hideCard(playerColor, card)
    elseif card == 'crusadeCard' then
        showCrusadeCard(playerColor)
    else
        showCard(playerColor, card)
    end
end


-- builds the XML string for the given section based on data defined in unitData (see top of file)
-- note: this is just for dataCard, although theoretically it can be used for any section
function buildXMLForSection(uiSection, dataSection)
    local uiString = ""     -- old: uiTemplates[section.."Header"]
    local _, _, rowHeight = uiTemplates[uiSection].find(uiTemplates[uiSection], 'Row.-preferredHeight="(%d+)"') -- get the height of the row to be added
    local rowParity = "White"
    for _, entry in pairs(unitData[dataSection] --[[@as table]]) do
        entry["rowParity"] = rowParity
        uiString = uiString..interpolate(uiTemplates[uiSection], entry)
        dataCardHeight = dataCardHeight + tonumber(rowHeight)
        rowParity = rowParity == "White" and "#f9f9f9" or "White"
    end
    self.UI.setValue(uiSection, uiString)
end

function buildUI()
    self.UI.setAttribute("ym-container", "unit-id", unitData.uuid)

    self.UI.setAttribute("dataCard", "height", unitData.uiHeight)
    self.UI.setAttribute("dataCard", "width", unitData.uiWidth)

    self.UI.setValue("data-unitName", unitData.unitName)
    self.UI.setValue("factionKeywords", unitData.factionKeywords)
    self.UI.setValue("keywords", unitData.keywords)

    self.UI.setAttribute("modelsTable9e", "active", false)
    self.UI.setAttribute("modelsTable10e", "active", true)
    buildXMLForSection("models10e", "models")

    self.UI.setAttribute("weaponsTable9e", "active", false)
    self.UI.setAttribute("weaponsTable10e", "active", true)
    buildXMLForSection("weapons10e", "weapons")


    buildXMLForSection("abilities", "abilities")


    local guid = self.getGUID()

    self.UI.setAttribute("dataCardCloseButton", "onClick", guid.."/hideCard(dataCard)")
    self.UI.setValue("highlightButtonsContainer", interpolate(uiTemplates.buttons, { guid=guid, width=(unitData.uiWidth/10)-4 }))

    self.UI.setAttribute("dataCardContentContainer", "height", dataCardHeight)

    if buildCrusadeUI ~= nil then buildCrusadeUI(guid) end
end

function setContextMenuItemsForUnit(override)
    local hasLoaded = self.getVar('hasLoaded')
    if override or not hasLoaded then
        local unit = getObjectsWithAllTags(unitModelTags)
        if not unitData.isSingleModel and #unit > 1 then
            for _, model in ipairs(unit) do
                model.clearContextMenu()
                model.addContextMenuItem('Toggle Coherency \u{2713}', toggleCoherencyChecking)
                model.addContextMenuItem('Attach/Detach Unit \u{00BB}', toggleAttachDetach)
            end
        else
            self.clearContextMenu()
            for _, tag in ipairs(self.getTags()) do
                if tag:match('_attached$') then
                    self.addContextMenuItem('Toggle Coherency \u{2713}', toggleCoherencyChecking)
                    break
                end
            end
            self.addContextMenuItem('Attach/Detach Unit \u{00BB}', toggleAttachDetach)
        end
    end
end


---@param playerColor PlayerColor
function toggleAttachDetach(playerColor)
    broadcastToColor('Select unit to attach to '..unitData.unitDecorativeName, playerColor, playerColor)
    last_player_color = playerColor
    isAttachingUnit = not isAttachingUnit
end

function updateEventHandlers(guid)
    self.UI.setAttribute("dataCardCloseButton", "onClick", guid.."/hideCard(dataCard)")
    self.UI.setValue("highlightButtonsContainer", interpolate(uiTemplates.buttons, { guid=guid, width=(unitData.uiWidth/10)-4 }))
end


--[[ HIGHLIGHTING FUNCTIONS ]]--


---@param player? any n/a
---@param color? color Higlight color. Nil removes highlight.
---@param tags? string[] Indentifying tags. Defaults to this unit's tags.
function highlightUnit(player, color, tags)
    tags = tags or unitModelTags
    highlightModels(getObjectsWithAllTags(tags), color)
end

---@param models object[] Models to highlight
---@param color color? Color to highlight. Nil removes highlight.
function highlightModels(models, color)
    for _, model in ipairs(models) do
        if color and color ~= '-1' then
            model.highlightOn(color)
            model.setVar("currentHighlightColor", color)
        else
            model.highlightOff()
            model.setVar("currentHighlightColor", nil)
        end
    end
end

---@param color? PlayerColor
function highlightAttachedModels(color)
    local models = getAllAttachedModels()
    highlightModels(models, color)
end

--[[ UNIT COHERENCY FUNCTIONS ]]--

---@param playerColor PlayerColor
function toggleCoherencyChecking(playerColor)
    isCurrentlyCheckingCoherency = not isCurrentlyCheckingCoherency
    local unit_names = {unitData.unitDecorativeName or unitData.unitName}
    for _, leader in ipairs(getAttachedLeaders()) do
        leader.setVar('isCurrentlyCheckingCoherency', isCurrentlyCheckingCoherency)
        leaderData = leader.getTable('unitData')  ---@type UnitData
        unit_names[#unit_names+1] = leaderData.unitDecorativeName or leaderData.unitName
    end
    local name_str  ---@type string
    if #unit_names > 2 then
        unit_names[#unit_names] = 'and '..unit_names[#unit_names]
        name_str = table.concat(unit_names, ', ')
    else
        name_str = table.concat(unit_names, ' and ')
    end
    if isCurrentlyCheckingCoherency then
        highlightCoherency()
        broadcastToColor("Checking coherency for "..name_str, playerColor, playerColor)
    else
        local oldHighlight = self.getVar("currentHighlightColor")  ---@type color?
        highlightUnit(nil, oldHighlight)
        local attachedModels = getAllAttachedModels()
        highlightModels(attachedModels, oldHighlight)
        broadcastToColor("No longer checking coherency for "..name_str, playerColor, playerColor)
    end
end

---@param t table<any, any>
function _printTable(t)
    for key, value in pairs(t) do
        log(('%s: %s'):format(tostring(key), tostring(value)))
    end
end

function highlightCoherency()
    local modelsInUnit = getObjectsWithAllTags(unitModelTags)
    local attachedModels = getAllAttachedModels()
    local filteredModels = {}  ---@type Object[]

    ---@param modelList Object[]
    function addModels(modelList)
        for _, model in ipairs(modelList) do
            local wounds = model.getName():match('(%d+)/%d+') or 1  ---@type string|number
            if model.is_face_down or tonumber(wounds) < 1 then
                model.highlightOff()
            else
                table.insert(filteredModels, model)
            end
        end
    end

    addModels(modelsInUnit)
    addModels(attachedModels)

    --if (#modelsInUnit + #attachedModels) > 1 and #filteredModels <= 1 then
    if #filteredModels <= 1 then
        for _, model in ipairs(filteredModels) do
            model.highlightOff()
            model.highlightOn("Green")
        end
        return
    end
    local coherencyCheckNum = (#filteredModels > 5) and 2 or 1
    local coherencyGroups = getCoherencyGroups(
        filteredModels, coherencyCheckNum)
    -- local numberOfBlobs = len(coherencyGroups)
    local numberOfBlobs = #coherencyGroups

    if numberOfBlobs == 0 then return
    elseif numberOfBlobs > 1 then
        for _, blob in ipairs(coherencyGroups) do
            for modelIdx, _ in pairs(blob) do
                filteredModels[modelIdx].highlightOff()
                filteredModels[modelIdx].highlightOn("Yellow")
            end
        end
    else
        for modelIdx, _ in pairs(coherencyGroups[1]) do
            filteredModels[modelIdx].highlightOff()
            filteredModels[modelIdx].highlightOn("Green")
        end
    end
end


---@param modelsToSearch object[]
---@param numberToLookFor integer
---@return table<integer, boolean>[]
function getCoherencyGroups(modelsToSearch, numberToLookFor)
    local edges = getCoherencyGraph(modelsToSearch)
    local blobs = {}  ---@type table<integer, boolean>[]
    local modelsToIgnore = {}  ---@type table<integer, boolean>

    for idx, model in ipairs(modelsToSearch) do
        if edges[idx] == nil or #edges[idx] < numberToLookFor then -- the model is out of coherency
            model.highlightOff()
            model.highlightOn("Red")

            modelsToIgnore[idx] = true
            -- remove from any blobs the model is already in
            for _, blob in ipairs(blobs) do
                blob[idx] = nil
            end
        else
            local found = false
            -- see if this index exists in a blob, if it does, ignore it
            for _, blob in ipairs(blobs) do
                if blob[idx] == true then
                    found = true
                    break
                end
            end

            if not found then
                local newBlob = {}

                table.insert(blobs, newBlob)
                addModelsToBlobRecursive(idx, newBlob, edges, modelsToIgnore)
            end
        end
    end

    return blobs
end


---comment
---@param modelsToSearch object[]
---@return integer[][]
function getCoherencyGraph(modelsToSearch)
    local edges = {}  ---@type integer[][]

    for idx=1, #modelsToSearch do
        for otherIdx=idx+1, #modelsToSearch do
            local firstPosition = modelsToSearch[idx].getPosition()
            local firstSize = determineBaseInInches(modelsToSearch[idx])
            local secondPosition = modelsToSearch[otherIdx].getPosition()
            local secondSize = determineBaseInInches(modelsToSearch[otherIdx])
            local verticalDisplacement = distanceBetweenVertical(firstPosition, secondPosition)

            -- handle circular bases
            if firstSize.x == firstSize.z and secondSize.x == secondSize.z then
                if distanceBetween2D(firstPosition, firstSize.x, secondPosition, secondSize.x) <= 2 and
                    verticalDisplacement <= 5 then
                    -- store all edges of a graph where models are nodes and edges represent coherency
                    storeEdges(edges, idx, otherIdx)
                end
            else -- handle non-circular bases
                if firstSize.x ~= firstSize.z and secondSize.x ~= secondSize.z then -- handle two ovals
                    -- if the bases were circles with radiuses = minor axes and they are in coherency,
                    -- the ovals must be in coherency
                    if distanceBetween2D(firstPosition, math.min(firstSize.x, firstSize.z), secondPosition, math.min(secondSize.x, secondSize.z)) <= 2 and
                        verticalDisplacement <= 5 then
                        -- store edges in graph
                        storeEdges(edges, idx, otherIdx)

                    -- if the bases were circles with radiuses = major axes and they are out of coherency,
                    -- there is no way for the ovals to be in coherency
                    elseif not (distanceBetween2D(firstPosition, math.max(firstSize.x, firstSize.z), secondPosition, math.max(secondSize.x, secondSize.z)) > 2 or
                                verticalDisplacement > 5) then
                        -- only way to get here is if coherency is uncertain, so now check a little more precisely (only a little)
                        if distanceBetween2D(firstPosition, (firstSize.x+firstSize.z)/2, secondPosition, (secondSize.x+secondSize.z)/2) <= 2 and
                            verticalDisplacement <= 5 then
                            storeEdges(edges, idx, otherIdx)
                        end
                    end
                else -- handle one circle and one oval
                    local oval, ovalPosition, circle, circlePosition

                    if firstSize.x ~= firstSize.z then
                        oval = firstSize
                        ovalPosition = firstPosition
                        circle = secondSize
                        circlePosition = secondPosition
                    else
                        oval = secondSize
                        ovalPosition = secondPosition
                        circle = firstSize
                        circlePosition = firstPosition
                    end

                    -- if the oval base was a circle with radius = minor axis and they are in coherency,
                    -- the models must be in coherency
                    if distanceBetween2D(circlePosition, circle.x, ovalPosition, math.min(oval.x, oval.z)) <= 2 and
                        verticalDisplacement <= 5 then
                        storeEdges(edges, idx, otherIdx)

                    -- if the oval base was a circle with radius = major axis and they are out of coherency,
                    -- there is no way for the models to be in coherency
                    elseif not (distanceBetween2D(circlePosition, circle.x, ovalPosition, math.max(oval.x, oval.z)) > 2 or
                                verticalDisplacement > 5) then
                        -- only way to get here is if coherency is uncertain, so now check a little more precisely (only a little)
                        if distanceBetween2D(circlePosition, circle.x, ovalPosition, (oval.x+oval.z)/2) <= 2 and
                            verticalDisplacement <= 5 then
                            storeEdges(edges, idx, otherIdx)
                        end
                    end
                end
            end
        end
    end

    return edges
end


---comment
---@param edges integer[][]
---@param idx integer
---@param otherIdx integer
function storeEdges(edges, idx, otherIdx)
    if edges[idx] == nil then edges[idx] = { otherIdx }
    else table.insert(edges[idx], otherIdx) end

    if edges[otherIdx] == nil then edges[otherIdx] = { idx }
    else table.insert(edges[otherIdx], idx) end
end

---comment
---@param idx integer
---@param blob table<integer, boolean>
---@param edges integer[][]
---@param modelsToIgnore any
function addModelsToBlobRecursive(idx, blob, edges, modelsToIgnore)
    -- at this point, idx should not exist in any blobs
    if modelsToIgnore[idx] ~= nil then return end
    if blob[idx] ~= nil then return end

    blob[idx] = true

    for _, edge in ipairs(edges[idx]) do
        addModelsToBlobRecursive(edge, blob, edges, modelsToIgnore)
    end
end


--[[ UTILITY FUNCTIONS ]]--

function interpolate(templateString, replacementValues)
    return (templateString:gsub('($%b{})', function(w) return replacementValues[w:sub(3, -2)] or w end))
end

function isInList(key, list)
    for _, k in pairs(list) do
        if k == key then return true end
    end
    return false
end


function distanceBetween2D(firstModelPosition, firstModelRadius, secondModelPosition, secondModelRadius)
    -- generally should only be checking coherency with circular bases?
    return getRawDistance(firstModelPosition.x, firstModelPosition.z,
                secondModelPosition.x, secondModelPosition.z) - firstModelRadius - secondModelRadius
end


function distanceBetweenVertical(firstModelPosition, secondModelPosition)
    -- vertical measuring assumes the model has a base because generally vehicles (or models without bases)
    -- dont need to check coherency, and the ones that do probably wont be out of vertical coherency
    -- because they cant end up on upper floors of buildings or walls
    return math.abs(firstModelPosition.y - secondModelPosition.y) - 0.2 -- this is assuming the model has a base
end

---comment
---@param firstA number
---@param firstB number
---@param secondA number
---@param secondB number
---@return number
function getRawDistance(firstA, firstB, secondA, secondB)
    return math.sqrt(
        (firstA - secondA)^2 + (firstB - secondB)^2
        -- math.pow(firstA - secondA, 2) +
        -- math.pow(firstB - secondB, 2)
    )
end

function includes(tab, val)
    return find(tab, val) > 0
end

function find(tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return index
        end
    end

    return -1
end

function filter(t, filterFunc)
    local out = {}

    for k, v in pairs(t) do
        if filterFunc(v, k, t) then table.insert(out, v) end
    end

    return out
end

function clone(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[clone(orig_key)] = clone(orig_value)
        end
        setmetatable(copy, clone(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function map(t, mapFunc)
    local out = {}

    for k, v in pairs(clone(t)) do
        table.insert(out, mapFunc(v, k))
    end

    return out
end

function recursivelyCleanElement(element)
    if element.value ~= nil then
        element.value = element.value:gsub("%s%s+", " ") -- remove extraneous spaces
    end

    if element.children ~= nil and #element.children > 0 then
        for _, child in ipairs(element.children) do
            recursivelyCleanElement(child)
        end
    end
end


--[[ MEASURING CIRCLE FUNCTIONS ]]--
---comment
---@param inc integer
---@param target object
function assignBase(inc, target)
    local savedBase = target.getTable("chosenBase")  ---@type { baseIdx: integer, base: BaseSize }

    if savedBase == nil then
        changeMeasurementCircle(0, target, determineBaseInInches(target), true)
    else
        local newIdx = savedBase.baseIdx + inc

        if newIdx < 1 then newIdx = #VALID_BASE_SIZES_IN_MM end
        if newIdx > #VALID_BASE_SIZES_IN_MM then newIdx = 1 end

        local newBase = {
            baseIdx = newIdx,
            base = {
                x = (VALID_BASE_SIZES_IN_MM[newIdx].x * MM_TO_INCH)/2,
                z = (VALID_BASE_SIZES_IN_MM[newIdx].z * MM_TO_INCH)/2
            }
        }
        target.setTable("chosenBase", newBase)
        changeMeasurementCircle(0, target, newBase.base, true)
    end
end

---comment
---@param model object
---@return BaseSize
function determineBaseInInches(model)
    local savedBase = model.getTable("chosenBase")  ---@type { baseIdx: integer, base: BaseSize}

    if savedBase ~= nil then
        return savedBase.base
    else
        local chosenBase =  VALID_BASE_SIZES_IN_MM[1]
        local modelSize = model.getBoundsNormalized().size
        local modelSizeX = modelSize.x
        local modelSizeZ = modelSize.z
        local closestSum = 10000000000
        local chosenBaseIdx = 1

        for k, base in pairs(VALID_BASE_SIZES_IN_MM) do
            local baseInchX = (MM_TO_INCH - 0.001) * base.x
            local baseInchZ = (MM_TO_INCH - 0.001) * base.z
            if modelSizeX > baseInchX and modelSizeZ > baseInchZ then
                local distSum = (modelSizeX - baseInchX) + (modelSizeZ - baseInchZ)
                if distSum < closestSum then
                    closestSum = distSum
                    chosenBase = base
                    chosenBaseIdx = k
                end
            end
        end

        if chosenBase == nil then
            chosenBase = { x=modelSizeX/2, z=modelSizeZ/2}
        else
            chosenBase = {
                x = (chosenBase.x * MM_TO_INCH)/2,
                z = (chosenBase.z * MM_TO_INCH)/2
            }
        end

        model.setTable("chosenBase", { baseIdx=chosenBaseIdx, base=chosenBase })

        return chosenBase
    end
end

---@param target object
function getCurrentCircleRadius(target)
    local measuringCircles = target.getTable("measuringCircles")  ---@type { name: color, points: table, color?: Color, thinkness?: float, rotation?: vector, radius?: integer }[]
    local currentColor = target.getVar("currentHighlightColor")  ---@type PlayerColor currentColor
    local radius  ---@type integer

    if measuringCircles then
        for _, circle in ipairs(measuringCircles) do
            if (circle.name == currentColor) then --or (not circle.name and not currentColor) then
                radius = circle.radius
                break
            end
        end
    end
    radius = radius or 0
    return radius
end

---comment
---@param change integer
---@param target object
---@param presetBase? BaseSize
---@param silent? boolean
function changeMeasurementCircle(change, target, presetBase, silent)
    if not target.hasTag(unitTag) then return end
    local currentColorRadius = getCurrentCircleRadius(target)
    local newRadius = math.max(currentColorRadius + change, 0)
    setMeasurementCircle(newRadius, target, presetBase, silent)
end

---@alias MeasuringCircle { name: PlayerColor, points: table, color?: Color, thinkness?: float, rotation?: vector, radius?: integer }

---@param radius integer
---@param target object
---@param presetBase? BaseSize
---@param silent? bool
function setMeasurementCircle(radius, target, presetBase, silent)
    if not target.hasTag(unitTag) then return end
    local currentCircles = target.getTable("measuringCircles")  ---@type MeasuringCircle[]
    local currentColor = target.getVar("currentHighlightColor")  ---@type PlayerColor currentColor
    -- local measuringCircles = {}  ---@type MeasuringCircle[]
    local measuringCircles = {}
    if currentCircles and currentColor then
        for _, circle in ipairs(currentCircles) do
            if circle.name and circle.name ~= currentColor and circle.name ~= "base" then
                table.insert(measuringCircles, circle)
            end
        end
    end
    if radius > 0 then
        local isRectangular = target.hasTag("rectangularMeasuring")
        local measuringPoints, basePoints  ---@type Vector, Vector

        if isRectangular then
            local modelBounds = target.getBoundsNormalized()
            measuringPoints = getRectangleVectorPoints(radius, modelBounds.size.x/2, modelBounds.size.z/2, target)
            basePoints = getRectangleVectorPoints(0, modelBounds.size.x/2, modelBounds.size.z/2, target)
        else
            local baseRadiuses = (presetBase == nil) and determineBaseInInches(target) or presetBase  ---@cast baseRadiuses -nil
            measuringPoints = getCircleVectorPoints(radius, baseRadiuses.x, baseRadiuses.z, target)
            basePoints = getCircleVectorPoints(0, baseRadiuses.x, baseRadiuses.z, target)
        end
        local measuring = {
            name = currentColor,
            color = currentColor == nil and {1, 0, 1} or Color.fromString(currentColor --[[@as PlayerColor]]),
            radius = radius,
            thickness = 0.1/(target.getScale().x),
            rotation  = {270, 0, 0},--isRectangular and {0, 0, 0} or {270, 0, 0}
            points = measuringPoints
        }
        local base = {
            name="base",
            color = currentColor == nil and {1, 0, 1} or Color.fromString(currentColor --[[@as PlayerColor]]),
            thickness = 0.1/(target.getScale().x),
            rotation  = {270, 0, 0},--isRectangular and {0, 0, 0} or {270, 0, 0}
            points = basePoints
        }
        table.insert(measuringCircles, measuring)
        table.insert(measuringCircles, base)
        if not silent then
            -- broadcastToAll("Measuring "..tostring(radius)..'"')
            broadcastToAll(('Measuring %d"'):format(radius))
        end
    elseif not silent then
        broadcastToAll("Measuring off")
    end
    target.setVectorLines(measuringCircles)
    target.setTable("measuringCircles", measuringCircles)
end


---@param mod integer
---@param target object
function changeUnitCircles(mod, target)
    if not target.hasTag(unitTag) then return end
    local currentColorRadius = getCurrentCircleRadius(target)
    local newRadius = math.max(currentColorRadius + mod, 0)
    setUnitCircles(newRadius, target)
end


---@param radius integer
---@param target object
function setUnitCircles(radius, target)
    if not target.hasTag(unitTag) then return end
    local models = getObjectsWithAllTags(unitModelTags)
    for _, model in ipairs(models) do
        local wounds = model.getName():match('(%d+)/%d+')
        if wounds and (tonumber(wounds) > 0 or radius == 0) then
            setMeasurementCircle(radius, model, nil, true)
        end
    end
    local attachedModels = getAllAttachedModels()
    for _, model in ipairs(attachedModels) do
        local wounds = model.getName():match('(%d+)/%d+')
        if wounds and (tonumber(wounds) > 0 or radius == 0) then
            setMeasurementCircle(radius, model, nil, true)
        end
    end
    if radius > 0 then
        -- broadcastToAll("Measuring "..tostring(radius)..'"')
        broadcastToAll(('Measuring %d"'):format(radius))
    else
        broadcastToAll('Measuring off')
    end
end


---@param radius integer
---@param baseX integer
---@param baseZ integer
---@param obj object
---@return vector
function getCircleVectorPoints(radius, baseX, baseZ, obj)
    local result = {}  ---@type vector
    local scaleFactor = 1/obj.getScale().x
    -- local rotationDegrees =  obj.getRotation().y
    local steps = 64
    local degrees = 360/steps
    for i = 0, steps do
        table.insert(result, {
            x = math.cos(math.rad(degrees*i))*((radius+baseX)*scaleFactor),
            z = MEASURING_RING_Y_OFFSET,
            y = math.sin(math.rad(degrees*i))*((radius+baseZ)*scaleFactor)
        })
    end
    return result
end


---comment
---@param radius integer
---@param sizeX integer
---@param sizeZ integer
---@param obj object
---@return vector
function getRectangleVectorPoints(radius, sizeX, sizeZ, obj)
    local result = {}  ---@type vector
    local scaleFactor = 1/obj.getScale().x

    sizeX = sizeX*scaleFactor
    sizeZ = sizeZ*scaleFactor
    radius = radius*scaleFactor

    local steps = 65
    local degrees = 360/(steps-1)
    local xOffset, zOffset = sizeX, sizeZ
    -- compensate for ignoring vertical line
    table.insert(result, {
        x = (math.cos(math.rad(degrees*0))*radius)+sizeX-0.001,
        y = (math.sin(math.rad(degrees*0))*radius)+sizeZ,
        z = MEASURING_RING_Y_OFFSET
    })

    for i = 1, steps-1 do
        if i == 16 then
            table.insert(result, { x= sizeX, y=(radius+sizeZ), z=MEASURING_RING_Y_OFFSET })
            table.insert(result, { x=-sizeX, y=(radius+sizeZ), z=MEASURING_RING_Y_OFFSET })
            xOffset = -sizeX
        elseif i == 33 then
            table.insert(result, { x=-radius-sizeX,       y= sizeZ, z=MEASURING_RING_Y_OFFSET })
            table.insert(result, { x=-radius-sizeX-0.001, y=-sizeZ, z=MEASURING_RING_Y_OFFSET })
            table.insert(result, { x=-radius-sizeX,       y=-sizeZ, z=MEASURING_RING_Y_OFFSET })
            zOffset = -sizeZ
        elseif i == 49 then
            table.insert(result, { x=-sizeX, y=-radius-sizeZ, z=MEASURING_RING_Y_OFFSET })
            table.insert(result, { x= sizeX, y=-radius-sizeZ, z=MEASURING_RING_Y_OFFSET })
            xOffset = sizeX
        elseif i == 65 then
            table.insert(result, { x=radius+sizeX,       y=-sizeZ, z=MEASURING_RING_Y_OFFSET })
            table.insert(result, { x=radius+sizeX-0.001, y= sizeZ, z=MEASURING_RING_Y_OFFSET })
        else
            table.insert(result, {
                x = (math.cos(math.rad(degrees*i))*radius)+xOffset,
                y = (math.sin(math.rad(degrees*i))*radius)+zOffset,
                z = MEASURING_RING_Y_OFFSET
            })
        end
    end
    -- compensate for ignoring vertical line
    table.insert(result, {
        x = (math.cos(math.rad(degrees*0))*radius)+sizeX-0.001,
        y = (math.sin(math.rad(degrees*0))*radius)+sizeZ,
        z = MEASURING_RING_Y_OFFSET
    })

    return result
end


--[[ CRUSADE STUFF ]]--


function showTallyCard(playerColor)
    local agendaManager = getAgendaManager()

    -- dont do anything if the agenda manager isnt present
    if agendaManager == nil then
        broadcastToColor("That unit is not associated with an Agenda Manager!", playerColor, "Red")
        return
    else
        buildAgendas(agendaManager.call("getTalliesForUnit", unitData.uuid))

        Wait.frames(function ()  -- delay for building agendas
            -- showCard("tallyCard", playerColor, updateCounters)
            showCard(playerColor, "tallyCard")
        end, 2)
    end
end

---@param player_color PlayerColor
function showCrusadeCard(player_color)
    loadCrusadeCard()
    -- delay to wait for update
    Wait.frames(function () showCard(player_color, "crusadeCard") end, 2)
end

function loadDecodedState(decodedState)
    crusadeCardData = decodedState.crusadeCard
end

function loadDefaultValues()
    crusadeCardData.fields.ccUnitName = unitData.unitDecorativeName
end

function getCrusadeCardSaveData()
    return {
        crusadeCard = crusadeCardData
    }
end

function buildCrusadeUI(guid)
    self.UI.setValue("tally-UnitName", unitData.unitDecorativeName)

    self.UI.setAttribute("crusadeCardCloseButton", "onClick", guid.."/hideCard(crusadeCard)")
    self.UI.setAttribute("tallyCardCloseButton", "onClick", guid.."/hideCard(tallyCard)")

    if crusadeCardData.fields.ccUnitName == "" then crusadeCardData.fields.ccUnitName = unitData.unitDecorativeName end

    for counter, val in pairs(crusadeCardData.counters) do
        self.UI.setAttribute(counter.."Up", "onClick", guid.."/incrementCounterText("..counter..")")
        self.UI.setAttribute(counter.."Down", "onClick", guid.."/decrementCounterText("..counter..")")
        self.UI.setValue(counter, val)
    end

    for id, val in pairs(crusadeCardData.fields) do
        self.UI.setValue(id, val)
        self.UI.setAttribute(id, "onEndEdit", guid.."/updateCrusadeCard()")
    end

    for id, val in pairs(crusadeCardData.toggles) do
        self.UI.setAttribute(id, "isOn", val)
        self.UI.setAttribute(id, "onValueChanged", guid.."/updateCrusadeCard()")
    end
end


--[[ TALLY CARD FUNCTIONS ]]--

function modTallyCounter(player, counter, mod)
    local agendaManager = getAgendaManager()

    -- dont do anything if the agenda manager isnt present
    if agendaManager == nil then
        broadcastToColor("Couldn't find the Agenda Manager!", player, "Red")
        return
    else
        local newValue = agendaManager.call("updateTallyForUnit", {
            unitID = unitData.uuid,
            tally = counter,
            mod = mod
        })

        UI.setValue("agenda-"..counter, newValue)
    end
end


function incrementTallyCounter(player, counter)
    modTallyCounter(player, counter, 1)
end


function decrementTallyCounter(player, counter)
    modTallyCounter(player, counter, -1)
end


function buildAgendas(listToBuild)
    if listToBuild ~= nil then
        local tallyString = ""
        local height = 40

        for tally, value in pairs(listToBuild) do
            tallyString = tallyString..interpolate(uiTemplates.agenda, {
                counterName = tally,
                counterID = "agenda-"..tally,
                guid = self.getGUID(),
                counterValue = value
            })

            height = height + 37
        end

        self.UI.setValue("tallyContainer", tallyString)
        self.UI.setAttribute("tallyCard", "height", height)
        return true
    end
    -- generally will only return false if it cant find the Agenda manager or there arent any agendas in the inputs
    return false
end

function getAgendaManager()
    for _, tag in ipairs(self.getTags()) do
        local agendaManagerGUID = tag:match(AGENDA_MANAGER_TAG_PATTERN)
        if agendaManagerGUID then
            return getObjectFromGUID(agendaManagerGUID)
        end
    end

    return nil
end


--[[ CRUSADE CARD UTILITY FUNCTIONS ]]--

function incrementCounterText(player, counter)
    crusadeCardData.counters[counter] = crusadeCardData.counters[counter] + 1
    UI.setValue(counter, crusadeCardData.counters[counter])
end


function decrementCounterText(player, counter)
    crusadeCardData.counters[counter] = crusadeCardData.counters[counter] - 1
    UI.setValue(counter, crusadeCardData.counters[counter])
end


function updateCrusadeCard(player, value, id)
    if crusadeCardData.fields[id] ~= nil then crusadeCardData.fields[id] = value
    else crusadeCardData.toggles[id] = value end
end


function loadCrusadeCard(fromData)
    if fromData then crusadeCardData = fromData end

    for id, val in pairs(crusadeCardData.fields) do
        self.UI.setValue(id, val)
    end
    for id, val in pairs(crusadeCardData.toggles) do
        self.UI.setAttribute(id, "isOn", val)
    end
    for counter, val in pairs(crusadeCardData.counters) do
        self.UI.setValue(counter, val)
    end

    -- if fromData is provided, that means its a model becoming a leader
    if fromData then
        buildCrusadeUI(self.getGUID())
    end
end


---@param mod integer
---@param target object
function fastChangeWounds(mod, target)
    local wounds, maxWounds = target.getName():match('(%d+)/(%d+)')  ---@type string?, string?
    if not wounds or not maxWounds then
        return
    elseif tonumber(wounds) >= tonumber(maxWounds) and mod > 0 then
        setUnitWounds(-1)
    elseif tonumber(wounds) < 1 and mod < 0 then
        setUnitWounds(0)
    else
        changeModelWoundCount(mod, target)
    end
end


-- this needs to be defined after all scripting functions
scriptingFunctions = {
    --[[1]]  {
        function (playerColor, target) toggleCard(playerColor, 'dataCard') end,
        function (playerColor, target) toggleCard(playerColor, 'crusadeCard') end
    },
    --[[2]]  {
        function (playerColor, target) changeModelWoundCount(-1, target) end,
        function (playerColor, target) fastChangeWounds(-5, target) end,
    },
    --[[3]]  {
        function (playerColor, target) changeModelWoundCount(1, target) end,
        function (playerColor, target) fastChangeWounds(5, target) end,
    },
    --[[4]]  {
        function (playerColor, target) changeMeasurementCircle(-1, target) end,
        function (playerColor, target) changeUnitCircles(-1, target) end,
    },
    --[[5]]  {
        function (playerColor, target) changeMeasurementCircle(1, target) end,
        function (playerColor, target) changeUnitCircles(1, target) end,
    },
    --[[6]]  {
        function (playerColor, target) setMeasurementCircle(0, target) end,
        function (playerColor, target) setUnitCircles(0, target) end,
    },
    --[[7]]  {
        function () cycleColor() end,
        toggleRectangularMeasuring,
    },
    --[[8]]  {
        function () cycleColor(true) end,
        function (playerColor, target) assignBase(-1, target) end
    },
    --[[9]] {
        function () end,
        function (playerColor, target) assignBase(1, target) end
    }
}

function addHotkeyBindinga()
    addHotkey('Show Data Card', function (playerColor) showCard(playerColor, 'dataCard') end)
    addHotkey('Show Crusade Card', showCrusadeCard)
    addHotkey('Increase Model Wound Count', function (playerColor, target) changeModelWoundCount(1, target) end)
    addHotkey('Decrease Model Wound Count', function (playerColor, target) changeModelWoundCount(-1, target) end)
    addHotkey('Increase Model Measurement Circle', function (playerColor, target) changeMeasurementCircle(1, target) end)
    addHotkey('Decrease Model Measurement Circle', function (playerColor, target) changeMeasurementCircle(-1, target) end)
    addHotkey('Reset Model Measurement Circle', function (playerColor, target) setMeasurementCircle(0, target) end)
    addHotkey('Increase Unit Measurement Circles', function (playerColor, target) changeUnitCircles(1, target) end)
    addHotkey('Decrease Unit Measurement Circles', function (playerColor, target) changeUnitCircles(-1, target) end)
    addHotkey('Reset Unit Measurement Circle', function (playerColor, target) setUnitCircles(0, target) end)
end