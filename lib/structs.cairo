from starkware.cairo.common.uint256 import Uint256



struct UserState:
    member balance : Uint256
    member additionalData : Uint256
end


# temporary replacement for IAaveIncentivesController contract
struct IAaveIncentivesController:
    member temp1: felt
end


# temporary replacement for IpoolAddressesProvider contract
struct IPoolAddressesProvider:
    member temp1: felt
end


# temporary replacement for Ipool contract
struct IPool:
    member _addressesProvider: IPoolAddressesProvider
end