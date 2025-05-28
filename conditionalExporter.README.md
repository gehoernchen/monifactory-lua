# Conditioanl Exporter

This script exports all items/fluids from one ME system to a storage container in a specified direction over a specified threshold. This might be used to export overflow from one ME to another ME or from one ME to a chest, etc.

Create a file that looks like this and call it `exporter-config`:
```lua
GLOBAL_TARGET = "north"
UPDATE_RATE = 15

EXPORTS = {
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
}
```

This example file will make sure that only 64 aluminium dust and 16 buckets of Hydrogen are kept in the source ME and pushed to the external storage container.

Notes:
- Amounts for fluids are given as mB.
- The `GLOBAL_TARGET` is the direction of a storage container seen from the ME Bridge. I.e., the external storage needs to be connected to the ME Bridge.
- `UPDATE_RATE` determines how often to check the amounts in the ME in seconds