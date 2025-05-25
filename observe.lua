local BRIDGE = peripheral.find("meBridge")
local CONFIG_REDSTONE_OUTPUT_SIDE = "back"
local OBSERVED = {
    {
        name = "gtceu:iridium_dust",
        minimumCount = 256,
        type = "item"
    },
    {
        name = "gtceu:osmium_dust",
        minimumCount = 256,
        type = "item"
    }
}

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

local function observeLoop()
    redstoneActive = false
    
    while true do
        minimumReachedAmount = #OBSERVED
        shell.run("clear")
        
        for i = 1, #OBSERVED do
            if OBSERVED[i]["type"] == "fluid" then
                amount = getCountFluid(OBSERVED[i]["name"])
            elseif OBSERVED[i]["type"] == "item" then
                amount = getCountItem(OBSERVED[i]["name"])
            end

            if amount < OBSERVED[i]["minimumCount"] then
                print(OBSERVED[i]["name"], "is under its minimum", OBSERVED[i]["minimumCount"])
                minimumReachedAmount = minimumReachedAmount - 1
            end
        end

        if minimumReachedAmount == 0 then
            redstone.setOutput(CONFIG_REDSTONE_OUTPUT_SIDE, false)
        else
            redstone.setOutput(CONFIG_REDSTONE_OUTPUT_SIDE, true)
        end

        os.sleep(15)
    end
end

observeLoop()
