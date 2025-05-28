# Observe

Observe.lua looks for amounts of items/fluids that you want to observe and emits redstone signals depending on its amount. If any minimum count is not met, a redstone signal is emitted.

Every UPDATE_RATE, all observed items and their amounts are printed.

Create a file that looks like this and call it `observe-config`:
```lua
UPDATE_RATE = 15
NEWLINES = true
CONFIG_REDSTONE_OUTPUT_SIDE = "left"
OBSERVED = {
    {
        name = "gtceu:ethylbenzene",
        minimumCount = 500000,
        type = "fluid"
    },
    {
        name = "gtceu:carbon_dust",
        minimumCount = 64,
        type = "item"
    }
}
```

You may start with the example `observe-config` provided here.

Notes:
- Amounts for fluids are given as mB.
- Without the configuration file, the script will not work
- If `NEWLINES` is given, each observed item is followed by a new line, aiding readability, true by default
- `CONFIG_REDSTONE_OUTPUT_SIDE` determines the side to output a redstone signal to, set to "back" by default
- `UPDATE_RATE` determines how often to check the amounts in the ME in seconds and is set to 15s by default