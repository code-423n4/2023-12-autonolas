
# ✨ So you want to run an audit

This `README.md` contains a set of checklists for our audit collaboration.

Your audit will use two repos: 
- **an _audit_ repo** (this one), which is used for scoping your audit and for providing information to wardens
- **a _findings_ repo**, where issues are submitted (shared with you after the audit) 

Ultimately, when we launch the audit, this repo will be made public and will contain the smart contracts to be reviewed and all the information needed for audit participants. The findings repo will be made public after the audit report is published and your team has mitigated the identified issues.

Some of the checklists in this doc are for **C4 (🐺)** and some of them are for **you as the audit sponsor (⭐️)**.

---
# Repo setup

## ⭐️ Sponsor: Add code to this repo

- [ ] Create a PR to this repo with the below changes:
- [ ] Provide a self-contained repository with working commands that will build (at least) all in-scope contracts, and commands that will run tests producing gas reports for the relevant contracts.
- [ ] Make sure your code is thoroughly commented using the [NatSpec format](https://docs.soliditylang.org/en/v0.5.10/natspec-format.html#natspec-format).
- [ ] Please have final versions of contracts and documentation added/updated in this repo **no less than 48 business hours prior to audit start time.**
- [ ] Be prepared for a 🚨code freeze🚨 for the duration of the audit — important because it establishes a level playing field. We want to ensure everyone's looking at the same code, no matter when they look during the audit. (Note: this includes your own repo, since a PR can leak alpha to our wardens!)


---

## ⭐️ Sponsor: Edit this `README.md` file

- [ ] Modify the contents of this `README.md` file. Describe how your code is supposed to work with links to any relevent documentation and any other criteria/details that the C4 Wardens should keep in mind when reviewing. ([Here's a well-constructed example.](https://github.com/code-423n4/2022-08-foundation#readme))
- [ ] Review the Gas award pool amount. This can be adjusted up or down, based on your preference - just flag it for Code4rena staff so we can update the pool totals across all comms channels.
- [ ] Optional / nice to have: pre-record a high-level overview of your protocol (not just specific smart contract functions). This saves wardens a lot of time wading through documentation.
- [ ] [This checklist in Notion](https://code4rena.notion.site/Key-info-for-Code4rena-sponsors-f60764c4c4574bbf8e7a6dbd72cc49b4#0cafa01e6201462e9f78677a39e09746) provides some best practices for Code4rena audits.

## ⭐️ Sponsor: Final touches
- [ ] Review and confirm the details in the section titled "Scoping details" and alert Code4rena staff of any changes.
- [ ] Check that images and other files used in this README have been uploaded to the repo as a file and then linked in the README using absolute path (e.g. `https://github.com/code-423n4/yourrepo-url/filepath.png`)
- [ ] Ensure that *all* links and image/file paths in this README use absolute paths, not relative paths
- [ ] Check that all README information is in markdown format (HTML does not render on Code4rena.com)
- [ ] Remove any part of this template that's not relevant to the final version of the README (e.g. instructions in brackets and italic)
- [ ] Delete this checklist and all text above the line below when you're ready.

---

# Autonolas audit details
- Total Prize Pool: XXX XXX USDC (Notion: Total award pool)
  - HM awards: XXX XXX USDC (Notion: HM (main) pool)
  - Analysis awards: XXX XXX USDC (Notion: Analysis pool)
  - QA awards: XXX XXX USDC (Notion: QA pool)
  - Bot Race awards: XXX XXX USDC (Notion: Bot Race pool)
  - Gas awards: XXX XXX USDC (Notion: Gas pool)
  - Judge awards: XXX XXX USDC (Notion: Judge Fee)
  - Lookout awards: XXX XXX USDC (Notion: Sum of Pre-sort fee + Pre-sort early bonus)
  - Scout awards: $500 USDC (Notion: Scout fee - but usually $500 USDC)
  - (this line can be removed if there is no mitigation) Mitigation Review: XXX XXX USDC (*Opportunity goes to top 3 certified wardens based on placement in this audit.*)
- Join [C4 Discord](https://discord.gg/code4rena) to register
- Submit findings [using the C4 form](https://code4rena.com/contests/2023-12-autonolas/submit)
- [Read our guidelines for more details](https://docs.code4rena.com/roles/wardens)
- Starts December 21, 2023 20:00 UTC 
- Ends January 08, 2024 20:00 UTC 

## Automated Findings / Publicly Known Issues

The 4naly3er report can be found [here](https://github.com/code-423n4/2023-12-autonolas/blob/main/4naly3er-report.md).

Automated findings output for the audit can be found [here](https://github.com/code-423n4/2023-12-autonolas/blob/main/bot-report.md) within 24 hours of audit opening.

_Note for C4 wardens: Anything included in this `Automated Findings / Publicly Known Issues` section is considered a publicly known issue and is ineligible for awards._

The known issues (some of them intended by design) that are not in scope for this audit are outlened in the following: (ADJUST LIKS)
- https://github.com/valory-xyz/autonolas-governance/blob/pre-c4a/docs/Vulnerabilities_list_governance.pdf 
- https://github.com/valory-xyz/autonolas-registries/blob/pre-c4a/docs/Vulnerabilities_list_registries.pdf  
- https://github.com/valory-xyz/autonolas-tokenomics/blob/pre-c4a/docs/Vulnerabilities_list_tokenomics.pdf  
- https://github.com/valory-xyz/autonolas-tokenomics-solana/blob/main/docs/Vulnerabilities_list_tokenomics-solana.pdf 

:warning: **Warning** <br /> 

The current version of the lock_box.sol contact fails when doing a CPI call to the Orca Whirlpool program in the `withdraw()` function.
The issue is described here: [CPI issue](https://github.com/hyperledger/solang/issues/1610).

The `withdraw()` function testing is wrapped into a `try-catch` logic.



# Overview 

This audit is focused on parts of the Autonolas protocol. The protocol can be divided in three main parts: governance, registries, and tokenomics. Here an overview of these parts. 

The **governance** is designed to assume various control points to steer the Autonolas protocol. The veOLAS virtualized claim on OLAS
Governance keys componetns are: a governance module (ADDREF), a Timelock (ADDREF), veOLAS (ADDREF). These components allow the community to propose, vote on, and implement changes. The governance token, veOLAS is the virtualized representation of OLAS locked and used a similar approach to veCRV, where votes are weighted depending on the time OLAS is locked other than the amount of locked OLAS. The maximum voting power for a fixed amount of locked OLAS can be achieved with the longest lock. In mathematical terms, voting power is calculated as amount * time_locked / MAXTIME. An overview of the governance process can be found [here](https://github.com/valory-xyz/autonolas-governance/blob/pre-c4a/docs/Governance_process.pdf). While the OLAS token is a tradable utility token that will provide access to the core functionalities of the Autonolas project. The token follows the ERC20 standard and is deployed on the Ethereum mainnet. The token has an inflationary model to account for the economic primitives enabled by Autonolas tokenomics, e.g., bonding mechanism and OLAS top-up to boost developers' incentives (cf. OLAS token section [here](https://github.com/valory-xyz/autonolas-tokenomics/blob/pre-c4a/docs/Autonolas_tokenomics_audit.pdf) and the [Autonolas withepaper](https://www.autonolas.network/documents/whitepaper/Whitepaper%20v1.0.pdf)). Exceptionally, some changes to the Autonolas Protocol can be executed by a
community-owned multisig wallet (CM), bypassing the governance process. To align CM actions with the DAO’s intentand ensure their reversibility, a guard mechanism was introduced (see GuardCM code(ADDREF) and [aip-3](https://github.com/valory-xyz/autonolas-aip/blob/aip-3/content/aips/core-enhancing-autonolas-protocol-security.md) for more details) 

The core governance coordination mechanisms are anchored on a single chain. However, due to Autonolas’ multi-chain
focus, Autonolas employs cross-chain governance to enable governance actions between Ethereum (L1) and L2 networks like Polygon and Gnosis Chain at present, and others in the future. For cross-chain governance, Autonolas sends messages from Ethereum-based governance contracts to the target chains, employing mechanisms like the [FxPortal](https://github.com/0xPolygon/fx-portal/tree/v1.0.5) for Polygon ( cf. Add contract link) and [Arbitrary Message Bridge (AMB)](https://docs.gnosischain.com/bridges/tokenbridge/amb-bridge) for Gnosis Chain (cf. Add contract link) . Further details on Autonolas cross-chain bridging design can be found [here](https://github.com/valory-xyz/autonolas-governance/blob/pre-c4a/docs/governace_bridge.pdf). Whenever necessary, supplemented contracts are implemented for L1-L2 token transfers, such us the contracts (ADDLINK) enabling transfers of token deployed on Polygon to Ethereum and vice-versa based on a [Polygon-native FxPortal](https://github.com/fx-portal/contracts). Motivations and design overview of token bridgig between Polygon and Ethereum can be found [here](https://github.com/valory-xyz/autonolas-governance/blob/pre-c4a/docs/Bonding_mechanism_with_Polygon_LP_token.pdf) 


**Registries** allow developer of code in form of agents, components, or sevices to register and manage their code on-chain. The code existing off-chain will be uniquely represented on-chain by means of NFTs. The registries part under audit is focussed on registations and management of agents and components (off-chain) code  uniquely representeded on chain as NFTs. A summary of registries is provided [here](https://github.com/valory-xyz/autonolas-registries/blob/pre-c4a/docs/AgentServicesFunctionality.pdf) 

The **tokenomics** aims to growth useful code and useful capital proportionally. 
- Toward of growth useful code, it is incentivizes the (off-chain) creation and the (on-chain) registration of agents and components code making up useful services via the donations system. Specifically, the developers registering their code on-chain can accrue incentives proportional to their code contribution to registered service which received a donation (cf. the section [How the staking model for agents and component code is incentivized](https://github.com/valory-xyz/autonolas-tokenomics/blob/pre-c4a/docs/Autonolas_tokenomics_audit.pdf)). 
- In order to grow useful capital, the protocol can grow its own liquidity by incentivizing
liquidity providers to sell their own liquidity pairs (with one of the tokens in the pair
being the protocol token, e.g. OLAS-ETH) to the protocol for OLAS at a discount (cf. the section [How and when the bonding mechanism is incentivized](https://github.com/valory-xyz/autonolas-tokenomics/blob/pre-c4a/docs/Autonolas_tokenomics_audit.pdf)).)
Cf. the [Autonolas tokenomics paper](https://www.autonolas.network/documents/whitepaper/Autonolas_Tokenomics_Core_Technical_Document.pdf) for more details. 

For enabling bonding of pairs on different chains the following workflow is used:

- Move OLAS token from Ethereum to the target chain, using bridges with low trust requirements, good security, and minimal manual and team interaction to start the process.
- Create an LP-token on the target chain with the bridged OLAS token on the target chain and use popular decentralized exchanges with a Uni-v2-style AMM design.
- Transfer the LP-token back to Ethereum using the same bridge methods.
- Use the transferred LP-token for bonding in Autonolas' mechanism on Ethereum.

Whenever necessary additional contracts are deployed to enable seamless bonding participation. This is the case for enabling bonding on Solana. Specifically, [Orca](https://docs.orca.so/) AMM to create the LP-token can be used on Solana. Despite the possibility of creating full [range deposit](https://docs.orca.so/reference/full-range-deposit-pools) with Orca, LPs retain the ability to provide concentrated liquidity within a specific range, and as representations of their liquidity they receive non-fungible tokens. To ensure compatibility with the existing [depository model]() (ADDLINL) the contract (ADDLINK) is designed to encapsulate concentrated liquidity from Orca whirlpool contract and represent the liquidity with a full range with fungible tokens. More details and an overview of the design can be found [here](https://github.com/valory-xyz/autonolas-tokenomics-solana/blob/main/docs/Bonding%20mechanism%20with%20liquidity%20on%20Solana..pdf).


## Links
- **Previous audits:** :  (ADJUST LINKS)

The following folders containing audit-related materials associated with development progresses.
- https://github.com/valory-xyz/autonolas-governance/tree/pre-c4a/audits  
- https://github.com/valory-xyz/autonolas-registries/tree/pre-c4a/audits
- https://github.com/valory-xyz/autonolas-tokenomics/tree/pre-c4a/audits 
- https://github.com/valory-xyz/autonolas-tokenomics-solana/tree/pre-c4a/audits 

- **Documentation:** (ADJUST LINKS)

[Autonolas whitepaper](https://www.autonolas.network/documents/whitepaper/Whitepaper%20v1.0.pdf)  

The following are relevant for governance related contracts: 

- [Summary of governance model](https://github.com/valory-xyz/autonolas-governance/blob/pre-c4a/docs/Governance_process.pdf) 
- [Cross-chain governance design](https://github.com/valory-xyz/autonolas-governance/blob/pre-c4a/docs/governace_bridge.pdf) 
- [Bridging token created natively on Polygon to Ethereum and motivations](https://github.com/valory-xyz/autonolas-governance/blob/pre-c4a/docs/Bonding_mechanism_with_Polygon_LP_token.pdf)
- [GuardCM design and updates](https://github.com/valory-xyz/autonolas-aip/blob/aip-3/content/aips/core-enhancing-autonolas-protocol-security.md) 

The following are relevant for registries related contracts: 

- [Summary of registries design](https://github.com/valory-xyz/autonolas-registries/blob/pre-c4a/docs/AgentServicesFunctionality.pdf) 
- [Definitions and data structures](https://github.com/valory-xyz/autonolas-registries/blob/pre-c4a/docs/definitions.md) 

The following are relevant for tokenomics related contract:

- [Summary of tokenomics model](https://github.com/valory-xyz/autonolas-tokenomics/blob/pre-c4a/docs/Autonolas_tokenomics_audit.pdf) 
- [Autonolas tokenomics paper](https://www.autonolas.network/documents/whitepaper/Autonolas_Tokenomics_Core_Technical_Document.pdf)
- [Autonolas whitepaper](https://www.autonolas.network/documents/whitepaper/Whitepaper%20v1.0.pdf) 
- Uniswap-v2 like pairs can be used for the depository contract, [here](https://github.com/valory-xyz/autonolas-tokenomics/blob/pre-c4a/docs/LP_token_guide.md ) an illustrative guide 

- **Website:** https://olas.network/  

- **Twitter:**  @autonolas  

- **Discord:**  https://discord.gg/Dh6UqUuV 


# Scope

[ ⭐️ SPONSORS: add scoping and technical details here ]

- [ ] In the table format shown below, provide the name of each contract and:
  - [ ] source lines of code (excluding blank lines and comments) in each *For line of code counts, we recommend running prettier with a 100-character line length, and using [cloc](https://github.com/AlDanial/cloc).* 
  - [ ] external contracts called in each
  - [ ] libraries used in each

## Files in scope

| Contract | SLOC | Purpose | Libraries used |  
| ----------- | ----------- | ----------- | ----------- |
| Governance contracts (11) | | | |
| ----------- | ----------- | ----------- | ----------- |
| [governace/GovernorOLAS.sol](https://github.com/code-423n4/2023-12-autonolas/blob/governace/contracts/GovernorOLAS.sol) | 70 | This contract is the governance module contract | [`@openzeppelin/*`](https://openzeppelin.com/contracts/GovernorOLAS.sol)  |
| ----------- | ----------- | ----------- | ----------- |
| [contracts/folder/Timelock.sol](https://github.com/code-423n4/2023-12-autonolas/blob/governace/contracts/Timelock.sol) | 7| This enforces a time delay on all
the proposal executions. | [`@openzeppelin/*`](https://openzeppelin.com/contracts/) |
| ----------- | ----------- | ----------- | ----------- |
| [contracts/folder/OLAS.sol](https://github.com/code-423n4/2023-12-autonolas/blob/governace/contracts/OLAS.sol) | 82 | ERC20 token enabling the core functionalities of the protocol | [`solmate/*`](https://github.com/transmissions11/solmate) |
| ----------- | ----------- | ----------- | ----------- |
| [contracts/folder/veOLAS.sol](https://github.com/code-423n4/2023-12-autonolas/blob/governace/contracts/veOLAS.sol) | 462 | veOLAS is a virtualized representation of the locked OLAS | [`@openzeppelin/*`](https://openzeppelin.com/contracts/)|
| ----------- | ----------- | ----------- | ----------- |
| [contracts/folder/wveOLAS.sol](https://github.com/code-423n4/2023-12-autonolas/blob/governace/contracts/wveOLAS.sol) | 140 | wveOLAS is a wrapper smart contract for view functions of veOLAS contract. This allows to fix non-intended view function behaviours in veOLAS | |
| ----------- | ----------- | ----------- | ----------- |
| [contracts/folder/GuardCM.sol](https://github.com/code-423n4/2023-12-autonolas/blob/governace/contracts/GuardCM.sol) | 321 | Smart contract for Gnosis Safe community multisig (CM) guard | [`@gnosis.pm/*`](https://github.com/safe-global/safe-contracts) |
| ----------- | ----------- | ----------- | ----------- |
| [contracts/folder/FxGovernorTunnel.sol](https://github.com/code-423n4/2023-12-autonolas/blob/governace/contracts/FxGovernorTunnel.sol) | 80 | Smart contract for the executing governance actions on Polygon dictated by cross-chain messages sends from Ethereum-based governance contracts| |
| ----------- | ----------- | ----------- | ----------- |
| [contracts/folder/HomeMediator.sol](https://github.com/code-423n4/2023-12-autonolas/blob/governace/contracts/HomeMediator.sol) | 82 | Smart contract for the executing governance actions on Gnosis chain dictated by cross-chain messages sends from Ethereum-based governance contracts| |
| ----------- | ----------- | ----------- | ----------- |
| [contracts/folder/BridgedERC20.sol](https://github.com/code-423n4/2023-12-autonolas/blob/governace/contracts/BridgedERC20.sol) | 33 | ERC20 token representation representation of token from another chain. Token can be minted and burned by the bridge mediator contract. | [`solmate/*`](https://github.com/transmissions11/solmate) |
| ----------- | ----------- | ----------- | ----------- |
| [contracts/folder/FxERC20ChildTunnel.sol](https://github.com/code-423n4/2023-12-autonolas/blob/governace/contracts/FxERC20ChildTunnel.sol) | 52 | Smart contract for the L2 token management part | [`fx-portal/*`](https://github.com/0xPolygon/fx-portal/tree/296ac8d41579f98d3a4dfb6d41737fae272a30ba) |
| ----------- | ----------- | ----------- | ----------- |
| [contracts/folder/FxERC20RootTunnel.sol](https://github.com/code-423n4/2023-12-autonolas/blob/governace/contracts/FxERC20RootTunnel.sol) | 49 | Smart contract for the L1 token management part | [`fx-portal/*`](https://github.com/0xPolygon/fx-portal/tree/296ac8d41579f98d3a4dfb6d41737fae272a30ba) |
| ----------- | ----------- | ----------- | ----------- |
| Governance interfaces (2) | | | |
| ----------- | ----------- | ----------- | ----------- |
| [contracts/folder/interfaces/IERC20.sol](https://github.com/code-423n4/2023-12-autonolas/blob/governace/contracts/interfaces/IERC20.sol) | 11 | ERC20 token interface| |
| ----------- | ----------- | ----------- | ----------- |
| [contracts/folder/interfaces/IErrors.sol](https://github.com/code-423n4/2023-12-autonolas/blob/governace/contracts/interfaces/IErrors.sol) | 19 | Errors interface | |
| ----------- | ----------- | ----------- | ----------- |
| Registries contracts (8) | | | |
| ----------- | ----------- | ----------- | ----------- |
| [registries/contracts/GenericRegistry.sol](https://github.com/code-423n4/2023-12-autonolas/blob/registries/contracts/GenericRegistry.sol) | 75 |  Smart contract for generic registry template | [`solmate/*`](https://github.com/transmissions11/solmate)   |
| ----------- | ----------- | ----------- | ----------- |
| [registries/contracts/UnitRegistry.sol](https://github.com/code-423n4/2023-12-autonolas/blob/registries/contracts/UnitRegistry.sol) |151|  Smart contract for registering units (either agent or components)| |
| ----------- | ----------- | ----------- | ----------- |
| [registries/contracts/ComponentRegistry.sol](https://github.com/code-423n4/2023-12-autonolas/blob/registries/contracts/ComponentRegistry.sol) | 26 | Smart contract for registering components | |
| ----------- | ----------- | ----------- | ----------- |
| [registries/contracts/AgentRegistry.sol](https://github.com/code-423n4/2023-12-autonolas/blob/registries/contracts/AgentRegistry.sol) | 41 | Smart contract for registering agents| |
| ----------- | ----------- | ----------- | ----------- |
| [registries/contracts/GenericManager.sol](https://github.com/code-423n4/2023-12-autonolas/blob/registries/contracts/GenericManager.sol) | 33 | Smart contract for generic registry manager template | |
| ----------- | ----------- | ----------- | ----------- |
| [registries/contracts/RegistriesManager.sol](https://github.com/code-423n4/2023-12-autonolas/blob/registries/contracts/RegistriesManager.sol) | 35 | Periphery smart contract for managing components and agents | |
| ----------- | ----------- | ----------- | ----------- |
| [registries/contracts/multisigs/GnosisSafeMultisig.sol](https://github.com/code-423n4/2023-12-autonolas/blob/registries/contracts/multisigs/GnosisSafeMultisig.sol) | 63 | Smart contract for Gnosis Safe multisig implementation of a generic multisig interface | [`@gnosis.pm/*`](https://github.com/safe-global/safe-contracts) |
| ----------- | ----------- | ----------- | ----------- |
| [registries/contracts/multisigs/GnosisSafeSameAddressMultisig.sol](https://github.com/code-423n4/2023-12-autonolas/blob/registries/contracts/multisigs/GnosisSafeSameAddressMultisig.sol)) | 66 | Smart contract for Gnosis Safe verification of an already existent multisig address | [`@gnosis.pm/*`](https://github.com/safe-global/safe-contracts) |
| ----------- | ----------- | ----------- | ----------- |
| Registries interfaces (2) | | | |
| ----------- | ----------- | ----------- | ----------- |
| [registries/contracts/interfaces/IErrorsRegistries.sol](https://github.com/code-423n4/2023-12-autonolas/blob/registries/contracts/interfaces/IErrorsRegistries.sol)) | 28 | Errors interface| |
| ----------- | ----------- | ----------- | ----------- |
| [registries/contracts/interfaces/IRegistry.sol](https://github.com/code-423n4/2023-12-autonolas/blob/registries/contracts/interfaces/IRegistry.sol) | 17 | Interface for the component / agent manipulation | |
| ----------- | ----------- | ----------- | ----------- |
| Tokenomics contracts (8) | | | |
| ----------- | ----------- | ----------- | ----------- |
| [tokenomics/contracts/Depository.sol](https://github.com/code-423n4/2023-12-autonolas/blob/tokenomics/contracts/Depository.sol) | 254 |  Smart contract handling the logic for creation and closure of bonding programs, and the deposits and reedems bonds |  |
| ----------- | ----------- | ----------- | ----------- |
| [tokenomics/contracts/Dispenser.sol](https://github.com/code-423n4/2023-12-autonolas/blob/tokenomics/contracts/Dispenser.sol) | 65 | Smart contract for distributing code incentives | |
| ----------- | ----------- | ----------- | ----------- |
| [tokenomics/contracts/DonatorBlacklist.sol](https://github.com/code-423n4/2023-12-autonolas/blob/tokenomics/contracts/DonatorBlacklist.sol) | 42 | Smart contract for blacklisting donors | |
| ----------- | ----------- | ----------- | ----------- |
| [tokenomics/contracts/GenericBondCalculator.sol](https://github.com/code-423n4/2023-12-autonolas/blob/tokenomics/contracts/GenericBondCalculator.sol) | 44 |  Smart contract for calculation of OLAS payouts for bond |  [`@prb-math/*`]](https://github.com/PaulRBerg/prb-math) |
| ----------- | ----------- | ----------- | ----------- |
| [tokenomics/contracts/Tokenomics.sol](https://github.com/code-423n4/2023-12-autonolas/blob/tokenomics/contracts/Tokenomics.sol) | 646 |  Smart contract implementing the tokenomics model for code incentives and discount factor bonding mechanism regulations | |
| ----------- | ----------- | ----------- | ----------- |
| [tokenomics/contracts/TokenomicsConstants.sol](https://github.com/code-423n4/2023-12-autonolas/blob/tokenomics/contracts/TokenomicsConstants.sol) | 59 |  Smart contract with tokenomics constants for annual inflation supplies| [`@prb-math/*`]](https://github.com/PaulRBerg/prb-math)|
| ----------- | ----------- | ----------- | ----------- |
| [tokenomics/contracts/TokenomicsProxy.sol](https://github.com/code-423n4/2023-12-autonolas/blob/tokenomics/contracts/TokenomicsProxy.sol) | 34 | Smart contract for tokenomics proxy. Proxy implementation is created based on the Universal Upgradeable Proxy Standard (UUPS) EIP-1822 | |
| ----------- | ----------- | ----------- | ----------- |
| [tokenomics/contracts/Treasury.sol](https://github.com/code-423n4/2023-12-autonolas/tokenomics/Treasury.sol]) | 289 | Smart contract for managing Olas Treasury| |
| ----------- | ----------- | ----------- | ----------- |
| Tokenomics interfaces (10) | | | |
| ----------- | ----------- | ----------- | ----------- |
| [tokenomics/contracts/interfaces/IDonatorBlacklist.sol](https://github.com/code-423n4/2023-12-autonolas/blob/tokenomics/contracts/interfaces/IDonatorBlacklist.sol]) | 4 |  DonatorBlacklist interface | |
| ----------- | ----------- | ----------- | ----------- |
| [tokenomics/contracts/interfaces/IErrorsTokenomics.sol](https://github.com/code-423n4/2023-12-autonolas/blob/tokenomics/contracts/interfaces/IErrorsTokenomics.sol) | 31 | Errors interface| |
| ----------- | ----------- | ----------- | ----------- |
| [contracts/folder/interfaces/IGenericBondCalculator.sol](https://github.com/code-423n4/2023-12-autonolas/blob/tokenomics/contracts/interfaces/IGenericBondCalculator.sol) | 6 | Interface for generic bond calculator | |
| ----------- | ----------- | ----------- | ----------- |
| [tokenomics/contracts/interfaces/IOLAS.sol](https://github.com/code-423n4/2023-12-autonolas/tokenomics/blob/contracts/interfaces/IOLAS.sol) | 5 | Interface for OLAS token | |
| ----------- | ----------- | ----------- | ----------- |
| [tokenomics/contracts/interfaces/IServiceRegistry.sol](https://github.com/code-423n4/2023-12-autonolas/blob/tokenomics/contracts/interfaces/IServiceRegistry.sol) | 12 | Interface for for the service registry calls | |
| ----------- | ----------- | ----------- | ----------- |
| [tokenomics/contracts/interfaces/IToken.sol](https://github.com/code-423n4/2023-12-autonolas/blob/tokenomics/contracts/interfaces/IToken.sol) | 10 | Generic token interface for IERC20 and IERC721 tokens | |
| ----------- | ----------- | ----------- | ----------- |
| [tokenomics/contracts/interfaces/ITokenomics.sol](https://github.com/code-423n4/2023-12-autonolas/blob/tokenomics/contracts/interfaces/ITokenomics.sol) | 17 | Interface for tokenomics management ||
| ----------- | ----------- | ----------- | ----------- |
| [tokenomics/contracts/interfaces/ITreasury.sol](https://github.com/code-423n4/2023-12-autonolas/blob/tokenomics/contracts/interfaces/ITreasury.sol) | 8 | Interface for trasury management | |
| ----------- | ----------- | ----------- | ----------- |
| [tokenomics/contracts/interfaces/IUniswapV2Pair.sol](https://github.com/code-423n4/2023-12-autonolas/blob/tokenomics/contracts/interfaces/IUniswapV2Pair.sol) | 7 | Uniswap v2 related interface | |
| ----------- | ----------- | ----------- | ----------- |
| [tokenomics/contracts/interfaces/IVotingEscrow.sol](https://github.com/code-423n4/2023-12-autonolas/blob/tokenomics/contracts/interfaces/IVotingEscrow.sol) | 4 | Interface for veOLAS (voting escrow) | |
| Lockbox Solana contracts (1) | | | |
| ----------- | ----------- | ----------- | ----------- |
| [lockbox-solana/solidity/liquidity_lockbox.sol](https://github.com/code-423n4/2023-12-autonolas/blob/lockbox-solana/solidity/liquidity_lockbox.sol) | 260 | Smart contract for encapsulating concentrated liquidity from Orca whirlpool contract and represent the full range liquidity with fungible tokens | whirlpool (ADDLINK) |
| ----------- | ----------- | ----------- | ----------- |
| Lockbox Solana library (1) | | | |
| ----------- | ----------- | ----------- | ----------- |
| [lockbox-solana/solidity/library/spl_token.sol](https://github.com/code-423n4/2023-12-autonolas/blob/lockbox-solana/solidity/library/spl_token.sol) | 77 | This library provides a way for Solidity to interact with Solana's SPL-Token | solana  (ADDLINK) , [`SplToken`]() (ADDLINK)|


## Out of scope

| File | SLOC | Purpose | Libraries used |  
| ----------- | ----------- | ----------- | ----------- |
| Governance contracts (11) | | | |
| [governance/contracts/test/BridgeSetup.sol](https://github.com/code-423n4/2023-12-autonolas/blob/governance/contracts/test/BridgeSetup.sol) |  | | |
| ----------- | ----------- | ----------- | ----------- |
| [governance/contracts/test/BrokenERC20.sol](https://github.com/code-423n4/2023-12-autonolas/blob/governance/contracts/test/BrokenERC20.sol) |  | | |
| ----------- | ----------- | ----------- | ----------- |
| [governance/contracts/test/SafeSetup.sol](https://github.com/code-423n4/2023-12-autonolas/blob/governance/contracts/test/SafeSetup.sol) |  | | |
| ----------- | ----------- | ----------- | ----------- |
| [governance/contracts/multisigs/test/MockTimelockCM.sol](https://github.com/code-423n4/2023-12-autonolas/blob/governance/contracts/multisigs/test/MockTimelockCM.sol) |  | | |
| ----------- | ----------- | ----------- | ----------- |
| [governance/contracts/multisigs/test/MockTreasury.sol](https://github.com/code-423n4/2023-12-autonolas/blob/governance/contracts/multisigs/test/MockTreasury.sol) |  | | |
| ----------- | ----------- | ----------- | ----------- |
| [governance/contracts/bridges/test/ChildMockERC20.sol](https://github.com/code-423n4/2023-12-autonolas/blob/governance/contracts/brides/test/ChildMockERC20.sol) |  | | |
| ----------- | ----------- | ----------- | ----------- |
| [governance/contracts/bridges/test/FxChildTunnel.sol](https://github.com/code-423n4/2023-12-autonolas/blob/governance/contracts/brides/test/FxChildTunnel.sol) |  | | |
| ----------- | ----------- | ----------- | ----------- |
| [governance/contracts/bridges/test/FxRootMock.sol](https://github.com/code-423n4/2023-12-autonolas/blob/governance/contracts/brides/test/FxRootMock.sol) |  | | |
| ----------- | ----------- | ----------- | ----------- |
| [governance/contracts/bridges/test/HomeMediatorTest.sol](https://github.com/code-423n4/2023-12-autonolas/blob/governance/contracts/brides/test/HomeMediatorTest.sol) |  | | |
| ----------- | ----------- | ----------- | ----------- |
| [governance/contracts/bridges/test/MockAMBMediator.sol](https://github.com/code-423n4/2023-12-autonolas/blob/governance/contracts/brides/test/MockAMBMediator.sol) |  | | |
| ----------- | ----------- | ----------- | ----------- |
| [governance/contracts/bridges/test/MockTimelock.sol](https://github.com/code-423n4/2023-12-autonolas/blob/governance/contracts/brides/test/MockTimelock.sol) |  | | |
| ----------- | ----------- | ----------- | ----------- |
| Registries contracts (3) | | | |
| [registries/contracts/test/ComponentRegistryTest.sol](https://github.com/code-423n4/2023-12-autonolas/blob/registries/contracts/test/ComponentRegistryTest.sol]) |  | | |
| ----------- | ----------- | ----------- | ----------- |
| [registries/contracts/test/GnosisSafeABICreator.sol](https://github.com/code-423n4/2023-12-autonolas/blob/registries/contracts/test/GnosisSafeABICreator.sol) |  | | |
| ----------- | ----------- | ----------- | ----------- |
| [registries/contracts/test/ReentrancyAttacker.sol](https://github.com/code-423n4/2023-12-autonolas/blob/registries/contracts/test/ReentrancyAttacker.sol) |  | | |
| ----------- | ----------- | ----------- | ----------- |
| Tokenomics contracts (10) | | | |
| [tokenomics/contracts/test/DepositAttacker.sol](https://github.com/code-423n4/2023-12-autonolas/blob/tokenomics/contracts/test/DepositAttacker.sol) |  | | |
| ----------- | ----------- | ----------- | ----------- |
| [tokenomics/contracts/test/ERC20Token.sol](https://github.com/code-423n4/2023-12-autonolas/blob/tokenomics/contracts/test/ERC20Token.sol) |  | | |
| ----------- | ----------- | ----------- | ----------- |
| [tokenomics/contracts/test/MockRegistry.sol](https://github.com/code-423n4/2023-12-autonolas/blob/tokenomics/contracts/test/MockRegistry.sol) |  | | |
| ----------- | ----------- | ----------- | ----------- |
| [tokenomics/contracts/test/MockTokenomics.sol](https://github.com/code-423n4/2023-12-autonolas/blob/tokenomics/contracts/test/MockTokenomics.sol) |  | | |
| ----------- | ----------- | ----------- | ----------- |
| [tokenomics/contracts/test/MockVE.sol](https://github.com/code-423n4/2023-12-autonolas/tokenomics/blob/contracts/test/MockVE.sol) |  | | |
| ----------- | ----------- | ----------- | ----------- |
| [tokenomics/contracts/test/ReentrancyAttacker.sol](https://github.com/code-423n4/2023-12-autonolas/blob/tokenomics/contracts/test/ReentrancyAttacker.sol) |  | | |
| ----------- | ----------- | ----------- | ----------- |
| [tokenomics/contracts/test/TestTokenomics.sol](https://github.com/code-423n4/2023-12-autonolas/blob/tokenomics/contracts/test/TestTokenomics.sol) |  | | |
| ----------- | ----------- | ----------- | ----------- |
| [tokenomics/contracts/test/UniswapFactory.sol](https://github.com/code-423n4/2023-12-autonolas/blob/tokenomics/contracts/test/UniswapFactory.sol) |  | | |
| ----------- | ----------- | ----------- | ----------- |
| [tokenomics/contracts/test/UniswapRouter.sol](https://github.com/code-423n4/2023-12-autonolas/blob/tokenomics/contracts/test/UniswapRouter.sol) |  | | |
| ----------- | ----------- | ----------- | ----------- |
| [tokenomics/contracts/test/Zuniswapv2.sol](https://github.com/code-423n4/2023-12-autonolas/blob/tokenomics/contracts/test/Zuniswapv2.sol) |  | | |
| ----------- | ----------- | ----------- | ----------- |
| Lockbox Solana (1) | | | |
| ----------- | ----------- | ----------- | ----------- |
| [lockbox-solana/solidity/test_position.sol](https://github.com/code-423n4/2023-12-autonolas/blob/lockbox-solana/solidity/test_position.sol) |  | | |
| ----------- | ----------- | ----------- | ----------- |


# External imports

- @prb/math/src/Common.sol 

# Additional Context

- [ ] Describe any novel or unique curve logic or mathematical models implemented in the contracts
- [ ] Please list specific ERC20 that your protocol is anticipated to interact with. Could be "any" (literally anything, fee on transfer tokens, ERC777 tokens and so forth) or a list of tokens you envision using on launch.
- [ ] Please list specific ERC721 that your protocol is anticipated to interact with.
- [ ] Which blockchains will this code be deployed to, and are considered in scope for this audit?
- [ ] Please list all trusted roles (e.g. operators, slashers, pausers, etc.), the privileges they hold, and any conditions under which privilege escalation is expected/allowable
- [ ] In the event of a DOS, could you outline a minimum duration after which you would consider a finding to be valid? This question is asked in the context of most systems' capacity to handle DoS attacks gracefully for a certain period.
- [ ] Is any part of your implementation intended to conform to any EIP's? If yes, please list the contracts in this format: 
  - `Contract1`: Should comply with `ERC/EIPX`
  - `Contract2`: Should comply with `ERC/EIPY`

## Attack ideas (Where to look for bugs)
*List specific areas to address - see [this blog post](https://medium.com/code4rena/the-security-council-elections-within-the-arbitrum-dao-a-comprehensive-guide-aa6d001aae60#9adb) for an example*

## Main invariants
*Describe the project's main invariants (properties that should NEVER EVER be broken).*

## Scoping Details 
[ ⭐️ SPONSORS: please confirm/edit the information below. ]

```
- If you have a public code repo, please share it here:  
- How many contracts are in scope?:   
- Total SLoC for these contracts?:  
- How many external imports are there?:  
- How many separate interfaces and struct definitions are there for the contracts within scope?:  
- Does most of your code generally use composition or inheritance?:   
- How many external calls?:   
- What is the overall line coverage percentage provided by your tests?:
- Is this an upgrade of an existing system?:
- Check all that apply (e.g. timelock, NFT, AMM, ERC20, rollups, etc.): 
- Is there a need to understand a separate part of the codebase / get context in order to audit this part of the protocol?:   
- Please describe required context:   
- Does it use an oracle?:  
- Describe any novel or unique curve logic or mathematical models your code uses: 
- Is this either a fork of or an alternate implementation of another project?:   
- Does it use a side-chain?:
- Describe any specific areas you would like addressed:
```

# Tests

## Governance
cd into sub repo:
```
cd governance
```

Install the project:
```
yarn install
```

Compile the code:
```
npx hardhat compile
```

Run tests with gas report:
```
npx hardhat test
```

All the tests come with the gas

Audit findings are located [here](https://github.com/code-423n4/2023-12-autonolas/blob/main/governance/audits).

The list of known vulnerabilities can be found [here](https://github.com/code-423n4/2023-12-autonolas/blob/main/governance/docs/Vulnerabilities_list_governance.pdf?raw=true).

## Registries
cd into sub repo:
```
cd registries
```

Install the project:
```
yarn install
```

Compile the code:
```
npx hardhat compile
```

Run tests with gas report:
```
npx hardhat test
```

Audit findings are located [here](https://github.com/code-423n4/2023-12-autonolas/blob/main/registries/audits).

The list of known vulnerabilities can be found [here](https://github.com/code-423n4/2023-12-autonolas/blob/main/registries/docs/Vulnerabilities_list_registries.pdf?raw=true).

## Tokenomics
cd into sub repo:
```
cd tokenomics
```

Install the project:
```
yarn install
```

Install [Foundry](https://book.getfoundry.sh/getting-started/installation) in order to test contracts with it along with Hardhat tests.

Compile the code:
```
npm run compile
```

Run tests with Hardhat and gas report:
```
npx hardhat test
```

Run tests with Foundry:
```
forge test --hh -vv
```

Audit findings are located [here](https://github.com/code-423n4/2023-12-autonolas/blob/main/tokenomics/audits).

The list of known vulnerabilities can be found [here](https://github.com/code-423n4/2023-12-autonolas/blob/main/tokenomics/docs/Vulnerabilities_list_tokenomics.pdf?raw=true).

## Lockbox-Solana
cd into sub repo:
```
cd lockbox-solana
```

Install rust:
```
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

Install solana:
```
sh -c "$(curl -sSfL https://release.solana.com/v1.17.7/install)"
```

Install anchor:
```
cargo install --git https://github.com/coral-xyz/anchor avm --locked --force
avm install 0.29.0
avm use 0.29.0
```

Install the project:
```
yarn install
```

Build the code with:
```
anchor build
```

Run the validator in a separate window:
```
./validator.sh
```

Execute the testing script:
```
solana airdrop 10000 9fit3w7t6FHATDaZWotpWqN7NpqgL3Lm1hqUop4hAy8h --url localhost && anchor test --skip-local-validator --skip-build
```

Audit findings are located [here](https://github.com/code-423n4/2023-12-autonolas/blob/main/lockbox-solana/audits).

The list of known vulnerabilities can be found [here](https://github.com/code-423n4/2023-12-autonolas/blob/main/lockbox-solana/docs/Vulnerabilities_list_tokenomics-solana.pdf?raw=true).

:warning: **Warning** <br />
The current version of the code fails when doing a CPI call to the Orca Whirlpool program in the `withdraw()` function.
The issue is described here: [CPI issue](https://github.com/hyperledger/solang/issues/1610).
For the moment, the `withdraw()` function testing is wrapped into a `try-catch` logic.


