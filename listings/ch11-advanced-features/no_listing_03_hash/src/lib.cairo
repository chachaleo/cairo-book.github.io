//ANCHOR: import

use hash::{HashStateTrait, HashStateExTrait};
use poseidon::PoseidonTrait;
use poseidon::poseidon_hash_span;
use pedersen::PedersenTrait;

//ANCHOR_END: import




#[derive(Drop,Hash)]
struct StructForHash {
    first: felt252,
    second: u8,
    third: (u32,u32),
    last : bool,
}

#[derive(Drop)]
struct StructForHashArray {
    first: felt252,
    second: felt252,
    third: Array<felt252>,
}

#[test]
fn hash_pedersen() {
    let hash_felt252 = pedersen::pedersen(1, 2);
    let hash_felt252_expected = PedersenTrait::new(1).update(2).finalize();

    assert(hash_felt252 == hash_felt252_expected, 'not equivalent');
}

#[test]
fn hash_pedersen_struct() {
    let struct_to_hash = StructForHash {first : 0, second : 1, third : (1,2), last : false};
    
    let hash_felt252 = PedersenTrait::new(0).update_with(struct_to_hash).finalize();
    let hash_felt252_expected = PedersenTrait::new(0).update(0).update(1).update(1).update(2).update(false.into()).finalize();
    
    assert(hash_felt252 == hash_felt252_expected, 'not equivalent');
}

#[test]
fn hash_poseidon_structure() {
    let struct_to_hash = StructForHash {first : 0, second : 1, third : (1,2), last : false};

    let mut hash = PoseidonTrait::new().update(0);
    hash = hash.update(1);
    hash = hash.update(1);
    hash = hash.update(2);
    let hash_felt252 = hash.update_with(false).finalize();

    let hash_felt252_expected = PoseidonTrait::new().update_with(struct_to_hash).finalize();

    assert( hash_felt252 == hash_felt252_expected, 'not equivalent');
}

fn hash_structure_Array() {
    let struct_to_hash = StructForHashArray {first : 0, second : 1, third : array![1, 2, 3, 4, 5]};
    
    let mut hash = PoseidonTrait::new().update(struct_to_hash.first).update(struct_to_hash.second);
    let hash_felt252 = hash.update(poseidon_hash_span(struct_to_hash.third.span())).finalize();
}