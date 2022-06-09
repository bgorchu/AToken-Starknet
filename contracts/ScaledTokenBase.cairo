%lang starknet


# from contracts.IncentivizedERC20 import IncentivizedERC20
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.starknet.common.syscalls import get_caller_address
from starkware.cairo.common.uint256 import Uint256, uint256_lt
from starkware.cairo.common.bool import TRUE
from openzeppelin.security.safemath import uint256_checked_add, uint256_checked_sub_le, uint256_checked_div_rem, uint256_checked_mul

from lib.structs import UserState, IAaveIncentivesController, IPool
from starkware.cairo.common.math import assert_nn
from lib.utils import uint256_assert_not_zero, is_not_zero

from openzeppelin.token.erc20.library import (
    ERC20_name,
    ERC20_symbol,
    ERC20_totalSupply,
    ERC20_decimals,
    ERC20_balanceOf,
    ERC20_allowance,

    ERC20_initializer,
    ERC20_approve,
    ERC20_increaseAllowance,
    ERC20_decreaseAllowance,
    ERC20_transfer,
    ERC20_transferFrom,
    ERC20_mint,
    ERC20_burn
)

from lib.wadraymath import (Wad, Ray, ray, ray_mul, ray_div,ray_sub, wad_to_ray, ray_to_wad )

@storage_var
func _userState(address : felt) -> (state : UserState):
end



##Store balance in ERC20 and additionalData here
@storage_var
func _additionalData(address : felt) -> (additionalData : Ray):
end



#temporary solution
@external
func addData{syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr}(user:felt, data:Ray)->(data:Ray):
    
    _additionalData.write(user, data)
    let (data) =_additionalData.read(user)
    return (data)
end



# temporary solution
@external
func readData{syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr}(user:felt)->(data:Ray):
    
    let (data) =_additionalData.read(user)
    return (data)
end



#Add IPool to the constructor
@constructor
func constructor{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr}(name:felt, symbol:felt, decimals: felt, recipient:felt, initial_supply:Uint256):


    #initialize ERC20 and mint
    ERC20_initializer(name, symbol, decimals)
    ERC20_mint(recipient, initial_supply)
    return ()
    
end



@external
func scaledBalanceOf{syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr}(user:felt) -> (balance:Uint256):
    
    let (balance)=balanceOf(user)
    return (balance)
end


@external
func getScaledUserBalanceAndSupply{syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr}(user:felt) -> (balance:Uint256, supply:Uint256):
    
    alloc_locals

    let (balance)=balanceOf(user)
    let (supply)= totalSupply()

    return (balance, supply)
end


@external 
func scaledTotalSupply{syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr}() -> (supply:Uint256):
    
    let (supply)= totalSupply()

    return (supply)
end

@view
func getPreviousIndex{syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr}(user:felt) -> (additionalData: Ray):
    

    let (additionalData)= _additionalData.read(user)
    return (additionalData)
end




#needs to have the onlyPool modifier
@external
func _mintScaled{syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr}(caller:felt, onBehalfOf:felt, amount:Uint256, index:Ray) -> (success:felt):
    
    alloc_locals

    let (amountRay)= wad_to_ray(Wad(amount))

    let (amountScaled)= ray_div(amountRay, index)

    #  with_attr error_message("INVALID_MINT_AMOUNT"):
    #     uint256_assert_not_zero(amountScaled)
    # end

    let (scaledBalance)=balanceOf(onBehalfOf)
    let (prevIndex)=getPreviousIndex(onBehalfOf)

    #need rayMul
    let (scaledBalanceRay)=wad_to_ray(Wad(scaledBalance))

    let (newBalance)=ray_mul(scaledBalanceRay, index)
    let (oldBalance)=ray_mul(scaledBalanceRay, prevIndex)


    let (balanceIncreaseRay)= ray_sub(newBalance, oldBalance)
     

    _additionalData.write(onBehalfOf, index)

    #second argument needs to be uint128
    ERC20_mint(onBehalfOf, amountScaled.ray)


    #carry guard here
    # let (amountToMint)= uint256_checked_add(amount,balanceIncrease)
    #emit Transfer and Mint events

    let (low_check) = is_not_zero(scaledBalance.low)
    let (high_check) = is_not_zero(scaledBalance.high)


    if (low_check+ high_check) == 0:
        return (success=0)
    else:
        return (success=1)
    end

end


#needs to have the onlyPool modifier
@external
func _burnScaled{syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr}(user:felt, target:felt, amount:Uint256, index:Ray) -> (success:felt):
    
    alloc_locals

    let (amountRay)= wad_to_ray(Wad(amount))

    let (amountScaled)= ray_div(amountRay, index)

    #  with_attr error_message("INVALID_MINT_AMOUNT"):
    #     uint256_assert_not_zero(amountScaled)
    # end

    let (scaledBalance)=balanceOf(user)
    let (prevIndex)=getPreviousIndex(user)

    #need raymul
    let (scaledBalanceRay)=wad_to_ray(Wad(scaledBalance))

    let (newBalance)=ray_mul(scaledBalanceRay, index)
    let (oldBalance)=ray_mul(scaledBalanceRay, prevIndex)

    let (balanceIncreaseRay)= ray_sub(newBalance, oldBalance)
     
    _additionalData.write(user, index)


    #second argument needs to be uin128
    ERC20_burn(user, amountScaled.ray)

    let isLess = uint256_lt(amount, balanceIncreaseRay.ray)


    if isLess.res==1:
    #uint256 amountToMint = balanceIncrease - amount;

    #emit Transfer and Mint events
        return (success=1)
    
    else:

    #uint256 amountToBurn = amount - balanceIncrease;

    #emit Transfer and Burn events
        return (success=0)

    end

end



@view
func name{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }() -> (name: felt):
    let (name) = ERC20_name()
    return (name)
end

@view
func symbol{
        syscall_ptr : felt*,
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }() -> (symbol: felt):
    let (symbol) = ERC20_symbol()
    return (symbol)
end

@view
func totalSupply{
        syscall_ptr : felt*, 
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }() -> (totalSupply: Uint256):
    let (totalSupply: Uint256) = ERC20_totalSupply()
    return (totalSupply)
end

@view
func decimals{
        syscall_ptr : felt*, 
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }() -> (decimals: felt):
    let (decimals) = ERC20_decimals()
    return (decimals)
end

@view
func balanceOf{
        syscall_ptr : felt*, 
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(account: felt) -> (balance: Uint256):
    let (balance: Uint256) = ERC20_balanceOf(account)
    return (balance)
end

@view
func allowance{
        syscall_ptr : felt*, 
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(owner: felt, spender: felt) -> (remaining: Uint256):
    let (remaining: Uint256) = ERC20_allowance(owner, spender)
    return (remaining)
end


@external
func transfer{
        syscall_ptr : felt*, 
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(recipient: felt, amount: Uint256) -> (success: felt):
    ERC20_transfer(recipient, amount)
    return (TRUE)
end

@external
func transferFrom{
        syscall_ptr : felt*, 
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(
        sender: felt, 
        recipient: felt, 
        amount: Uint256
    ) -> (success: felt):
    ERC20_transferFrom(sender, recipient, amount)
    return (TRUE)
end

@external
func approve{
        syscall_ptr : felt*, 
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(spender: felt, amount: Uint256) -> (success: felt):
    ERC20_approve(spender, amount)
    return (TRUE)
end

@external
func increaseAllowance{
        syscall_ptr : felt*, 
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(spender: felt, added_value: Uint256) -> (success: felt):
    ERC20_increaseAllowance(spender, added_value)
    return (TRUE)
end


@external
func decreaseAllowance{
        syscall_ptr : felt*, 
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(spender: felt, subtracted_value: Uint256) -> (success: felt):
    ERC20_decreaseAllowance(spender, subtracted_value)
    return (TRUE)
end