-- VERSION 0.1
-- 2025-05-25

local CONFIG_FILE = "exporter-config"

-- non-local so it can be overriden but have a default
BRIDGE = peripheral.find("meBridge")
UPDATE_RATE = 10
GLOBAL_TARGET = "back"

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

local function exportConditional(target)
    for item, values in pairs(EXPORTS) do
        if values["type"] == "item" then
            amountME = getCountItem(values["name"])
        elseif values["type"] == "fluid" then
            amountME = getCountFluid(values["name"])
        end
         
        if amountME > values["count"] then
            toExportAmount = amountME - values["count"]
            if values["type"] == "item" then
                exportItem(values["name"], toExportAmount, target)
            elseif values["type"] == "fluid" then
                exportFluid(values["name"], toExportAmount, target)
            end
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
        
        printedLines = printedLines + 1

        if printedLines == MAX_LINES then
            shell.run("clear")
        end
    end
end

exportLoop()                    
