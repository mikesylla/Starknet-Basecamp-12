use snforge_std::{declare, DeclareResultTrait, ContractClassTrait};
use starknet::{ContractAddress};
use contracts::Counter::{ICounterDispatcher, ICounterDispatcherTrait};
use openzeppelin_access::ownable::interface::{IOwnableDispatcher, IOwnableDispatcherTrait};

const ZERO_COUNT: u32 = 0;

fn OWNER() -> ContractAddress {
    'OWNER'.try_into().unwrap()
}

// util deploy function
fn __deploy__(init_value: u32) -> (ICounterDispatcher, IOwnableDispatcher, ) {
    let contract_class = declare("Counter").unwrap().contract_class();
    //let contract_class = declare("Counter").expect('Failed to declare').contract_class();

    // serialize constructor
    let mut calldata: Array<felt252> = array![];
    init_value.serialize(ref calldata);
    OWNER().serialize(ref calldata);

    // deploy contract
    let (contract_address, _) = contract_class.deploy(@calldata).expect('failed to deploy');

    let counter = ICounterDispatcher{ contract_address };
    let ownable = IOwnableDispatcher{ contract_address };
    (counter, ownable)
}

#[test]
fn test_counter_deployment() {
    let (counter, ownable) = __deploy__(ZERO_COUNT);
    // count 1
    let count_1 = counter.get_counter();

    // assertions
    assert(count_1 == ZERO_COUNT, 'count not set');
    assert(ownable.owner() == OWNER(), 'owner not set');
}

#[test]
fn test_increase_counter() {
    let (counter, ownable) = __deploy__(ZERO_COUNT);
    // get current count
    let count_1 = counter.get_counter();

    // assertions
    assert(count_1 == ZERO_COUNT, 'count not set');

    // state-changing txs
    counter.increase_counter();

    // retrieve current count
    let count_2 = counter.get_counter();
    assert(count_2 == count_1 + 1, 'invalid count');
}