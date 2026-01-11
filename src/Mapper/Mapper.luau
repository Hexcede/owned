--!strict
--!optimize 2
--!native

local Types = require("../Types")

type Cleanup = Types.Cleanup

type Lifetime = Types.Lifetime

type LifetimeMapper<K> = Types.LifetimeMapper<K>

type RefCounter<T> = Types.RefCounter<T>
type Mapper<K, V> = Types.Mapper<K, V>

local WeakMap = require("../Weak/WeakMap")
local RefCounter = require("../RefCounter/RefCounter")

local function Mapper<K, V>(lifetimeMapper: LifetimeMapper<K>, map: (key: K, lifetime: Lifetime) -> (V, () -> ()?)): Mapper<K, V>
    local valueRefs: {[K]: RefCounter<V>} = {}

    WeakMap.Weak(valueRefs, "k")

    local function Has(key: K)
        return not not valueRefs[key]
    end

    local function Get(key: K): V?
        if not Has(key) then
            return nil
        end

        return valueRefs[key].Get()
    end

    local function AddReference(key: K): RefCounter<V>
        if Has(key) then
            return valueRefs[key]
        end

        local keyLifetimeRef = lifetimeMapper.Use(key)
        local value, deferred = map(key, keyLifetimeRef)

        local refCounter = RefCounter(keyLifetimeRef, value)

        if keyLifetimeRef.IsAlive() then
            valueRefs[key] = refCounter

            keyLifetimeRef.Add(function()
                valueRefs[key] = nil
            end)
        end

        if deferred then
            deferred()
        end

        return refCounter
    end

    local function Add(key: K): V
        return AddReference(key).Get()
    end

    local function Use(key: K, lifetime: Lifetime?): (V, Cleanup)
        return AddReference(key).Use(lifetime)
    end

    local function Drop(key: K)
        lifetimeMapper.Drop(key)
    end

    local self: Mapper<K, V> = table.freeze({
        Has = Has,
        Get = Get,

        Add = Add,
        AddReference = AddReference,
        Use = Use,
        Drop = Drop,
    })

    return self
end

return Mapper