-- VERSION 0.1
-- 2025-05-25

shell.run("clear")

local bridge = peripheral.find("meBridge")
local globalTarget = "north"

exports = {
    { 
        name = "gtceu:aluminium_dust",
        count = 64,
        type = "item"
    },
    {
        name = "gtceu:hydrogen",
        count = 16000,
        type = "fluid"
    },
    {
        name = "gtceu:carbon_dust",
        count = 64,
        type = "item"
    },
    {
        name = "gtceu:sulfuric_acid",
        count = 16000,
        type = "fluid"
    },
    {
        name = "gtceu:hydrochloric_acid",
        count = 16000,
        type = "fluid"
    }    
}

local function getCountItem(itemName)
    item = bridge.getItem({name=itemName})
    
    if item == nil then
        return 0
    end
    
    return item["amount"]
end    

local function getCountFluid(fluidName)
    allFluids = bridge.listFluid()
    
    for i = 1, #allFluids do
        if allFluids[i]["name"] == fluidName then
            return allFluids[i]["amount"]
        end  
    end
    
    return 0
end

local function exportItem(itemName, count, target)
    print("Exporting", itemName, "for", count)
    bridge.exportItem({name=itemName, count=count}, target)
end

local function exportFluid(fluidName, count, target)
    print("Exporting", fluidName, "for", count)
    bridge.exportFluid({name=fluidName, count=count}, target)
end    

local function exportConditional()
    for item, values in pairs(exports) do
        if values["type"] == "item" then
            amountME = getCountItem(values["name"])
        elseif values["type"] == "fluid" then
            amountME = getCountFluid(values["name"])
        end
         
        if amountME > values["count"] then
            toExportAmount = amountME - values["count"]
            if values["type"] == "item" then
                exportItem(values["name"], toExportAmount, globalTarget)
            elseif values["type"] == "fluid" then
                exportFluid(values["name"], toExportAmount, globalTarget)
            end
        end
    end
end    

local function exportLoop()
    while true do
        exportConditional()
        sleep(5)
    end
end

exportLoop()                    
