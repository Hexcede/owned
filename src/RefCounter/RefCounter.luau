--!strict
--!optimize 2
--!native
--!nolint LocalShadow

local Lifetime = require("../Lifetime/Lifetime")
local Types = require("../Types")

type Cleanup = Types.Cleanup

type RefCounter<T> = Types.RefCounter<T>

type Lifetime = Types.Lifetime

local function RefCounter<T>(lifetime: Lifetime, value: T): RefCounter<T>
    local ownLifetime = Lifetime(lifetime)

    local refCount = 0

    local function Drop()
        ownLifetime.Drop()
    end

    local function maybeCollect()
        if refCount > 0 then
            return
        end

        Drop()
    end

    local function decrementRef()
        refCount -= 1

        task.defer(maybeCollect)
    end

    local function Get(): T
        return value
    end

    local function Use(lifetime: Lifetime?): (T, Cleanup)
        local refLifetime = Lifetime(ownLifetime)

        refCount += 1

        refLifetime.Add(decrementRef)

        if lifetime then
            lifetime.Take(refLifetime)
        end

        return value, refLifetime.Drop
    end

    local self: RefCounter<T> = table.freeze({
        Get = Get,
        Use = Use,
        Drop = Drop,
    })

    return self
end

return RefCounter