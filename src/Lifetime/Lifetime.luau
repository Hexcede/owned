--!strict
--!optimize 2
--!native

local Types = require("../Types")

type Cleanup = Types.Cleanup

type Lifetime = Types.Lifetime

local function Lifetime(parent: Lifetime?): Lifetime
    local isDead = false

    local cleanupCount = 0
    local cleanups: {Cleanup} = {}

    local function IsDead(): boolean
        return isDead
    end

    local function IsAlive(): boolean
        return not IsDead()
    end

    local function Drop()
        if isDead then
            return
        end

        isDead = true
        table.freeze(cleanups)

        -- Run cleanups in reverse order
        for i=cleanupCount, 1, -1 do
            cleanups[i]()
        end
    end

    local function Add(cleanup: Cleanup): Cleanup
        if isDead then
            cleanup()

            return function()end
        end

        cleanupCount += 1
        cleanups[cleanupCount] = cleanup

        local isCleaned = false

        local function removeCleanup()
            if isCleaned then
                return
            end

            isCleaned = true

            if isDead then
                return
            end

            local index = table.find(cleanups, cleanup)

            if index then
                table.remove(cleanups, index)
                cleanupCount -= 1
            end
        end

        return removeCleanup
    end

    local function Take(lifetime: Lifetime): Cleanup
        local linkLifetime = Lifetime()

        -- Clean up the link when the parent is cleaned
        linkLifetime.Add(Add(linkLifetime.Drop))

        -- Clean up the link when the child is cleaned
        linkLifetime.Add(lifetime.Add(linkLifetime.Drop))

        -- Clean up the child when the parent is cleaned
        linkLifetime.Add(Add(lifetime.Drop))

        return linkLifetime.Drop
    end

    local self: Lifetime = table.freeze({
        IsDead = IsDead,
        IsAlive = IsAlive,

        Drop = Drop,

        Add = Add,

        Take = Take,
    })

    if parent then
        parent.Take(self)
    end

    return self, Drop
end

return Lifetime