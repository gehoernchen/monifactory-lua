# Conditioanl Exporter

This script exports all items/fluids from one ME system to a storage container in a specified direction over a specified threshold. This might be used to export overflow from one ME to another ME or from one ME to a chest, etc.

## General

Create a file called `exporter-config` and put it into the same directory as the conditionalExporter.
For an example, see [Example](#example).

Your general setup needs to be as follows:
- Place a computer that touches an ME bridge from Advanced Peripherals
- The ME bridge needs to be connected to the AE system that is being read from
- Place a target inventory next to the ME bridge that will be the target

Additional notes:
- Amounts for fluids are given as mB.
- The `GLOBAL_TARGET` is the direction of a storage container seen from the ME Bridge. I.e., the external storage needs to be connected to the ME Bridge.
- `UPDATE_RATE` determines how often to check the amounts in the ME in seconds
- You may use a complex condition in your export entry (i.e., check another item's count to determine whether to export), explained in [Complex conditions](#Complex-conditions), or just export everything above a threshold
  - For the second functionality - export everything above a threshold -, set your `count` to what you want to keep and set `condition = overflow`, which will make sure only the desired `count` of your entry will be kept

## Complex conditions

For constructing CONDITIONS, use this:
- Use an appropriate name for your condition; you will reference it in your export entry
- Make sure your CONDITION has a type (`fluid` or `item`) and a `count`
- The `count` is used in conjunction with the CONDITION's `mode` field
  - A `mode` can be either of `when_more` or `when_less`
  - i.e., the desired count is compared with the actual count in the AE system for being more or being less, making a CONDITION either true or false when evaluating it

## Targets

Use these directions:
```
up
down
north
east
south
west
```

The direction you are exporting to is relative from the ME bridge. I.e., the actual exporter is the ME bridge, the ME bridge needs to touch the target inventory.

## Example

This example file will make sure that only 64 aluminium dust and 16 buckets of Hydrogen are kept in the source ME and pushed to the external storage container.

Create a file that looks like this and call it `exporter-config`:
```lua
GLOBAL_TARGET = "north"
UPDATE_RATE = 15

EXPORTS = {
    { 
        name = "gtceu:aluminium_dust",
        count = 64,
        type = "item",
        condition = "overflow"
    },
    { 
        name = "gtceu:hydrogen_gas",
        count = 64000,
        type = "fluid",
        condition = "overflow"
    },
    { 
        name = "gtceu:carbon_dust",
        count = 64,
        type = "item",
        condition = "overflow"
    },
    { 
        name = "gtceu:sulfuric_acid",
        count = 64000,
        type = "fluid",
        condition = "overflow"
    },
    { 
        name = "gtceu:hydrochloric_acid",
        count = 64000,
        type = "fluid",
        condition = "overflow"
    },
    { 
        name = "gtceu:nitrogen_dioxide",
        count = 32000,
        type = "fluid",
        condition = "oxygen"
    },
    { 
        name = "gtceu:gold_dust",
        count = 256,
        type = "item",
        condition = "overflow"
    },
}

CONDITIONS = {
    oxygen = {
        name = "gtceu:oxygen",
        type = "fluid",
        count = 500000,
        mode = "when_less"
    }
}
```