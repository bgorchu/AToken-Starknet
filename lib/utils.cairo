from starkware.cairo.common.uint256 import Uint256
from starkware.cairo.common.cairo_builtins import HashBuiltin



func assert_not_zero(value):
    %{
        from starkware.cairo.common.math_utils import assert_integer
        assert_integer(ids.value)
        assert ids.value % PRIME != 0, f'assert_not_zero failed: {ids.value} = 0.'
    %}
    if value == 0:
        # If value == 0, add an unsatisfiable requirement.
        value = 1
    end

    return ()
end



func is_not_zero(value) -> (res):
    if value == 0:
        return (res=0)
    end

    return (res=1)
end



func uint256_assert_not_zero{
    syscall_ptr : felt*,
    pedersen_ptr : HashBuiltin*,
    range_check_ptr
  }(a : Uint256):
    let (low_check) = is_not_zero(a.low)
    let (high_check) = is_not_zero(a.high)
    with_attr error_message("is zero"):
      assert_not_zero(low_check + high_check)
    end

    return ()
end