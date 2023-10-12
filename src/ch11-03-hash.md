### Hashing: An Introduction

At its essence, hashing is a process of converting input data (often called a message) of any length into a fixed-size value, typically referred to as a hash value or simply "hash." This transformation is deterministic, meaning that the same input will always produce the same hash value. Hash functions are a fundamental component in various fields, including data storage, cryptography, and data integrity verification.

Now, let's look into two specific hashing methods: Poseidon and Pedersen.

### Poseidon Hashing Method

Poseidon is a family of hash functions designed for being very efficient as algebraic circuits. As such, they may be very useful in ZK proving systems such as STARKs and others.

Poseidon is a sponge construction based on the Hades permutation. Cairo's version of Poseidon is based on a three element state permutation.


#### Pros:
1. Optimized for arithmetic circuits: Poseidon is designed primarily for zk-SNARKs (Zero-Knowledge Succinct Non-Interactive Argument of Knowledge), where arithmetic circuits are used. As such, it is efficient in such settings.
2. Sponge-based construction: This allows for flexible input and output lengths, making it versatile for various applications.
3. Strong security claims: Poseidon claims to offer strong collision and pre-image resistance.

#### Cons:
1. Not as widely adopted: As a newer hashing method, it may not be as thoroughly tested or adopted in the real world as some other methods.
2. Optimization constraints: Since Poseidon is optimized for specific use-cases, it might not be the best choice for general-purpose applications.

### Pedersen Hashing Method

Pedersen hash functions are based on elliptic curve cryptography. It leverages the properties of elliptic curve point multiplications and additions. It exploits the hardness of the Elliptic Curve Discrete Logarithm Problem (ECDLP) to ensure security.

#### Pros:
1. Elliptic curve-based: Pedersen hashes use elliptic curve operations, which can offer robust security.
2. Homomorphic properties: This allows for certain mathematical operations on the original data based on its hash values without revealing the data itself.
3. Efficiency: Pedersen hashes can be computed efficiently, making them suitable for various applications.

#### Cons:
1. Deterministic but not unique: Two different sets of inputs can produce the same hash, which might be a vulnerability in certain applications.
2. Dependence on trusted setup: The security of Pedersen hashes depends on the initial parameters being generated securely and kept secret.



### Hashing interfaces

The interfaces used for hashing have build-in implmentation for the hasing algorithm Pedersen and Poseidon. 

The interfaces contains a strut `HashState` that is used as a pointer to the hash. It stores the value of the hash and can be updated to perform nested hashing. 

```rust
#[derive(Copy, Drop)]
struct HashState {
    state: felt252,
}
```

The functions

- `new() -> HashState` : initilize a new hash state
- `update(self: HashState, value: felt252) -> HashState`: update the hash with a `felt252` and return a `HashState` 
- `finalize(self: HashState) -> felt252` : returns the value of the hash, once finalized() has been called the HashState is dropped.
- `update_with(self: S, value: T) -> S` : update the hash with any type that derives the Hash trait and return a `HashState``




### Using Pedersen 

Pedersen can easilly be used to hash single value or pair of values using the function `pedersen(a: felt252, b: felt252) -> felt252`


```rust
fn hash_pedersen() {
    let a : felt252 = 10;
    let hash_felt252 = pedersen::pedersen(0, a);
}
```

Let's have a deeper dive into our understanding of Perderson and have a look at the PerdersenTrait.

The function uses the HashState struct that works as a pointer to the hash.  

```rust
#[derive(Copy, Drop)]
struct HashState {
    state: felt252,
}
```

This two methods are equivialent 

```rust
fn hash_Pedersen() {
    let hash_felt252 = pedersen::pedersen(0, 2);
    let hash_felt252 = PedersenTrait::new(0).update(2).finalize();
}

```

The update methods will actually iterativaly apply the pederson function to the hash returned and the next value to hash. It can therefore easilly be used succinctement or durectly apply the update function of the trait on the whole structure.


Let us decompose the second method. `PedersenTrait::new(0)` initializes and returns a HashState. `update(2)` is a method of `self: HashState`, It modifies the value of the hash stored in the value `state` of the `HashState` and returns the HashState. Finnally, `finalize()` is a method of `self: HashState` applied on the result of the update method, it will return the value of the felt252 `state` after the HashState is dropped.








### Using Poseidon

```rust
#[derive(Copy, Drop)]
struct HashState {
    s0: felt252,
    s1: felt252,
    s2: felt252,
    odd: bool,
}
```



### The Hash Trait

You can directly hash the whole struct by importing the trait Hash on your structure. Instad of hashing each element one by one, you get to call the hash function (Pedersen or Poseidon) of your choice on your structure directly. The Hash trait can be derive on any structure containing the following types : felt252, integer, bool, tuple, unit.


However you cannot import the trait on a struct that contains an Array or a `Felt252Dict`. 

On array, you can use Poseidon function ` poseidon_hash_span(mut span: Span<felt252>) -> felt252`

example :

```rust
#[derive(Drop)]
struct StructForHashArray {
    first: felt252,
    second: usize,
    third: Array<felt252>,
}

fn hash_structureArray() {
    let struct_to_hash = StructForHashArray {first : 0, second : 1, third : array![1, 2, 3, 4, 5]};
    
    let mut hash = PoseidonTrait::new().update(struct_to_hash.first).update_with(struct_to_hash.second);

    let hash_felt252 = hash.update(poseidon_hash_span(struct_to_hash.third.span())).finalize();
}
```

Note that you can use the function `update` to update the hash with a value of type `felt252` but you have to use `update_with` for any other type (or cast the variable)

Felt252Dict : doesn't make sence as it has no length. However if your use a struct using dict with fixed lengthyou can implement an iterative hash function that will hash the values of the dict iteratively.
