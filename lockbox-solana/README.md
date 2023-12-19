# autonolas-tokenomics-solana
Autonolas tokenomics contracts on Solana.

## Introduction
This repository contain the liquidity lockbox set of contracts on Solana. The description of the concept can be found here:
[Liquidity lockbox concept](https://github.com/valory-xyz/autonolas-tokenomics-solana/blob/main/docs/Bonding_mechanism_with_liquidity_on_Solana?raw=true).

The repository is still under active development.

## Pre-requisites
- Solang version: `v0.3.3`;
- Solana version: `solana-cli 1.17.7 (src:fca44b78; feat:3073089885, client:SolanaLabs)`;
- Anchor version: `anchor-cli 0.29.0`.

## Development
Install the dependencies:
```
yarn
```

Build the code with:
```
anchor build
```

Run the validator in a separate window:
```
./validator.sh
```

Then, execute the testing script:
```
solana airdrop 10000 9fit3w7t6FHATDaZWotpWqN7NpqgL3Lm1hqUop4hAy8h --url localhost && anchor test --skip-local-validator
```

For debugging, after run local validator:
```
solana logs -v --url localhost GUGGHzwC8wEKY3g7QS38YmoS8t5Q2faWAGAfxDK2bXbb
solana logs -v --url localhost whirLbMiicVdio4qvUfM5KAg6Ct8VwpYzGff3uctyCc
```

If the `@programId` in liquidity_lockbox.sol does not match with the deployed one, update it and re-run
```
anchor build
```

### Audits
The audit is provided as development matures. The latest audit report can be found here: [audits](https://github.com/valory-xyz/autonolas-tokenomics-solana/blob/main/audits).
A list of known vulnerabilities can be found here: [Vulnerabilities list](https://github.com/valory-xyz/autonolas-tokenomics-solana/blob/main/docs/Vulnerabilities_list_tokenomics-solana.pdf?raw=true).

:warning: **Warning** <br />
The current version of the code fails when doing a CPI call to the Orca Whirlpool program in the `withdraw()` function.
The issue is described here: [CPI issue](https://github.com/hyperledger/solang/issues/1610).

For the moment, the `withdraw()` function testing is wrapped into a `try-catch` logic.

## Acknowledgements
The liquidity lockbox contracts were inspired and based on the following sources:
- [Solang](https://github.com/hyperledger/solang);
- [Orca](https://github.com/orca-so/whirlpools);
- [EverlastingsongSolsandbox](https://github.com/everlastingsong/solsandbox);
- [Everlastingsong Microscope](https://everlastingsong.github.io/account-microscope);
- [Everlastingsong Nebula](https://everlastingsong.github.io/nebula/).