## Hashing

At its essence, hashing is a process of converting input data (often called a message) of any length into a fixed-size value, typically referred to as a hash value or simply "hash." This transformation is deterministic, meaning that the same input will always produce the same hash value. Hash functions are a fundamental component in various fields, including data storage, cryptography, and data integrity verification.

### Hashing: An Example

Let us look at a full example of how to use hashes and the corresponding Trait.

First we have to know that two different type of hashing methods are implemented in Cairo : Perdersen and Poseidon.

 - Poseidon is a family of hash functions designed for being very efficient as algebraic circuits. As such, they may be very useful in ZK proving systems such as STARKs and others. Poseidon is a sponge construction based on the Hades permutation. Cairo's version of Poseidon is based on a three element state permutation.

- Pedersen hash functions are based on elliptic curve cryptography. It leverages the properties of elliptic curve point multiplications and additions. It exploits the hardness of the Elliptic Curve Discrete Logarithm Problem (ECDLP) to ensure security.


#### When to use them ?

Pedersen was introduced first, it is still used in storage (i.e. for Legacy Map) but Poseidon should mostly be used in practice as it is faster (cheaper) than Pedersen.


#### The Hash Trait

First we need to import the PoseidonTrait and PedersenTrait,// and also the HashStateTrait and HashStateExTrait for Array
```rust
use poseidon::PoseidonTrait;
use pedersen::PedersenTrait;
```


That HashTrait can be derrived on a function as follow :

```rust
#[derive(Drop,Hash)]
struct StructForHash {
    first: felt252,
    second: felt252,
    third: (u32,u32),
    last : bool,
}
```

Deriving the HashTrait allow us to use the hashing methods directly on the whole structure. The Hash trait can be derive on any 
structure where all field are hashable: felt252, integer, bool, tuple, unit. You cannot import the trait on a struct that contains an `Array<T>` or a `Felt252Dict`.

As our structure derives the trait HashTrait, we can call the function as follow :

```rust
    let struct_to_hash = StructForHash {first : 0, second : 1, third : (1,2), last : false};

    let hash = PoseidonTrait::new().update_with(struct_to_hash).finalize();
    let hash = PedersenTrait::new(0).update_with(struct_to_hash).finalize();

```

### Hashing a Struct containing an array

Let us look at an example of hashing a function that contains an `Array<T>`.
To hash an `Array<T>` or a struct that contains an `Array<T>` you can use the build-in function in poseidon 
` poseidon_hash_span(mut span: Span<felt252>) -> felt252` .

First let us import the following trait and function :

```rust
use hash::{HashStateTrait, HashStateExTrait};
use poseidon::PoseidonTrait;
use poseidon::poseidon_hash_span;
```

Now we define the structure, as you might have notice we didn't derived the Hash trait. If you try to derive the 
Hash trait on this structure it will rise an error because the structure contains a field not hashable.

```rust
#[derive(Drop)]
struct StructForHashArray {
    first: felt252,
    second: felt252,
    third: Array<felt252>,
}
```
This time we have to use manually the methods of the HashTrait implemented by the PoseidonTrait, their definition can be found [here](https://github.com/starkware-libs/cairo/blob/775b4f84e705293ded7b7cc203650eb983246842/corelib/src/poseidon.cairo).

But in short, the HashState struct contains the current value of the hash, it has to be initilized and putdated with the new value. It works as a pointer to the current stated ans returns a `felt252`when the computation of the hash is done. the following function can be used : 

- `new(base: felt252) -> HashState`: initilize a new hash state
- `update(self: HashState, value: felt252) -> HashState`: update the hash with a `felt252` and return a `HashState` 
- `finalize(self: HashState) -> felt252` : returns the value of the hash, once finalized() has been called the HashState is dropped.
- `update_with(self: S, value: T) -> S` : update the hash with any type that derives the Hash trait and return a `HashState``


Let us go back to our example, we initialized a HashState (`hash`) and updateted it and then called the function `finalize()` on the 
HashState to get the computed hash `hash_felt252`.

```rust
let struct_to_hash = StructForHashArray {first : 0, second : 1, third : array![1, 2, 3, 4, 5]};
    
let mut hash = PoseidonTrait::new().update(struct_to_hash.first).update(struct_to_hash.second);
let hash_felt252 = hash.update(poseidon_hash_span(struct_to_hash.third.span())).finalize();

```



Note: Pedersen hashing can be using calling directly this function :`pedersen(a: felt252, b: felt252) -> felt252`.

```rust
fn hash_pedersen() {
    let a : felt252 = 10;
    let hash_felt252 = pedersen::pedersen(0, a);
}
```
