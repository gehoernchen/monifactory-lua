-- VERSION 0.3
-- 2025-05-28
-- Antonia

local CONFIG_FILE = "observe-config"

-- non-local so it can be overriden but have a default
NEWLINES = true
UPDATE_RATE = 15
BRIDGE = peripheral.find("meBridge")
CONFIG_REDSTONE_OUTPUT_SIDE = ""

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

    if redstone.getOutput(CONFIG_REDSTONE_OUTPUT_SIDE) then
        rsStatus = "Enabled"
    else
        rsStatus = "Disabled"
    end

    print("Redstone:", CONFIG_REDSTONE_OUTPUT_SIDE, "&", rsStatus)
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
    require(CONFIG_FILE)
    
    while true do
        redstoneActive = true
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
                redstoneActive = false
            else
                OBSERVED[i]["color"] = colors.white
            end
        end

        redstone.setOutput(CONFIG_REDSTONE_OUTPUT_SIDE, redstoneActive)
        printObservedItems()

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
