local BRIDGE = peripheral.find("meBridge")
local CONFIG_REDSTONE_OUTPUT_SIDE = "left"
local OBSERVED = {
    {
        name = "gtceu:ethylbenzene",
        minimumCount = 500000,
        type = "fluid"
    },
    {
        name = "gtceu:ammonia",
        minimumCount = 500000,
        type = "fluid"
    },
    {
        name = "gtceu:coal_tar",
        minimumCount = 500000,
        type = "fluid"
    },
    {
        name = "gtceu:carbon_dioxide",
        minimumCount = 500000,
        type = "fluid"
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

        if minimumReachedAmount == #OBSERVED then
            redstone.setOutput(CONFIG_REDSTONE_OUTPUT_SIDE, true)
        else
            redstone.setOutput(CONFIG_REDSTONE_OUTPUT_SIDE, false)
        end

        os.sleep(15)
    end
end

observeLoop()
