--!strict
--!optimize 2
--!native

local Types = require("../Types")

type Lifetime = Types.Lifetime

type RefCounter<V> = Types.RefCounter<V>

type LifetimeMapper<K> = Types.LifetimeMapper<K>

local WeakMap = require("../Weak/WeakMap")
local Lifetime = require("../Lifetime/Lifetime")
local RefCounter = require("../RefCounter/RefCounter")

local function LifetimeMapper<K>(lifetime: Lifetime): LifetimeMapper<K>
    local lifetimeRefs: {[K]: RefCounter<Lifetime>} = {}

    WeakMap.Weak(lifetimeRefs, "k")

    local function UseRef(key: K)
        local lifetimeRef = lifetimeRefs[key]

        if lifetimeRef then
            return lifetimeRef
        end

        local newLifetime = Lifetime(lifetime)
        local newLifetimeRef = RefCounter(lifetime, newLifetime)

        lifetimeRefs[key] = newLifetimeRef

        newLifetime.Add(function()
            lifetimeRefs[key] = nil
        end)

        return newLifetimeRef
    end

    local function Use(key: K): Lifetime
        local lifetimeRef = UseRef(key)

        local lifetime, dropReference = lifetimeRef.Use()
        local sublifetime = Lifetime(lifetime)

        sublifetime.Add(dropReference)

        return sublifetime
    end

    local function Drop(key: K)
        local lifetimeRef = lifetimeRefs[key]

        if lifetimeRef then
            lifetimeRef.Get().Drop()
        end
    end

    local self: LifetimeMapper<K> = {
        Use = Use,
        UseRef = UseRef,
        Drop = Drop,
    }

    return self
end

return LifetimeMapper