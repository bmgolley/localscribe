---@diagnostic disable: need-check-nil

local DEBUG = false

---@diagnostic disable: duplicate-doc-field, duplicate-set-field
---@class RosterData
---@field edition string
---@field order string[]
---@field armyData table<string, Unit>
---@field uiHeight string
---@field uiWidth string
---@field decorativeNames bool
---@field baseScript string
---@field height any
---@field xml any
---@field err? any
---@field showKeywords? 'all'|'filter'
---@field ignoredKeywords? string[]
---@field statsInvFNP? bool
---@field shortenWeaponAbilites? bool
---@field indentWeaponProfiles? bool

---@class Unit
---@field name string
---@field decorativeName? string
---@field factionKeywords string[]
---@field keywords string[]
---@field abilities { [string]: { name: string, desc: string } }
---@field models Models
---@field modelProfiles { [string]: ModelProfile }
---@field weapons  { [string]: WeaponProfile }
---@field isSingleModel bool
---@field uuid string
---@field rules any[]
---@field unassignedWeapons any[]
---@field modelsPerRow? int
---@field footprint? { height: int, width: int }
---@field woundTrack? table
---@field unitAbilities? string[]

---@class Models
---@field models { [string]: Model }
---@field totalNumberOfModels int

---@class Model
---@field name string
---@field abilities string[]
---@field weapons { name: string, number: int }[]
---@field number int
---@field node table
---@field associatedModels? { [string]: var }[]
---@field associatedModelBounds? Bounds
---@field modelAbilities? string[]

---@class YMButton
---@field unit string
---@field model string
---@field buttonID string

---@class TableObject<T>: { [integer]: T }
local TableObject = {}
---@generic T
---@param o T[]?
---@return TableObject
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
    for _, list in ipairs(...) do
        for _, obj in ipairs(list) do
            self:insert(obj)
        end
    end
end
---@diagnostic enable: duplicate-doc-field, duplicate-set-field

local loadedData ---@type RosterData
local originalLoadedOrder, uiHeight, uiWidth, decorativeNames  ---@type string[], string, string, bool
local url = 'http://localhost:40000'

local ignoredKeywords = {
    -- Unit class
    -- ['Infantry'] = true,
    -- ['Vehicle'] = true,
    -- ['Monster'] = true,

    -- Unit category
    -- ['Aircraft'] = true,
    -- ['Walker'] = true,
    ['Battleline'] = true,
    ['Epic Hero'] = true,
    ['Dedicated Transport'] = true,

    -- Faction specific
    ['Imperium'] = true,

    ['Rhino'] = true,
    ['Land Raider'] = true,

    ['Crusader'] = true,
    ['Redeemer'] = true,
    ['Banisher'] = true,

    ['Cerastus'] = true,
    ['Dominus'] = true,

    ['Retinue'] = true,
    ['Navis Imperialis'] = true,
    -- ['Anathema Psykana'] = true,

    -- ['Militarum Tempestus'] = true,
    ['Cadian'] = true,
    ['Command Squad'] = true,
    ['Loyal Protector'] = true,

    ['Great Devourer'] = true,
    ['Vanguard Invader'] = true,

    ['Ethereal'] = true
}

local uiTemplates = {
    UNIT_CONTAINER = [[ <VerticalLayout class="transparent" childForceExpandHeight="false">
                            <Text class="unitName">${unitName}</Text>
                            <VerticalLayout class="unitContainer" childForceExpandHeight="false" preferredHeight="${height}" spacing="20">
                                ${unitData}
                            </VerticalLayout>
                        </VerticalLayout> ]],
    MODEL_CONTAINER = [[<VerticalLayout preferredWidth="500" childForceExpandHeight="false" class="modelContainer" id="${unitID}|${modelID}" preferredHeight="${height}">
                            <Text class="modelDataName">${numberString}${modelName}</Text>
                            ${weapons}
                            ${abilities}
                        </VerticalLayout> ]],
    MODEL_DATA = [[ <VerticalLayout childForceExpandHeight="false" childForceExpandWidth="false">
                        <Text height="15"><!-- spacer --></Text>
                        <Text class="modelDataTitle">${dataType}</Text>
                        <Text class="modelData" preferredHeight="${height}">${data}</Text>
                    </VerticalLayout> ]],

    MODEL_GROUPING_CONTAINER = [[ <HorizontalLayout class="groupingContainer">${modelGroups}</HorizontalLayout> ]]
}

--[[ UNIT SCRIPTING DATA ]]--
--[[ everything in this section is meant to be a string because this is what we
are inputting into created models ]]--

local UNIT_SPECIFIC_DATA_TEMPLATE = [[--[[ UNIT-SPECIFIC DATA ${endBracket}--
unitData = {
    unitName = "${unitName}",
    unitDecorativeName = "${unitDecorativeName}",
    factionKeywords = "${factionKeywords}",
    keywords = "${keywords}",
    abilities = {
        ${abilities}
    },
    models = {
        ${models}
    },
    weapons = {
        ${weapons}
    },
    uuid = "${uuid}"${singleModel},
    uiHeight = ${height},
    uiWidth = ${width}
}]]
local RANGED_WEAPON_TEMPLATE_10E = [[[c6c930]${name}[-]
${range} A:${a} BS:${bs} S:${s} AP:${ap} D:${d}]]
local MELEE_WEAPON_TEMPLATE_10E = [[[c6c930]${name}[-]
A:${a} WS:${ws} S:${s} AP:${ap} D:${d}]]
local ABILITITY_STRING_TEMPLATE = '{ name = [[${name}]], desc = [=[${desc}]=] }'
local WEAPON_ENTRY_TEMPLATE_10E = '{ name="${name}", range=[[${range}]], a="${a}", bsws="${bsws}", s="${s}", ap="${ap}", d="${d}", abilities=[[${abilities}]], shortabilities=[[${shortAbilities}]] }'

local YELLOW_STORAGE_GUID = "43ecc1"
local ARMY_BOARD_GUID = "2955a6"
local DELETION_ZONE_GUID = "f33dff"
local AGENDA_MANAGER_GUID = "45cd3f"
local IS_IN_HOME_MOD
local yellowStorage, YELLOW_STORAGE_XML, YELLOW_STORAGE_SCRIPT, armyBoard ---@type object, any, string, object --, uiHeight, uiWidth, edition
local army  ---@type table<string, Unit>
local SLOT_POINTS = {slot={}, boundingBox={}, placed={}, models={}}
local SLOTS_TO_DISPLAY = {
    "slot",
    "boundingBox",
    "placed",
    "models"
}
local DEFAULT_MODEL_SPACING = 0.15
local DEFAULT_FOOTPRINT_PADDING = 0.5
local BOUNDING_BOX_RATIO = 2
local MODEL_PLACEMENT_Y = 5.4
local ARMY_PLACEMENT_STARTING_X = -5
local ARMY_PLACEMENT_STARTING_Z = -7

local CREATE_ARMY_BUTTON = {
    label="CREATE ARMY", click_function="createArmy", function_owner=self,
    position={0.5, 1.5, 0}, rotation={180, 0, 180}, height=550, width=2750, font_size=220, font_style = "Bold",
    font_color={1, 1, 1}, color={0, 150/255, 0}
}
local ON_BUTTON = {
    label="LOAD ROSTER", click_function="moveToLoadingScreen", function_owner=self,
    position={0, 0.52, 0}, rotation={180, 0, 180}, height=550, width=2750, font_size=220, font_style = "Bold",
    font_color={1, 1, 1}, color={0, 150/255, 0}
}
local modelAssociations = {}
local activeButtons = {}  ---@type YMButton[]
-- local numAssociatedObjects, firstModelAssociation = 0, true
local ERROR_RED = { 1, 0.25, 0.25 }

local RELOAD_BUTTON = {
    label="RELOAD ROSTER", click_function="moveToLoadingScreen", function_owner=self,
    position={0, 3.65, -20}, rotation={180, 0, 180}, height=550, width=2750, font_size=220, font_style = "Bold",
    font_color={1, 1, 1}, color={0, 150/255, 0}
}

-- Hopefully-temporary code to deal with the outbreak of a TTS virus

local sillySpaces = string.rep("  ", 90)
local naiveRemovalPattern = string.format("(%s.+)$", sillySpaces)
---@param obj object
---@return boolean
---@return string
function detectSillySpaces(obj)
    local script = obj.getLuaScript()
    if script:find(sillySpaces) then
        return true, script
    else
        return false, script
    end
end

---@param obj object
---@param debugNote string
function clean(obj, debugNote)
    Wait.stopAll()
    local hasSillySpaces, script = detectSillySpaces(obj)
    if hasSillySpaces then
        local cleanedScript = script:gsub(naiveRemovalPattern, "")
        obj.setLuaScript(cleanedScript)
        print("One or more of the models you just spawned in contained malicious code. Yellowscribe has deleted it and the model is now safe to use, but you should contact the source of the model to get them to fix it.")
    end
end

function onObjectSpawn(obj)
    clean(obj, "onObjectSpawn")
end

function onObjectLeaveContainer(container, obj)
    clean(obj, "onObjectLeaveContainer")
end

-- End virus handling code


function moveToLoadingScreen()
    UI.hide("welcomeWindow")
    UI.show("loading")
    local xml = self.UI.getXmlTable()
    clearXMLTagRecursive(xml, 'loadedContainer')
    self.UI.setXmlTable(xml)
    Wait.time(|| sendRequest(), 0.2)
    Wait.time(function () -- delay so that animations dont blend
        Wait.condition(function ()
            if loadedData.err == nil then
                loadEditedArmy(loadedData)
            else
                UI.hide("loading")
                -- wait because sometimes the response comes back before the loading screen even shows up
                Wait.time(function ()
                    broadcastToAll(loadedData.err, ERROR_RED)
                    UI.show("welcomeWindow")
                end, 0.2)
            end
        end,
        function () return loadedData ~= nil end,
        20,
        function ()
            UI.hide("loading")
            broadcastToAll("Something has gone horribly wrong! Please try again.", ERROR_RED)
            UI.show("welcomeWindow")
        end)
    end, 0.15)
    self.createButton(RELOAD_BUTTON)
end

function sendRequest()
    WebRequest.get(url, handleResponse)
end

---@param response WebRequestInstance
function handleResponse(response)
    -- Check if the request failed to complete e.g. if your Internet connection dropped out.
    if response.is_error then
        broadcastToAll('Server error: '..response.error, ERROR_RED)
        log(response.text)
        return
    end
    loadedData = JSON.decode(response.text)  --[[@as RosterData]]
    YELLOW_STORAGE_SCRIPT = loadedData.baseScript
    if loadedData.ignoredKeywords ~= nil then
        ignoredKeywords = {}
        for _, keyword in ipairs(loadedData.ignoredKeywords) do
            ignoredKeywords[keyword] = true
        end
    end
end

-- function acceptEditedArmy()
--     UI.hide("mainPanel")
--     loadEditedArmy({ -- args sent as table because this used to be Global and I'm too lazy to rewrite it
--         data = loadedData,
--         order = originalLoadedOrder,
--         uiHeight = uiHeight,
--         uiWidth = uiWidth,
--         decorativeNames = decorativeNames
--     })
-- end

-- function turnOnYellowMachine()
--     showWindow("welcomeWindow")
-- end



--[[ EVENT HANDLERS ]]--

function onLoad()
    IS_IN_HOME_MOD = Global.getVar("isYMBS2TTS") ~= nil

    yellowStorage = getObjectFromGUID(YELLOW_STORAGE_GUID)  --[[@as object]]
    if not yellowStorage then
        if IS_IN_HOME_MOD then
            broadcastToAll("Error: storage object missing.")
        end
        self.destruct()
        return
    end
    YELLOW_STORAGE_XML = yellowStorage.getData().XmlUI  ---@type string
    YELLOW_STORAGE_SCRIPT = yellowStorage.getLuaScript()

    if not IS_IN_HOME_MOD then
        getObjectFromGUID(AGENDA_MANAGER_GUID).destruct()
        getObjectFromGUID(DELETION_ZONE_GUID).destruct()
        yellowStorage.destruct()

        self.setPosition{x=0, y=4, z=0}
        self.createButton(ON_BUTTON)
        self.setLock(false)

        CREATE_ARMY_BUTTON.position = {0, 0.6, 0}
    else
        moveToLoadingScreen()
    end
end

function onScriptingButtonDown(index, player_color)
    --slotPoints = { {5, 1, 5}, {-5, 1, -5} }
    if DEBUG then
        Global.setVectorLines(SLOT_POINTS[SLOTS_TO_DISPLAY[index]])
    end
end

---comment
---@param player player
---@param action Action
---@param targets object[]
function onPlayerAction(player, action, targets)
    if action == Player.Action.PickUp and #activeButtons > 0 then
        makeSureObjectsAreAttached(targets)

        local intendedTargets  ---@type object[]

        if #player.getSelectedObjects() == 0 then
            intendedTargets = { player.getHoverObject() }
        else
            intendedTargets = player.getSelectedObjects()

            if not includes(intendedTargets, player.getHoverObject()) then
                table.insert(intendedTargets, player.getHoverObject())
            end
        end

        local targetsData = map(intendedTargets, function (target)
            local data = target.getData()

            data.States = nil

            return data
        end)

        for _, activeButton in pairs(activeButtons) do
            local buttonModel = army[activeButton.unit].models.models[activeButton.model]
            buttonModel.associatedModels = targetsData
            -- its ok if we overwrite this every time, we only ever need one and they shooould be all the same
            buttonModel.associatedModelBounds = intendedTargets[1].getBoundsNormalized()
            self.UI.setAttributes(activeButton.buttonID, {
                color = "#33ff33"
            })
        end

        for _, target in ipairs(intendedTargets) do
            target.highlightOn({ r=51/255, g=1, b=51/255 }, 2)
        end

        activeButtons = {}
    end
end



--[[ MODEL SELECTION ]]--

---@param player any
---@param _ any
---@param unitAndModelID string
function selectModelGroup(player, _, unitAndModelID)
    local idValues = split(unitAndModelID, "|")
    local unitID, modelID = idValues[1], idValues[2]
    local sameButtonIndex = find(map(activeButtons, |button| button.buttonID), unitAndModelID)

    if sameButtonIndex > 0 then
        if army[unitID].models.models[modelID].associatedModels then
            for _, modelData in ipairs(army[unitID].models.models[modelID].associatedModels) do
                pcall(|model| getObjectFromGUID(modelData.GUID).highlightOff(), modelData)
                -- getObjectFromGUID(modelData.GUID).highlightOff()
            end
        end
        army[unitID].models.models[modelID].associatedModels = nil
        table.remove(activeButtons, sameButtonIndex)
        self.UI.setAttribute(unitAndModelID, "color", "White")
    else
        table.insert(activeButtons, { unit = unitID, model = modelID, buttonID = unitAndModelID })
        self.UI.setAttribute(unitAndModelID, "color", "#ff00ca")

        if #activeButtons == 1 then -- if it's the first button selected
            broadcastToAll("Pick up a model or models to represent your selection!", {r=1, g=0, b=202/255})
        end
    end
end

function showAssociatedModel(_, _, button)
    highlightAssociatedModel(button, true)
end

function hideAssociatedModel(_, _, button)
    highlightAssociatedModel(button, false)
end

function highlightAssociatedModel(unitAndModelID, on)
    local idValues = split(unitAndModelID, "|")
    local buttonModel = army[idValues[1]].models.models[idValues[2]]

    if buttonModel.associatedModels ~= nil and #buttonModel.associatedModels > 0 then
        for _, associatedModel in ipairs(buttonModel.associatedModels) do
            local object = getObjectFromGUID(associatedModel.GUID)

            if object ~= nil then
                if on then
                    object.highlightOn({ r=51/255, g=1, b=51/255 })
                else
                    object.highlightOff()
                end
            end
        end
    end
end


---@param objects Object[]
function makeSureObjectsAreAttached(objects)
    for _, attachmentSet in ipairs(getObjectsToAttach(filter(objects, |object| #object.getJoints() > 0))) do
        for _, jointedObj in pairs(attachmentSet.toAttach) do
            if attachmentSet.lowestObj ~= jointedObj then
                attachmentSet.lowestObj.addAttachment(jointedObj)
            end
        end
    end
end


---@param objects Object[]
function getObjectsToAttach(objects)
    local toAttach = {}

    for _, object in ipairs(objects) do
        local attachmentSet = getObjectsToAttachRecursive(object, {}, {
            lowestY = object.getPosition().y,
            lowestObj = object,
            toAttach = { [object.getGUID()]=object }
        })

        for guid, _ in pairs(attachmentSet.toAttach) do
            for _, set in ipairs(toAttach) do
                if set.toAttach[guid] ~= nil then
                    mergeAttachmentSets(attachmentSet, set)
                    goto afterInsert
                end
            end
        end

        table.insert(toAttach, attachmentSet)
        ::afterInsert::
    end
    return toAttach
end


---@alias AttachmentSet { lowestY: integer, lowestObj: object, toAttach: { [string]: object } }

---comment
---@param object object
---@param found { [string]: bool }
---@param toAttachTable AttachmentSet
---@return AttachmentSet
function getObjectsToAttachRecursive(object, found, toAttachTable)
    for _, joint in ipairs(object.getJoints()) do
        if found[joint.joint_object_guid] == nil then
            local jointedObj = getObjectFromGUID(joint.joint_object_guid)  ---@cast jointedObj -nil
            local jointedObjY = jointedObj.getPosition().y

            found[joint.joint_object_guid] = true
            toAttachTable.toAttach[joint.joint_object_guid] = jointedObj

            if jointedObjY < toAttachTable.lowestY then
                toAttachTable.lowestY = jointedObjY
                toAttachTable.lowestObj = jointedObj
            end

            getObjectsToAttachRecursive(jointedObj, found, toAttachTable)
        end
    end

    return toAttachTable
end


---@param setToMerge AttachmentSet
---@param mergeIntoSet AttachmentSet
function mergeAttachmentSets(setToMerge, mergeIntoSet)
    for guid, obj in pairs(setToMerge.toAttach) do
        if mergeIntoSet.toAttach[guid] == nil then
            mergeIntoSet.toAttach[guid] = obj
        end
    end

    if setToMerge.lowestY < mergeIntoSet.lowestY then
        mergeIntoSet.lowestY = setToMerge.lowestY
        mergeIntoSet.lowestObj = setToMerge.lowestObj
    end
end


--[[ ARMY CREATION ]]--

-- formats and creates the army based on selected models
function createArmy()
    -- we only want to create models for ones that have a model selected
    local unitsToCreate = filter(army, function (unit)
        unit.models.models = filter(unit.models.models, function (model)
            if model.associatedModels == nil or #model.associatedModels == 0 then
                -- make sure we are spawning thr right number of models if only part of a unit is beign spawned
                unit.models.totalNumberOfModels = unit.models.totalNumberOfModels - model.number
            end

            return model.associatedModels ~= nil and #model.associatedModels > 0
        end)

        return len(unit.models.models) > 0
    end)

    if len(unitsToCreate) == 0 then
        broadcastToAll("You haven't selected any models!", ERROR_RED)
        return
    end

    -- delete anything that might get in the way in the future
    deleteAllObjectsInCreationZone()

    -- this feels so inefficient to go through the array so many times,
    -- but at this point, the array really shouldn't be that long,
    -- so I dont have to worry too much about big-O
    unitsToCreate = table.sort(map(unitsToCreate, function (unit)
        unit.models.models = table.sort(unit.models.models, |modelA, modelB| modelA.number < modelB.number)

        --[[ for _, model in ipairs(unit.models.models) do
            model.associatedModel = getObjectFromGUID(model.associatedModel)
        end --]]

        unit.footprint = determineFootprint(unit)

        return unit
    end), function (unitA, unitB)
        if unitA.footprint.width == unitB.footprint.width then
            return unitB.footprint.height < unitA.footprint.height
        end

        return unitA.footprint.width > unitB.footprint.width
    end)  --[[@as { [string]: Unit }]]

    local selfPosition = self.getPosition()

    -- at this point, we should have a list of units sorted by width then height of their footprints
    placeArmy(unitsToCreate, ARMY_PLACEMENT_STARTING_X + selfPosition.x, ARMY_PLACEMENT_STARTING_Z + selfPosition.z, selfPosition.y)
end

---@param unitMap { [string]: Unit }
---@param startingX int
---@param startingZ int
---@param startingY int
function placeArmy(unitMap, startingX, startingZ, startingY)
    local emptySlots = {} ---@type { x: int, z: int, h: int, w: int}[]
    local boundingBox = { h=0, w=0 }

    for _, unit in pairs(unitMap) do
        local placedInEmptySlot = false

        -- try to place at an origin
        for idx, slot in ipairs(emptySlots) do
            if unit.footprint.height <= slot.h and unit.footprint.width <= slot.w then
                placeUnit(unit, startingX-slot.x, startingZ+slot.z, startingY)

                if DEBUG then
                    table.insert(SLOT_POINTS.placed, { points= {
                        {startingX-slot.x, MODEL_PLACEMENT_Y+1, startingZ+slot.z},
                        {startingX-slot.x-unit.footprint.width, MODEL_PLACEMENT_Y+1, startingZ+slot.z},
                        {startingX-slot.x-unit.footprint.width, MODEL_PLACEMENT_Y+1, startingZ+slot.z+unit.footprint.height},
                        {startingX-slot.x, MODEL_PLACEMENT_Y+1, startingZ+slot.z+unit.footprint.height},
                        {startingX-slot.x, MODEL_PLACEMENT_Y+1, startingZ+slot.z}
                    },
                    color = {0, 0, 0}})
                end

                table.remove(emptySlots, idx)

                -- slot to the side should be filled first if possible
                -- so insert the top one first
                if (slot.h - unit.footprint.height) >= 1 then
                    if DEBUG then
                        table.insert(SLOT_POINTS.slot, {points= {
                            {startingX-slot.x, MODEL_PLACEMENT_Y+1, startingZ+slot.z+unit.footprint.height},
                            {startingX-slot.x-slot.w, MODEL_PLACEMENT_Y+1, startingZ+slot.z+unit.footprint.height},
                            {startingX-slot.x-slot.w, MODEL_PLACEMENT_Y+1, startingZ+slot.z+slot.h},
                            {startingX-slot.x, MODEL_PLACEMENT_Y+1, startingZ+slot.z+slot.h},
                            {startingX-slot.x, MODEL_PLACEMENT_Y+1, startingZ+slot.z+unit.footprint.height}
                        },
                        color = {0, 1, 0}})
                    end

                    table.insert(emptySlots, {
                        x = slot.x,
                        z = slot.z + unit.footprint.height,
                        h = slot.h - unit.footprint.height,
                        w = slot.w
                    })
                end

                if (slot.w - unit.footprint.width) >= 1 then
                    if DEBUG then
                        table.insert(SLOT_POINTS.slot, { points = {
                            {startingX-slot.x-unit.footprint.width, MODEL_PLACEMENT_Y+1, startingZ+slot.z},
                            {startingX-boundingBox.w, MODEL_PLACEMENT_Y+1, startingZ+slot.z},
                            {startingX-boundingBox.w, MODEL_PLACEMENT_Y+1, startingZ+slot.z+unit.footprint.height},
                            {startingX-slot.x-unit.footprint.width, MODEL_PLACEMENT_Y+1, startingZ+slot.z+unit.footprint.height},
                            {startingX-slot.x-unit.footprint.width, MODEL_PLACEMENT_Y+1, startingZ+slot.z}
                        },
                        color = {0, 0, 1}})
                    end

                    table.insert(emptySlots, {
                        x = slot.x + unit.footprint.width,
                        z = slot.z,
                        w = slot.w - unit.footprint.width,
                        h = unit.footprint.height
                    })
                end
                -- >= 1 because we dont want to make additional tiny slots that will never be filled

                placedInEmptySlot = true
                break;
            end
        end

        if placedInEmptySlot then -- do nothing

        -- if expanding upward makes sense
        elseif (boundingBox.h + unit.footprint.height) < (boundingBox.w * BOUNDING_BOX_RATIO) then
            placeUnit(unit, startingX, startingZ + boundingBox.h, startingY)

            if DEBUG then
                table.insert(SLOT_POINTS.placed, { points= {
                    {startingX, MODEL_PLACEMENT_Y+1, startingZ+boundingBox.h},
                    {startingX-unit.footprint.width, MODEL_PLACEMENT_Y+1, startingZ+boundingBox.h},
                    {startingX-unit.footprint.width, MODEL_PLACEMENT_Y+1, startingZ+boundingBox.h+unit.footprint.height},
                    {startingX, MODEL_PLACEMENT_Y+1, startingZ+boundingBox.h+unit.footprint.height},
                    {startingX, MODEL_PLACEMENT_Y+1, startingZ+boundingBox.h}
                },
                color = {0, 0, 0}})
            end

            if (boundingBox.w - unit.footprint.width >= 1) then
                if DEBUG then
                    table.insert(SLOT_POINTS.slot, { points= {
                        {startingX-unit.footprint.width, MODEL_PLACEMENT_Y+1, startingZ+boundingBox.h},
                        {startingX-boundingBox.w, MODEL_PLACEMENT_Y+1, startingZ+boundingBox.h},
                        {startingX-boundingBox.w, MODEL_PLACEMENT_Y+1, startingZ+boundingBox.h+unit.footprint.height},
                        {startingX-unit.footprint.width, MODEL_PLACEMENT_Y+1, startingZ+boundingBox.h+unit.footprint.height},
                        {startingX-unit.footprint.width, MODEL_PLACEMENT_Y+1, startingZ+boundingBox.h}
                    },
                    color = {1, 0, 1}})
                end

                table.insert(emptySlots, {
                    x = unit.footprint.width,
                    z = boundingBox.h,
                    h = unit.footprint.height,
                    w = boundingBox.w - unit.footprint.width
                })
            end

            boundingBox.h = boundingBox.h + unit.footprint.height

        -- else place at far left
        else
            placeUnit(unit, startingX - boundingBox.w, startingZ, startingY)

            if DEBUG then
                table.insert(SLOT_POINTS.placed, { points= {
                    {startingX-boundingBox.w, MODEL_PLACEMENT_Y+1, startingZ},
                    {startingX-boundingBox.w-unit.footprint.width, MODEL_PLACEMENT_Y+1, startingZ},
                    {startingX-boundingBox.w-unit.footprint.width, MODEL_PLACEMENT_Y+1, startingZ+unit.footprint.height},
                    {startingX-boundingBox.w, MODEL_PLACEMENT_Y+1, startingZ+unit.footprint.height},
                    {startingX-boundingBox.w, MODEL_PLACEMENT_Y+1, startingZ}
                },
                color = {0, 0, 0}})
            end

            if boundingBox.h - unit.footprint.height >= 1 then
                if DEBUG then
                    table.insert(SLOT_POINTS.slot, { points= {
                        {startingX-boundingBox.w, MODEL_PLACEMENT_Y+1, startingZ+unit.footprint.height},
                        {startingX-boundingBox.w-unit.footprint.width, MODEL_PLACEMENT_Y+1, startingZ+unit.footprint.height},
                        {startingX-boundingBox.w-unit.footprint.width, MODEL_PLACEMENT_Y+1, startingZ+boundingBox.h},
                        {startingX-boundingBox.w, MODEL_PLACEMENT_Y+1, startingZ+boundingBox.h},
                        {startingX-boundingBox.w, MODEL_PLACEMENT_Y+1, startingZ+unit.footprint.height}
                    },
                    color = {0, 0, 0}})
                end

                table.insert(emptySlots, {
                    x = boundingBox.w,
                    z = unit.footprint.height,
                    h = boundingBox.h - unit.footprint.height,
                    w = unit.footprint.width
                })
            end

            boundingBox.w = boundingBox.w + unit.footprint.width

            if boundingBox.h == 0 then boundingBox.h = unit.footprint.height end -- handle first unit
        end
    end

    if DEBUG then
        SLOT_POINTS.boundingBox = {{
            points= {
                {startingX, MODEL_PLACEMENT_Y+1, startingZ},
                {startingX-boundingBox.w, MODEL_PLACEMENT_Y+1, startingZ},
                {startingX-boundingBox.w, MODEL_PLACEMENT_Y+1, startingZ+boundingBox.h},
                {startingX, MODEL_PLACEMENT_Y+1, startingZ+boundingBox.h},
                {startingX, MODEL_PLACEMENT_Y+1, startingZ},
            },
            color = {0, 0, 0}
        }}
    end

    local boardPosition = { x=startingX-(boundingBox.w*0.5), y=5+startingY, z=startingZ+(boundingBox.h * 0.5) }
    local boardScale = { x=(0.5*boundingBox.w), y=1, z=(0.5*boundingBox.h)}

    if armyBoard == nil then
        armyBoard = spawnObject{
            type = "Custom_Tile",
            sound = false,
            position = boardPosition,
            scale = boardScale
        }
        armyBoard.setCustomObject{
            image = "https://steamusercontent-a.akamaihd.net/ugc/1698405413696745750/BC055E0445A3CEC1A0A0754CF4F1646977612B09/",
            thickness = 0.37
        }
        armyBoard.setLock(true)
    else
        armyBoard.setScale(boardScale)
        armyBoard.setPosition(boardPosition)
    end
end

---@param unit Unit
---@param startX int
---@param startZ int
---@param startY int
function placeUnit(unit, startX, startZ, startY)
    -- cheap way of determining a "sergeant" model:
    -- sort by number, pick the first, hope for the best
    local isFirstModel = true
    local xOffset = startX - DEFAULT_FOOTPRINT_PADDING -- left is negative
    local zOffset = startZ + DEFAULT_FOOTPRINT_PADDING -- up is positive
    local modelSize
    local currentRowHeight, currentModelsInRow = 0, 0
    local keys = {}  ---@type string[]
    for k in pairs(unit.weapons) do keys[#keys+1] = k end
    table.sort(keys, |weaponA, weaponB|weaponSort(unit.weapons[weaponA], unit.weapons[weaponB]))
    local weaponList = {}  ---@type { [string]: WeaponProfile }
    for _, weapon in ipairs(keys) do weaponList[weapon] = unit.weapons[weapon] end
    -- log(weaponList)
    unit.weapons = weaponList
    for _, weapon in pairs(unit.weapons) do
        if weapon.name:find('%s%-%s') and not weapon.name:find('\u{25ba}') and not weapon.name:lower():find('melee$') and not weapon.name:lower():find('ranged$') then
            weapon.name = '\u{25ba} '..weapon.name
        end
        if weapon.range:lower():find('^n/a') then
            weapon.range = 'N/A'
        end
    end
    local leaderData = formatLeaderScript(unit)
    for _, model in pairs(unit.models.models) do
        --local currentModelObj = getObjectFromGUID(model.associatedModel)
        -- I dont remember why I'm passing the data as an object instead of just as arguments
        local modelProfile = getProfileForModel(model, unit)
        if not modelProfile then
            print('invalid model data')
            return
        end
        local modelDescription = buildModelDescription(model, unit, modelProfile)
        local modelNickname = (modelProfile ~= nil and ("[00ff16]"..modelProfile.w.."/"..modelProfile.w.."[-] ") or "")
                                ..getModelDisplayName(model, unit)
        local modelTags = getModelTags(model, unit)
        ---@diagnostic disable-next-line: assign-type-mismatch
        local modelData = formatModelData( ---@type { [string]: var }[]
            model.associatedModels, modelDescription, modelNickname, modelTags)
        modelSize = model.associatedModelBounds.size
        --log(model)

        if currentRowHeight < modelSize.z then currentRowHeight = modelSize.z end
        for _=1, model.number do
            local spawned_model = createModelFromData(
                chooseRandomModel(modelData),  ---@diagnostic disable-line: param-type-mismatch
                --unit.decorativeName and unit.decorativeName or unit.name,
                xOffset - (modelSize.x*0.5),
                startY,
                zOffset + (modelSize.z*0.5),
                leaderData
            )
            spawned_model.addTag('leaderModel')
            spawned_model.setTable('unitLeaderTags', {'uuid_'..unit.uuid, 'lsModel', 'leaderModel'})
            table.insert(SLOT_POINTS.models, { points = {
                {xOffset, MODEL_PLACEMENT_Y+1, zOffset},
                {xOffset-modelSize.x, MODEL_PLACEMENT_Y+1, zOffset},
                {xOffset-modelSize.x, MODEL_PLACEMENT_Y+1, zOffset+modelSize.z},
                {xOffset, MODEL_PLACEMENT_Y+1, zOffset+modelSize.z},
                {xOffset, MODEL_PLACEMENT_Y+1, zOffset}
            },
            color = {0, 0, 1}})
            leaderData = nil
            currentModelsInRow = currentModelsInRow + 1
            if currentModelsInRow == unit.modelsPerRow then
                currentModelsInRow = 0
                xOffset = startX - DEFAULT_FOOTPRINT_PADDING
                zOffset = zOffset + currentRowHeight + DEFAULT_MODEL_SPACING
            else
                xOffset = xOffset - (modelSize.x + DEFAULT_MODEL_SPACING)
            end
        end
    end
end

-- determines how much space a unit should take up once it is created
---@param unit Unit
---@return { width: int, height: int }
function determineFootprint(unit)
    -- determine models per row
    local modelsPerRow = unit.models.totalNumberOfModels
    local currentModelsInRow, currentWidth, footprintWidth, footprintHeight, modelsLeft = 0, 0, 0, 0, 0
    local currentRow = 1
    local currentHeights = {}
    local currentModelBounds

    if modelsPerRow > 5 then
        if modelsPerRow < 20 and modelsPerRow % 3 == 0 then
            if modelsPerRow < 12 then modelsPerRow = 3
            else modelsPerRow = modelsPerRow / 3 end
        elseif modelsPerRow < 20 and modelsPerRow % 5 == 0 then
            modelsPerRow = 5
        elseif modelsPerRow > 10 then
            modelsPerRow = 10
        end
    end

    unit.modelsPerRow = modelsPerRow

    -- I realize that this is doing almost exactly what we will do later when actually creating the models
    -- unfortunately, this is the only way that I can think of to guarantee the footprint of a unit
    -- with models of different sizes
    for _, model in pairs(unit.models.models) do
        currentModelBounds = model.associatedModelBounds.size

        if currentHeights[currentRow] == nil or currentModelBounds.z > currentHeights[currentRow] then
            currentHeights[currentRow] = currentModelBounds.z
        end

        if (currentModelsInRow + model.number) >= modelsPerRow then
            currentWidth = currentWidth + ((modelsPerRow - currentModelsInRow) * (currentModelBounds.x + DEFAULT_MODEL_SPACING))

            if currentWidth > footprintWidth then footprintWidth = currentWidth end

            modelsLeft = model.number - (modelsPerRow - currentModelsInRow)
            currentRow = currentRow + 1

            while modelsLeft >= modelsPerRow do
                table.insert(currentHeights, currentModelBounds.z + DEFAULT_MODEL_SPACING)
                currentRow = currentRow + 1
                modelsLeft = modelsLeft - modelsPerRow
                currentWidth = (currentModelBounds.x + DEFAULT_MODEL_SPACING) * modelsPerRow
            end

            if modelsLeft > 0 then
                table.insert(currentHeights, currentModelBounds.z + DEFAULT_MODEL_SPACING)
                currentModelsInRow = modelsLeft
            end

            if currentWidth > footprintWidth then footprintWidth = currentWidth end

            currentWidth = currentModelsInRow * (currentModelBounds.x + DEFAULT_MODEL_SPACING)
        else
            currentWidth = currentWidth + (model.number * (currentModelBounds.x + DEFAULT_MODEL_SPACING))
            currentModelsInRow = currentModelsInRow + model.number
        end
    end

    --if footprintHeight == 0 then footprintHeight = currentHeight end -- in case it hasnt been set yet (usually only because a row hasnt been filled)
    for _, height in ipairs(currentHeights) do
        footprintHeight = footprintHeight + height
    end

    return { width = footprintWidth+(2*DEFAULT_FOOTPRINT_PADDING), height = footprintHeight+(2*DEFAULT_FOOTPRINT_PADDING) }
end

---@generic T : { [string]: var }[]
---formats both the leader and follower model data from a given model
---@param associatedModels T
---@param description string
---@param nickname string
---@param tags string[]
---@return T
function formatModelData(associatedModels, description, nickname, tags)
    for _, modelData in ipairs(associatedModels) do
        modelData.Description = description
        modelData.Nickname = nickname
        modelData.Tags = tags
        -- make sure base data doesnt include any xml or luascript
        modelData.XmlUI = ""
        modelData.LuaScript = ""
        modelData.LuaScriptState = nil
    end
    return associatedModels
end


---@param unit Unit
---@return string
function formatLeaderScript(unit)
    return interpolate(UNIT_SPECIFIC_DATA_TEMPLATE, {
        unitName = unit.name,
        unitDecorativeName = (unit.decorativeName ~= nil and unit.decorativeName ~= "") and unit.decorativeName:gsub('"', '\\"') or unit.name,
        factionKeywords = table.concat(unit.factionKeywords, ", "), -- dont break xml   --map(unit.factionKeywords, |keyword| (keyword:gsub(">", "＞"):gsub("<", "＜")))
        keywords = table.concat(unit.keywords, ", "), -- dont break xml   --map(unit.keywords, |keyword| (keyword:gsub(">", "＞"):gsub("<", "＜")))
        abilities = getFormattedAbilities(unit.abilities, unit.rules),
        models = table.concat(map(unit.modelProfiles, tableToFlatString), ", \n\t\t"),
        weapons = table.concat(map(unit.weapons, function (weapon) return interpolate(WEAPON_ENTRY_TEMPLATE_10E, weapon) end ), ", \n\t\t"),
        endBracket = "]]",
        uuid = unit.uuid,
        height = uiHeight,
        width = uiWidth,
        singleModel = (not unit.isSingleModel) and "" or ", \n\tisSingleModel = true",
    })..YELLOW_STORAGE_SCRIPT
end


---@param model Model
---@param unit Unit
---@return string
function getModelDisplayName(model, unit)
    if unit.isSingleModel or decorativeNames then
        if unit.decorativeName ~= nil and unit.decorativeName ~= "" then
            return unit.decorativeName
        else
            return model.name
        end
    end

    return model.name
end

---@param model Model
---@param unit Unit
---@return string[]
function getModelTags(model, unit)
    local tags = { "lsModel", "uuid_"..unit.uuid }
    return tags
end

---Combine abilities and rules and format them properly to be displayed in a unit's datasheet
---@param abilities { [string]: { name: string, desc: string } }
---@param rules any
---@return string
function getFormattedAbilities(abilities, rules)
    local keys = {}  ---@type string[]
    for k in pairs(abilities) do keys[#keys+1] = k end
    table.sort(keys, function (abl1, abl2)
        abl1 = abl1:lower():trim()--match('^%s*(.*)%s*$')
        abl2 = abl2:lower():trim()--match('^%s*(.*)%s*$')
        return (abl1 == 'core') or (abl1 == 'faction' and abl2 ~= 'core')
    end)
    local abilityList = {}  ---@type { [string]: { name: string, desc: string } }
    for _, abl in ipairs(keys) do abilityList[abl] = abilities[abl] end
    abilities = abilityList
    -- log(abilities)
    local abilitiesString = table.concat(map(abilities, function (ability)
        ability.name = ability.name:gsub("%[", "("):gsub("%]", ")") -- try not to break formatting

        return interpolate(ABILITITY_STRING_TEMPLATE, ability)
    end), ", \n\t\t")

    if #rules > 0 then
        abilitiesString = abilitiesString..
                            (len(abilities) > 0 and ", \n\t\t" or "")..
                            interpolate(ABILITITY_STRING_TEMPLATE, {
                                name="Additional Rules\n(see the books)",
                                desc = table.concat(map(rules, |rule| (rule:gsub("%[", "("):gsub("%]", ")"))), ", ")-- try not to break formatting
                            })
    end

    return abilitiesString
end

---@generic T: { [string]: var }
-- chooses a random model from the given array
-- technically this is a general method that could be used for selecting
-- a random value from any array
---@param modelArray T[]
---@return T?
function chooseRandomModel(modelArray)
    local model
    if not modelArray or #modelArray == 0 then
        model = nil
    elseif #modelArray == 1 then
        model = modelArray[1]
    else
        model = modelArray[math.random(1, #modelArray)] -- both inclusive
    end
    return model
end

-- spawns a model from the given data set
---@param modelData { [string]: var }
---@param x float
---@param z float
---@param y float
---@param leaderModelScript string?
---@return object
function createModelFromData(modelData, x, y, z, leaderModelScript)
    if leaderModelScript ~= nil then
        modelData = clone(modelData) -- prevent weird things with tables being treated as references
        table.insert(modelData.Tags, "leaderModel")
        modelData.XmlUI = YELLOW_STORAGE_XML
        modelData.LuaScript = leaderModelScript
    end
    local spawnData = {
        data = modelData,
        position = {
            x = x,
            y = MODEL_PLACEMENT_Y+y,
            z = z
        },
        rotation = { x=0, y=180, z=0 }, -- this seems right for most (but not all models)
    }
    local model = spawnObjectData(spawnData)
    return model
end

---finds the appropriate characteristic profile for the given model in the given unit
---@param model Model
---@param unit Unit
---@return ModelProfile?
function getProfileForModel(model, unit)
    local model_profile  ---@typr ModelProfile
    for _, profile in pairs(unit.modelProfiles) do
        if profile.name == model.name then
            model_profile = profile
            goto found
        end
    end
    -- if there arent any exactly matching profiles, try a more fuzzy search
    for _, profile in pairs(unit.modelProfiles) do
        local found = profile.name:find(model.name, 1, true) -- search for plain text (ie not pattern)
        if found ~= nil then
            model_profile = profile
            goto found
        end
    end
    -- if there arent any matching profiles, assume theres only one profile for every model in the unit
    for _, profile in pairs(unit.modelProfiles) do
        model_profile = profile
        goto found
    end
    -- returns nil if not found
    ::found::
    return model_profile
end

-- gets a model's description
---@param model Model
---@param unit Unit
---@param modelProfile ModelProfile
function buildModelDescription(model, unit, modelProfile)
    local sections = {
        formatCharDesc(unit, modelProfile),
        -- formatWeaponDesc(model, unit, modelProfile ~= nil),
        -- formatAbilityDesc(model, unit, modelProfile ~= nil),
        -- formatKeywords(model, unit, modelProfile ~= nil),
        formatWeaponDesc(model, unit),
        formatAbilityDesc(model, unit),
        formatKeywords(model, unit),
    }
    local desc = TableObject:new()
    for _, section in ipairs(sections) do
        if #section > 0 then
            desc:insert(section)
        end
    end
    return desc:concat('\n\n')
end

-- formats the characteristics section in a model's description
---@param unit Unit
---@param modelProfile ModelProfile
function formatCharDesc(unit, modelProfile)
    if modelProfile == nil then return "" end -- handles the rare case where a model just doesnt have a profile (eg Mekboy Workshop)

    local save = tonumber(modelProfile.sv:match('%d'))
    local saveStr = ''
    if loadedData.statsInvFNP then
        local invStr, fnpStr, inv ---@type string, string, integer
        for _, ability in pairs(unit.abilities) do
            if ability.name == 'Core' then
                invStr = ability.desc:match('Invulnerable (%d)%+')
                fnpStr = ability.desc:match('Feel No Pain (%d)%+')
                break
            end
        end
        if invStr then
            inv = tonumber(invStr)  --[[@as integer]]
            if inv == save then
                invStr = '++'
            else
                invStr = inv..'++'
            end
            saveStr = saveStr..'/[sup]'..invStr..'[/sup]'
        end
        if fnpStr then
            local fnp = tonumber(fnpStr)  --[[@as integer]]
            if fnp == inv or not inv and fnp == save then
                fnpStr = '+++'
            else
                fnpStr = fnp..'+++'
            end
            saveStr = saveStr..'/[sub]'..fnpStr..'[/sub]'
        end
        if saveStr:len() > 0 then
            saveStr = '[cccccc][i]'..saveStr..'[/i][-]'
        end
    end
    saveStr = modelProfile.sv..saveStr
    local headings = TableObject:new()  --@type TableObject<string>
    local values = TableObject:new()  ---@type TableObject
    for heading, value in pairs(modelProfile) do
        ---@cast heading string
        ---@cast value string
        if heading ~= "name" then
            if heading == 'sv' then
                value = saveStr
            elseif value == '-' then
                value = "  "..value
            end
            values:insert(value)
            heading = formatHeading(heading, value)
            headings:insert(heading)
        end
    end
    local headingStr = headings:concat()
    local valueStr = values:concat('   ')
    local desc = '[56f442]'..headingStr..'[-]\n'..valueStr
    return desc
end

-- formats the heading line for the characteristics section in a model's description
-- the spacing is based on the values given so that they line up properly
---@param heading string
---@param value string
---@return string
function formatHeading(heading, value)
    value = value:gsub("\\", ""):gsub('%[.-%]', '')
    local spacing = value:len() - heading:len()
    if heading == 'sv' and value:len() > 2 then
        spacing = spacing + 4 + math.floor(0.5*(value:len() - 2))
    elseif heading == 'ld' then
        spacing = spacing + 1
    elseif (heading == 't') and value:len() == 1 then
        spacing = spacing + 2
    elseif heading == 't' and value:len() > 1 then
        spacing = spacing + 3
    elseif (heading == 'w' or heading == 'oc') and value:len() > 1 then
        spacing = spacing + 4
    elseif heading ~= "m" then
        spacing = spacing + 3
    end

    if (heading == "m" and value:len() > 2) then -- or (heading == "w" and value:len() > 1)
        if heading == "m" and value:find('%-') ~= nil then
            spacing = spacing + 3
        else
            spacing = spacing + 1
        end
    end
    lspacing = math.floor(spacing/2)
    rspacing = heading ~= 'oc' and math.max(math.ceil(spacing/2), 3) or 0
    if heading == 'm' then
        rspacing = rspacing + 2
    elseif heading == 'ld' then
        rspacing = rspacing + 1
    end

    return (' '):rep(lspacing)..capitalize(heading)..(' '):rep(rspacing)
end


-- decides whether to fully capitalize or (in the case of ld and sv) titlecase a string
---@param heading string
---@return string
function capitalize(heading)
    if heading == "ld" or heading == "sv" then return titlecase(heading) end
    return heading:upper()
end


---only use this for changing ld and sv to Ld and Sv
---@param s string
---@return string
function titlecase(s)
    return s:gsub("^(%w)", |a| a:upper())  ---@diagnostic disable-line redundant-return-value
end


-- formats the string for the weapons section in a model's description
---@param model Model
---@param unit Unit
---@param needSpacingBefore? bool
---@return string
function formatWeaponDesc(model, unit, needSpacingBefore)
    if #model.weapons == 0 then return "" end

    ---@diagnostic disable-next-line: assign-type-mismatch
    local rangedWeapons = filter(model.weapons, |weapon| unit.weapons[weapon.name].range:lower() ~= "melee")  ---@type { name: string, number: int }[]
    ---@diagnostic disable-next-line: assign-type-mismatch
    local meleeWeapons = filter(model.weapons, |weapon| unit.weapons[weapon.name].range:lower() == "melee")  ---@type { name: string, number: int }[]

    -- local weapons = needSpacingBefore and "\n\n" or ""
    local weapons = TableObject:new()
    ---@param weaponList { name: string, number: int }[]
    ---@param initial string
    function addSection(weaponList, initial)
        if #weaponList == 0 then return end
        formatted = TableObject:new{('[e85545]%s weapons[-]'):format(initial)}
        local lastName  ---@type string?
        for _, weapon in ipairs(weaponList) do
    --         weapons = weapons.."\n"..formatWeapon(unit.weapons[weapon.name], weapon.number, lastName)
            formatted:insert(formatWeapon(unit.weapons[weapon.name], weapon.number, lastName))
            lastName = weapon.name
        end
        weapons:insert(formatted:concat('\n'))
    end
    addSection(rangedWeapons, 'Ranged')
    addSection(meleeWeapons, 'Melee')

    -- if #meleeWeapons > 0 then
    --     if #rangedWeapons > 0 then weapons = weapons .. "\n\n" end
    --     weapons = weapons .. "[e85545]Melee weapons[-]"
    --     for _, weapon in ipairs(meleeWeapons) do
    --         weapons = weapons.."\n"..formatWeapon(unit.weapons[weapon.name], weapon.number)
    --     end
    -- end

    return weapons:concat('\n\n')
end


---Formats the string for a weapon entry in a model's description
---@param weaponProfile WeaponProfile
---@param number int
---@param lastName? string
---@return string
function formatWeapon(weaponProfile, number, lastName)
    local profileName = weaponProfile.name:gsub('%s+%([Mm]elee%)$', ''):gsub('%s+%([Rr]anged%)$', '')
    profileName = profileName:gsub('%s*%-%s*[Mm]elee$', ''):gsub('%s*%-%s*[Rr]anged$', '')
    local isProfile = loadedData.indentWeaponProfiles and profileName:find('%s%-%s')
    if isProfile then
        local weaponName = profileName:match('(.*)%s%-')  ---@type string
        weaponName = weaponName:gsub('\u{25ba}%s', '') ---@type string
        profileName = profileName:match('%-%s(.*)') ---@type string
        lastName = lastName and lastName:match('(.*)%s%-')  ---@type string?
        lastName = lastName and lastName:gsub('\u{25ba}%s', '')
        if weaponName ~= lastName then
            weaponName = number == 1 and weaponName or (number..'\u{00d7}'..weaponName)
            profileName = weaponName..'\n\u{2514} '..profileName
        else
            profileName = '\u{2514} '..profileName
        end
    else
        profileName = number == 1 and profileName or (number..'\u{00d7}'..profileName)
    end
    local desc  ---@type string
    local stats = {
            name = profileName,
            a = weaponProfile.a,
            s = weaponProfile.s,
            ap = weaponProfile.ap,
            d = weaponProfile.d,
            -- ability = (not weaponProfile.shortAbilities or weaponProfile.shortAbilities == '-') and '' or 'Ab:' .. weaponProfile.shortAbilities
            -- ability = (not weaponProfile.shortAbilities or weaponProfile.shortAbilities == '-') and nil or '[7bc596][' .. weaponProfile.shortAbilities..'][-]'
            abilities = weaponProfile.shortAbilities and weaponProfile.shortAbilities ~= '-' and ('[7bc596][%s][-]'):format(weaponProfile.shortAbilities)
        }
    if weaponProfile.range:lower() == "melee" then
        stats.ws = weaponProfile.bsws
        desc = interpolate(MELEE_WEAPON_TEMPLATE_10E, stats)
    else
        stats.bs = weaponProfile.bsws:lower() == 'n/a' and '\u{2013}' or weaponProfile.bsws
        stats.range = weaponProfile.range:lower() == 'n/a' and ' \u{2014}   ' or weaponProfile.range
        desc = interpolate(RANGED_WEAPON_TEMPLATE_10E, stats):gsub('\n%s+', '\n')
    end
    if stats.abilities then
        style = loadedData.shortenWeaponAbilites and ' [sub]%s[/sub]' or '\n[sup]%s[/sup]'
        desc = desc..style:format(stats.abilities)
    end
    if weaponProfile.abilities:lower():find('psychic') then
        desc = desc:gsub('c6c930', '5785fe')
    end
    desc = desc:trim()
    if isProfile then
        desc = desc:gsub('%[%-%]\n', '%1    '):gsub('%d\n', '%1    ')
    end
    return desc
end


-- formats the string for the abilities section in a model's description
---@param model Model
---@param unit Unit
---@return string
function formatAbilityDesc(model, unit)
    if #model.abilities == 0 then return "" end
    local abilities = TableObject:new()
    local abilitiesStr
    if model.modelAbilities and unit.unitAbilities then
        if #model.modelAbilities > 0 then
            local modelAbilities = TableObject:new{'[dc61ed]Model Abilities[-]'}
            for _, abl in ipairs(model.modelAbilities) do
                if not abl:find('^[Uu]nit [Cc]omposition$') and (
                        not loadedData.statsInvFNP
                        or not abl:find('^Invulnerable %d%+$')
                        and not abl:find('^Feel No Pain %d%+$')
                    ) then
                    modelAbilities:insert(abl)
                end
            end
            abilities:insert(modelAbilities:concat('\n'))
        end
        local unitAbilities = TableObject:new{'[dc61ed]Unit Abilities[-]'}
        for _, abl in ipairs(unit.unitAbilities) do
            if not abl:find('^[Uu]nit [Cc]omposition$') and (
                    not loadedData.statsInvFNP
                    or not abl:find('^Invulnerable %d%+$')
                    and not abl:find('^Feel No Pain %d%+$')
                ) then
                unitAbilities:insert(abl)
            end
        end
        abilities:insert(unitAbilities:concat('\n'))
        abilitiesStr = abilities:concat('\n\n')
    else
        abilities:insert('[dc61ed]Abilities[-]')
        for _, abl in ipairs(model.abilities) do
            if not abl:find('^[Uu]nit [Cc]omposition$') and (
                    not loadedData.statsInvFNP
                    or not abl:find('^Invulnerable %d%+$')
                    and not abl:find('^Feel No Pain %d%+$')
                ) then
                abilities:insert(abl)
            end
        end
        abilitiesStr = abilities:concat('\n')
    end
    return abilitiesStr
end


---@param model Model
---@param unit Unit
---@param needSpacingBefore? bool
function formatKeywords(model, unit, needSpacingBefore)
    if not loadedData.showKeywords then return '' end
    local unitKeywords = TableObject:new()
    if loadedData.showKeywords == 'all' then
        unitKeywords:extend(unit.factionKeywords, unit.keywords)
    else
        for _, keyword in ipairs(unit.keywords) do
            if not ignoredKeywords[keyword] and unit.name ~= keyword and not unit.name:match('%('..keyword..'%)$') then
                table.insert(unitKeywords, keyword)
            end
        end
    end
    if not #unitKeywords then return '' end
    local keywords = table.concat(unitKeywords, ', ')
    keywords = "[48c9b0]Keywords[-]\n"..keywords
    return keywords
end


function deleteAllObjectsInCreationZone()
    local deletionZone = getObjectFromGUID(DELETION_ZONE_GUID) --[[@as Layout]]

    if deletionZone == nil then return end

    for _, object in ipairs(deletionZone.getObjects()) do
        if object ~= armyBoard and object.getGUID() ~= YELLOW_STORAGE_GUID then
            object.setLuaScript('') -- prevent unintended consequences of destruction
            object.destruct() -- at this point the object is a different object because we reloaded it
        end
    end
end

--[[ INITIALIZATION HELPER FUNCTIONS ]]--

---@param name string
function showWindow(name)
    -- delay in case of update
    Wait.frames(function ()
        UI.setXml(self.UI.getXml())

        Wait.frames(function ()
            UI.setAttribute("mainPanel", "active", true)
            UI.show(name)
        end, 2)
    end, 2)
end


--[[ LOADING FROM GLOBAL UI ]]--
---@param data RosterData
function loadEditedArmy(data)
    self.clearButtons()
    self.createButton(RELOAD_BUTTON)

    army = data.armyData
    uiHeight = data.uiHeight
    uiWidth = data.uiWidth
    decorativeNames = data.decorativeNames
    --YELLOW_STORAGE_SCRIPT = armyData.baseScript -- yes I know I'm assigning a new value to something I marked as a constant, sue me
    -- _printTable(data.order)
    local formattedArmyData = getLoadedArmyXML(data.order)

    if formattedArmyData.totalHeight < 3000 then
        self.UI.setAttributes("loadedScrollContainer", {
            noScrollbars = true,
            width = 2030
        })
    else
        self.UI.setAttributes("loadedScrollContainer", {
            noScrollbars = false,
            width = 2050
        })
    end

    self.UI.setAttribute("loadedContainer", "height", formattedArmyData.totalHeight)--formattedArmyData.totalHeight
    self.UI.setValue("loadedContainer", formattedArmyData.xml)
    self.UI.setAttribute("postLoading", "active", "false")
    self.UI.hide("postLoading")
    self.UI.setClass("mainPanel", "hiddenBigWindow")

    self.createButton(CREATE_ARMY_BUTTON)

    Wait.frames(function ()
        UI.hide("mainPanel")
        self.UI.setAttribute("loadedScrollContainer", "active", "true")
        self.UI.setXml(self.UI.getXml())
    end, 2)
end

---comment
---@param xml UITable[]
---@param tag string
function clearXMLTagRecursive(xml, tag)
    for _, uitable in ipairs(xml) do
        if uitable.attributes.id == tag then
            uitable.children = {}
        else
            clearXMLTagRecursive(uitable.children, tag)
        end
    end
end

---@param order string[]
---@return { xml: string, totalHeight: int }
function getLoadedArmyXML(order)
    local xmlString = ""
    local modelInUnitCount, modelDataForXML, currentUnitContainerHeight, totalUnitContainerHeight
    local maxModelHeight, totalHeight = 0, 0

    for _, uuid in ipairs(order) do
        local unit = army[uuid]
        local modelGroupString, unitDataString = "", ""

        modelInUnitCount = 0
        currentUnitContainerHeight = 0
        totalUnitContainerHeight = 50 -- name

        for modelID, model in pairs(unit.models.models) do
            modelInUnitCount = modelInUnitCount + 1
            modelDataForXML = getModelDataForXML(uuid, modelID, model, unit.weapons)
            modelGroupString = modelGroupString..interpolate(uiTemplates.MODEL_CONTAINER, modelDataForXML)

            if modelDataForXML.height > maxModelHeight then
                maxModelHeight = modelDataForXML.height
                currentUnitContainerHeight = modelDataForXML.height
            end

            if modelInUnitCount % 4 == 0 then
                unitDataString = unitDataString..interpolate(uiTemplates.MODEL_GROUPING_CONTAINER, {
                    modelGroups = modelGroupString,
                    width = "1000",
                    height = maxModelHeight
                })

                modelInUnitCount = 0
                maxModelHeight = 0
                modelGroupString = ""
                totalUnitContainerHeight = totalUnitContainerHeight + currentUnitContainerHeight + 20 -- spacing
            end
        end

        if modelInUnitCount ~= 0 then
            unitDataString = unitDataString..interpolate(uiTemplates.MODEL_GROUPING_CONTAINER, {
                modelGroups = modelGroupString,
                width = tostring(250 * modelInUnitCount),
                height = maxModelHeight
            })
            maxModelHeight = 0
            totalUnitContainerHeight = totalUnitContainerHeight + currentUnitContainerHeight
        end

        totalHeight = totalHeight + totalUnitContainerHeight + 100 -- spacing

        xmlString = xmlString..interpolate(uiTemplates.UNIT_CONTAINER, {
            unitName = unit.decorativeName and unit.decorativeName or unit.name,
            unitData = unitDataString,
            height = totalUnitContainerHeight
        })
    end

    return { xml = xmlString, totalHeight = totalHeight }
end

---@param weaponA WeaponProfile
---@param weaponB WeaponProfile
---@return bool
function weaponSort(weaponA, weaponB)
    local aIsCCW = weaponA.name:lower():find("close combat weapon") and 1 or 0
    local bIsCCW = weaponB.name:lower():find("close combat weapon") and 1 or 0
    local aIsMelee = weaponA.range:lower():find("melee") and 1 or 0
    local bIsMelee = weaponB.range:lower():find("melee") and 1 or 0
    local aHasRange = weaponA.range:lower():find("^%d") and 1 or 0
    local bHasRange = weaponB.range:lower():find("^%d") and 1 or 0
    local aIsPistol = weaponA.abilities:lower():find("pistol") and 1 or 0
    local bIsPistol = weaponB.abilities:lower():find("pistol") and 1 or 0
    local aIsOneShot = weaponA.abilities:lower():find("one.shot") and 1 or 0
    local bIsOneShot = weaponB.abilities:lower():find("one.shot") and 1 or 0
    local aIsExtraAttacks = weaponA.abilities:lower():find("extra attacks") and 1 or 0
    local bIsExtraAttacks = weaponB.abilities:lower():find("extra attacks") and 1 or 0
    if aIsCCW ~= bIsCCW then
        return aIsCCW < bIsCCW
    elseif aIsExtraAttacks ~= bIsExtraAttacks then
        return aIsExtraAttacks < bIsExtraAttacks
    elseif aIsMelee ~= bIsMelee then
        return aIsMelee < bIsMelee
    elseif aHasRange ~= bHasRange then
        return aHasRange < bHasRange
    elseif aIsPistol ~= bIsPistol then
        return aIsPistol < bIsPistol
    elseif aIsOneShot ~= bIsOneShot then
        return aIsOneShot < bIsOneShot
    else
        return false
        -- return weaponA.name < weaponB.name
    end

end


---comment
---@param unitID any
---@param modelID any
---@param model Model
---@param characteristicProfiles any
---@return table
function getModelDataForXML(unitID, modelID, model, characteristicProfiles)
    local weaponSection, abilitiesSection = "", ""
    local totalCardHeight = 40 -- name
    -- model.weapons = table.sort(model.weapons, |weaponA, weaponB| weaponSort(characteristicProfiles[weaponA.name], characteristicProfiles[weaponB.name]))
    table.sort(model.weapons, |weaponA, weaponB| weaponSort(characteristicProfiles[weaponA.name], characteristicProfiles[weaponB.name]))

    if model.weapons ~= nil and #model.weapons > 0 then
        weaponSection = interpolate(uiTemplates.MODEL_DATA, {
            dataType = "Weapons:",
            data = table.concat(map(model.weapons,
                                    |weapon| weapon.number == 1 and weapon.name or (weapon.number.."x "..weapon.name))
                                , "\n"),
            height = 37 * #model.weapons
        })
        totalCardHeight = totalCardHeight + (37 * #model.weapons) + (#model.abilities > 0 and 55 or 60) -- title and spacer
    end

    if #model.abilities > 0 then
        abilitiesSection = interpolate(uiTemplates.MODEL_DATA, {
            dataType = "Abilities:",
            data = table.concat(model.abilities, "\n"),
            height = 37 * #model.abilities
        })
        totalCardHeight = totalCardHeight + (37 * #model.abilities) + 60 -- title and spacer
    end

    return {
        modelName = model.name,
        numberString = model.number > 1 and (tostring(model.number).."x ") or "",
        weapons = weaponSection,
        abilities = abilitiesSection,
        unitID = unitID,
        modelID = modelID,
        height = totalCardHeight
    }
end




--[[ UTILITY FUNCTIONS ]]--

---Populates a template string from provided key-value pairs
---@param templateString string
---@param replacementValues { [string]: string|integer }
---@return string
function interpolate(templateString, replacementValues)
    return (templateString:gsub('($%b{})', |w| replacementValues[w:sub(3, -2)] or w)) -- extra parenthesis to prevent double return from gsub
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

---comment
---@param s string
---@param delimiter string
---@return string[]
function split(s, delimiter)
    local result = {}
    for match in (s..delimiter):gmatch("(.-)%"..delimiter) do
        table.insert(result, match)
    end
    return result
end

---comment
---@generic K: any
---@generic V: any
---@param t table<K, V>
---@param filterFunc fun(table, K, V): bool
---@return table<K, V>
function filter(t, filterFunc)
    local out = {}

    for k, v in pairs(clone(t)) do
        if filterFunc(v, k, t) then table.insert(out, v) end
    end

    return out
end

function includes(tab, val, checkKey)
    for _, value in ipairs(tab) do
        if checkKey ~= nil then
            if value[checkKey] == val[checkKey] then
                return true
            end
        else
            if value == val then
                return true
            end
        end
    end

    return false
end

function find(tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return index
        end
    end

    return -1
end

function map(t, mapFunc)
    local out = {}

    for k, v in pairs(clone(t)) do
        table.insert(out, mapFunc(v, k))
    end

    return out
end

---@param t table
---@return integer
function len(t)
    local count = 0
    for _, _ in pairs(t) do
        count = count + 1
    end
    return count
end


---@param s string
function string.trim(s)  ---@diagnostic disable-line duplicate-set-field
    return s:gsub('^%s+', ''):gsub('%s+$', '')
end


-- this should only ever be used with one dimensional tables
function tableToFlatString(t)
    return tableToString(t, ", ")
end

-- this is not a particularly robust solution, it is only really for my purposes in this script
-- thus, I very much do not recommend anyone copy this
-- note to self: can make it recursive to traverse multi-dimensional tables but eh
-- warnings:
--      this assumes a table is array-like if the key "1" exists,
--      this assumes all values are strings
function tableToString(t, delimiter, bracketsOnNewLine, extraTabbing, tabBeforeFirstElement)
    local out = "{ "
    local arrayLike = t[1] ~= nil

    if bracketsOnNewLine ~= nil and bracketsOnNewLine then
        out = out.."\n"..(tabBeforeFirstElement ~= nil and tabBeforeFirstElement or "")
    end

    out = out..table.concat(map(t, function (v, k)
        if arrayLike then return v end
        return k..'="'..v:gsub('"', '\\"')..'"'
    end), delimiter)

    if bracketsOnNewLine ~= nil and bracketsOnNewLine then
        return out.."\n"..(extraTabbing ~= nil and extraTabbing or "").."}"
    end

    return out.." }"
end

---@param t table<any, any>
---@param i? int
function _printTable(t, i)
    if not i then
        i = 0
    end
    for key, value in pairs(t) do
        if type(value) == 'table' then
            local contents = false
            for _ in pairs(value) do
                contents = true
                break
            end
            if contents then
                log(('%s%s = {'):format((' '):rep(i), tostring(key)))
                _printTable(value, i + 2)
                log((' '):rep(i)..'}')
            else
                log(('%s%s = {}'):format((' '):rep(i), tostring(key)))
            end
        else
            log(('%s%s = %s'):format((' '):rep(i), tostring(key), tostring(value)))
        end
    end
end