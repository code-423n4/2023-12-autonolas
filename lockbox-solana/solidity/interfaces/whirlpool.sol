enum CurrIndex {
	Below,
	Inside,
	Above
}
enum TickLabel {
	Upper,
	Lower
}
enum Direction {
	Left,
	Right
}
struct OpenPositionBumps {
	uint8	positionBump;
}
struct OpenPositionWithMetadataBumps {
	uint8	positionBump;
	uint8	metadataBump;
}
struct PositionRewardInfo {
	uint128	growthInsideCheckpoint;
	uint64	amountOwed;
}
struct Tick {
	bool	initialized;
	int128	liquidityNet;
	uint128	liquidityGross;
	uint128	feeGrowthOutsideA;
	uint128	feeGrowthOutsideB;
	uint128[3]	rewardGrowthsOutside;
}
/// Stores the state relevant for tracking liquidity mining rewards at the `Whirlpool` level.
/// These values are used in conjunction with `PositionRewardInfo`, `Tick.reward_growths_outside`,
/// and `Whirlpool.reward_last_updated_timestamp` to determine how many rewards are earned by open
/// positions.
struct WhirlpoolRewardInfo {
	/// Reward token mint.
	address	mint;
	/// Reward vault token account.
	address	vault;
	/// Authority account that has permission to initialize the reward and set emissions.
	address	authority;
	/// Q64.64 number that indicates how many tokens per second are earned per unit of liquidity.
	uint128	emissionsPerSecondX64;
	/// Q64.64 number that tracks the total tokens earned per unit of liquidity since the reward
	/// emissions were turned on.
	uint128	growthGlobalX64;
}
struct WhirlpoolBumps {
	uint8	whirlpoolBump;
}
@program_id("whirLbMiicVdio4qvUfM5KAg6Ct8VwpYzGff3uctyCc")
interface whirlpool {
	/// Initializes a WhirlpoolsConfig account that hosts info & authorities
	/// required to govern a set of Whirlpools.
	/// 
	/// ### Parameters
	/// - `fee_authority` - Authority authorized to initialize fee-tiers and set customs fees.
	/// - `collect_protocol_fees_authority` - Authority authorized to collect protocol fees.
	/// - `reward_emissions_super_authority` - Authority authorized to set reward authorities in pools.
	@selector([0xd0,0x7f,0x15,0x01,0xc2,0xbe,0xc4,0x46])
	function initializeConfig(address feeAuthority,address collectProtocolFeesAuthority,address rewardEmissionsSuperAuthority,uint16 defaultProtocolFeeRate) external;
	/// Initializes a Whirlpool account.
	/// Fee rate is set to the default values on the config and supplied fee_tier.
	/// 
	/// ### Parameters
	/// - `bumps` - The bump value when deriving the PDA of the Whirlpool address.
	/// - `tick_spacing` - The desired tick spacing for this pool.
	/// - `initial_sqrt_price` - The desired initial sqrt-price for this pool
	/// 
	/// #### Special Errors
	/// `InvalidTokenMintOrder` - The order of mints have to be ordered by
	/// `SqrtPriceOutOfBounds` - provided initial_sqrt_price is not between 2^-64 to 2^64
	/// 
	@selector([0x5f,0xb4,0x0a,0xac,0x54,0xae,0xe8,0x28])
	function initializePool(WhirlpoolBumps bumps,uint16 tickSpacing,uint128 initialSqrtPrice) external;
	/// Initializes a tick_array account to represent a tick-range in a Whirlpool.
	/// 
	/// ### Parameters
	/// - `start_tick_index` - The starting tick index for this tick-array.
	/// Has to be a multiple of TickArray size & the tick spacing of this pool.
	/// 
	/// #### Special Errors
	/// - `InvalidStartTick` - if the provided start tick is out of bounds or is not a multiple of
	/// TICK_ARRAY_SIZE * tick spacing.
	@selector([0x0b,0xbc,0xc1,0xd6,0x8d,0x5b,0x95,0xb8])
	function initializeTickArray(int32 startTickIndex) external;
	/// Initializes a fee_tier account usable by Whirlpools in a WhirlpoolConfig space.
	/// 
	/// ### Authority
	/// - "fee_authority" - Set authority in the WhirlpoolConfig
	/// 
	/// ### Parameters
	/// - `tick_spacing` - The tick-spacing that this fee-tier suggests the default_fee_rate for.
	/// - `default_fee_rate` - The default fee rate that a pool will use if the pool uses this
	/// fee tier during initialization.
	/// 
	/// #### Special Errors
	/// - `FeeRateMaxExceeded` - If the provided default_fee_rate exceeds MAX_FEE_RATE.
	@selector([0xb7,0x4a,0x9c,0xa0,0x70,0x02,0x2a,0x1e])
	function initializeFeeTier(uint16 tickSpacing,uint16 defaultFeeRate) external;
	/// Initialize reward for a Whirlpool. A pool can only support up to a set number of rewards.
	/// 
	/// ### Authority
	/// - "reward_authority" - assigned authority by the reward_super_authority for the specified
	/// reward-index in this Whirlpool
	/// 
	/// ### Parameters
	/// - `reward_index` - The reward index that we'd like to initialize. (0 <= index <= NUM_REWARDS)
	/// 
	/// #### Special Errors
	/// - `InvalidRewardIndex` - If the provided reward index doesn't match the lowest uninitialized
	/// index in this pool, or exceeds NUM_REWARDS, or
	/// all reward slots for this pool has been initialized.
	@selector([0x5f,0x87,0xc0,0xc4,0xf2,0x81,0xe6,0x44])
	function initializeReward(uint8 rewardIndex) external;
	/// Set the reward emissions for a reward in a Whirlpool.
	/// 
	/// ### Authority
	/// - "reward_authority" - assigned authority by the reward_super_authority for the specified
	/// reward-index in this Whirlpool
	/// 
	/// ### Parameters
	/// - `reward_index` - The reward index (0 <= index <= NUM_REWARDS) that we'd like to modify.
	/// - `emissions_per_second_x64` - The amount of rewards emitted in this pool.
	/// 
	/// #### Special Errors
	/// - `RewardVaultAmountInsufficient` - The amount of rewards in the reward vault cannot emit
	/// more than a day of desired emissions.
	/// - `InvalidTimestamp` - Provided timestamp is not in order with the previous timestamp.
	/// - `InvalidRewardIndex` - If the provided reward index doesn't match the lowest uninitialized
	/// index in this pool, or exceeds NUM_REWARDS, or
	/// all reward slots for this pool has been initialized.
	@selector([0x0d,0xc5,0x56,0xa8,0x6d,0xb0,0x1b,0xf4])
	function setRewardEmissions(uint8 rewardIndex,uint128 emissionsPerSecondX64) external;
	/// Open a position in a Whirlpool. A unique token will be minted to represent the position
	/// in the users wallet. The position will start off with 0 liquidity.
	/// 
	/// ### Parameters
	/// - `tick_lower_index` - The tick specifying the lower end of the position range.
	/// - `tick_upper_index` - The tick specifying the upper end of the position range.
	/// 
	/// #### Special Errors
	/// - `InvalidTickIndex` - If a provided tick is out of bounds, out of order or not a multiple of
	/// the tick-spacing in this pool.
	@selector([0x87,0x80,0x2f,0x4d,0x0f,0x98,0xf0,0x31])
	function openPosition(OpenPositionBumps bumps,int32 tickLowerIndex,int32 tickUpperIndex) external;
	/// Open a position in a Whirlpool. A unique token will be minted to represent the position
	/// in the users wallet. Additional Metaplex metadata is appended to identify the token.
	/// The position will start off with 0 liquidity.
	/// 
	/// ### Parameters
	/// - `tick_lower_index` - The tick specifying the lower end of the position range.
	/// - `tick_upper_index` - The tick specifying the upper end of the position range.
	/// 
	/// #### Special Errors
	/// - `InvalidTickIndex` - If a provided tick is out of bounds, out of order or not a multiple of
	/// the tick-spacing in this pool.
	@selector([0xf2,0x1d,0x86,0x30,0x3a,0x6e,0x0e,0x3c])
	function openPositionWithMetadata(OpenPositionWithMetadataBumps bumps,int32 tickLowerIndex,int32 tickUpperIndex) external;
	/// Add liquidity to a position in the Whirlpool. This call also updates the position's accrued fees and rewards.
	/// 
	/// ### Authority
	/// - `position_authority` - authority that owns the token corresponding to this desired position.
	/// 
	/// ### Parameters
	/// - `liquidity_amount` - The total amount of Liquidity the user is willing to deposit.
	/// - `token_max_a` - The maximum amount of tokenA the user is willing to deposit.
	/// - `token_max_b` - The maximum amount of tokenB the user is willing to deposit.
	/// 
	/// #### Special Errors
	/// - `LiquidityZero` - Provided liquidity amount is zero.
	/// - `LiquidityTooHigh` - Provided liquidity exceeds u128::max.
	/// - `TokenMaxExceeded` - The required token to perform this operation exceeds the user defined amount.
	@selector([0x2e,0x9c,0xf3,0x76,0x0d,0xcd,0xfb,0xb2])
	function increaseLiquidity(uint128 liquidityAmount,uint64 tokenMaxA,uint64 tokenMaxB) external;
	/// Withdraw liquidity from a position in the Whirlpool. This call also updates the position's accrued fees and rewards.
	/// 
	/// ### Authority
	/// - `position_authority` - authority that owns the token corresponding to this desired position.
	/// 
	/// ### Parameters
	/// - `liquidity_amount` - The total amount of Liquidity the user desires to withdraw.
	/// - `token_min_a` - The minimum amount of tokenA the user is willing to withdraw.
	/// - `token_min_b` - The minimum amount of tokenB the user is willing to withdraw.
	/// 
	/// #### Special Errors
	/// - `LiquidityZero` - Provided liquidity amount is zero.
	/// - `LiquidityTooHigh` - Provided liquidity exceeds u128::max.
	/// - `TokenMinSubceeded` - The required token to perform this operation subceeds the user defined amount.
	@selector([0xa0,0x26,0xd0,0x6f,0x68,0x5b,0x2c,0x01])
	function decreaseLiquidity(uint128 liquidityAmount,uint64 tokenMinA,uint64 tokenMinB) external;
	/// Update the accrued fees and rewards for a position.
	/// 
	/// #### Special Errors
	/// - `TickNotFound` - Provided tick array account does not contain the tick for this position.
	/// - `LiquidityZero` - Position has zero liquidity and therefore already has the most updated fees and reward values.
	@selector([0x9a,0xe6,0xfa,0x0d,0xec,0xd1,0x4b,0xdf])
	function updateFeesAndRewards() external;
	/// Collect fees accrued for this position.
	/// 
	/// ### Authority
	/// - `position_authority` - authority that owns the token corresponding to this desired position.
	@selector([0xa4,0x98,0xcf,0x63,0x1e,0xba,0x13,0xb6])
	function collectFees() external;
	/// Collect rewards accrued for this position.
	/// 
	/// ### Authority
	/// - `position_authority` - authority that owns the token corresponding to this desired position.
	@selector([0x46,0x05,0x84,0x57,0x56,0xeb,0xb1,0x22])
	function collectReward(uint8 rewardIndex) external;
	/// Collect the protocol fees accrued in this Whirlpool
	/// 
	/// ### Authority
	/// - `collect_protocol_fees_authority` - assigned authority in the WhirlpoolConfig that can collect protocol fees
	@selector([0x16,0x43,0x17,0x62,0x96,0xb2,0x46,0xdc])
	function collectProtocolFees() external;
	/// Perform a swap in this Whirlpool
	/// 
	/// ### Authority
	/// - "token_authority" - The authority to withdraw tokens from the input token account.
	/// 
	/// ### Parameters
	/// - `amount` - The amount of input or output token to swap from (depending on amount_specified_is_input).
	/// - `other_amount_threshold` - The maximum/minimum of input/output token to swap into (depending on amount_specified_is_input).
	/// - `sqrt_price_limit` - The maximum/minimum price the swap will swap to.
	/// - `amount_specified_is_input` - Specifies the token the parameter `amount`represents. If true, the amount represents the input token of the swap.
	/// - `a_to_b` - The direction of the swap. True if swapping from A to B. False if swapping from B to A.
	/// 
	/// #### Special Errors
	/// - `ZeroTradableAmount` - User provided parameter `amount` is 0.
	/// - `InvalidSqrtPriceLimitDirection` - User provided parameter `sqrt_price_limit` does not match the direction of the trade.
	/// - `SqrtPriceOutOfBounds` - User provided parameter `sqrt_price_limit` is over Whirlppool's max/min bounds for sqrt-price.
	/// - `InvalidTickArraySequence` - User provided tick-arrays are not in sequential order required to proceed in this trade direction.
	/// - `TickArraySequenceInvalidIndex` - The swap loop attempted to access an invalid array index during the query of the next initialized tick.
	/// - `TickArrayIndexOutofBounds` - The swap loop attempted to access an invalid array index during tick crossing.
	/// - `LiquidityOverflow` - Liquidity value overflowed 128bits during tick crossing.
	/// - `InvalidTickSpacing` - The swap pool was initialized with tick-spacing of 0.
	@selector([0xf8,0xc6,0x9e,0x91,0xe1,0x75,0x87,0xc8])
	function swap(uint64 amount,uint64 otherAmountThreshold,uint128 sqrtPriceLimit,bool amountSpecifiedIsInput,bool aToB) external;
	/// Close a position in a Whirlpool. Burns the position token in the owner's wallet.
	/// 
	/// ### Authority
	/// - "position_authority" - The authority that owns the position token.
	/// 
	/// #### Special Errors
	/// - `ClosePositionNotEmpty` - The provided position account is not empty.
	@selector([0x7b,0x86,0x51,0x00,0x31,0x44,0x62,0x62])
	function closePosition() external;
	/// Set the default_fee_rate for a FeeTier
	/// Only the current fee authority has permission to invoke this instruction.
	/// 
	/// ### Authority
	/// - "fee_authority" - Set authority in the WhirlpoolConfig
	/// 
	/// ### Parameters
	/// - `default_fee_rate` - The default fee rate that a pool will use if the pool uses this
	/// fee tier during initialization.
	/// 
	/// #### Special Errors
	/// - `FeeRateMaxExceeded` - If the provided default_fee_rate exceeds MAX_FEE_RATE.
	@selector([0x76,0xd7,0xd6,0x9d,0xb6,0xe5,0xd0,0xe4])
	function setDefaultFeeRate(uint16 defaultFeeRate) external;
	/// Sets the default protocol fee rate for a WhirlpoolConfig
	/// Protocol fee rate is represented as a basis point.
	/// Only the current fee authority has permission to invoke this instruction.
	/// 
	/// ### Authority
	/// - "fee_authority" - Set authority that can modify pool fees in the WhirlpoolConfig
	/// 
	/// ### Parameters
	/// - `default_protocol_fee_rate` - Rate that is referenced during the initialization of a Whirlpool using this config.
	/// 
	/// #### Special Errors
	/// - `ProtocolFeeRateMaxExceeded` - If the provided default_protocol_fee_rate exceeds MAX_PROTOCOL_FEE_RATE.
	@selector([0x6b,0xcd,0xf9,0xe2,0x97,0x23,0x56,0x00])
	function setDefaultProtocolFeeRate(uint16 defaultProtocolFeeRate) external;
	/// Sets the fee rate for a Whirlpool.
	/// Fee rate is represented as hundredths of a basis point.
	/// Only the current fee authority has permission to invoke this instruction.
	/// 
	/// ### Authority
	/// - "fee_authority" - Set authority that can modify pool fees in the WhirlpoolConfig
	/// 
	/// ### Parameters
	/// - `fee_rate` - The rate that the pool will use to calculate fees going onwards.
	/// 
	/// #### Special Errors
	/// - `FeeRateMaxExceeded` - If the provided fee_rate exceeds MAX_FEE_RATE.
	@selector([0x35,0xf3,0x89,0x41,0x08,0x8c,0x9e,0x06])
	function setFeeRate(uint16 feeRate) external;
	/// Sets the protocol fee rate for a Whirlpool.
	/// Protocol fee rate is represented as a basis point.
	/// Only the current fee authority has permission to invoke this instruction.
	/// 
	/// ### Authority
	/// - "fee_authority" - Set authority that can modify pool fees in the WhirlpoolConfig
	/// 
	/// ### Parameters
	/// - `protocol_fee_rate` - The rate that the pool will use to calculate protocol fees going onwards.
	/// 
	/// #### Special Errors
	/// - `ProtocolFeeRateMaxExceeded` - If the provided default_protocol_fee_rate exceeds MAX_PROTOCOL_FEE_RATE.
	@selector([0x5f,0x07,0x04,0x32,0x9a,0x4f,0x9c,0x83])
	function setProtocolFeeRate(uint16 protocolFeeRate) external;
	/// Sets the fee authority for a WhirlpoolConfig.
	/// The fee authority can set the fee & protocol fee rate for individual pools or
	/// set the default fee rate for newly minted pools.
	/// Only the current fee authority has permission to invoke this instruction.
	/// 
	/// ### Authority
	/// - "fee_authority" - Set authority that can modify pool fees in the WhirlpoolConfig
	@selector([0x1f,0x01,0x32,0x57,0xed,0x65,0x61,0x84])
	function setFeeAuthority() external;
	/// Sets the fee authority to collect protocol fees for a WhirlpoolConfig.
	/// Only the current collect protocol fee authority has permission to invoke this instruction.
	/// 
	/// ### Authority
	/// - "fee_authority" - Set authority that can collect protocol fees in the WhirlpoolConfig
	@selector([0x22,0x96,0x5d,0xf4,0x8b,0xe1,0xe9,0x43])
	function setCollectProtocolFeesAuthority() external;
	/// Set the whirlpool reward authority at the provided `reward_index`.
	/// Only the current reward authority for this reward index has permission to invoke this instruction.
	/// 
	/// ### Authority
	/// - "reward_authority" - Set authority that can control reward emission for this particular reward.
	/// 
	/// #### Special Errors
	/// - `InvalidRewardIndex` - If the provided reward index doesn't match the lowest uninitialized
	/// index in this pool, or exceeds NUM_REWARDS, or
	/// all reward slots for this pool has been initialized.
	@selector([0x22,0x27,0xb7,0xfc,0x53,0x1c,0x55,0x7f])
	function setRewardAuthority(uint8 rewardIndex) external;
	/// Set the whirlpool reward authority at the provided `reward_index`.
	/// Only the current reward super authority has permission to invoke this instruction.
	/// 
	/// ### Authority
	/// - "reward_authority" - Set authority that can control reward emission for this particular reward.
	/// 
	/// #### Special Errors
	/// - `InvalidRewardIndex` - If the provided reward index doesn't match the lowest uninitialized
	/// index in this pool, or exceeds NUM_REWARDS, or
	/// all reward slots for this pool has been initialized.
	@selector([0xf0,0x9a,0xc9,0xc6,0x94,0x5d,0x38,0x19])
	function setRewardAuthorityBySuperAuthority(uint8 rewardIndex) external;
	/// Set the whirlpool reward super authority for a WhirlpoolConfig
	/// Only the current reward super authority has permission to invoke this instruction.
	/// This instruction will not change the authority on any `WhirlpoolRewardInfo` whirlpool rewards.
	/// 
	/// ### Authority
	/// - "reward_emissions_super_authority" - Set authority that can control reward authorities for all pools in this config space.
	@selector([0xcf,0x05,0xc8,0xd1,0x7a,0x38,0x52,0xb7])
	function setRewardEmissionsSuperAuthority() external;
	/// Perform a two-hop swap in this Whirlpool
	/// 
	/// ### Authority
	/// - "token_authority" - The authority to withdraw tokens from the input token account.
	/// 
	/// ### Parameters
	/// - `amount` - The amount of input or output token to swap from (depending on amount_specified_is_input).
	/// - `other_amount_threshold` - The maximum/minimum of input/output token to swap into (depending on amount_specified_is_input).
	/// - `amount_specified_is_input` - Specifies the token the parameter `amount`represents. If true, the amount represents the input token of the swap.
	/// - `a_to_b_one` - The direction of the swap of hop one. True if swapping from A to B. False if swapping from B to A.
	/// - `a_to_b_two` - The direction of the swap of hop two. True if swapping from A to B. False if swapping from B to A.
	/// - `sqrt_price_limit_one` - The maximum/minimum price the swap will swap to in the first hop.
	/// - `sqrt_price_limit_two` - The maximum/minimum price the swap will swap to in the second hop.
	/// 
	/// #### Special Errors
	/// - `ZeroTradableAmount` - User provided parameter `amount` is 0.
	/// - `InvalidSqrtPriceLimitDirection` - User provided parameter `sqrt_price_limit` does not match the direction of the trade.
	/// - `SqrtPriceOutOfBounds` - User provided parameter `sqrt_price_limit` is over Whirlppool's max/min bounds for sqrt-price.
	/// - `InvalidTickArraySequence` - User provided tick-arrays are not in sequential order required to proceed in this trade direction.
	/// - `TickArraySequenceInvalidIndex` - The swap loop attempted to access an invalid array index during the query of the next initialized tick.
	/// - `TickArrayIndexOutofBounds` - The swap loop attempted to access an invalid array index during tick crossing.
	/// - `LiquidityOverflow` - Liquidity value overflowed 128bits during tick crossing.
	/// - `InvalidTickSpacing` - The swap pool was initialized with tick-spacing of 0.
	/// - `InvalidIntermediaryMint` - Error if the intermediary mint between hop one and two do not equal.
	/// - `DuplicateTwoHopPool` - Error if whirlpool one & two are the same pool.
	@selector([0xc3,0x60,0xed,0x6c,0x44,0xa2,0xdb,0xe6])
	function twoHopSwap(uint64 amount,uint64 otherAmountThreshold,bool amountSpecifiedIsInput,bool aToBOne,bool aToBTwo,uint128 sqrtPriceLimitOne,uint128 sqrtPriceLimitTwo) external;
	/// Initializes a PositionBundle account that bundles several positions.
	/// A unique token will be minted to represent the position bundle in the users wallet.
	@selector([0x75,0x2d,0xf1,0x95,0x18,0x12,0xc2,0x41])
	function initializePositionBundle() external;
	/// Initializes a PositionBundle account that bundles several positions.
	/// A unique token will be minted to represent the position bundle in the users wallet.
	/// Additional Metaplex metadata is appended to identify the token.
	@selector([0x5d,0x7c,0x10,0xb3,0xf9,0x83,0x73,0xf5])
	function initializePositionBundleWithMetadata() external;
	/// Delete a PositionBundle account. Burns the position bundle token in the owner's wallet.
	/// 
	/// ### Authority
	/// - `position_bundle_owner` - The owner that owns the position bundle token.
	/// 
	/// ### Special Errors
	/// - `PositionBundleNotDeletable` - The provided position bundle has open positions.
	@selector([0x64,0x19,0x63,0x02,0xd9,0xef,0x7c,0xad])
	function deletePositionBundle() external;
	/// Open a bundled position in a Whirlpool. No new tokens are issued
	/// because the owner of the position bundle becomes the owner of the position.
	/// The position will start off with 0 liquidity.
	/// 
	/// ### Authority
	/// - `position_bundle_authority` - authority that owns the token corresponding to this desired position bundle.
	/// 
	/// ### Parameters
	/// - `bundle_index` - The bundle index that we'd like to open.
	/// - `tick_lower_index` - The tick specifying the lower end of the position range.
	/// - `tick_upper_index` - The tick specifying the upper end of the position range.
	/// 
	/// #### Special Errors
	/// - `InvalidBundleIndex` - If the provided bundle index is out of bounds.
	/// - `InvalidTickIndex` - If a provided tick is out of bounds, out of order or not a multiple of
	/// the tick-spacing in this pool.
	@selector([0xa9,0x71,0x7e,0xab,0xd5,0xac,0xd4,0x31])
	function openBundledPosition(uint16 bundleIndex,int32 tickLowerIndex,int32 tickUpperIndex) external;
	/// Close a bundled position in a Whirlpool.
	/// 
	/// ### Authority
	/// - `position_bundle_authority` - authority that owns the token corresponding to this desired position bundle.
	/// 
	/// ### Parameters
	/// - `bundle_index` - The bundle index that we'd like to close.
	/// 
	/// #### Special Errors
	/// - `InvalidBundleIndex` - If the provided bundle index is out of bounds.
	/// - `ClosePositionNotEmpty` - The provided position account is not empty.
	@selector([0x29,0x24,0xd8,0xf5,0x1b,0x55,0x67,0x43])
	function closeBundledPosition(uint16 bundleIndex) external;
}
