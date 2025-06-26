-- VERSION 0.6
-- 2025-06-26
-- Antonia

local CONFIG_FILE = "observe-config"

-- non-local so it can be overriden but have a default
NEWLINES = true
UPDATE_RATE = 15
BRIDGE = peripheral.find("meBridge")
CONFIG_REDSTONE_OUTPUT_SIDE = ""
INVERT_REDSTONE = false

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

    redstonePrintLine = "Redstone: " .. CONFIG_REDSTONE_OUTPUT_SIDE .. " & " .. rsStatus

    if INVERT_REDSTONE then
        redstonePrintLine = redstonePrintLine .. " (inverted)"
    end

    print(redstonePrintLine)
    print()
    print("Observed objects:")
    
    for _, item in pairs(OBSERVED) do
        color = item["color"]
        
        if color == nil then
            color = colors.white
        end

        term.setTextColor(color)

        minimumCountStr = "min"
        maximumCountStr = "max"

        -- build output string for this item
        itemLine = item["name"]
        itemLine = itemLine .. " T:"
        
        -- if item has minimum count, add this to string
        if item["minimumCount"] ~= nil then
            if item["type"] == "item" then
                itemLine = itemLine .. " " .. minimumCountStr .. " " .. item["minimumCount"]
            else
                itemLine = itemLine .. " " .. minimumCountStr .. " " .. item["minimumCount"] / 1000 .. "B"
            end
        end

        if item["maximumCount"] ~= nil then
            if item["type"] == "item" then
                itemLine = itemLine .. " " .. maximumCountStr .. " " .. item["maximumCount"]
            else
                itemLine = itemLine .. " " .. maximumCountStr .. " " .. item["maximumCount"] / 1000 .. "B"
            end
        end

        -- now add actual amount
        -- differentiate between item and fluid to do some maths to make buckets nicer to read
        if item["type"] == "item" then
            itemLine = itemLine .. " " .. "A:" .. " " .. item["actualAmount"]
        else
            itemLine = itemLine .. " " .. "A:" .. " " .. item["actualAmount"] / 1000 .. "B"
        end

        print(itemLine)

        if NEWLINES then
            print()
        end
    end

    term.setTextColor(colors.white)
end

local function observeLoop()
    require(CONFIG_FILE)
    
    while true do
        local time = textutils.formatTime(os.time("local"), true)
        redstoneChanged = false
        redstoneActive = true
        doLoop = true
        shell.run("clear")

        for i = 1, #OBSERVED do
            -- check if there is an ME
            if BRIDGE.listCells() == nil then
                print(time)
                print("ME not found, skipping...")
                doLoop = false
                break
            end

            if OBSERVED[i]["type"] == "fluid" then
                amount = getCountFluid(OBSERVED[i]["name"])
            elseif OBSERVED[i]["type"] == "item" then
                amount = getCountItem(OBSERVED[i]["name"])
            end

            OBSERVED[i]["actualAmount"] = amount

            if OBSERVED[i]["actualAmount"] == nil then
                OBSERVED[i]["actualAmount"] = "N/A"
                goto continue
            end

            -- check if the item has a minimum we must act for
            if OBSERVED[i]["minimumCount"] ~= nil then
                if OBSERVED[i]["actualAmount"] <= OBSERVED[i]["minimumCount"] then
                    OBSERVED[i]["color"] = colors.red

                    if redstoneChanged then
                        goto continue
                    end

                    redstoneActive = false
                    redstoneChanged = true

                    goto continue
                else
                    OBSERVED[i]["color"] = colors.white
                end

            end

            -- check if the item has a maximum we must act for
            if OBSERVED[i]["maximumCount"] ~= nil then
                if OBSERVED[i]["actualAmount"] >= OBSERVED[i]["maximumCount"] then
                    OBSERVED[i]["color"] = colors.green

                    -- maximum takes precedence
                    -- if redstoneChanged then
                    --    goto continue
                    -- end

                    redstoneActive = true
                    redstoneChanged = true

                    goto continue
                else
                    OBSERVED[i]["color"] = colors.white
                end
            end

            ::continue::
        end

        if INVERT_REDSTONE then
            redstoneActive = not redstoneActive
        end

        redstone.setOutput(CONFIG_REDSTONE_OUTPUT_SIDE, redstoneActive)
        
        if doLoop then
            printObservedItems()
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
