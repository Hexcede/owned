# Owned

A collection of utilities for some different datatypes & cleanup related things.

## Items

### Lifetime

Lifetimes are just a collection of simple, ordered cleanup functions.

Example:
```luau
local lifetime = Lifetime()

lifetime.Add(function()
    print("cleaned up")
end)

lifetime.Cleanup()
```

Lifetimes in other lifetimes can be created & managed in a few ways:
```luau
local lifetimeA = Lifetime()
local licetimeB = Lifetime()

-- Put lifetimeC into lifetimeB so that the latter also cleans up the former
local remove = lifetimeB.Take(lifetimeC)

-- Remove lifetimeC from lifetimeB without cleaning it up (useful for heirarchies)
remove()

-- Create a liftime within lifetimeA
local lifetimeB = Lifetime(lifetimeA)

-- Equivalent to:
local lifetimeB = Lifetime()

lifetimeA.Take(lifetimeB)
```

Lifetimes can also reference eachother circularly. They will be cleaned up together.
```luau
local lifetimeA = Lifetime()
local lifetimeB = Lifetime()

lifetimeA.Take(lifetimeB)
lifetimeB.Take(lifetimeA)
```

### RefCounter

This is a utility for creating a counted reference to a value. It takes a Lifetime and a value. The Lifetime will be cleaned up shortly after all references are dropped. The reference does not become 'live' until the first time it is referenced via `.Use()`.

Example:
```luau
local lifetime = Lifetime()

lifetime.Add(function()
    print("no more references")
end)

local valueRef = RefCounter(lifetime, "cool value")

local cleanupReference, value = valueRef.Use()

print("value is", value)

task.wait(1)

cleanupReference()
```

If you want to just read the value directly without referencing it, `.Get()` is a way to get it. This is useful if you want to temporarily use the value without causing it to drop or preventing it from dropping.

### Mapper

This takes a lifetime and a constructor which maps from an input/key to an output.

```luau
local function Constructor(instance: Instance, lifetime: Lifetime)
    local count = 0

    lifetime.Add(Observe.Attribute(instance, "Count", function(newCount)
        count = newCount
        return
    end))

    local function GetCount()
        return count
    end

    local self = {
        GetCount = GetCount,
    }

    return self
end

local mapper = Mapper(lifetime, Constructor)

local myObject = mapper.Use(lifetime, workspace.MyFolder)

print(myObject.GetCount())
```

You can use this to created signals associated with a set of values for example:
```luau
local function OwnedSignal<T...>(_, lifetime: Lifetime): Signal<T...>
    local signal = Signal.new()

    lifetime.Add(function()
        signal:Destroy()
    end)

    return signal
end

local addedSignals = Mapper(lifetime, OwnedSignal)
local removedSignals = Mapper(lifetime, OwnedSignal)

-- Use an added signal
local addedSignal = addedSignals.Use(lifetime, object)

-- Fire an added signal if one is being used
if addedSignals.Has(object) then
    addedSignals.Add(object):Fire()
end
```

### Pack

This is just an extremely simple typechecked vararg pack for sanity reasons & convenience. Nothing more to it really.
```luau
local packed = Pack(1, 2, 3)

print(packed()) -- 1 2 3
print(packed()) -- 1 2 3
```

### WeakMap

This is a utility for sharing weak metatables, for little to no reason other than for basic type checking & because it looks a little cleaner.

Examples:
```luau
WeakMap.Weak(myTable, "k")
WeakMap.Weak(myTable, WeakMap.WEAK_VALUES)
WeakMap.Weak(myTable, WeakMap.KEYS_MASK[mode]) -- Masks against keys so that values are not weak
```

## Performance

The performance of the modules contained in this library wasn't a major consideration in its design. It has more overhead than it might need to, in exchange for convenient API design. It is intended for high level bookkeeping.

If you are using it in anything particularly performance heavy, you are likely overengineering your project slightly, or your design criteria are somewhat unique.