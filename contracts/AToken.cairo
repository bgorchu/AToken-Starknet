%lang starknet




#Add IPool to the constructor
@constructor
func constructor{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr}(name:felt, symbol:felt, decimals: felt, recipient:felt, initial_supply:Uint256):


    
    ScaledBalanceTokenBase_initializer(name, symbol, decimals, recipient, initial_supply)


    #set treasury address
    #set underlying asset address
    #set incentives controller address
    return ()
    
end


#mint 
#burn



#onlyPool modifier
@external
func mintToTreasury{syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr}(amount: Uint256, index:Uint256):


    return()
end


#onlyPool modifier
@external
func transferOnLiquidation{syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr}(amount: Uint256, index:Uint256):


    return()
end


# Wrappers around ERC20 operations that throw on failure 
# (when the token contract returns false)
@external
func safeTransfer{syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr}(to: Uint256, amount:Uint256):


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


