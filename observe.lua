local BRIDGE = peripheral.find("meBridge")
local CONFIG_FILE = "observe-config"

local function getCountItem(itemName)
    item = BRIDGE.getItem({name=itemName})
    
    if item == nil then
        return 0
    end
    
    return item["amount"]
end    
 
local function getCountFluid(fluidName, asBuckets)
    allFluids = BRIDGE.listFluid()
    
    for i = 1, #allFluids do
        if allFluids[i]["name"] == fluidName then
            return allFluids[i]["amount"]
        end  
    end
    
    return 0
end

local function printObservedItems()
    local time = textutils.formatTime(os.time("local"), true)

    print("Last updated:", time)
    print()
    print("Observed objects:")
    
    for _, item in pairs(OBSERVED) do
        term.setTextColor(item["color"])

        if item["type"] == "item" then
            print(item["name"], "T:", item["minimumCount"], "A:", item["actualAmount"])
        else
            print(item["name"], "T:", item["minimumCount"] / 1000 .. 'B', "A:", item["actualAmount"] / 1000 .. 'B')
        end
        if NEWLINES then
            print()
        end
    end

    term.setTextColor(colors.white)
end

local function observeLoop()
    redstoneActive = false
    require(CONFIG_FILE)
    
    while true do
        minimumReachedAmount = #OBSERVED
        shell.run("clear")
        
        -- prepare table
        for i = 1, #OBSERVED do
            if OBSERVED[i]["type"] == "fluid" then
                amount = getCountFluid(OBSERVED[i]["name"])
            elseif OBSERVED[i]["type"] == "item" then
                amount = getCountItem(OBSERVED[i]["name"])
            end

            OBSERVED[i]["actualAmount"] = amount

            if OBSERVED[i]["actualAmount"] < OBSERVED[i]["minimumCount"] then
                OBSERVED[i]["color"] = colors.red
                minimumReachedAmount = minimumReachedAmount - 1
            else
                OBSERVED[i]["color"] = colors.white
                minimumReachedAmount = minimumReachedAmount - 1
            end
        end

        printObservedItems()

        if minimumReachedAmount == #OBSERVED then
            redstone.setOutput(CONFIG_REDSTONE_OUTPUT_SIDE, true)
        else
            redstone.setOutput(CONFIG_REDSTONE_OUTPUT_SIDE, false)
        end

        os.sleep(UPDATE_RATE)
    end
end

local function checkConfigExists()
    if not fs.exists(CONFIG_FILE) then
        print("Configuration file", CONFIG_FILE, "does not exist! Exiting now.")
        error()
    end
end

checkConfigExists()
observeLoop()
