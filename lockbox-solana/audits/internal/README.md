# Internal audit of autonolas-tokenomics-solana
The review has been performed based on the contract code in the following repository:<br>
`https://github.com/valory-xyz/autonolas-tokenomics-solana` <br>
commit: `f41380246b6f777acd0a540a400854bd92ebf0cc` or `tag: v0.1.0-pre-internal-audit`<br> 

## Objectives
The audit focused on contracts in this repo.

### Security issues. Updated 19-12-23

### Notes
```
address _pool,
address _bridgedTokenMint,
address _pdaBridgedTokenAccount,
correctness of parameters area of responsibility of deployer.
```
- No code changes required

```
    @mutableAccount(userPositionAccount)
    @mutableAccount(pdaPositionAccount)
    @mutableAccount(userBridgedTokenAccount)
    @mutableAccount(bridgedTokenMint)
    @account(position)
    @account(positionMint)
    @signer(userWallet)
    function deposit() external {

userPositionAccount checked by positionMint
pdaPositionAccount checked by ownership of pdaProgram, pdaProgram is find in constructor
userBridgedTokenAccount responsibility of user
bridgedTokenMint checked by global bridgedTokenMint
position checked by a lot of checks _getPositionData()
positionMint checked vs position in _getPositionData()
```
- No code changes required

```
    @mutableAccount(pool)
    @mutableAccount(tokenProgramId)
    @mutableAccount(position)
    @mutableAccount(userBridgedTokenAccount)
    @mutableAccount(pdaBridgedTokenAccount)
    @mutableAccount(userWallet)
    @mutableAccount(userPositionAccount)
    @mutableAccount(bridgedTokenMint)
    @mutableAccount(pdaPositionAccount)
    @mutableAccount(userTokenAccountA)
    @mutableAccount(userTokenAccountB)
    @mutableAccount(tokenVaultA)
    @mutableAccount(tokenVaultB)
    @mutableAccount(tickArrayLower)
    @mutableAccount(tickArrayUpper)
    @mutableAccount(positionMint)
    @signer(sig)
    // Transfer with PDA
    function withdraw(uint64 amount) external {

pool checked by global pool
tokenProgramId cannot be faked
position checked by map
userBridgedTokenAccount as responsibility of user
pdaBridgedTokenAccount checked by global pdaBridgedTokenAccount
userPositionAccount ??
bridgedTokenMint not checked
pdaPositionAccount checked by global map
userTokenAccountA as responsibility of user
userTokenAccountB as responsibility of user
tokenVaultA not checked
tokenVaultB not checked
tickArrayLower not checked
tickArrayUpper not checked
positionMint not checked
```
- Checks and usage clarification need to be added:
-- userPositionAccount
-- bridgedTokenMint
-- positionMint
- It is possible to leave it as the responsibility of the `whirlpool`
-- tokenVaultA
-- tokenVaultB
-- tickArrayLower
-- tickArrayUpper
[x] fixed

- Pay attention on getLiquidityAmountsAndPositions
```
            if (totalLiquidity >= amount) {
                break;
```
[x] fixed