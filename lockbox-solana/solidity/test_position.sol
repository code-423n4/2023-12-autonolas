struct Position {
    address whirlpool;      // 32
    address position_mint;  // 32
    uint128 liquidity;      // 16
    int32 tick_lower_index; // 4
    int32 tick_upper_index; // 4
}

@program_id("4fujZhdXYV57NzNUhHcAibK59fYRXKb4NpM4g5SCU8tw")
contract test_position {
    Position public position;

    @payer(payer)
    constructor(address _whirlpool, address _position_mint) {
        position.whirlpool = _whirlpool;
        position.position_mint = _position_mint;
        position.liquidity = 24458563;
        position.tick_lower_index = -443632;
        position.tick_upper_index = 443632;
    }

    function updatePosition(
        address _whirlpool,
        address _position_mint,
        uint128 _liquidity,
        int32 _tick_lower_index,
        int32 _tick_upper_index
    ) public {
        position.whirlpool = _whirlpool;
        position.position_mint = _position_mint;
        position.liquidity = _liquidity + type(uint32).max;
        position.tick_lower_index = _tick_lower_index;
        position.tick_upper_index = _tick_upper_index;
    }

    function getLiquidity() public view returns (uint128) {
        return position.liquidity;
    }
}
