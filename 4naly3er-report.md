# Report


## Gas Optimizations


| |Issue|Instances|
|-|:-|:-:|
| [GAS-1](#GAS-1) | Using bools for storage incurs overhead | 5 |
| [GAS-2](#GAS-2) | Cache array length outside of loop | 8 |
| [GAS-3](#GAS-3) | Use calldata instead of memory for function arguments that do not get mutated | 17 |
| [GAS-4](#GAS-4) | For Operations that will not overflow, you could use unchecked | 562 |
| [GAS-5](#GAS-5) | Use Custom Errors | 18 |
| [GAS-6](#GAS-6) | Don't initialize variables with default value | 45 |
| [GAS-7](#GAS-7) | `++i` costs less gas than `i++`, especially when it's used in `for`-loops (`--i`/`i--` too) | 8 |
| [GAS-8](#GAS-8) | Using `private` rather than `public` for constants, saves gas | 27 |
| [GAS-9](#GAS-9) | Use shift Right/Left instead of division/multiplication if possible | 1 |
| [GAS-10](#GAS-10) | Use != 0 instead of > 0 for unsigned integer comparison | 47 |
### <a name="GAS-1"></a>[GAS-1] Using bools for storage incurs overhead
Use uint256(1) and uint256(2) for true/false to avoid a Gwarmaccess (100 gas), and to avoid Gsset (20000 gas) when changing from ‘false’ to ‘true’, after having been ‘true’ in the past. See [source](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/58f635312aa21f947cae5f8578638a85aa2519f5/contracts/security/ReentrancyGuard.sol#L23-L27).

*Instances (5)*:
```solidity
File: registries/contracts/GenericManager.sol

16:     bool public paused;

```

```solidity
File: tokenomics/contracts/DonatorBlacklist.sol

27:     mapping(address => bool) public mapBlacklistedDonators;

```

```solidity
File: tokenomics/contracts/Tokenomics.sol

225:     mapping(uint256 => mapping(uint256 => bool)) public mapNewUnits;

227:     mapping(address => bool) public mapNewOwners;

```

```solidity
File: tokenomics/contracts/Treasury.sol

88:     mapping(address => bool) public mapEnabledTokens;

```

### <a name="GAS-2"></a>[GAS-2] Cache array length outside of loop
If not cached, the solidity compiler will always read the length of the array during each iteration. That is, if it is a storage array, this is an extra sload operation (100 additional extra gas for each iteration except for the first) and if it is a memory array, this is an extra mload operation (3 additional gas for each iteration except for the first).

*Instances (8)*:
```solidity
File: registries/contracts/AgentRegistry.sol

40:         for (uint256 iDep = 0; iDep < dependencies.length; ++iDep) {

```

```solidity
File: registries/contracts/ComponentRegistry.sol

29:         for (uint256 iDep = 0; iDep < dependencies.length; ++iDep) {

```

```solidity
File: tokenomics/contracts/Depository.sol

357:         for (uint256 i = 0; i < bondIds.length; ++i) {

```

```solidity
File: tokenomics/contracts/DonatorBlacklist.sol

67:         for (uint256 i = 0; i < accounts.length; ++i) {

```

```solidity
File: tokenomics/contracts/Tokenomics.sol

1110:         for (uint256 i = 0; i < unitIds.length; ++i) {

1132:         for (uint256 i = 0; i < unitIds.length; ++i) {

1180:         for (uint256 i = 0; i < unitIds.length; ++i) {

1202:         for (uint256 i = 0; i < unitIds.length; ++i) {

```

### <a name="GAS-3"></a>[GAS-3] Use calldata instead of memory for function arguments that do not get mutated
Mark data types as `calldata` instead of `memory` where possible. This makes it so that the data is not automatically loaded into memory. If the data passed into the function does not need to be changed (like updating values in an array), it can be passed in as `calldata`. The one exception to this is if the argument must later be passed into another function that takes an argument that specifies `memory` storage.

*Instances (17)*:
```solidity
File: governance/contracts/veOLAS.sol

138:     constructor(address _token, string memory _name, string memory _symbol) {

138:     constructor(address _token, string memory _name, string memory _symbol) {

```

```solidity
File: registries/contracts/AgentRegistry.sol

20:     constructor(string memory _name, string memory _symbol, string memory _baseURI, address _componentRegistry)

20:     constructor(string memory _name, string memory _symbol, string memory _baseURI, address _componentRegistry)

20:     constructor(string memory _name, string memory _symbol, string memory _baseURI, address _componentRegistry)

70:     function calculateSubComponents(uint32[] memory unitIds) external view returns (uint32[] memory subComponentIds)

```

```solidity
File: registries/contracts/ComponentRegistry.sol

16:     constructor(string memory _name, string memory _symbol, string memory _baseURI)

16:     constructor(string memory _name, string memory _symbol, string memory _baseURI)

16:     constructor(string memory _name, string memory _symbol, string memory _baseURI)

```

```solidity
File: registries/contracts/GenericRegistry.sol

78:     function setBaseURI(string memory bURI) external virtual {

```

```solidity
File: registries/contracts/RegistriesManager.sol

31:         uint32[] memory dependencies

```

```solidity
File: registries/contracts/UnitRegistry.sol

49:     function create(address unitOwner, bytes32 unitHash, uint32[] memory dependencies)

```

```solidity
File: registries/contracts/interfaces/IRegistry.sol

19:         uint32[] memory dependencies

38:     function calculateSubComponents(uint32[] memory unitIds) external view returns (uint32[] memory subComponentIds);

```

```solidity
File: registries/contracts/multisigs/GnosisSafeMultisig.sol

12:         bytes memory initializer,

92:         address[] memory owners,

94:         bytes memory data

```

### <a name="GAS-4"></a>[GAS-4] For Operations that will not overflow, you could use unchecked

*Instances (562)*:
```solidity
File: governance/contracts/OLAS.sol

22:     uint256 public constant oneYear = 1 days * 365;

101:         uint256 numYears = (block.timestamp - timeLaunch) / oneYear;

101:         uint256 numYears = (block.timestamp - timeLaunch) / oneYear;

107:             numYears -= 9;

108:             for (uint256 i = 0; i < numYears; ++i) {

108:             for (uint256 i = 0; i < numYears; ++i) {

109:                 supplyCap += (supplyCap * maxMintCapFraction) / 100;

109:                 supplyCap += (supplyCap * maxMintCapFraction) / 100;

109:                 supplyCap += (supplyCap * maxMintCapFraction) / 100;

113:         remainder = supplyCap - _totalSupply;

135:             spenderAllowance -= amount;

154:         spenderAllowance += amount;

```

```solidity
File: governance/contracts/bridges/BridgedERC20.sol

4: import {ERC20} from "../../lib/solmate/src/tokens/ERC20.sol";

4: import {ERC20} from "../../lib/solmate/src/tokens/ERC20.sol";

4: import {ERC20} from "../../lib/solmate/src/tokens/ERC20.sol";

4: import {ERC20} from "../../lib/solmate/src/tokens/ERC20.sol";

4: import {ERC20} from "../../lib/solmate/src/tokens/ERC20.sol";

4: import {ERC20} from "../../lib/solmate/src/tokens/ERC20.sol";

```

```solidity
File: governance/contracts/bridges/FxERC20ChildTunnel.sol

4: import {FxBaseChildTunnel} from "../../lib/fx-portal/contracts/tunnel/FxBaseChildTunnel.sol";

4: import {FxBaseChildTunnel} from "../../lib/fx-portal/contracts/tunnel/FxBaseChildTunnel.sol";

4: import {FxBaseChildTunnel} from "../../lib/fx-portal/contracts/tunnel/FxBaseChildTunnel.sol";

4: import {FxBaseChildTunnel} from "../../lib/fx-portal/contracts/tunnel/FxBaseChildTunnel.sol";

4: import {FxBaseChildTunnel} from "../../lib/fx-portal/contracts/tunnel/FxBaseChildTunnel.sol";

4: import {FxBaseChildTunnel} from "../../lib/fx-portal/contracts/tunnel/FxBaseChildTunnel.sol";

4: import {FxBaseChildTunnel} from "../../lib/fx-portal/contracts/tunnel/FxBaseChildTunnel.sol";

5: import {IERC20} from "../interfaces/IERC20.sol";

5: import {IERC20} from "../interfaces/IERC20.sol";

71:         uint256 /* stateId */,

71:         uint256 /* stateId */,

71:         uint256 /* stateId */,

71:         uint256 /* stateId */,

```

```solidity
File: governance/contracts/bridges/FxERC20RootTunnel.sol

4: import {FxBaseRootTunnel} from "../../lib/fx-portal/contracts/tunnel/FxBaseRootTunnel.sol";

4: import {FxBaseRootTunnel} from "../../lib/fx-portal/contracts/tunnel/FxBaseRootTunnel.sol";

4: import {FxBaseRootTunnel} from "../../lib/fx-portal/contracts/tunnel/FxBaseRootTunnel.sol";

4: import {FxBaseRootTunnel} from "../../lib/fx-portal/contracts/tunnel/FxBaseRootTunnel.sol";

4: import {FxBaseRootTunnel} from "../../lib/fx-portal/contracts/tunnel/FxBaseRootTunnel.sol";

4: import {FxBaseRootTunnel} from "../../lib/fx-portal/contracts/tunnel/FxBaseRootTunnel.sol";

4: import {FxBaseRootTunnel} from "../../lib/fx-portal/contracts/tunnel/FxBaseRootTunnel.sol";

5: import {IERC20} from "../interfaces/IERC20.sol";

5: import {IERC20} from "../interfaces/IERC20.sol";

```

```solidity
File: governance/contracts/bridges/HomeMediator.sol

153:             for (uint256 j = 0; j < payloadLength; ++j) {

153:             for (uint256 j = 0; j < payloadLength; ++j) {

154:                 payload[j] = data[i + j];

157:             i += payloadLength;

```

```solidity
File: governance/contracts/veOLAS.sol

12: Voting escrow has time-weighted votes derived from the amount of tokens locked. The maximum voting power can be

14: # w ^ = amount * time_locked / MAXTIME

14: # w ^ = amount * time_locked / MAXTIME

15: # 1 +        /

15: # 1 +        /

16: #   |      /

17: #   |    /

18: #   |  /

19: #   |/

20: # 0 +--------+------> time

20: # 0 +--------+------> time

20: # 0 +--------+------> time

20: # 0 +--------+------> time

20: # 0 +--------+------> time

20: # 0 +--------+------> time

20: # 0 +--------+------> time

20: # 0 +--------+------> time

20: # 0 +--------+------> time

20: # 0 +--------+------> time

20: # 0 +--------+------> time

20: # 0 +--------+------> time

20: # 0 +--------+------> time

20: # 0 +--------+------> time

20: # 0 +--------+------> time

20: # 0 +--------+------> time

24: because Ethereum changes its block times. What we can do is to extrapolate ***At functions.

24: because Ethereum changes its block times. What we can do is to extrapolate ***At functions.

24: because Ethereum changes its block times. What we can do is to extrapolate ***At functions.

107:     uint256 internal constant MAXTIME = 4 * 365 * 86400;

107:     uint256 internal constant MAXTIME = 4 * 365 * 86400;

109:     int128 internal constant IMAXTIME = 4 * 365 * 86400;

109:     int128 internal constant IMAXTIME = 4 * 365 * 86400;

161:             pv = mapUserPoints[account][lastPointNumber - 1];

207:                 uOld.slope = int128(oldLocked.amount) / IMAXTIME;

209:                     uOld.slope *

211:                         uint128(oldLocked.endTime - uint64(block.timestamp))

215:                 uNew.slope = int128(newLocked.amount) / IMAXTIME;

217:                     uNew.slope *

219:                         uint128(newLocked.endTime - uint64(block.timestamp))

253:         uint256 block_slope; // dblock/dt

253:         uint256 block_slope; // dblock/dt

253:         uint256 block_slope; // dblock/dt

258:                 (1e18 * uint256(block.number - lastPoint.blockNumber)) /

258:                 (1e18 * uint256(block.number - lastPoint.blockNumber)) /

258:                 (1e18 * uint256(block.number - lastPoint.blockNumber)) /

259:                 uint256(block.timestamp - lastPoint.ts);

265:             uint64 tStep = (lastCheckpoint / WEEK) * WEEK;

265:             uint64 tStep = (lastCheckpoint / WEEK) * WEEK;

266:             for (uint256 i = 0; i < 255; ++i) {

266:             for (uint256 i = 0; i < 255; ++i) {

271:                     tStep += WEEK;

279:                 lastPoint.bias -=

280:                     lastPoint.slope *

281:                     int128(int64(tStep - lastCheckpoint));

282:                 lastPoint.slope += dSlope;

295:                     initialPoint.blockNumber +

297:                         (block_slope * uint256(tStep - initialPoint.ts)) / 1e18

297:                         (block_slope * uint256(tStep - initialPoint.ts)) / 1e18

297:                         (block_slope * uint256(tStep - initialPoint.ts)) / 1e18

303:                     curNumPoint += 1;

320:             lastPoint.slope += (uNew.slope - uOld.slope);

320:             lastPoint.slope += (uNew.slope - uOld.slope);

321:             lastPoint.bias += (uNew.bias - uOld.bias);

321:             lastPoint.bias += (uNew.bias - uOld.bias);

339:                 oldDSlope += uOld.slope;

341:                     oldDSlope -= uNew.slope; // It was a new deposit, not extension

341:                     oldDSlope -= uNew.slope; // It was a new deposit, not extension

341:                     oldDSlope -= uNew.slope; // It was a new deposit, not extension

350:                 newDSlope -= uNew.slope; // old slope disappeared at this point

350:                 newDSlope -= uNew.slope; // old slope disappeared at this point

350:                 newDSlope -= uNew.slope; // old slope disappeared at this point

389:             supplyAfter = supplyBefore + amount;

401:             lockedBalance.amount += uint128(amount);

444:         if (lockedBalance.endTime < (block.timestamp + 1)) {

508:             unlockTime = ((block.timestamp + unlockTime) / WEEK) * WEEK;

508:             unlockTime = ((block.timestamp + unlockTime) / WEEK) * WEEK;

508:             unlockTime = ((block.timestamp + unlockTime) / WEEK) * WEEK;

516:         if (unlockTime < (block.timestamp + 1)) {

520:         if (unlockTime > block.timestamp + MAXTIME) {

523:                 block.timestamp + MAXTIME,

554:         if (lockedBalance.endTime < (block.timestamp + 1)) {

582:             unlockTime = ((block.timestamp + unlockTime) / WEEK) * WEEK;

582:             unlockTime = ((block.timestamp + unlockTime) / WEEK) * WEEK;

582:             unlockTime = ((block.timestamp + unlockTime) / WEEK) * WEEK;

589:         if (lockedBalance.endTime < (block.timestamp + 1)) {

597:         if (unlockTime < (lockedBalance.endTime + 1)) {

605:         if (unlockTime > block.timestamp + MAXTIME) {

608:                 block.timestamp + MAXTIME,

639:             supplyAfter = supplyBefore - amount;

679:                 maxPointNumber -= 1;

684:         for (uint256 i = 0; i < 128; ++i) {

684:         for (uint256 i = 0; i < 128; ++i) {

685:             if ((minPointNumber + 1) > maxPointNumber) {

688:             uint256 mid = (minPointNumber + maxPointNumber + 1) / 2;

688:             uint256 mid = (minPointNumber + maxPointNumber + 1) / 2;

688:             uint256 mid = (minPointNumber + maxPointNumber + 1) / 2;

697:             if (point.blockNumber < (blockNumber + 1)) {

700:                 maxPointNumber = mid - 1;

722:             PointVoting memory uPoint = mapUserPoints[account][pointNumber - 1];

723:             uPoint.bias -= uPoint.slope * int128(int64(ts) - int64(uPoint.ts));

723:             uPoint.bias -= uPoint.slope * int128(int64(ts) - int64(uPoint.ts));

723:             uPoint.bias -= uPoint.slope * int128(int64(ts) - int64(uPoint.ts));

759:         if (uPoint.blockNumber < (blockNumber + 1)) {

790:             PointVoting memory pointNext = mapSupplyPoints[minPointNumber + 1];

791:             dBlock = pointNext.blockNumber - point.blockNumber;

792:             dt = pointNext.ts - point.ts;

794:             dBlock = block.number - point.blockNumber;

795:             dt = block.timestamp - point.ts;

799:             blockTime += (dt * (blockNumber - point.blockNumber)) / dBlock;

799:             blockTime += (dt * (blockNumber - point.blockNumber)) / dBlock;

799:             blockTime += (dt * (blockNumber - point.blockNumber)) / dBlock;

799:             blockTime += (dt * (blockNumber - point.blockNumber)) / dBlock;

818:         uPoint.bias -=

819:             uPoint.slope *

820:             int128(int64(uint64(blockTime)) - int64(uPoint.ts));

835:         uint64 tStep = (lastPoint.ts / WEEK) * WEEK;

835:         uint64 tStep = (lastPoint.ts / WEEK) * WEEK;

836:         for (uint256 i = 0; i < 255; ++i) {

836:         for (uint256 i = 0; i < 255; ++i) {

839:                 tStep += WEEK;

847:             lastPoint.bias -=

848:                 lastPoint.slope *

849:                 int128(int64(tStep) - int64(lastPoint.ts));

853:             lastPoint.slope += dSlope;

880:         if (sPoint.blockNumber < (blockNumber + 1)) {

```

```solidity
File: lockbox-solana/solidity/library/spl_token.sol

11: 		InitializeMint, // 0

11: 		InitializeMint, // 0

12: 		InitializeAccount, // 1

12: 		InitializeAccount, // 1

13: 		InitializeMultisig, // 2

13: 		InitializeMultisig, // 2

14: 		Transfer, // 3

14: 		Transfer, // 3

15: 		Approve, // 4

15: 		Approve, // 4

16: 		Revoke, // 5

16: 		Revoke, // 5

17: 		SetAuthority, // 6

17: 		SetAuthority, // 6

18: 		MintTo, // 7

18: 		MintTo, // 7

19: 		Burn, // 8

19: 		Burn, // 8

20: 		CloseAccount, // 9

20: 		CloseAccount, // 9

21: 		FreezeAccount, // 10

21: 		FreezeAccount, // 10

22: 		ThawAccount, // 11

22: 		ThawAccount, // 11

23: 		TransferChecked, // 12

23: 		TransferChecked, // 12

24: 		ApproveChecked, // 13

24: 		ApproveChecked, // 13

25: 		MintToChecked, // 14

25: 		MintToChecked, // 14

26: 		BurnChecked, // 15

26: 		BurnChecked, // 15

27: 		InitializeAccount2, // 16

27: 		InitializeAccount2, // 16

28: 		SyncNative, // 17

28: 		SyncNative, // 17

29: 		InitializeAccount3, // 18

29: 		InitializeAccount3, // 18

30: 		InitializeMultisig2, // 19

30: 		InitializeMultisig2, // 19

31: 		InitializeMint2, // 20

31: 		InitializeMint2, // 20

32: 		GetAccountDataSize, // 21

32: 		GetAccountDataSize, // 21

33: 		InitializeImmutableOwner, // 22

33: 		InitializeImmutableOwner, // 22

34: 		AmountToUiAmount, // 23

34: 		AmountToUiAmount, // 23

35: 		UiAmountToAmount, // 24

35: 		UiAmountToAmount, // 24

36: 		InitializeMintCloseAuthority, // 25

36: 		InitializeMintCloseAuthority, // 25

37: 		TransferFeeExtension, // 26

37: 		TransferFeeExtension, // 26

38: 		ConfidentialTransferExtension, // 27

38: 		ConfidentialTransferExtension, // 27

39: 		DefaultAccountStateExtension, // 28

39: 		DefaultAccountStateExtension, // 28

40: 		Reallocate, // 29

40: 		Reallocate, // 29

41: 		MemoTransferExtension, // 30

41: 		MemoTransferExtension, // 30

42: 		CreateNativeMint // 31

42: 		CreateNativeMint // 31

```

```solidity
File: lockbox-solana/solidity/liquidity_lockbox.sol

4: import "./library/spl_token.sol";

4: import "./library/spl_token.sol";

5: import "./interfaces/whirlpool.sol";

5: import "./interfaces/whirlpool.sol";

42:     int32 public constant minTickLowerIndex = -443632;

190:         numPositionAccounts++;

190:         numPositionAccounts++;

192:         totalLiquidity += positionLiquidity;

258:         totalLiquidity -= amount;

283:         uint64 remainder = positionLiquidity - amount;

324:             firstAvailablePositionAccountIndex++;

324:             firstAvailablePositionAccountIndex++;

353:         for (uint32 i = firstAvailablePositionAccountIndex; i < numPositionAccounts; ++i) {

353:         for (uint32 i = firstAvailablePositionAccountIndex; i < numPositionAccounts; ++i) {

358:             liquiditySum += positionLiquidity;

359:             numPositions++;

359:             numPositions++;

363:                 amountLeft = liquiditySum - amount;

372:         for (uint32 i = 0; i < numPositions; ++i) {

372:         for (uint32 i = 0; i < numPositions; ++i) {

373:             positionAddresses[i] = positionAccounts[firstAvailablePositionAccountIndex + i];

380:             positionAmounts[numPositions - 1] = amountLeft;

```

```solidity
File: registries/contracts/AgentRegistry.sol

4: import "./UnitRegistry.sol";

5: import "./interfaces/IRegistry.sol";

5: import "./interfaces/IRegistry.sol";

40:         for (uint256 iDep = 0; iDep < dependencies.length; ++iDep) {

40:         for (uint256 iDep = 0; iDep < dependencies.length; ++iDep) {

41:             if (dependencies[iDep] < (lastId + 1) || dependencies[iDep] > componentTotalSupply) {

```

```solidity
File: registries/contracts/ComponentRegistry.sol

4: import "./UnitRegistry.sol";

29:         for (uint256 iDep = 0; iDep < dependencies.length; ++iDep) {

29:         for (uint256 iDep = 0; iDep < dependencies.length; ++iDep) {

30:             if (dependencies[iDep] < (lastId + 1) || dependencies[iDep] > maxComponentId) {

```

```solidity
File: registries/contracts/GenericManager.sol

4: import "./interfaces/IErrorsRegistries.sol";

4: import "./interfaces/IErrorsRegistries.sol";

```

```solidity
File: registries/contracts/GenericRegistry.sol

4: import "../lib/solmate/src/tokens/ERC721.sol";

4: import "../lib/solmate/src/tokens/ERC721.sol";

4: import "../lib/solmate/src/tokens/ERC721.sol";

4: import "../lib/solmate/src/tokens/ERC721.sol";

4: import "../lib/solmate/src/tokens/ERC721.sol";

5: import "./interfaces/IErrorsRegistries.sol";

5: import "./interfaces/IErrorsRegistries.sol";

73:         return unitId > 0 && unitId < (totalSupply + 1);

98:         unitId = id + 1;

120:         result = bytes32 (0x3030303030303030303030303030303030303030303030303030303030303030 +

121:         uint256 (result) +

122:             (uint256 (result) + 0x0606060606060606060606060606060606060606060606060606060606060606 >> 4 &

123:             0x0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F) * 39);

```

```solidity
File: registries/contracts/RegistriesManager.sol

4: import "./GenericManager.sol";

5: import "./interfaces/IRegistry.sol";

5: import "./interfaces/IRegistry.sol";

```

```solidity
File: registries/contracts/UnitRegistry.sol

4: import "./GenericRegistry.sol";

78:         unitId++;

78:         unitId++;

97:             uint32[] memory addSubComponentIds = new uint32[](numSubComponents + 1);

98:             for (uint256 i = 0; i < numSubComponents; ++i) {

98:             for (uint256 i = 0; i < numSubComponents; ++i) {

211:         for (uint32 i = 0; i < numUnits; ++i) {

211:         for (uint32 i = 0; i < numUnits; ++i) {

215:             maxNumComponents += numComponents[i];

227:         for (counter = 0; counter < maxNumComponents; ++counter) {

227:         for (counter = 0; counter < maxNumComponents; ++counter) {

234:             for (uint32 i = 0; i < numUnits; ++i) {

234:             for (uint32 i = 0; i < numUnits; ++i) {

236:                 for (; processedComponents[i] < numComponents[i]; ++processedComponents[i]) {

236:                 for (; processedComponents[i] < numComponents[i]; ++processedComponents[i]) {

244:                         numComponentsCheck++;

244:                         numComponentsCheck++;

254:                 processedComponents[minIdxComponent]++;

254:                 processedComponents[minIdxComponent]++;

262:         for (uint32 i = 0; i < counter; ++i) {

262:         for (uint32 i = 0; i < counter; ++i) {

```

```solidity
File: registries/contracts/multisigs/GnosisSafeMultisig.sol

77:                 uint256 payloadLength = dataLength - DEFAULT_DATA_LENGTH;

79:                 for (uint256 i = 0; i < payloadLength; ++i) {

79:                 for (uint256 i = 0; i < payloadLength; ++i) {

80:                     payload[i] = data[i + DEFAULT_DATA_LENGTH];

```

```solidity
File: registries/contracts/multisigs/GnosisSafeSameAddressMultisig.sol

111:             uint256 payloadLength = dataLength - DEFAULT_DATA_LENGTH;

113:             for (uint256 i = 0; i < payloadLength; ++i) {

113:             for (uint256 i = 0; i < payloadLength; ++i) {

114:                 payload[i] = data[i + DEFAULT_DATA_LENGTH];

139:         for (uint256 i = 0; i < numOwners; ++i) {

139:         for (uint256 i = 0; i < numOwners; ++i) {

140:             if (owners[i] != checkOwners[numOwners - i - 1]) {

140:             if (owners[i] != checkOwners[numOwners - i - 1]) {

```

```solidity
File: tokenomics/contracts/Depository.sol

4: import {IErrorsTokenomics} from "./interfaces/IErrorsTokenomics.sol";

4: import {IErrorsTokenomics} from "./interfaces/IErrorsTokenomics.sol";

5: import {IGenericBondCalculator} from "./interfaces/IGenericBondCalculator.sol";

5: import {IGenericBondCalculator} from "./interfaces/IGenericBondCalculator.sol";

6: import {IToken} from "./interfaces/IToken.sol";

6: import {IToken} from "./interfaces/IToken.sol";

7: import {ITokenomics} from "./interfaces/ITokenomics.sol";

7: import {ITokenomics} from "./interfaces/ITokenomics.sol";

8: import {ITreasury} from "./interfaces/ITreasury.sol";

8: import {ITreasury} from "./interfaces/ITreasury.sol";

215:         uint256 maturity = block.timestamp + vesting;

234:         productCounter = uint32(productId + 1);

255:         for (uint256 i = 0; i < numProducts; ++i) {

255:         for (uint256 i = 0; i < numProducts; ++i) {

267:                 ++numClosedProducts;

267:                 ++numClosedProducts;

274:         for (uint256 i = 0; i < numClosedProducts; ++i) {

274:         for (uint256 i = 0; i < numClosedProducts; ++i) {

309:         maturity = block.timestamp + product.vesting;

328:         supply -= payout;

334:         bondCounter = uint32(bondId + 1);

357:         for (uint256 i = 0; i < bondIds.length; ++i) {

357:         for (uint256 i = 0; i < bondIds.length; ++i) {

373:             payout += pay;

402:         for (uint256 i = 0; i < numProducts; ++i) {

402:         for (uint256 i = 0; i < numProducts; ++i) {

406:                 ++numSelectedProducts;

406:                 ++numSelectedProducts;

413:         for (uint256 i = 0; i < numProducts; ++i) {

413:         for (uint256 i = 0; i < numProducts; ++i) {

416:                 ++numPos;

416:                 ++numPos;

448:         for (uint256 i = 0; i < numBonds; ++i) {

448:         for (uint256 i = 0; i < numBonds; ++i) {

458:                     ++numAccountBonds;

458:                     ++numAccountBonds;

460:                     payout += mapUserBonds[i].payout;

468:         for (uint256 i = 0; i < numBonds; ++i) {

468:         for (uint256 i = 0; i < numBonds; ++i) {

471:                 ++numPos;

471:                 ++numPos;

```

```solidity
File: tokenomics/contracts/Dispenser.sol

4: import "./interfaces/IErrorsTokenomics.sol";

4: import "./interfaces/IErrorsTokenomics.sol";

5: import "./interfaces/ITokenomics.sol";

5: import "./interfaces/ITokenomics.sol";

6: import "./interfaces/ITreasury.sol";

6: import "./interfaces/ITreasury.sol";

103:         if ((reward + topUp) > 0) {

```

```solidity
File: tokenomics/contracts/DonatorBlacklist.sol

67:         for (uint256 i = 0; i < accounts.length; ++i) {

67:         for (uint256 i = 0; i < accounts.length; ++i) {

```

```solidity
File: tokenomics/contracts/GenericBondCalculator.sol

4: import {mulDiv} from "@prb/math/src/Common.sol";

4: import {mulDiv} from "@prb/math/src/Common.sol";

4: import {mulDiv} from "@prb/math/src/Common.sol";

5: import "./interfaces/ITokenomics.sol";

5: import "./interfaces/ITokenomics.sol";

6: import "./interfaces/IUniswapV2Pair.sol";

6: import "./interfaces/IUniswapV2Pair.sol";

64:         amountOLAS = ITokenomics(tokenomics).getLastIDF() * totalTokenValue / 1e36;

64:         amountOLAS = ITokenomics(tokenomics).getLastIDF() * totalTokenValue / 1e36;

89:                 priceLP = (reserve1 * 1e18) / totalSupply;

89:                 priceLP = (reserve1 * 1e18) / totalSupply;

```

```solidity
File: tokenomics/contracts/Tokenomics.sol

4: import "./TokenomicsConstants.sol";

5: import "./interfaces/IDonatorBlacklist.sol";

5: import "./interfaces/IDonatorBlacklist.sol";

6: import "./interfaces/IErrorsTokenomics.sol";

6: import "./interfaces/IErrorsTokenomics.sol";

7: import "./interfaces/IOLAS.sol";

7: import "./interfaces/IOLAS.sol";

8: import "./interfaces/IServiceRegistry.sol";

8: import "./interfaces/IServiceRegistry.sol";

9: import "./interfaces/IToken.sol";

9: import "./interfaces/IToken.sol";

10: import "./interfaces/ITreasury.sol";

10: import "./interfaces/ITreasury.sol";

11: import "./interfaces/IVotingEscrow.sol";

11: import "./interfaces/IVotingEscrow.sol";

320:         if (block.timestamp >= (_timeLaunch + ONE_YEAR)) {

321:             revert Overflow(_timeLaunch + ONE_YEAR, block.timestamp);

325:         uint256 zeroYearSecondsLeft = uint32(_timeLaunch + ONE_YEAR - block.timestamp);

325:         uint256 zeroYearSecondsLeft = uint32(_timeLaunch + ONE_YEAR - block.timestamp);

329:         uint256 _inflationPerSecond = getInflationForYear(0) / zeroYearSecondsLeft;

367:         uint256 _maxBond = (_inflationPerSecond * _epochLen * _maxBondFraction) / 100;

367:         uint256 _maxBond = (_inflationPerSecond * _epochLen * _maxBondFraction) / 100;

367:         uint256 _maxBond = (_inflationPerSecond * _epochLen * _maxBondFraction) / 100;

551:         emit TokenomicsParametersUpdateRequested(epochCounter + 1, _devsPerCapital, _codePerDev, _epsilonRate, _epochLen,

576:         if (_rewardComponentFraction + _rewardAgentFraction > 100) {

577:             revert WrongAmount(_rewardComponentFraction + _rewardAgentFraction, 100);

581:         if (_maxBondFraction + _topUpComponentFraction + _topUpAgentFraction > 100) {

581:         if (_maxBondFraction + _topUpComponentFraction + _topUpAgentFraction > 100) {

582:             revert WrongAmount(_maxBondFraction + _topUpComponentFraction + _topUpAgentFraction, 100);

582:             revert WrongAmount(_maxBondFraction + _topUpComponentFraction + _topUpAgentFraction, 100);

586:         uint256 eCounter = epochCounter + 1;

592:         tp.epochPoint.rewardTreasuryFraction = uint8(100 - _rewardComponentFraction - _rewardAgentFraction);

592:         tp.epochPoint.rewardTreasuryFraction = uint8(100 - _rewardComponentFraction - _rewardAgentFraction);

620:             eBond -= amount;

636:         uint256 eBond = effectiveBond + amount;

657:             totalIncentives *= mapEpochTokenomics[epochNum].unitPoints[unitType].rewardUnitFraction;

659:             totalIncentives = mapUnitIncentives[unitType][unitId].reward + totalIncentives / 100;

659:             totalIncentives = mapUnitIncentives[unitType][unitId].reward + totalIncentives / 100;

672:             totalIncentives *= mapEpochTokenomics[epochNum].epochPoint.totalTopUpsOLAS;

673:             totalIncentives *= mapEpochTokenomics[epochNum].unitPoints[unitType].topUpUnitFraction;

674:             uint256 sumUnitIncentives = uint256(mapEpochTokenomics[epochNum].unitPoints[unitType].sumUnitTopUpsOLAS) * 100;

675:             totalIncentives = mapUnitIncentives[unitType][unitId].topUp + totalIncentives / sumUnitIncentives;

675:             totalIncentives = mapUnitIncentives[unitType][unitId].topUp + totalIncentives / sumUnitIncentives;

702:         for (uint256 i = 0; i < numServices; ++i) {

702:         for (uint256 i = 0; i < numServices; ++i) {

714:             for (uint256 unitType = 0; unitType < 2; ++unitType) {

714:             for (uint256 unitType = 0; unitType < 2; ++unitType) {

724:                 if (incentiveFlags[unitType] || incentiveFlags[unitType + 2]) {

726:                     uint96 amount = uint96(amounts[i] / numServiceUnits);

728:                     for (uint256 j = 0; j < numServiceUnits; ++j) {

728:                     for (uint256 j = 0; j < numServiceUnits; ++j) {

745:                             mapUnitIncentives[unitType][serviceUnitIds[j]].pendingRelativeReward += amount;

750:                         if (topUpEligible && incentiveFlags[unitType + 2]) {

751:                             mapUnitIncentives[unitType][serviceUnitIds[j]].pendingRelativeTopUp += amount;

752:                             mapEpochTokenomics[curEpoch].unitPoints[unitType].sumUnitTopUpsOLAS += amount;

758:                 for (uint256 j = 0; j < numServiceUnits; ++j) {

758:                 for (uint256 j = 0; j < numServiceUnits; ++j) {

762:                         mapEpochTokenomics[curEpoch].unitPoints[unitType].numNewUnits++;

762:                         mapEpochTokenomics[curEpoch].unitPoints[unitType].numNewUnits++;

768:                             mapEpochTokenomics[curEpoch].epochPoint.numNewOwners++;

768:                             mapEpochTokenomics[curEpoch].epochPoint.numNewOwners++;

808:         for (uint256 i = 0; i < numServices; ++i) {

808:         for (uint256 i = 0; i < numServices; ++i) {

817:         donationETH += mapEpochTokenomics[curEpoch].epochPoint.totalDonationsETH;

861:         idf = 1e18 + fKD;

897:         uint256 prevEpochTime = mapEpochTokenomics[epochCounter - 1].epochPoint.endTime;

898:         uint256 diffNumSeconds = block.timestamp - prevEpochTime;

915:         incentives[1] = (incentives[0] * tp.epochPoint.rewardTreasuryFraction) / 100;

915:         incentives[1] = (incentives[0] * tp.epochPoint.rewardTreasuryFraction) / 100;

917:         incentives[2] = (incentives[0] * tp.unitPoints[0].rewardUnitFraction) / 100;

917:         incentives[2] = (incentives[0] * tp.unitPoints[0].rewardUnitFraction) / 100;

918:         incentives[3] = (incentives[0] * tp.unitPoints[1].rewardUnitFraction) / 100;

918:         incentives[3] = (incentives[0] * tp.unitPoints[1].rewardUnitFraction) / 100;

925:         uint256 numYears = (block.timestamp - timeLaunch) / ONE_YEAR;

925:         uint256 numYears = (block.timestamp - timeLaunch) / ONE_YEAR;

931:             uint256 yearEndTime = timeLaunch + numYears * ONE_YEAR;

931:             uint256 yearEndTime = timeLaunch + numYears * ONE_YEAR;

933:             inflationPerEpoch = (yearEndTime - prevEpochTime) * curInflationPerSecond;

933:             inflationPerEpoch = (yearEndTime - prevEpochTime) * curInflationPerSecond;

935:             curInflationPerSecond = getInflationForYear(numYears) / ONE_YEAR;

937:             inflationPerEpoch += (block.timestamp - yearEndTime) * curInflationPerSecond;

937:             inflationPerEpoch += (block.timestamp - yearEndTime) * curInflationPerSecond;

937:             inflationPerEpoch += (block.timestamp - yearEndTime) * curInflationPerSecond;

945:             inflationPerEpoch = curInflationPerSecond * diffNumSeconds;

951:         incentives[4] = (inflationPerEpoch * tp.epochPoint.maxBondFraction) / 100;

951:         incentives[4] = (inflationPerEpoch * tp.epochPoint.maxBondFraction) / 100;

965:             incentives[4] = effectiveBond + incentives[4] - curMaxBond;

965:             incentives[4] = effectiveBond + incentives[4] - curMaxBond;

970:         TokenomicsPoint storage nextEpochPoint = mapEpochTokenomics[eCounter + 1];

975:             emit IncentiveFractionsUpdated(eCounter + 1);

978:             for (uint256 i = 0; i < 2; ++i) {

978:             for (uint256 i = 0; i < 2; ++i) {

1002:             emit TokenomicsParametersUpdated(eCounter + 1);

1010:         numYears = (block.timestamp + curEpochLen - timeLaunch) / ONE_YEAR;

1010:         numYears = (block.timestamp + curEpochLen - timeLaunch) / ONE_YEAR;

1010:         numYears = (block.timestamp + curEpochLen - timeLaunch) / ONE_YEAR;

1015:             uint256 yearEndTime = timeLaunch + numYears * ONE_YEAR;

1015:             uint256 yearEndTime = timeLaunch + numYears * ONE_YEAR;

1017:             inflationPerEpoch = (yearEndTime - block.timestamp) * curInflationPerSecond;

1017:             inflationPerEpoch = (yearEndTime - block.timestamp) * curInflationPerSecond;

1019:             curInflationPerSecond = getInflationForYear(numYears) / ONE_YEAR;

1021:             inflationPerEpoch += (block.timestamp + curEpochLen - yearEndTime) * curInflationPerSecond;

1021:             inflationPerEpoch += (block.timestamp + curEpochLen - yearEndTime) * curInflationPerSecond;

1021:             inflationPerEpoch += (block.timestamp + curEpochLen - yearEndTime) * curInflationPerSecond;

1021:             inflationPerEpoch += (block.timestamp + curEpochLen - yearEndTime) * curInflationPerSecond;

1023:             curMaxBond = (inflationPerEpoch * nextEpochPoint.epochPoint.maxBondFraction) / 100;

1023:             curMaxBond = (inflationPerEpoch * nextEpochPoint.epochPoint.maxBondFraction) / 100;

1030:             curMaxBond = (curEpochLen * curInflationPerSecond * nextEpochPoint.epochPoint.maxBondFraction) / 100;

1030:             curMaxBond = (curEpochLen * curInflationPerSecond * nextEpochPoint.epochPoint.maxBondFraction) / 100;

1030:             curMaxBond = (curEpochLen * curInflationPerSecond * nextEpochPoint.epochPoint.maxBondFraction) / 100;

1037:         curMaxBond += effectiveBond;

1052:         uint256 accountRewards = incentives[2] + incentives[3];

1054:         incentives[5] = (inflationPerEpoch * tp.unitPoints[0].topUpUnitFraction) / 100;

1054:         incentives[5] = (inflationPerEpoch * tp.unitPoints[0].topUpUnitFraction) / 100;

1056:         incentives[6] = (inflationPerEpoch * tp.unitPoints[1].topUpUnitFraction) / 100;

1056:         incentives[6] = (inflationPerEpoch * tp.unitPoints[1].topUpUnitFraction) / 100;

1060:         uint256 accountTopUps = incentives[5] + incentives[6];

1067:             epochCounter = uint32(eCounter + 1);

1104:         for (uint256 i = 0; i < 2; ++i) {

1104:         for (uint256 i = 0; i < 2; ++i) {

1110:         for (uint256 i = 0; i < unitIds.length; ++i) {

1110:         for (uint256 i = 0; i < unitIds.length; ++i) {

1132:         for (uint256 i = 0; i < unitIds.length; ++i) {

1132:         for (uint256 i = 0; i < unitIds.length; ++i) {

1145:             reward += mapUnitIncentives[unitTypes[i]][unitIds[i]].reward;

1148:             topUp += mapUnitIncentives[unitTypes[i]][unitIds[i]].topUp;

1174:         for (uint256 i = 0; i < 2; ++i) {

1174:         for (uint256 i = 0; i < 2; ++i) {

1180:         for (uint256 i = 0; i < unitIds.length; ++i) {

1180:         for (uint256 i = 0; i < unitIds.length; ++i) {

1202:         for (uint256 i = 0; i < unitIds.length; ++i) {

1202:         for (uint256 i = 0; i < unitIds.length; ++i) {

1211:                     totalIncentives *= mapEpochTokenomics[lastEpoch].unitPoints[unitTypes[i]].rewardUnitFraction;

1213:                     reward += totalIncentives / 100;

1213:                     reward += totalIncentives / 100;

1220:                     totalIncentives *= mapEpochTokenomics[lastEpoch].epochPoint.totalTopUpsOLAS;

1221:                     totalIncentives *= mapEpochTokenomics[lastEpoch].unitPoints[unitTypes[i]].topUpUnitFraction;

1222:                     uint256 sumUnitIncentives = uint256(mapEpochTokenomics[lastEpoch].unitPoints[unitTypes[i]].sumUnitTopUpsOLAS) * 100;

1224:                     topUp += totalIncentives / sumUnitIncentives;

1224:                     topUp += totalIncentives / sumUnitIncentives;

1229:             reward += mapUnitIncentives[unitTypes[i]][unitIds[i]].reward;

1231:             topUp += mapUnitIncentives[unitTypes[i]][unitIds[i]].topUp;

1238:         inflationPerEpoch = inflationPerSecond * epochLen;

1264:         idf = mapEpochTokenomics[epochCounter - 1].epochPoint.idf;

```

```solidity
File: tokenomics/contracts/TokenomicsConstants.sol

4: import "@prb/math/src/UD60x18.sol";

4: import "@prb/math/src/UD60x18.sol";

4: import "@prb/math/src/UD60x18.sol";

16:     uint256 public constant ONE_YEAR = 1 days * 365;

48:             numYears -= 9;

55:             for (uint256 i = 0; i < numYears; ++i) {

55:             for (uint256 i = 0; i < numYears; ++i) {

56:                 supplyCap += (supplyCap * maxMintCapFraction) / 100;

56:                 supplyCap += (supplyCap * maxMintCapFraction) / 100;

56:                 supplyCap += (supplyCap * maxMintCapFraction) / 100;

85:             numYears -= 9;

92:             for (uint256 i = 1; i < numYears; ++i) {

92:             for (uint256 i = 1; i < numYears; ++i) {

93:                 supplyCap += (supplyCap * maxMintCapFraction) / 100;

93:                 supplyCap += (supplyCap * maxMintCapFraction) / 100;

93:                 supplyCap += (supplyCap * maxMintCapFraction) / 100;

97:             inflationAmount = (supplyCap * maxMintCapFraction) / 100;

97:             inflationAmount = (supplyCap * maxMintCapFraction) / 100;

```

```solidity
File: tokenomics/contracts/Treasury.sol

4: import "./interfaces/IErrorsTokenomics.sol";

4: import "./interfaces/IErrorsTokenomics.sol";

5: import "./interfaces/IOLAS.sol";

5: import "./interfaces/IOLAS.sol";

6: import "./interfaces/IToken.sol";

6: import "./interfaces/IToken.sol";

7: import "./interfaces/IServiceRegistry.sol";

7: import "./interfaces/IServiceRegistry.sol";

8: import "./interfaces/ITokenomics.sol";

8: import "./interfaces/ITokenomics.sol";

126:         amount += msg.value;

128:         if (amount + ETHFromServices > type(uint96).max) {

224:         uint256 reserves = mapTokenReserves[token] + tokenAmount;

276:         for (uint256 i = 0; i < numServices; ++i) {

276:         for (uint256 i = 0; i < numServices; ++i) {

280:             totalAmount += amounts[i];

289:         uint256 donationETH = ETHFromServices + msg.value;

291:         if (donationETH + ETHOwned > type(uint96).max) {

335:                 amountOwned -= tokenAmount;

355:                 reserves -= tokenAmount;

403:             amountETHFromServices -= accountRewards;

445:                 amountETHFromServices -= treasuryRewards;

448:                 amountETHOwned += treasuryRewards;

```

### <a name="GAS-5"></a>[GAS-5] Use Custom Errors
[Source](https://blog.soliditylang.org/2021/04/21/custom-errors/)
Instead of using error strings, to reduce deployment and runtime cost, you should use Custom Errors. This would save both deployment and runtime cost.

*Instances (18)*:
```solidity
File: lockbox-solana/solidity/liquidity_lockbox.sol

75:             revert("Invalid bump");

99:             revert("Liquidity overflow");

104:             revert("Wrong pool address");

109:             revert("Wrong NFT address");

114:             revert("Wrong ticks");

119:             revert("Wrong PDA owner");

125:             revert("Wrong PDA header");

131:             revert("Wrong position PDA");

152:             revert("Wrong user position ATA");

157:             revert("Wrong bridged token mint account");

163:             revert("Wrong PDA position owner");

216:             revert("Wrong liquidity token account");

221:             revert("Wrong position ATA");

227:             revert("No liquidity on a provided token account");

232:             revert("Amount exceeds a position liquidity");

237:             revert("Wrong PDA bridged token ATA");

242:             revert("Pool address is incorrect");

247:             revert("Wrong bridged token mint account");

```

### <a name="GAS-6"></a>[GAS-6] Don't initialize variables with default value

*Instances (45)*:
```solidity
File: governance/contracts/OLAS.sol

108:             for (uint256 i = 0; i < numYears; ++i) {

```

```solidity
File: governance/contracts/bridges/HomeMediator.sol

125:         for (uint256 i = 0; i < dataLength;) {

153:             for (uint256 j = 0; j < payloadLength; ++j) {

```

```solidity
File: governance/contracts/veOLAS.sol

266:             for (uint256 i = 0; i < 255; ++i) {

285:                     lastPoint.bias = 0;

289:                     lastPoint.slope = 0;

323:                 lastPoint.slope = 0;

326:                 lastPoint.bias = 0;

684:         for (uint256 i = 0; i < 128; ++i) {

836:         for (uint256 i = 0; i < 255; ++i) {

```

```solidity
File: lockbox-solana/solidity/liquidity_lockbox.sol

348:         uint64 liquiditySum = 0;

349:         uint32 numPositions = 0;

350:         uint64 amountLeft = 0;

372:         for (uint32 i = 0; i < numPositions; ++i) {

```

```solidity
File: registries/contracts/AgentRegistry.sol

40:         for (uint256 iDep = 0; iDep < dependencies.length; ++iDep) {

```

```solidity
File: registries/contracts/ComponentRegistry.sol

29:         for (uint256 iDep = 0; iDep < dependencies.length; ++iDep) {

```

```solidity
File: registries/contracts/UnitRegistry.sol

98:             for (uint256 i = 0; i < numSubComponents; ++i) {

211:         for (uint32 i = 0; i < numUnits; ++i) {

234:             for (uint32 i = 0; i < numUnits; ++i) {

262:         for (uint32 i = 0; i < counter; ++i) {

```

```solidity
File: registries/contracts/multisigs/GnosisSafeMultisig.sol

79:                 for (uint256 i = 0; i < payloadLength; ++i) {

```

```solidity
File: registries/contracts/multisigs/GnosisSafeSameAddressMultisig.sol

113:             for (uint256 i = 0; i < payloadLength; ++i) {

139:         for (uint256 i = 0; i < numOwners; ++i) {

```

```solidity
File: tokenomics/contracts/Depository.sol

255:         for (uint256 i = 0; i < numProducts; ++i) {

274:         for (uint256 i = 0; i < numClosedProducts; ++i) {

357:         for (uint256 i = 0; i < bondIds.length; ++i) {

402:         for (uint256 i = 0; i < numProducts; ++i) {

413:         for (uint256 i = 0; i < numProducts; ++i) {

448:         for (uint256 i = 0; i < numBonds; ++i) {

468:         for (uint256 i = 0; i < numBonds; ++i) {

```

```solidity
File: tokenomics/contracts/DonatorBlacklist.sol

67:         for (uint256 i = 0; i < accounts.length; ++i) {

```

```solidity
File: tokenomics/contracts/Tokenomics.sol

702:         for (uint256 i = 0; i < numServices; ++i) {

714:             for (uint256 unitType = 0; unitType < 2; ++unitType) {

728:                     for (uint256 j = 0; j < numServiceUnits; ++j) {

758:                 for (uint256 j = 0; j < numServiceUnits; ++j) {

808:         for (uint256 i = 0; i < numServices; ++i) {

978:             for (uint256 i = 0; i < 2; ++i) {

1104:         for (uint256 i = 0; i < 2; ++i) {

1110:         for (uint256 i = 0; i < unitIds.length; ++i) {

1132:         for (uint256 i = 0; i < unitIds.length; ++i) {

1174:         for (uint256 i = 0; i < 2; ++i) {

1180:         for (uint256 i = 0; i < unitIds.length; ++i) {

1202:         for (uint256 i = 0; i < unitIds.length; ++i) {

```

```solidity
File: tokenomics/contracts/TokenomicsConstants.sol

55:             for (uint256 i = 0; i < numYears; ++i) {

```

```solidity
File: tokenomics/contracts/Treasury.sol

276:         for (uint256 i = 0; i < numServices; ++i) {

```

### <a name="GAS-7"></a>[GAS-7] `++i` costs less gas than `i++`, especially when it's used in `for`-loops (`--i`/`i--` too)
*Saves 5 gas per loop*

*Instances (8)*:
```solidity
File: lockbox-solana/solidity/liquidity_lockbox.sol

190:         numPositionAccounts++;

324:             firstAvailablePositionAccountIndex++;

359:             numPositions++;

```

```solidity
File: registries/contracts/UnitRegistry.sol

78:         unitId++;

244:                         numComponentsCheck++;

254:                 processedComponents[minIdxComponent]++;

```

```solidity
File: tokenomics/contracts/Tokenomics.sol

762:                         mapEpochTokenomics[curEpoch].unitPoints[unitType].numNewUnits++;

768:                             mapEpochTokenomics[curEpoch].epochPoint.numNewOwners++;

```

### <a name="GAS-8"></a>[GAS-8] Using `private` rather than `public` for constants, saves gas
If needed, the values can be read from the verified contract source code, or if there are multiple values there can be a single getter function that [returns a tuple](https://github.com/code-423n4/2022-08-frax/blob/90f55a9ce4e25bceed3a74290b854341d8de6afa/src/contracts/FraxlendPair.sol#L156-L178) of the values of all currently-public constants. Saves **3406-3606 gas** in deployment gas due to the compiler not having to create non-payable getter functions for deployment calldata, not having to store the bytes of the value outside of where it's used, and not adding another entry to the method ID table

*Instances (27)*:
```solidity
File: governance/contracts/OLAS.sol

22:     uint256 public constant oneYear = 1 days * 365;

24:     uint256 public constant tenYearSupplyCap = 1_000_000_000e18;

26:     uint256 public constant maxMintCapFraction = 2;

```

```solidity
File: governance/contracts/bridges/HomeMediator.sol

53:     uint256 public constant DEFAULT_DATA_LENGTH = 36;

```

```solidity
File: governance/contracts/veOLAS.sol

111:     uint8 public constant decimals = 18;

```

```solidity
File: governance/contracts/wveOLAS.sol

136:     string public constant name = "Voting Escrow OLAS";

138:     string public constant symbol = "veOLAS";

140:     uint8 public constant decimals = 18;

```

```solidity
File: lockbox-solana/solidity/liquidity_lockbox.sol

27:     address public constant orca = address"whirLbMiicVdio4qvUfM5KAg6Ct8VwpYzGff3uctyCc";

39:     bytes public constant pdaProgramSeed = "pdaProgram";

42:     int32 public constant minTickLowerIndex = -443632;

43:     int32 public constant maxTickLowerIndex = 443632;

```

```solidity
File: registries/contracts/AgentRegistry.sol

13:     string public constant VERSION = "1.0.0";

```

```solidity
File: registries/contracts/ComponentRegistry.sol

10:     string public constant VERSION = "1.0.0";

```

```solidity
File: registries/contracts/GenericRegistry.sol

33:     string public constant CID_PREFIX = "f01701220";

```

```solidity
File: registries/contracts/multisigs/GnosisSafeMultisig.sol

26:     bytes4 public constant GNOSIS_SAFE_SETUP_SELECTOR = 0xb63e800d;

28:     uint256 public constant DEFAULT_DATA_LENGTH = 144;

```

```solidity
File: registries/contracts/multisigs/GnosisSafeSameAddressMultisig.sol

53:     uint256 public constant DEFAULT_DATA_LENGTH = 20;

```

```solidity
File: tokenomics/contracts/Depository.sol

75:     uint256 public constant MIN_VESTING = 1 days;

77:     string public constant VERSION = "1.0.1";

```

```solidity
File: tokenomics/contracts/TokenomicsConstants.sol

11:     string public constant VERSION = "1.0.1";

14:     bytes32 public constant PROXY_TOKENOMICS = 0xbd5523e7c3b6a94aa0e3b24d1120addc2f95c7029e097b466b2bedc8d4b4362f;

16:     uint256 public constant ONE_YEAR = 1 days * 365;

18:     uint256 public constant MIN_EPOCH_LENGTH = 1 weeks;

20:     uint256 public constant MIN_PARAM_VALUE = 1e14;

```

```solidity
File: tokenomics/contracts/TokenomicsProxy.sol

28:     bytes32 public constant PROXY_TOKENOMICS = 0xbd5523e7c3b6a94aa0e3b24d1120addc2f95c7029e097b466b2bedc8d4b4362f;

```

```solidity
File: tokenomics/contracts/Treasury.sol

56:     address public constant ETH_TOKEN_ADDRESS = address(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE);

```

### <a name="GAS-9"></a>[GAS-9] Use shift Right/Left instead of division/multiplication if possible

*Instances (1)*:
```solidity
File: governance/contracts/veOLAS.sol

688:             uint256 mid = (minPointNumber + maxPointNumber + 1) / 2;

```

### <a name="GAS-10"></a>[GAS-10] Use != 0 instead of > 0 for unsigned integer comparison

*Instances (47)*:
```solidity
File: governance/contracts/veOLAS.sol

160:         if (lastPointNumber > 0) {

206:             if (oldLocked.endTime > block.timestamp && oldLocked.amount > 0) {

214:             if (newLocked.endTime > block.timestamp && newLocked.amount > 0) {

227:             if (newLocked.endTime > 0) {

237:         if (curNumPoint > 0) {

403:         if (unlockTime > 0) {

413:         if (amount > 0) {

512:         if (lockedBalance.amount > 0) {

721:         if (pointNumber > 0) {

724:             if (uPoint.bias > 0) {

798:         if (dBlock > 0) {

821:         if (uPoint.bias > 0) {

857:         if (lastPoint.bias > 0) {

```

```solidity
File: governance/contracts/wveOLAS.sol

196:         if (userNumPoints > 0) {

215:         if (uPoint.blockNumber > 0 && blockNumber >= uPoint.blockNumber) {

235:         if (uPoint.blockNumber > 0 && blockNumber >= uPoint.blockNumber) {

```

```solidity
File: lockbox-solana/solidity/liquidity_lockbox.sol

379:         if (numPositions > 0 && amountLeft > 0) {

379:         if (numPositions > 0 && amountLeft > 0) {

```

```solidity
File: registries/contracts/GenericRegistry.sol

73:         return unitId > 0 && unitId < (totalSupply + 1);

```

```solidity
File: registries/contracts/UnitRegistry.sol

252:             if (numComponentsCheck > 0) {

```

```solidity
File: registries/contracts/multisigs/GnosisSafeMultisig.sol

50:         if (dataLength > 0) {

```

```solidity
File: tokenomics/contracts/Depository.sol

260:             if (supply > 0) {

404:             if ((active && mapBondProducts[i].supply > 0) || (!active && mapBondProducts[i].supply == 0)) {

425:         status = (mapBondProducts[productId].supply > 0);

483:         if (payout > 0) {

```

```solidity
File: tokenomics/contracts/Dispenser.sol

103:         if ((reward + topUp) > 0) {

```

```solidity
File: tokenomics/contracts/GenericBondCalculator.sol

74:         if (totalSupply > 0) {

```

```solidity
File: tokenomics/contracts/Tokenomics.sol

529:         if (_epsilonRate > 0 && _epsilonRate <= 17e18) {

543:         if (uint96(_veOLASThreshold) > 0) {

656:         if (totalIncentives > 0) {

669:         if (totalIncentives > 0) {

694:         incentiveFlags[0] = (mapEpochTokenomics[curEpoch].unitPoints[0].rewardUnitFraction > 0);

695:         incentiveFlags[1] = (mapEpochTokenomics[curEpoch].unitPoints[1].rewardUnitFraction > 0);

696:         incentiveFlags[2] = (mapEpochTokenomics[curEpoch].unitPoints[0].topUpUnitFraction > 0);

697:         incentiveFlags[3] = (mapEpochTokenomics[curEpoch].unitPoints[1].topUpUnitFraction > 0);

989:             if (nextEpochLen > 0) {

996:             if (nextVeOLASThreshold > 0) {

1028:         } else if (tokenomicsParametersUpdated > 0) {

1041:         if (incentives[0] > 0) {

1138:             if (lastEpoch > 0 && lastEpoch < curEpoch) {

1206:             if (lastEpoch > 0 && lastEpoch < curEpoch) {

1210:                 if (totalIncentives > 0) {

1217:                 if (totalIncentives > 0) {

```

```solidity
File: tokenomics/contracts/Treasury.sol

402:         if (accountRewards > 0 && amountETHFromServices >= accountRewards) {

413:         if (accountTopUps > 0) {

441:         if (treasuryRewards > 0) {

515:             if (mapTokenReserves[token] > 0) {

```


## Non Critical Issues


| |Issue|Instances|
|-|:-|:-:|
| [NC-1](#NC-1) | Array indices should be referenced via `enum`s rather than via numeric literals | 1 |
| [NC-2](#NC-2) | Event is missing `indexed` fields | 6 |
| [NC-3](#NC-3) | Constants should be defined rather than using magic numbers | 6 |
| [NC-4](#NC-4) | Functions not used internally could be marked external | 6 |
### <a name="NC-1"></a>[NC-1] Array indices should be referenced via `enum`s rather than via numeric literals

*Instances (1)*:
```solidity
File: governance/contracts/veOLAS.sol

144:         mapSupplyPoints[0] = PointVoting(

```

### <a name="NC-2"></a>[NC-2] Event is missing `indexed` fields
Index event fields make the field more quickly accessible to off-chain tools that parse events. However, note that each index field costs extra gas during emission, so it's not necessarily best to index the maximum allowed per event (three fields). Each event should use three indexed fields if there are three or more fields, and gas usage is not particularly of concern for the events in question. If there are fewer than three fields, all of the fields should be indexed.

*Instances (6)*:
```solidity
File: governance/contracts/veOLAS.sol

94:     event Deposit(

101:     event Withdraw(address indexed account, uint256 amount, uint256 ts);

102:     event Supply(uint256 previousSupply, uint256 currentSupply);

```

```solidity
File: registries/contracts/GenericRegistry.sol

12:     event BaseURIChanged(string baseURI);

```

```solidity
File: registries/contracts/UnitRegistry.sol

9:     event CreateUnit(uint256 unitId, UnitType uType, bytes32 unitHash);

10:     event UpdateUnitHash(uint256 unitId, UnitType uType, bytes32 unitHash);

```

### <a name="NC-3"></a>[NC-3] Constants should be defined rather than using magic numbers

*Instances (6)*:
```solidity
File: lockbox-solana/solidity/library/spl_token.sol

110: 		return account.data.readUint64LE(36);

116: 		return account.data.readUint64LE(64);

```

```solidity
File: lockbox-solana/solidity/liquidity_lockbox.sol

91:             positionMint: position.data.readAddress(40),

92:             liquidity: position.data.readUint128LE(72),

93:             tickLowerIndex: position.data.readInt32LE(88),

94:             tickUpperIndex: position.data.readInt32LE(92)

```

### <a name="NC-4"></a>[NC-4] Functions not used internally could be marked external

*Instances (6)*:
```solidity
File: governance/contracts/veOLAS.sol

733:     function balanceOf(

766:     function getVotes(address account) public view override returns (uint256) {

807:     function getPastVotes(

864:     function totalSupply() public view override returns (uint256) {

895:     function totalSupplyLocked() public view returns (uint256) {

902:     function getPastTotalSupply(

```


## Low Issues


| |Issue|Instances|
|-|:-|:-:|
| [L-1](#L-1) | Empty Function Body - Consider commenting why | 3 |
| [L-2](#L-2) | Initializers could be front-run | 1 |
| [L-3](#L-3) | Unsafe ERC20 operation(s) | 10 |
### <a name="L-1"></a>[L-1] Empty Function Body - Consider commenting why

*Instances (3)*:
```solidity
File: governance/contracts/GovernorOLAS.sol

40:     {}

```

```solidity
File: governance/contracts/Timelock.sol

14:     ) TimelockController(minDelay, proposers, executors, msg.sender) {}

```

```solidity
File: tokenomics/contracts/Tokenomics.sol

234:     {}

```

### <a name="L-2"></a>[L-2] Initializers could be front-run
Initializers could be front-run, allowing an attacker to either set their own values, take ownership of the contract, and in the best case forcing a re-deployment

*Instances (1)*:
```solidity
File: registries/contracts/multisigs/GnosisSafeMultisig.sol

12:         bytes memory initializer,

```

### <a name="L-3"></a>[L-3] Unsafe ERC20 operation(s)

*Instances (10)*:
```solidity
File: governance/contracts/bridges/FxERC20ChildTunnel.sol

79:         bool success = IERC20(childToken).transfer(to, amount);

102:         bool success = IERC20(childToken).transferFrom(msg.sender, address(this), amount);

```

```solidity
File: governance/contracts/bridges/FxERC20RootTunnel.sol

98:         bool success = IERC20(rootToken).transferFrom(msg.sender, address(this), amount);

```

```solidity
File: governance/contracts/veOLAS.sol

415:             IERC20(token).transferFrom(msg.sender, address(this), amount);

656:         IERC20(token).transfer(msg.sender, amount);

```

```solidity
File: lockbox-solana/solidity/liquidity_lockbox.sol

167:         SplToken.transfer(

251:         SplToken.transfer(

```

```solidity
File: tokenomics/contracts/Depository.sol

390:         IToken(olas).transfer(msg.sender, payout);

```

```solidity
File: tokenomics/contracts/Treasury.sol

235:         bool success = IToken(token).transferFrom(account, address(this), tokenAmount);

362:                 success = IToken(token).transfer(to, tokenAmount);

```
