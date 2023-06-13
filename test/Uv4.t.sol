// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { PRBTest } from "@prb/test/PRBTest.sol";
import { console2 } from "forge-std/console2.sol";
import { StdCheats } from "forge-std/StdCheats.sol";

import { FixedPoint96 } from "v4-core/libraries/FixedPoint96.sol";
import { IHooks } from "v4-core/interfaces/IHooks.sol";
import { IPoolManager } from "v4-core/interfaces/IPoolManager.sol";
import { PoolManager } from "v4-core/PoolManager.sol";

contract Hooks is IHooks { }

/// @dev If this is your first time with Forge, read this tutorial in the Foundry Book:
/// https://book.getfoundry.sh/forge/writing-tests
contract Uv4Test is PRBTest, StdCheats {
    PoolManager internal poolManager;
    Hooks internal hooks;

    address internal constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address internal constant UNI = 0x1f9840a85d5aF5bf1D1762F925BDADdC4201F984;
    /// @dev A function invoked before each test case is run.

    function setUp() public virtual {
        // Instantiate the contract-under-test.
        poolManager = new PoolManager(1 ether);
        vm.etch(0x9000000000000000000000000000000000000000, Hooks.code);
    }

    /// @dev Basic test. Run it with `forge test -vvv` to see the console log.
    function test_Initialize() external {
        IPoolManager.PoolKey memory poolKey = IPoolManager.PoolKey({
            /// @notice The lower currency of the pool, sorted numerically
            currency0: WETH,
            /// @notice The higher currency of the pool, sorted numerically
            currency1: UNI,
            /// @notice The pool swap fee, capped at 1_000_000. The upper 4 bits determine if the hook sets any fees.
            fee: 3000,
            /// @notice Ticks that involve positions must be a multiple of tick spacing
            tickSpacing: 60,
            /// @notice The hooks of the pool
            hooks: 0x9000000000000000000000000000000000000000
        });

        poolManager.initialize(poolKey, FixedPoint96.Q96);
    }

    // /// @dev Fuzz test that provides random values for an unsigned integer, but which rejects zero as an input.
    // /// If you need more sophisticated input validation, you should use the `bound` utility instead.
    // /// See https://twitter.com/PaulRBerg/status/1622558791685242880
    // function testFuzz_Example(uint256 x) external {
    //     vm.assume(x != 0); // or x = bound(x, 1, 100)
    //     assertEq(foo.id(x), x, "value mismatch");
    // }

    // /// @dev Fork test that runs against an Ethereum Mainnet fork. For this to work, you need to set
    // `API_KEY_ALCHEMY`
    // /// in your environment You can get an API key for free at https://alchemy.com.
    // function testFork_Example() external {
    //     // Silently pass this test if there is no API key.
    //     string memory alchemyApiKey = vm.envOr("API_KEY_ALCHEMY", string(""));
    //     if (bytes(alchemyApiKey).length == 0) {
    //         return;
    //     }

    //     // Otherwise, run the test against the mainnet fork.
    //     vm.createSelectFork({ urlOrAlias: "mainnet", blockNumber: 16_428_000 });
    //     address usdc = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    //     address holder = 0x7713974908Be4BEd47172370115e8b1219F4A5f0;
    //     uint256 actualBalance = IERC20(usdc).balanceOf(holder);
    //     uint256 expectedBalance = 196_307_713.810457e6;
    //     assertEq(actualBalance, expectedBalance);
    // }
}
