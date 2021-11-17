object \"GuestBook\" {
    code {
        let size := datasize(\"runtime\")
        datacopy(0, dataoffset(\"runtime\"), size)
        return(0, size)
    }
    object \"runtime\" {
        code {
            function $$sign($book_msg) -> return_val {
                mcopys($book_msg, div(map_value_ptr(0, caller()), 32), 132)
                log1(abi_encode_string_100($book_msg), add(64, ceil32(mload($book_msg))), 0xcd5d879305a2503cad08d3e2d007778eec8dc5def7bc74dd20875842b2ff7765)
                {
                    return_val := 0x0
                    leave
                }
            }
            function $$get_msg($addr) -> return_val { {
                return_val := scopym(div(map_value_ptr(0, $addr), 32), 132)
                leave
            } }
            function abi_decode_component_address_calldata(head_start, offset) -> return_val {
                let ptr := add(head_start, offset)
                return_val := calldataload(ptr)
                if iszero(is_left_padded(96, return_val)) { revert_with_Error_uint256(259) }
            }
            function abi_decode_component_string_100_calldata(head_start, head_offset) -> return_val, data_start_offset, data_end_offset {
                let head_ptr := add(head_start, head_offset)
                data_start_offset := calldataload(head_ptr)
                let data_start := add(head_start, data_start_offset)
                let string_size := calldataload(data_start)
                if gt(string_size, 100) { revert_with_Error_uint256(259) }
                let data_size := add(string_size, 32)
                let padded_data_size := ceil32(data_size)
                data_end_offset := add(data_start_offset, padded_data_size)
                let end_word := calldataload(sub(add(head_start, data_end_offset), 32))
                let padding_size_bits := mul(sub(padded_data_size, data_size), 8)
                if iszero(is_right_padded(padding_size_bits, end_word)) { revert_with_Error_uint256(259) }
                return_val := ccopym(data_start, data_size)
            }
            function abi_decode_data_address_calldata(head_start, data_end) -> return_val_0 {
                let encoding_size := sub(data_end, head_start)
                if iszero(eq(encoding_size, 32)) { revert_with_Error_uint256(259) }
                let head_offset_0 := 0
                let decoded_val_0 := abi_decode_component_address_calldata(head_start, head_offset_0)
                if iszero(eq(encoding_size, 32)) { revert_with_Error_uint256(259) }
                return_val_0 := decoded_val_0
            }
            function abi_decode_data_string_100_calldata(head_start, data_end) -> return_val_0 {
                let encoding_size := sub(data_end, head_start)
                if or(lt(encoding_size, 64), gt(encoding_size, 192)) { revert_with_Error_uint256(259) }
                let head_offset_0 := 0
                let decoded_val_0, data_start_offset_0, data_end_offset_0 := abi_decode_component_string_100_calldata(head_start, head_offset_0)
                if iszero(eq(data_start_offset_0, 32)) { revert_with_Error_uint256(259) }
                if iszero(eq(encoding_size, data_end_offset_0)) { revert_with_Error_uint256(259) }
                return_val_0 := decoded_val_0
            }
            function abi_encode_string_100(encode_val_0) -> return_ptr {
                return_ptr := avail()
                let data_offset := 32
                {
                    mstore(alloc(32), data_offset)
                    let num_bytes := mload(encode_val_0)
                    let data_size := ceil32(add(32, num_bytes))
                    data_offset := add(data_offset, data_size)
                }
                {
                    let num_bytes := mload(encode_val_0)
                    let data_size := add(32, num_bytes)
                    let remainder := sub(ceil32(data_size), data_size)
                    pop(mcopym(encode_val_0, data_size))
                    pop(alloc(remainder))
                }
            }
            function abi_encode_uint256(encode_val_0) -> return_ptr {
                return_ptr := avail()
                let data_offset := 32
                {
                    let ptr := alloc(32)
                    mstore(ptr, encode_val_0)
                }
            }
            function abi_unpack(mptr, array_size, inner_data_size) { for { let i := 0 } lt(i, array_size) { i := add(i, 1) } {
                let val_ptr := add(mptr, mul(i, inner_data_size))
                let val := mloadn(val_ptr, inner_data_size)
                pop(alloc_mstoren(val, 32))
            } }
            function adjust_numeric_i128(value) -> cleaned { cleaned := signextend(15, value) }
            function adjust_numeric_i16(value) -> cleaned { cleaned := signextend(1, value) }
            function adjust_numeric_i32(value) -> cleaned { cleaned := signextend(3, value) }
            function adjust_numeric_i64(value) -> cleaned { cleaned := signextend(7, value) }
            function adjust_numeric_i8(value) -> cleaned { cleaned := signextend(0, value) }
            function adjust_numeric_u128(value) -> cleaned { cleaned := and(value, 0xffffffffffffffffffffffffffffffff) }
            function adjust_numeric_u16(value) -> cleaned { cleaned := and(value, 0xffff) }
            function adjust_numeric_u32(value) -> cleaned { cleaned := and(value, 0xffffffff) }
            function adjust_numeric_u64(value) -> cleaned { cleaned := and(value, 0xffffffffffffffff) }
            function adjust_numeric_u8(value) -> cleaned { cleaned := and(value, 0xff) }
            function alloc(size) -> ptr {
                ptr := mload(0x00)
                if eq(ptr, 0x00) { ptr := 0x20 }
                mstore(0x00, add(ptr, size))
            }
            function alloc_mstoren(val, size) -> ptr {
                ptr := alloc(size)
                mstoren(ptr, size, val)
            }
            function avail() -> ptr {
                ptr := mload(0x00)
                if eq(ptr, 0x00) { ptr := 0x20 }
            }
            function bytes_mcopys(mptr, sptr, size) {
                let word_ptr := div(sptr, 32)
                mcopys(mptr, word_ptr, size)
            }
            function bytes_scopym(sptr, size) -> mptr {
                let word_ptr := div(sptr, 32)
                mptr := scopym(word_ptr, size)
            }
            function bytes_scopys(ptr1, ptr2, size) {
                let word_ptr1 := div(ptr1, 32)
                let word_ptr2 := div(ptr2, 32)
                scopys(word_ptr1, word_ptr2, size)
            }
            function bytes_sloadn(sptr, size) -> val {
                let word_ptr := div(sptr, 32)
                let bytes_offset := mod(sptr, 32)
                val := sloadn(word_ptr, bytes_offset, size)
            }
            function bytes_sstoren(sptr, size, val) {
                let word_ptr := div(sptr, 32)
                let bytes_offset := mod(sptr, 32)
                sstoren(word_ptr, bytes_offset, size, val)
            }
            function ccopym(cptr, size) -> mptr {
                mptr := alloc(size)
                calldatacopy(mptr, cptr, size)
            }
            function ceil32(n) -> return_val { return_val := mul(div(add(n, 31), 32), 32) }
            function checked_add_i128(val1, val2) -> sum {
                if and(iszero(slt(val1, 0)), sgt(val2, sub(0x7fffffffffffffffffffffffffffffff, val1))) { revert_with_Panic_uint256(17) }
                if and(slt(val1, 0), slt(val2, sub(0xffffffffffffffffffffffffffffffff80000000000000000000000000000000, val1))) { revert_with_Panic_uint256(17) }
                sum := add(val1, val2)
            }
            function checked_add_i16(val1, val2) -> sum {
                if and(iszero(slt(val1, 0)), sgt(val2, sub(0x7fff, val1))) { revert_with_Panic_uint256(17) }
                if and(slt(val1, 0), slt(val2, sub(0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff8000, val1))) { revert_with_Panic_uint256(17) }
                sum := add(val1, val2)
            }
            function checked_add_i256(val1, val2) -> sum {
                if and(iszero(slt(val1, 0)), sgt(val2, sub(0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff, val1))) { revert_with_Panic_uint256(17) }
                if and(slt(val1, 0), slt(val2, sub(0x8000000000000000000000000000000000000000000000000000000000000000, val1))) { revert_with_Panic_uint256(17) }
                sum := add(val1, val2)
            }
            function checked_add_i32(val1, val2) -> sum {
                if and(iszero(slt(val1, 0)), sgt(val2, sub(0x7fffffff, val1))) { revert_with_Panic_uint256(17) }
                if and(slt(val1, 0), slt(val2, sub(0xffffffffffffffffffffffffffffffffffffffffffffffffffffffff80000000, val1))) { revert_with_Panic_uint256(17) }
                sum := add(val1, val2)
            }
            function checked_add_i64(val1, val2) -> sum {
                if and(iszero(slt(val1, 0)), sgt(val2, sub(0x7fffffffffffffff, val1))) { revert_with_Panic_uint256(17) }
                if and(slt(val1, 0), slt(val2, sub(0xffffffffffffffffffffffffffffffffffffffffffffffff8000000000000000, val1))) { revert_with_Panic_uint256(17) }
                sum := add(val1, val2)
            }
            function checked_add_i8(val1, val2) -> sum {
                if and(iszero(slt(val1, 0)), sgt(val2, sub(0x7f, val1))) { revert_with_Panic_uint256(17) }
                if and(slt(val1, 0), slt(val2, sub(0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff80, val1))) { revert_with_Panic_uint256(17) }
                sum := add(val1, val2)
            }
            function checked_add_u128(val1, val2) -> sum {
                if gt(val1, sub(0xffffffffffffffffffffffffffffffff, val2)) { revert_with_Panic_uint256(17) }
                sum := add(val1, val2)
            }
            function checked_add_u16(val1, val2) -> sum {
                if gt(val1, sub(0xffff, val2)) { revert_with_Panic_uint256(17) }
                sum := add(val1, val2)
            }
            function checked_add_u256(val1, val2) -> sum {
                if gt(val1, sub(0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff, val2)) { revert_with_Panic_uint256(17) }
                sum := add(val1, val2)
            }
            function checked_add_u32(val1, val2) -> sum {
                if gt(val1, sub(0xffffffff, val2)) { revert_with_Panic_uint256(17) }
                sum := add(val1, val2)
            }
            function checked_add_u64(val1, val2) -> sum {
                if gt(val1, sub(0xffffffffffffffff, val2)) { revert_with_Panic_uint256(17) }
                sum := add(val1, val2)
            }
            function checked_add_u8(val1, val2) -> sum {
                if gt(val1, sub(0xff, val2)) { revert_with_Panic_uint256(17) }
                sum := add(val1, val2)
            }
            function checked_div_i128(val1, val2) -> result {
                if iszero(val2) { revert_with_Panic_uint256(18) }
                if and(eq(val1, 0xffffffffffffffffffffffffffffffff80000000000000000000000000000000), eq(val2, sub(0, 1))) { revert_with_Panic_uint256(17) }
                result := sdiv(val1, val2)
            }
            function checked_div_i16(val1, val2) -> result {
                if iszero(val2) { revert_with_Panic_uint256(18) }
                if and(eq(val1, 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff8000), eq(val2, sub(0, 1))) { revert_with_Panic_uint256(17) }
                result := sdiv(val1, val2)
            }
            function checked_div_i256(val1, val2) -> result {
                if iszero(val2) { revert_with_Panic_uint256(18) }
                if and(eq(val1, 0x8000000000000000000000000000000000000000000000000000000000000000), eq(val2, sub(0, 1))) { revert_with_Panic_uint256(17) }
                result := sdiv(val1, val2)
            }
            function checked_div_i32(val1, val2) -> result {
                if iszero(val2) { revert_with_Panic_uint256(18) }
                if and(eq(val1, 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffff80000000), eq(val2, sub(0, 1))) { revert_with_Panic_uint256(17) }
                result := sdiv(val1, val2)
            }
            function checked_div_i64(val1, val2) -> result {
                if iszero(val2) { revert_with_Panic_uint256(18) }
                if and(eq(val1, 0xffffffffffffffffffffffffffffffffffffffffffffffff8000000000000000), eq(val2, sub(0, 1))) { revert_with_Panic_uint256(17) }
                result := sdiv(val1, val2)
            }
            function checked_div_i8(val1, val2) -> result {
                if iszero(val2) { revert_with_Panic_uint256(18) }
                if and(eq(val1, 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff80), eq(val2, sub(0, 1))) { revert_with_Panic_uint256(17) }
                result := sdiv(val1, val2)
            }
            function checked_div_unsigned(val1, val2) -> result {
                if iszero(val2) { revert_with_Panic_uint256(18) }
                result := div(val1, val2)
            }
            function checked_exp_helper(_power, _base, exponent, max) -> power, base {
                power := _power
                base := _base
                for { } gt(exponent, 1) { } {
                    if gt(base, div(max, base)) { revert_with_Panic_uint256(17) }
                    if and(exponent, 1) { power := mul(power, base) }
                    base := mul(base, base)
                    exponent := shr(1, exponent)
                }
            }
            function checked_exp_i128(base, exponent) -> power { power := checked_exp_signed(base, exponent, 0xffffffffffffffffffffffffffffffff80000000000000000000000000000000, 0x7fffffffffffffffffffffffffffffff) }
            function checked_exp_i16(base, exponent) -> power { power := checked_exp_signed(base, exponent, 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff8000, 0x7fff) }
            function checked_exp_i256(base, exponent) -> power { power := checked_exp_signed(base, exponent, 0x8000000000000000000000000000000000000000000000000000000000000000, 0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff) }
            function checked_exp_i32(base, exponent) -> power { power := checked_exp_signed(base, exponent, 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffff80000000, 0x7fffffff) }
            function checked_exp_i64(base, exponent) -> power { power := checked_exp_signed(base, exponent, 0xffffffffffffffffffffffffffffffffffffffffffffffff8000000000000000, 0x7fffffffffffffff) }
            function checked_exp_i8(base, exponent) -> power { power := checked_exp_signed(base, exponent, 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff80, 0x7f) }
            function checked_exp_signed(base, exponent, min, max) -> power {
                switch exponent
                case 0 {
                    power := 1
                    leave
                }
                case 1 {
                    power := base
                    leave
                }
                if iszero(base) {
                    power := 0
                    leave
                }
                power := 1
                switch sgt(base, 0)
                case 1 { if gt(base, div(max, base)) { revert_with_Panic_uint256(17) } }
                case 0 { if slt(base, sdiv(max, base)) { revert_with_Panic_uint256(17) } }
                if and(exponent, 1) { power := base }
                base := mul(base, base)
                exponent := shr(1, exponent)
                power, base := checked_exp_helper(power, base, exponent, max)
                if and(sgt(power, 0), gt(power, div(max, base))) { revert_with_Panic_uint256(17) }
                if and(slt(power, 0), slt(power, sdiv(min, base))) { revert_with_Panic_uint256(17) }
                power := mul(power, base)
            }
            function checked_exp_u128(base, exponent) -> power { power := checked_exp_unsigned(base, exponent, 0xffffffffffffffffffffffffffffffff) }
            function checked_exp_u16(base, exponent) -> power { power := checked_exp_unsigned(base, exponent, 0xffff) }
            function checked_exp_u256(base, exponent) -> power { power := checked_exp_unsigned(base, exponent, 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff) }
            function checked_exp_u32(base, exponent) -> power { power := checked_exp_unsigned(base, exponent, 0xffffffff) }
            function checked_exp_u64(base, exponent) -> power { power := checked_exp_unsigned(base, exponent, 0xffffffffffffffff) }
            function checked_exp_u8(base, exponent) -> power { power := checked_exp_unsigned(base, exponent, 0xff) }
            function checked_exp_unsigned(base, exponent, max) -> power {
                if iszero(exponent) {
                    power := 1
                    leave
                }
                if iszero(base) {
                    power := 0
                    leave
                }
                switch base
                case 1 {
                    power := 1
                    leave
                }
                case 2 {
                    if gt(exponent, 255) { revert_with_Panic_uint256(17) }
                    power := exp(2, exponent)
                    if gt(power, max) { revert_with_Panic_uint256(17) }
                    leave
                }
                if and(sgt(power, 0), gt(power, div(max, base))) { revert_with_Panic_uint256(17) }
                if or(and(lt(base, 11), lt(exponent, 78)), and(lt(base, 307), lt(exponent, 32))) {
                    power := exp(base, exponent)
                    if gt(power, max) { revert_with_Panic_uint256(17) }
                    leave
                }
                power, base := checked_exp_helper(1, base, exponent, max)
                if gt(power, div(max, base)) { revert_with_Panic_uint256(17) }
                power := mul(power, base)
            }
            function checked_mod_signed(val1, val2) -> result {
                if iszero(val2) { revert_with_Panic_uint256(18) }
                result := smod(val1, val2)
            }
            function checked_mod_unsigned(val1, val2) -> result {
                if iszero(val2) { revert_with_Panic_uint256(18) }
                result := mod(val1, val2)
            }
            function checked_mul_i128(val1, val2) -> product {
                if and(and(sgt(val1, 0), sgt(val2, 0)), gt(val1, div(0x7fffffffffffffffffffffffffffffff, val2))) { revert_with_Panic_uint256(17) }
                if and(and(sgt(val1, 0), slt(val2, 0)), slt(val2, sdiv(0xffffffffffffffffffffffffffffffff80000000000000000000000000000000, val1))) { revert_with_Panic_uint256(17) }
                if and(and(slt(val1, 0), sgt(val2, 0)), slt(val1, sdiv(0xffffffffffffffffffffffffffffffff80000000000000000000000000000000, val2))) { revert_with_Panic_uint256(17) }
                if and(and(slt(val1, 0), slt(val2, 0)), slt(val1, sdiv(0x7fffffffffffffffffffffffffffffff, val2))) { revert_with_Panic_uint256(17) }
                product := mul(val1, val2)
            }
            function checked_mul_i16(val1, val2) -> product {
                if and(and(sgt(val1, 0), sgt(val2, 0)), gt(val1, div(0x7fff, val2))) { revert_with_Panic_uint256(17) }
                if and(and(sgt(val1, 0), slt(val2, 0)), slt(val2, sdiv(0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff8000, val1))) { revert_with_Panic_uint256(17) }
                if and(and(slt(val1, 0), sgt(val2, 0)), slt(val1, sdiv(0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff8000, val2))) { revert_with_Panic_uint256(17) }
                if and(and(slt(val1, 0), slt(val2, 0)), slt(val1, sdiv(0x7fff, val2))) { revert_with_Panic_uint256(17) }
                product := mul(val1, val2)
            }
            function checked_mul_i256(val1, val2) -> product {
                if and(and(sgt(val1, 0), sgt(val2, 0)), gt(val1, div(0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff, val2))) { revert_with_Panic_uint256(17) }
                if and(and(sgt(val1, 0), slt(val2, 0)), slt(val2, sdiv(0x8000000000000000000000000000000000000000000000000000000000000000, val1))) { revert_with_Panic_uint256(17) }
                if and(and(slt(val1, 0), sgt(val2, 0)), slt(val1, sdiv(0x8000000000000000000000000000000000000000000000000000000000000000, val2))) { revert_with_Panic_uint256(17) }
                if and(and(slt(val1, 0), slt(val2, 0)), slt(val1, sdiv(0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff, val2))) { revert_with_Panic_uint256(17) }
                product := mul(val1, val2)
            }
            function checked_mul_i32(val1, val2) -> product {
                if and(and(sgt(val1, 0), sgt(val2, 0)), gt(val1, div(0x7fffffff, val2))) { revert_with_Panic_uint256(17) }
                if and(and(sgt(val1, 0), slt(val2, 0)), slt(val2, sdiv(0xffffffffffffffffffffffffffffffffffffffffffffffffffffffff80000000, val1))) { revert_with_Panic_uint256(17) }
                if and(and(slt(val1, 0), sgt(val2, 0)), slt(val1, sdiv(0xffffffffffffffffffffffffffffffffffffffffffffffffffffffff80000000, val2))) { revert_with_Panic_uint256(17) }
                if and(and(slt(val1, 0), slt(val2, 0)), slt(val1, sdiv(0x7fffffff, val2))) { revert_with_Panic_uint256(17) }
                product := mul(val1, val2)
            }
            function checked_mul_i64(val1, val2) -> product {
                if and(and(sgt(val1, 0), sgt(val2, 0)), gt(val1, div(0x7fffffffffffffff, val2))) { revert_with_Panic_uint256(17) }
                if and(and(sgt(val1, 0), slt(val2, 0)), slt(val2, sdiv(0xffffffffffffffffffffffffffffffffffffffffffffffff8000000000000000, val1))) { revert_with_Panic_uint256(17) }
                if and(and(slt(val1, 0), sgt(val2, 0)), slt(val1, sdiv(0xffffffffffffffffffffffffffffffffffffffffffffffff8000000000000000, val2))) { revert_with_Panic_uint256(17) }
                if and(and(slt(val1, 0), slt(val2, 0)), slt(val1, sdiv(0x7fffffffffffffff, val2))) { revert_with_Panic_uint256(17) }
                product := mul(val1, val2)
            }
            function checked_mul_i8(val1, val2) -> product {
                if and(and(sgt(val1, 0), sgt(val2, 0)), gt(val1, div(0x7f, val2))) { revert_with_Panic_uint256(17) }
                if and(and(sgt(val1, 0), slt(val2, 0)), slt(val2, sdiv(0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff80, val1))) { revert_with_Panic_uint256(17) }
                if and(and(slt(val1, 0), sgt(val2, 0)), slt(val1, sdiv(0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff80, val2))) { revert_with_Panic_uint256(17) }
                if and(and(slt(val1, 0), slt(val2, 0)), slt(val1, sdiv(0x7f, val2))) { revert_with_Panic_uint256(17) }
                product := mul(val1, val2)
            }
            function checked_mul_u128(val1, val2) -> product {
                if and(iszero(iszero(val1)), gt(val2, div(0xffffffffffffffffffffffffffffffff, val1))) { revert_with_Panic_uint256(17) }
                product := mul(val1, val2)
            }
            function checked_mul_u16(val1, val2) -> product {
                if and(iszero(iszero(val1)), gt(val2, div(0xffff, val1))) { revert_with_Panic_uint256(17) }
                product := mul(val1, val2)
            }
            function checked_mul_u256(val1, val2) -> product {
                if and(iszero(iszero(val1)), gt(val2, div(0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff, val1))) { revert_with_Panic_uint256(17) }
                product := mul(val1, val2)
            }
            function checked_mul_u32(val1, val2) -> product {
                if and(iszero(iszero(val1)), gt(val2, div(0xffffffff, val1))) { revert_with_Panic_uint256(17) }
                product := mul(val1, val2)
            }
            function checked_mul_u64(val1, val2) -> product {
                if and(iszero(iszero(val1)), gt(val2, div(0xffffffffffffffff, val1))) { revert_with_Panic_uint256(17) }
                product := mul(val1, val2)
            }
            function checked_mul_u8(val1, val2) -> product {
                if and(iszero(iszero(val1)), gt(val2, div(0xff, val1))) { revert_with_Panic_uint256(17) }
                product := mul(val1, val2)
            }
            function checked_neg_i128(val1) -> result {
                if eq(val1, 0xffffffffffffffffffffffffffffffff80000000000000000000000000000000) { revert_with_Panic_uint256(17) }
                result := sub(0, val1)
            }
            function checked_neg_i16(val1) -> result {
                if eq(val1, 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff8000) { revert_with_Panic_uint256(17) }
                result := sub(0, val1)
            }
            function checked_neg_i256(val1) -> result {
                if eq(val1, 0x8000000000000000000000000000000000000000000000000000000000000000) { revert_with_Panic_uint256(17) }
                result := sub(0, val1)
            }
            function checked_neg_i32(val1) -> result {
                if eq(val1, 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffff80000000) { revert_with_Panic_uint256(17) }
                result := sub(0, val1)
            }
            function checked_neg_i64(val1) -> result {
                if eq(val1, 0xffffffffffffffffffffffffffffffffffffffffffffffff8000000000000000) { revert_with_Panic_uint256(17) }
                result := sub(0, val1)
            }
            function checked_neg_i8(val1) -> result {
                if eq(val1, 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff80) { revert_with_Panic_uint256(17) }
                result := sub(0, val1)
            }
            function checked_sub_i128(val1, val2) -> diff {
                if and(iszero(slt(val2, 0)), slt(val1, add(0xffffffffffffffffffffffffffffffff80000000000000000000000000000000, val2))) { revert_with_Panic_uint256(17) }
                if and(slt(val2, 0), sgt(val1, add(0x7fffffffffffffffffffffffffffffff, val2))) { revert_with_Panic_uint256(17) }
                diff := sub(val1, val2)
            }
            function checked_sub_i16(val1, val2) -> diff {
                if and(iszero(slt(val2, 0)), slt(val1, add(0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff8000, val2))) { revert_with_Panic_uint256(17) }
                if and(slt(val2, 0), sgt(val1, add(0x7fff, val2))) { revert_with_Panic_uint256(17) }
                diff := sub(val1, val2)
            }
            function checked_sub_i256(val1, val2) -> diff {
                if and(iszero(slt(val2, 0)), slt(val1, add(0x8000000000000000000000000000000000000000000000000000000000000000, val2))) { revert_with_Panic_uint256(17) }
                if and(slt(val2, 0), sgt(val1, add(0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff, val2))) { revert_with_Panic_uint256(17) }
                diff := sub(val1, val2)
            }
            function checked_sub_i32(val1, val2) -> diff {
                if and(iszero(slt(val2, 0)), slt(val1, add(0xffffffffffffffffffffffffffffffffffffffffffffffffffffffff80000000, val2))) { revert_with_Panic_uint256(17) }
                if and(slt(val2, 0), sgt(val1, add(0x7fffffff, val2))) { revert_with_Panic_uint256(17) }
                diff := sub(val1, val2)
            }
            function checked_sub_i64(val1, val2) -> diff {
                if and(iszero(slt(val2, 0)), slt(val1, add(0xffffffffffffffffffffffffffffffffffffffffffffffff8000000000000000, val2))) { revert_with_Panic_uint256(17) }
                if and(slt(val2, 0), sgt(val1, add(0x7fffffffffffffff, val2))) { revert_with_Panic_uint256(17) }
                diff := sub(val1, val2)
            }
            function checked_sub_i8(val1, val2) -> diff {
                if and(iszero(slt(val2, 0)), slt(val1, add(0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff80, val2))) { revert_with_Panic_uint256(17) }
                if and(slt(val2, 0), sgt(val1, add(0x7f, val2))) { revert_with_Panic_uint256(17) }
                diff := sub(val1, val2)
            }
            function checked_sub_unsigned(val1, val2) -> diff {
                if lt(val1, val2) { revert_with_Panic_uint256(17) }
                diff := sub(val1, val2)
            }
            function cloadn(ptr, size) -> val { val := shr(sub(256, mul(8, size)), calldataload(ptr)) }
            function contract_create(data_ptr, data_size, value) -> return_address {
                let mptr := alloc(data_size)
                datacopy(mptr, data_ptr, data_size)
                return_address := create(value, mptr, data_size)
            }
            function contract_create2(data_ptr, data_size, value, salt) -> return_address {
                let mptr := alloc(data_size)
                datacopy(mptr, data_ptr, data_size)
                return_address := create2(value, mptr, data_size, salt)
            }
            function free(ptr) { mstore(0x00, ptr) }
            function is_left_padded(size_bits, val) -> return_val {
                let bits_shifted := sub(256, size_bits)
                let shifted_val := shr(bits_shifted, val)
                return_val := iszero(shifted_val)
            }
            function is_right_padded(size_bits, val) -> return_val {
                let bits_shifted := sub(256, size_bits)
                let shifted_val := shl(bits_shifted, val)
                return_val := iszero(shifted_val)
            }
            function load_data_string(code_ptr, size) -> mptr {
                mptr := alloc(32)
                mstore(mptr, size)
                let content_ptr := alloc(size)
                datacopy(content_ptr, code_ptr, size)
            }
            function map_value_ptr(a, b) -> return_val {
                let ptr := avail()
                mstore(ptr, a)
                mstore(add(ptr, 32), b)
                let hash := keccak256(ptr, 64)
                return_val := set_zero(248, 256, hash)
            }
            function mcopym(ptr1, size) -> ptr2 {
                ptr2 := alloc(size)
                let offset := 0
                for { } lt(add(offset, 32), size) { } {
                    let _ptr1 := add(ptr1, offset)
                    let _ptr2 := add(ptr2, offset)
                    mstore(_ptr2, mload(_ptr1))
                    offset := add(offset, 32)
                }
                let rem := sub(size, offset)
                if gt(rem, 0) {
                    let _ptr1 := add(ptr1, offset)
                    let _ptr2 := add(ptr2, offset)
                    mstoren(_ptr2, rem, mloadn(_ptr1, rem))
                }
            }
            function mcopys(mptr, sptr, size) {
                let mptr_offset := 0
                let sptr_offset := 0
                for { } lt(add(mptr_offset, 32), size) { } {
                    let _mptr := add(mptr, mptr_offset)
                    let _sptr := add(sptr, sptr_offset)
                    sstore(_sptr, mload(_mptr))
                    mptr_offset := add(mptr_offset, 32)
                    sptr_offset := add(sptr_offset, 1)
                }
                let rem := sub(size, mptr_offset)
                if gt(rem, 0) {
                    let _mptr := add(mptr, mptr_offset)
                    let _sptr := add(sptr, sptr_offset)
                    let zeroed_val := set_zero(mul(rem, 8), 256, mload(_mptr))
                    sstore(_sptr, zeroed_val)
                }
            }
            function mloadn(ptr, size) -> val { val := shr(sub(256, mul(8, size)), mload(ptr)) }
            function mstoren(ptr, size, val) {
                let size_bits := mul(8, size)
                let left := shl(sub(256, size_bits), val)
                let right := shr(size_bits, mload(add(ptr, size)))
                mstore(ptr, or(left, right))
            }
            function revert_with_Error_uint256(val) {
                let ptr := alloc_mstoren(0x2e36a709, 4)
                pop(abi_encode_uint256(val))
                revert(ptr, add(4, add(32, 0)))
            }
            function revert_with_Panic_uint256(val) {
                let ptr := alloc_mstoren(0x4e487b71, 4)
                pop(abi_encode_uint256(val))
                revert(ptr, add(4, add(32, 0)))
            }
            function scopym(sptr, size) -> mptr {
                mptr := alloc(size)
                let mptr_offset := 0
                let sptr_offset := 0
                for { } lt(add(mptr_offset, 32), size) { } {
                    let _mptr := add(mptr, mptr_offset)
                    let _sptr := add(sptr, sptr_offset)
                    mstore(_mptr, sload(_sptr))
                    mptr_offset := add(mptr_offset, 32)
                    sptr_offset := add(sptr_offset, 1)
                }
                let rem := sub(size, mptr_offset)
                if gt(rem, 0) {
                    let _mptr := add(mptr, mptr_offset)
                    let _sptr := add(sptr, sptr_offset)
                    mstoren(_mptr, rem, sloadn(_sptr, 0, rem))
                }
            }
            function scopys(ptr1, ptr2, size) {
                let word_size := div(add(size, 31), 32)
                let offset := 0
                for { } lt(add(offset, 1), size) { } {
                    let _ptr1 := add(ptr1, offset)
                    let _ptr2 := add(ptr2, offset)
                    sstore(_ptr2, sload(_ptr1))
                    offset := add(offset, 1)
                }
            }
            function send_value(to_address, value_in_wei) -> result {
                if lt(selfbalance(), value_in_wei) { revert_with_Error_uint256(256) }
                let success := call(gas(), to_address, value_in_wei, 0, 0, 0, 0)
                if iszero(success) { revert_with_Error_uint256(257) }
                result := 0x0
            }
            function set_zero(start_bit, end_bit, val) -> result {
                let left_shift_dist := sub(256, start_bit)
                let right_shift_dist := end_bit
                let left := shl(left_shift_dist, shr(left_shift_dist, val))
                let right := shr(right_shift_dist, shl(right_shift_dist, val))
                result := or(left, right)
            }
            function sloadn(word_ptr, bytes_offset, bytes_size) -> val {
                let bits_offset := mul(bytes_offset, 8)
                let bits_size := mul(bytes_size, 8)
                let bits_padding := sub(256, bits_size)
                let word := sload(word_ptr)
                let word_shl := shl(bits_offset, word)
                val := shr(bits_padding, word_shl)
            }
            function sstoren(word_ptr, bytes_offset, bytes_size, val) {
                let bits_offset := mul(bytes_offset, 8)
                let bits_size := mul(bytes_size, 8)
                let old_word := sload(word_ptr)
                let zeroed_word := set_zero(bits_offset, add(bits_offset, bits_size), old_word)
                let left_shift_dist := sub(sub(256, bits_size), bits_offset)
                let offset_val := shl(left_shift_dist, val)
                let new_word := or(zeroed_word, offset_val)
                sstore(word_ptr, new_word)
            }
            function ternary(test, if_expr, else_expr) -> result { switch test
            case 1 { result := if_expr }
            case 0 { result := else_expr } }
            switch cloadn(0, 4)
            case 0x79d6348d {
                let call_val_0 := abi_decode_data_string_100_calldata(4, calldatasize())
                pop($$sign(call_val_0))
                return(0, 0)
            }
            case 0xd60bed18 {
                let call_val_0 := abi_decode_data_address_calldata(4, calldatasize())
                let return_val := $$get_msg(call_val_0)
                let encoding_start := abi_encode_string_100(return_val)
                let encoding_size := add(64, ceil32(mload(return_val)))
                return(encoding_start, encoding_size)
            }
            default { return(0, 0) }
        }
    }
}