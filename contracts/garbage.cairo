#Temporary solution
# @external
# func changeUserBalance{syscall_ptr : felt*,
#         pedersen_ptr : HashBuiltin*,
#         range_check_ptr}(account:felt, amount:Uint256, add:felt): 

#         alloc_locals
#         let (userState)=_userState.read(account)

#         if add == 1:
#             let (newBalance)=uint256_checked_add(userState.balance,amount)
#             let newState=UserState(newBalance,userState.additionalData)

#             _userState.write(account, newState) 
#         else:
#             let (newBalance)=uint256_checked_sub_le(userState.balance,amount)

#             let newState=UserState(newBalance,userState.additionalData)
#             _userState.write(account, newState) 

#         end

#         return()
# end



#Temporary solution
# @external
# func changeTotalSupply{syscall_ptr : felt*,
#         pedersen_ptr : HashBuiltin*,
#         range_check_ptr}(amount:Uint256, add: felt): 

#         let (oldSupply)=totalSupply()


#         #add an overflow guard here
#         if add == 1:
#             let (newSupply)= uint256_checked_add(oldSupply,amount)
#             _totalSupply.write(newSupply) 
#         else:
#             let (newSupply)=uint256_checked_sub_le(oldSupply,amount)
#             _totalSupply.write(newSupply) 
#         end

#         return()
# end