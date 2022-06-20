%lang starknet


from starkware.cairo.common.uint256 import Uint256, uint256_lt



@storage_var
func _treasury() -> (res : felt):
end


@storage_var
func _underlyingAsset() -> (res : felt):
end


@storage_var
func _incentivesController() -> (res : felt):
end



#Add IPool to the constructor
@constructor
func constructor{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr}(name:felt, symbol:felt, decimals: felt, recipient:felt, initial_supply:Uint256):


    
    ScaledBalanceTokenBase_initializer(name, symbol, decimals, recipient, initial_supply)

    # _treasury.write()
    # __underlyingAsset.write()
    # _incentivesController.write()

    #set incentives controller address
    return ()
    
end


#mint 
#burn
#balanceOf
#totalSupply



#onlyPool modifier
@external
func mintToTreasury{syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr}(amount: Uint256, index:Uint256):

    let (treasury)= treasury.read()

    # ScaledTokenBase._mintScaled(Pool.address,treasury, amount, index)

    return()
end


#onlyPool modifier
@external
func transferOnLiquidation{syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr}(from: felt, to:felt, value:Uint256):


    _transfer(from, to, value, false)

    return()
end


@external
func RESERVE_TREASURY_ADDRESS{syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr}()->(address:felt):

    _treasury.read()
    return()
end

@external
func UNDERLYING_ASSET_ADDRESS{syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr}()->(address:felt):

    _underlyingAsset.read()
    return()
end


# Wrappers around ERC20 operations that throw on failure 
# (when the token contract returns false)
# @external
# func safeTransfer{syscall_ptr: felt*,
#         pedersen_ptr: HashBuiltin*,
#         range_check_ptr}(to: Uint256, amount:Uint256):


#     return()
# end


# @external
# func transferUnderlyingTo{syscall_ptr: felt*,
#         pedersen_ptr: HashBuiltin*,
#         range_check_ptr}(to: Uint256, amount:Uint256):


#     return()
# end



@external
func _transfer{syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr}(from:felt, to:felt, amount:Uint256, validate:felt):

    
        


    return()
end

#onlyPoolAdmin modifier
@external
func rescueTokens{syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr}(token:felt, to:felt, amount:felt):



    return()
end



@external 
func permit{}():


end



## Transfer only after we check the HF from the Pool
@external 
func _transfer{}():

end


