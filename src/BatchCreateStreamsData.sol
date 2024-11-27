// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.22;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { ud60x18 } from "@prb/math/src/UD60x18.sol";
import { ISablierV2LockupLinear } from "@sablier/v2-core/src/interfaces/ISablierV2LockupLinear.sol";
import { Broker, LockupLinear } from "@sablier/v2-core/src/types/DataTypes.sol";
import { ISablierV2Batch } from "@sablier/v2-periphery/src/interfaces/ISablierV2Batch.sol";
import { Batch } from "@sablier/v2-periphery/src/types/DataTypes.sol";
import { Test } from "forge-std/src/Test.sol";

// Run `bun run test -vvvv` and copy the return data.
contract BatchCreateStreamsData is Test {
    IERC20 public constant FJO = IERC20(0x69457A1C9Ec492419344DA01Daf0DF0e0369d5D0);
    ISablierV2LockupLinear public constant LOCKUP_LINEAR =
        ISablierV2LockupLinear(0xAFb979d9afAd1aD27C5eFf4E27226E3AB9e5dCC9);
    ISablierV2Batch public constant SABLIER_BATCH = ISablierV2Batch(0xEa07DdBBeA804E7fe66b958329F8Fa5cDA95Bd55);
    address public constant SENDER = 0xeC83F8F9D37cAf8ffC47d1BdaF74e36F3bA7Eb11;

    address[] public recipients = [
        0x8950D9117C136B29A9b1aE8cd38DB72226404243,
        0xC4154B854249Ae979A48511A1779f40847884ada,
        0x5Daef2E38b446920A5Bc2D16A3D33AA36d271da9,
        0x820803ba68e40B3d770496fC9EF2F1d33C7d2EE3,
        0x78fd06A971d8bd1CcF3BA2E16CD2D5EA451933E2,
        0x103CDE1a2F5eD7ce509a178F9cFb9E56553dc45b,
        0x0174998c7e8fa81D45dE706a1c911497921a8122,
        0x12aE1783deC1aF9dF875487Bec51EE980645B942,
        0x08d0461103687aefa226EfD1F40DB72Ef0293822,
        0x8a2E1aAE015909cdc3dFE31D8AdbBb29f27f570f,
        0x153879908F6837A4c4f51E368CDd1c6c0c6Fc12B
    ];
    uint128[] public intactAmount = [
        253_060_000_000_000_000_000,
        5_985_040_000_000_000_000_000,
        44_573_510_000_000_000_000_000,
        1_544_990_000_000_000_000_000,
        1_479_010_000_000_000_000_000,
        120_531_451_124_283_973_296_690,
        1_183_210_000_000_000_000_000,
        21_237_660_000_000_000_000_000,
        10_083_739_428_958_460_292_306,
        1_104_960_000_000_000_000_000,
        18_546_309_574_497_257_786_795
    ];

    function test_GetTransactionData() external view returns (bytes memory txData) {
        // Check that the lengths of the recipients and intactAmount arrays are equal.
        assertEq(recipients.length, intactAmount.length);

        Batch.CreateWithRange[] memory batchParams = new Batch.CreateWithRange[](recipients.length);
        for (uint256 i; i < recipients.length; ++i) {
            batchParams[i].sender = SENDER;
            batchParams[i].recipient = recipients[i];
            batchParams[i].totalAmount = intactAmount[i];
            batchParams[i].cancelable = true;
            batchParams[i].transferable = true;
            batchParams[i].range = LockupLinear.Range({
                start: 1_732_716_349, // Current timestamp
                cliff: 1_732_716_349, // No cliff
                end: 1_732_716_349 + 31_536_000 // 1 year
             });
            batchParams[i].broker = Broker(address(0), ud60x18(0));
        }

        // SABLIER_BATCH.createWithRange({ lockupLinear: LOCKUP_LINEAR, asset: FJO, batch: batchParams });

        return abi.encodeCall(ISablierV2Batch.createWithRange, (LOCKUP_LINEAR, FJO, batchParams));
    }
}
