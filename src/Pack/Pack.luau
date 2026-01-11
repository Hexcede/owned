--!strict
--!optimize 2
--!native

local function Pack<T...>(...: T...): () -> T...
    local items: {[number]: any, n: number} = table.freeze(table.pack(...))
    local length = items.n

    local function Unpack(): T...
        return table.unpack(items, 1, length)
    end

    return Unpack
end

return Pack