--!strict
--!optimize 2

export type Cleanup = () -> ()

export type WeakMode = "k" | "v" | "kv" | "vk"

export type Pack<T...> = () -> T...

export type Lifetime = {
    --- @return Whether or not the lifetime is dead
    IsDead: () -> boolean,
    --- @return Whether or not the Lifetime is alive
    IsAlive: () -> boolean,

    --- Forcefully cleans up the lifetime.
    Drop: Cleanup,

    --- Adds a cleanup function.
    --- @return A function which removes the cleanup *without* calling it
    Add: (cleanup: Cleanup) -> Cleanup,

    --- Adds a Lifetime.
    --- @return A function which removes the lifetime *without* cleaning it up
    Take: (cleanups: Lifetime) -> Cleanup,
}

export type RefCounter<V> = {
    --- Uses the ref counter reference.
    --- @return The value stored in the reference
    --- @return A function which removes the reference
    Use: (lifetime: Lifetime?) -> (V, Cleanup),

    --- Gets the stored value *without* referencing it.
    --- @return The stored value
    Get: () -> V,

    --- Forcefully drops the stored value.
    Drop: Cleanup,
}

export type LifetimeMapper<K> = {
    --- Gets or creates a lifetime associated with the given key
    --- @return The lifetime associated with the given key
    Use: (key: K) -> Lifetime,
    --- Gets or creates a reference to a lifetime associated with the given key
    --- @return The reference to the lifetime associated with the given key
    UseRef: (key: K) -> RefCounter<Lifetime>,
    --- Forcefully drops the lifetime for the given key.
    Drop: (key: K) -> (),
}

export type Mapper<K, V> = {
    --- @return Whether or not the key is present in the mapper
    Has: (key: K) -> boolean,

    --- Gets the mapped value if any.
    Get: (key: K) -> V?,

    --- Gets or computes a reference to the mapped value for a key.
    --- @return The reference to the value associated with the key
    AddReference: (key: K) -> RefCounter<V>,
    --- Gets or computes the value for a key without referencing it.
    --- @return The value associated with the key
    Add: (key: K) -> V,

    --- Gets or computes the mapped value.
    --- @return The value mapped to the key
    --- @return A function which releases the reference to the value
    Use: (key: K, lifetime: Lifetime?) -> (V, Cleanup),

    --- Cleans & removes the key/value completely.
    Drop: (key: K) -> (),
}

return nil