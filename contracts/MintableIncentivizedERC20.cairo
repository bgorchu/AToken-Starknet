%lang starknet


from contracts.IncentivizedERC20 import IncentivizedERC20
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.starknet.common.syscalls import get_caller_address
from starkware.cairo.common.uint256 import Uint256
from starkware.cairo.common.bool import TRUE
from openzeppelin.security.safemath import uint256_checked_add, uint256_checked_sub_le




##Constructor cannot be declared twice. One needs to be initializer
@constructor
func constructor{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr}(name:felt, symbol:felt, decimals: felt):

    IncentivizedERC20.initializer(name, symbol, decimals) 
    return ()
    
end


@view
func Symbol{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }() -> (symbol:felt):
    let (symbol) = IncentivizedERC20.symbol()
    return (symbol)
end



@view
func total_Supply{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }() -> (totalSupply: Uint256):
    let (totalSupply: Uint256) = IncentivizedERC20.totalSupply()
    return (totalSupply)
end

@view
func addbalance{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(balance:Uint256, additionalData:felt) :
    let (caller_address) = get_caller_address()
    IncentivizedERC20.addBalance(caller_address, balance, additionalData)
    return ()
end


@view
func balanceof{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(account:felt) -> (balance: Uint256):
    let (totalSupply: Uint256) = IncentivizedERC20.balanceOf(account)
    return (totalSupply)
end


@view
func _mint{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(account:felt, amount: Uint256):
    let (oldTotalSupply) = total_Supply()
    let (oldAccountBalance) = IncentivizedERC20.balanceOf(account)

    IncentivizedERC20.changeTotalSupply(amount, 1)
    IncentivizedERC20.changeUserBalance(account, amount, 1)


    #Incentivescontroller logic here
    return ()
end



@view
func _burn{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(account:felt, amount: Uint256):
    let (oldTotalSupply) = total_Supply()
    let (oldAccountBalance) = IncentivizedERC20.balanceOf(account)

    IncentivizedERC20.changeTotalSupply(amount, 0)
    IncentivizedERC20.changeUserBalance(account, amount, 0)

    #Incentivescontroller logic here
    return ()
end
