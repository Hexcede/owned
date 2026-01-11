--!strict
--!optimize 2

local Types = require("@self/Types")

local WeakMap = require("@self/Weak/WeakMap")
local Lifetime = require("@self/Lifetime/Lifetime")
local RefCounter = require("@self/RefCounter/RefCounter")
local Mapper = require("@self/Mapper/Mapper")
local Pack = require("@self/Pack/Pack")

--- A function to perform some associated cleanup logic.
export type Cleanup = Types.Cleanup
--- Valid modes for weak keys/values.
export type WeakMode = Types.WeakMode
--- A collection of ordered cleanup functions for managed garbage collection.
export type Lifetime = Types.Lifetime
--- A simple reference counter implementation.
export type RefCounter<T> = Types.RefCounter<T>
--- A structure which maps from a set of values to associated lifetimes.
export type LifetimeMapper<K> = Types.LifetimeMapper<K>
--- A simple Map wrapper which maps keys to stored values.
export type Mapper<K, V> = Types.Mapper<K, V>
--- A packed varg in a function for convenience.
export type Pack<T...> = Types.Pack<T...>

local Owned = table.freeze({
    WeakMap = WeakMap,

    Lifetime = Lifetime,
    RefCounter = RefCounter,

    Mapper = Mapper,
    Pack = Pack,
})

return Owned