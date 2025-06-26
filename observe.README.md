# Observe

Observe.lua looks for amounts of items/fluids that you want to observe and emits redstone signals depending on its amount. If any minimum count is not met, a redstone signal is emitted.

Every UPDATE_RATE, all observed items and their amounts are printed.

Create a file that looks like this and call it `observe-config`:
```lua
UPDATE_RATE = 15
NEWLINES = true
CONFIG_REDSTONE_OUTPUT_SIDE = "left"
{
        name = "gtceu:nitrogen_dioxide",
        minimumCount = 500000,
        type = "fluid",
    },
    {
        name = "gtceu:deuterium",
        minimumCount = 500000,
        type = "fluid",
    },
    {
        name = "enderio:item_conduit",
        maximumCount = 128,
        minimumCount = 50,
        type = "item",
    },
    {
        name = "enderio:vibrant_conduit",
        maximumCount = 50,
        minimumCount = 10,
        type = "item",
    }
```

You may start with the example `observe-config` provided here.

An item can have a maximumCount, minimumCount or both at the same time.
If any item's maximum is reached, redstone is turned off. Maximum counts take precedence, i.e., even if a minimum is active, redstone output is toggled when at least one maximum is reached.

Red lines denote when a minimum is fulfilled. Green lines denote a maximum having been reached.

Notes:
- Amounts for fluids are given as mB.
- Without the configuration file, the script will not work.
- If `NEWLINES` is given, each observed item is followed by a new line, aiding readability, true by default.
- `CONFIG_REDSTONE_OUTPUT_SIDE` determines the side to output a redstone signal to, set to "back" by default.
- `UPDATE_RATE` determines how often to check the amounts in the ME in seconds and is set to 15s by default.
- You can add a `mode` to an item