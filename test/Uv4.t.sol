// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { PRBTest } from "@prb/test/PRBTest.sol";
import { console2 } from "forge-std/console2.sol";
import { StdCheats } from "forge-std/StdCheats.sol";

import { Hooks as HooksLib } from "v4-core/libraries/Hooks.sol";
import { Currency } from "v4-core/libraries/CurrencyLibrary.sol";
import { FixedPoint96 } from "v4-core/libraries/FixedPoint96.sol";
import { TickMath } from "v4-core/libraries/TickMath.sol";
import { IHooks, BalanceDelta } from "v4-core/interfaces/IHooks.sol";
import { IPoolManager } from "v4-core/interfaces/IPoolManager.sol";
import { PoolManager } from "v4-core/PoolManager.sol";

contract Hooks is IHooks {
    function beforeInitialize(
        address sender,
        IPoolManager.PoolKey calldata key,
        uint160 sqrtPriceX96
    )
        external
        returns (bytes4)
    {
        return this.beforeInitialize.selector;
    }

    function afterInitialize(
        address sender,
        IPoolManager.PoolKey calldata key,
        uint160 sqrtPriceX96,
        int24 tick
    )
        external
        returns (bytes4)
    {
        return this.afterInitialize.selector;
    }

    function beforeModifyPosition(
        address sender,
        IPoolManager.PoolKey calldata key,
        IPoolManager.ModifyPositionParams calldata params
    )
        external
        returns (bytes4)
    {
        return this.beforeModifyPosition.selector;
    }

    function afterModifyPosition(
        address sender,
        IPoolManager.PoolKey calldata key,
        IPoolManager.ModifyPositionParams calldata params,
        BalanceDelta delta
    )
        external
        returns (bytes4)
    {
        return this.afterModifyPosition.selector;
    }

    function beforeSwap(
        address sender,
        IPoolManager.PoolKey calldata key,
        IPoolManager.SwapParams calldata params
    )
        external
        returns (bytes4)
    {
        return this.beforeSwap.selector;
    }

    function afterSwap(
        address sender,
        IPoolManager.PoolKey calldata key,
        IPoolManager.SwapParams calldata params,
        BalanceDelta delta
    )
        external
        returns (bytes4)
    {
        return this.afterSwap.selector;
    }

    function beforeDonate(
        address sender,
        IPoolManager.PoolKey calldata key,
        uint256 amount0,
        uint256 amount1
    )
        external
        returns (bytes4)
    {
        return this.beforeDonate.selector;
    }

    function afterDonate(
        address sender,
        IPoolManager.PoolKey calldata key,
        uint256 amount0,
        uint256 amount1
    )
        external
        returns (bytes4)
    {
        return this.afterDonate.selector;
    }
}

/// @dev If this is your first time with Forge, read this tutorial in the Foundry Book:
/// https://book.getfoundry.sh/forge/writing-tests
contract Uv4Test is PRBTest, StdCheats {
    PoolManager internal poolManager;
    Hooks internal hooks;

    Currency internal constant WETH = Currency.wrap(address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2));
    Currency internal constant UNI = Currency.wrap(address(0x1f9840a85d5aF5bf1D1762F925BDADdC4201F984));
    /// @dev A function invoked before each test case is run.

    function setUp() public virtual {
        // Instantiate the contract-under-test.
        poolManager = new PoolManager(1 ether);
        vm.etch(0x9000000000000000000000000000000000000000, type(Hooks).runtimeCode);
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
            hooks: hooks
        });

        poolManager.initialize(poolKey, TickMath.getSqrtRatioAtTick(0));
    }
}
