-- VERSION 1.1
-- 2025-06-08
-- Antonia

local CONFIG_FILE = "exporter-config"

-- non-local so it can be overriden but have a default
BRIDGE = peripheral.find("meBridge")
UPDATE_RATE = 10
-- GLOBAL_TARGET = "back"
MAX_LINES = 10

local function getCountItem(itemName)
    item = BRIDGE.getItem({name=itemName})
    
    if item == nil then
        return 0
    end
    
    return item["amount"]
end    

local function getCountFluid(fluidName)
    allFluids = BRIDGE.listFluid()
    
    for i = 1, #allFluids do
        if allFluids[i]["name"] == fluidName then
            return allFluids[i]["amount"]
        end  
    end
    
    return 0
end

local function getCountThing(name, type)
    if type == "item" then
        return getCountItem(name)
    elseif type == "fluid" then
        return getCountFluid(name)
    end
end

local function exportItem(itemName, count, target)
    local time = textutils.formatTime(os.time("local"), true)

    print(time, "| Export", itemName, "for", count)
    BRIDGE.exportItem({name=itemName, count=count}, target)
end

local function exportFluid(fluidName, count, target)
    local time = textutils.formatTime(os.time("local"), true)
    
    print(time, "| Export", fluidName, "for", count / 1000 .. "B")
    BRIDGE.exportFluid({name=fluidName, count=count}, target)
end    

local function exportThing(name, count, target, type)
    local time = textutils.formatTime(os.time("local"), true)

    if type == "item" then
        exportItem(name, count, target)
    elseif type == "fluid" then
        exportFluid(name, count, target)
    end
end

local function exportConditional(target)
    -- get amount of item we're observing
    for _, exportItem in pairs(EXPORTS) do
        conditionSuccessful = false

        -- get condition of export item
        conditionName = exportItem["condition"]

        -- if only using "overflow" there might not be a CONDITIONS table
        if CONDITIONS ~= nil then
            conditionObject = CONDITIONS[conditionName]
        end

        -- check if the condition is "overflow" - special built-in condition
        if conditionName == "overflow" then
            actualAmount = getCountThing(exportItem["name"], exportItem["type"])

            if actualAmount > exportItem["count"] then
                toExportAmount = actualAmount - exportItem["count"]
                toExportName = exportItem["name"]
                toExportType = exportItem["type"]

                conditionSuccessful = true
            end
        elseif (conditionObject["mode"] == "when_less" or conditionObject["mode"] == "when_more") then
            -- check if the condition is actually true
            conditionObjectActualAmount = getCountThing(conditionObject["name"], conditionObject["type"])
            conditionObjectCheckAmount = conditionObject["count"]
            toExportAmount = exportItem["count"]

            if conditionObject["mode"] == "when_less" then
                if conditionObjectCheckAmount > conditionObjectActualAmount then
                    conditionSuccessful = true
                end
            elseif conditionObject["mode"] == "when_more" then
                if conditionObjectCheckAmount < conditionObjectActualAmount then
                    conditionSuccessful = true
                end
            end
        end

        -- when the set condition is true, export things
        if conditionSuccessful then
            toExportName = exportItem["name"]
            toExportType = exportItem["type"]

            exportThing(toExportName, toExportAmount, target, toExportType)
        end
    end
end    

local function exportLoop()
    shell.run("clear")

    require(CONFIG_FILE)
    local target = GLOBAL_TARGET

    while true do
        exportConditional(target)
        sleep(UPDATE_RATE)
    end
end

exportLoop()                    
