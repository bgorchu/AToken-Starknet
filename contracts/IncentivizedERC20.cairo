%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.starknet.common.syscalls import get_caller_address
from starkware.cairo.common.uint256 import Uint256, uint256_add, uint256_sub
from starkware.cairo.common.bool import TRUE
from openzeppelin.security.safemath import uint256_checked_add, uint256_checked_sub_le
# from openzeppelin.token.erc20.library import ERC20

# onlyPoolAdmin modifier
# onlyPool modifier



# @storage_var
# func _userState(address : felt) -> (state : UserState):
# end

# @storage_var
# func _allowances(delegator : felt, delegatee : felt) -> (allowance : Uint256):
# end

# private vs internal variables?
# Strings are felts in the OpenZeppelin implementation

# @storage_var
# func _totalSupply() -> (totalSupply : Uint256):
# end

# @storage_var
# func _name() -> (name : felt):
# end

# @storage_var
# func _symbol() -> (symbol: felt):
# end

# @storage_var
# func _decimals() -> (decimals : felt):
# end


# needs to be internal
@storage_var
func _incentivesController() -> (incentivesController : IAaveIncentivesController):
end

# needs to be internal and immutable
@storage_var
func _addressesProvider() -> ( addressesProvider: IPoolAddressesProvider):
end

# needs to be public and immutable
@storage_var
func POOL() -> (pool: IPool):
end


@storage_var
func owner() -> (owner: felt):
end





namespace IncentivizedERC20:


# @constructor
func initializer{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr}(name:felt, symbol:felt, decimals: felt,initial_supply: Uint256,
        recipient: felt):

    # _addressesProvider.write(pool._addressesProvider) #needs to call a function inside pool called .ADDRESSES_PROVIDER()
    let (caller_address) = get_caller_address()
    # ERC20.initializer(name, symbol, decimals)
    # ERC20._mint(recipient, initial_supply)

    # _name.write(name)
    # _symbol.write(symbol)
    # _decimals.write(decimals)
    owner.write(caller_address)
    # POOL.write(pool)

    return ()
    
end



@view
func name{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }() -> (name: felt):
    let (name) = ERC20.name()
    return (name)
end

@view
func symbol{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }() -> (symbol: felt):
    let (symbol) = ERC20.symbol()
    return (symbol)
end

@view
func totalSupply{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }() -> (totalSupply: Uint256):
    let (totalSupply: Uint256) = ERC20.total_supply()
    return (totalSupply)
end

@view
func decimals{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }() -> (decimals: felt):
    let (decimals) = ERC20.decimals()
    return (decimals)
end

@view
func balanceOf{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(account: felt) -> (balance: Uint256):
    let (balance: Uint256) = ERC20.balance_of(account)
    return (balance)
end

@view
func allowance{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(owner: felt, spender: felt) -> (remaining: Uint256):
    let (remaining: Uint256) = ERC20.allowance(owner, spender)
    return (remaining)
end


#
# Externals
#

# @external
# func transfer{
#         syscall_ptr : felt*,
#         pedersen_ptr : HashBuiltin*,
#         range_check_ptr
#     }(recipient: felt, amount: Uint256) -> (success: felt):
#     ERC20.transfer(recipient, amount)
#     return (TRUE)
# end

# @external
# func transferFrom{
#         syscall_ptr : felt*,
#         pedersen_ptr : HashBuiltin*,
#         range_check_ptr
#     }(
#         sender: felt,
#         recipient: felt,
#         amount: Uint256
#     ) -> (success: felt):
#     ERC20.transfer_from(sender, recipient, amount)
#     return (TRUE)
# end


# @external
# func increaseAllowance{
#         syscall_ptr : felt*,
#         pedersen_ptr : HashBuiltin*,
#         range_check_ptr
#     }(spender: felt, added_value: Uint256) -> (success: felt):
#     ERC20.increase_allowance(spender, added_value)
#     return (TRUE)
# end

# @external
# func decreaseAllowance{
#         syscall_ptr : felt*,
#         pedersen_ptr : HashBuiltin*,
#         range_check_ptr
#     }(spender: felt, subtracted_value: Uint256) -> (success: felt):
#     ERC20.decrease_allowance(spender, subtracted_value)
#     return (TRUE)
# end



#getIncentivesController() function

#setIncentivesController() function



#Amount needs to uint128
@external
func transfer{syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr}(sender:felt, recipient:felt, amount:Uint256)-> (success: felt):


    #AAVE casts amount to uint128 

    _transfer(sender, recipient, amount)

    return (TRUE)
end


#Amount needs to uint128 and needs to be cast in advance
func _transfer{syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr}(sender:felt, recipient:felt, amount: Uint256)->(): 


    alloc_locals
    let (oldSenderState)= _userState.read(sender)
    let (oldRecipientState)= _userState.read(recipient)

    let (newSenderBalance)= uint256_checked_sub_le(oldSenderState.balance, amount)
    let newSenderState=UserState(newSenderBalance, oldSenderState.additionalData)
     ##can I only change one field of struct with .write()?
    _userState.write(sender, newSenderState)    

    
    let (newRecipientBalance)=uint256_checked_add(oldRecipientState.balance, amount)
    let newRecipientState=UserState(newRecipientBalance, oldRecipientState.additionalData)
    _userState.write(recipient, newRecipientState)  

    ## incentivesController logic goes here

    return ()
end


@external
func approve{syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr}(owner:felt, spender:felt, amount: Uint256):


    _approve(owner,spender, amount)
    return()
end



#this function needs to be internal
func _approve{syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr}(owner:felt, spender:felt, amount: Uint256):

    ERC20.approve(spender, amount)
    return (TRUE)
end



#Only for testing purposes
@external
func addBalance{syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr}(caller:felt, balance:Uint256, additionalData:felt): 

        let temp= UserState(balance, additionalData)

        _userState.write(caller, temp)
        return()
end


#Only for testing purposes
@external
func allowance{syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr}(owner:felt, spender: felt)->(res:Uint256): 
        let (res) = _allowances.read(owner, spender)
        return (res)
end



#Temporary solution
@external
func changeTotalSupply{syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr}(amount:Uint256, add: felt): 

        let (oldSupply)=_totalSupply.read()
        let (caller_address) = get_caller_address() 
        let (Owner)=owner.read()

        assert caller_address = Owner

        #add an overflow guard here
        if add == 1:
            let (newSupply)= uint256_checked_add(oldSupply,amount)
            _totalSupply.write(newSupply) 
        else:
            let (newSupply)=uint256_checked_sub_le(oldSupply,amount)
            _totalSupply.write(newSupply) 
        end

        return()
end


#Temporary solution
@external
func changeUserBalance{syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr}(account:felt, amount:Uint256, add:felt): 

        alloc_locals
        let (userState)=_userState.read(account)
        let (Owner)=owner.read()

        let (caller_address) = get_caller_address() 
        assert caller_address = Owner

        if add == 1:
            let (newBalance)=uint256_checked_add(userState.balance,amount)
            let newState=UserState(newBalance,userState.additionalData)

            _userState.write(account, newState) 
        else:
            let (newBalance)=uint256_checked_sub_le(userState.balance,amount)

            let newState=UserState(newBalance,userState.additionalData)
            _userState.write(account, newState) 

        end

        return()
end




@external
func increaseAllowance{syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr}(spender:felt, addedValue: Uint256)->(success: felt): 


        let (caller_address) = get_caller_address()

        #Cast?
        let (oldAllowance:Uint256)= _allowances.read(caller_address, spender)

        let (newAllowance)=uint256_checked_add(oldAllowance, addedValue) 
        _approve(caller_address, spender, newAllowance)

        return (TRUE)
        
end


@external
func decreaseAllowance{syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr}(spender:felt, subtractedValue: Uint256)->(success: felt): 

        alloc_locals
        let (caller_address) = get_caller_address()

        #Cast?
        let (oldAllowance:Uint256)= _allowances.read(caller_address, spender)

        let (newAllowance)=uint256_checked_sub_le(oldAllowance, subtractedValue) 
        _approve(caller_address, spender, newAllowance)

        return (TRUE)
        
end

end

#setname
#setsymbol
#setdecimals


