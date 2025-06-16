while true do
    redstone.setOutput("top", true)
    redstone.setOutput("right", true)
    redstone.setOutput("front", true)
    redstone.setOutput("left", true)
    redstone.setOutput("back", true)
    redstone.setOutput("bottom", true)
    os.sleep(1)

    redstone.setOutput("top", false)
    redstone.setOutput("right", false)
    redstone.setOutput("front", false)
    redstone.setOutput("left", false)
    redstone.setOutput("back", false)
    redstone.setOutput("bottom", false)

    print("Updated, sleeping for 1 hour")
    os.sleep(3600)
end
