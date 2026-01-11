--!strict
--!optimize 2

local Types = require("../Types")

type WeakMode = Types.WeakMode

local WEAK_KEYS = table.freeze({__mode = "k"})
local WEAK_VALUES = table.freeze({__mode = "v"})
local WEAK_PAIRS = table.freeze({__mode = "kv"})

--- Maps from a mode to a metatable for that mode.
local WEAK_MAP = table.freeze({
    k = WEAK_KEYS,
    v = WEAK_VALUES,
    kv = WEAK_PAIRS,
    vk = WEAK_PAIRS,
})

--- Takes a table and an optional weak mode and overrides the metatable.
local function Weak<K, V>(t: {[K]: V}, mode: WeakMode?)
    setmetatable(t, WEAK_MAP[mode])
end

--- A map which selects keys only if the input mode has it.
local KEYS_MASK = table.freeze({
    kv = "k",
    vk = "k",
    k = "k",
})

--- A map which selects values only if the input mdoe has it.
local VALUES_MASK = table.freeze({
    kv = "v",
    vk = "v",
    v = "v",
})

--- A collection of utilities for simple weak tables using a shared metatable.
local WeakMap = table.freeze({
    KEYS_MASK = KEYS_MASK,
    VALUES_MASK = VALUES_MASK,

    WEAK_KEYS = WEAK_KEYS,
    WEAK_VALUES = WEAK_VALUES,
    WEAK_PAIRS = WEAK_PAIRS,

    WEAK_MAP = WEAK_MAP,

    Weak = Weak,
})

return WeakMap