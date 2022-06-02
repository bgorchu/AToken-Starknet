"""contract.cairo test file."""
import os

import pytest
from starkware.starknet.testing.starknet import Starknet
from dataclasses import dataclass
# from openzeppelinutils import *
from nile.signer import Signer
from utils.Account import Account
import asyncio

NUM_SIGNING_ACCOUNTS=2
DUMMY_PRIVATE = 123456789987654321
L1_ADDRESS = 0x1f9840a85d5aF5bf1D1762F925BDADdC4201F984


def str_to_felt(text):
    b_text = bytes(text, "ascii")
    return int.from_bytes(b_text, "big")

def felt_to_str(felt):
    b_felt = felt.to_bytes(31, "big")
    return b_felt.decode()

# The path to the contract source code.
CONTRACT_FILE = os.path.join("contracts", "MintableIncentivizedERC20.cairo")


# @dataclass
# class IPoolAddressesProvider:
#     temp1: int

# @dataclass
# class Pool:
#     _addressesProvider: IPoolAddressesProvider

@pytest.fixture(scope='module')
def event_loop():
    return asyncio.new_event_loop()


@pytest.fixture(scope='module')
async def account_factory():
    # Initialize network
    starknet = await Starknet.empty()
    accounts = []
    print(f'Deploying {NUM_SIGNING_ACCOUNTS} accounts...')
    for i in range(NUM_SIGNING_ACCOUNTS):
        account = Account(DUMMY_PRIVATE + i, L1_ADDRESS)
        await account.create(starknet)
        accounts.append(account)
        print(f'Account {i} is: {account}')

    return starknet, accounts



@pytest.fixture(scope='module')
async def application_factory(account_factory):
    starknet, accounts = account_factory
    name=str_to_felt("TEST")
    symbol=str_to_felt("TST")
    

    application = await starknet.deploy(
        source=CONTRACT_FILE,
        constructor_calldata=[
           name,
            symbol,
            18        
        ]
    )
    return starknet, accounts, application



#Test the constructor and getter functions
#Passing structs does not work for now
@pytest.mark.asyncio
async def test_create_and_read_allowance(application_factory):
    """Test increase_balance method."""
    # Create a new Starknet class that simulates the StarkNet
    # system.

    # starknet = await Starknet.empty()
    _, accounts, application = application_factory

    user_0 = accounts[0]
    user_0_number = 543
    user_1 = accounts[1]
    user_1_number = 888

    execution_info = await application.Symbol().invoke()
    assert execution_info.result.symbol== str_to_felt("TST")

    

    balanceStruct=divmod(100, 2**128)


    await user_0.tx_with_nonce(
        to=application.contract_address,
        selector_name='addbalance',
        calldata=[balanceStruct[0], balanceStruct[1], 1])


    
    #check added balance
    execution_info = await application.balanceof(user_0.address).call()
    print(execution_info)
    assert execution_info.result.balance == divmod(100, 2**128)



    # check decimals function
    # execution_info = await application.decimals().call()
    # assert execution_info.result == (18,)


    #check name function
    # execution_info = await application.name().invoke()
    # assert execution_info.result.name == str_to_felt("TEST")


    #check Symbol function
    # execution_info = await application.symbol().invoke()
    # assert execution_info.result.symbol== str_to_felt("TST")


   
    balanceStruct=divmod(10, 2**128)


    await user_1.tx_with_nonce(
        to=application.contract_address,
        selector_name='addbalance',
        calldata=[balanceStruct[0], balanceStruct[1], 1])

    # get UserState
    execution_info = await application.balanceof(user_1.address).invoke()
    print(execution_info)
    assert execution_info.result.balance== divmod(10, 2**128)

    

    amountStruct=divmod(50, 2**128)

    #Approve user 2 to use 50 tokens
    await user_0.tx_with_nonce(
        to=application.contract_address,
        selector_name='Approve',
        calldata=[user_1.address, amountStruct[0], amountStruct[1]])

    execution_info = await application.Allowance(user_0.address,user_1.address).invoke()
    print(execution_info)
    assert execution_info.result.res== divmod(50, 2**128)


    transferStruct= divmod(10, 2**128)


    await user_0.tx_with_nonce(
        to=application.contract_address,
        selector_name='Transfer',
        calldata=[user_1.address, transferStruct[0], transferStruct[1]])

    # await application.Transfer(user_1.address, transferStruct[0], transferStruct[1]).invoke()
    execution_info = await application.balanceof(user_1.address).invoke()
    print(execution_info)

    assert execution_info.result.balance== divmod(20, 2**128)


    # await application._mint(user_1.address, 20).invoke()
    # execution_info = await application.balanceOf(user_1.address).invoke()
    # print(execution_info)
    # assert execution_info.result.balance== 40




    # Check the result of get_balance().
    # execution_info = await contract.get_allowance(delegatee=1).call()
    # assert execution_info.result == (1,)

    # await contract.add_allowance(delegatee=2, allowance=2).invoke()
    # execution_info = await contract.get_allowance(delegatee=2).call()