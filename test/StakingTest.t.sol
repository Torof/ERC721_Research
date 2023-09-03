// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.21;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/NFT_Staking/NFT.sol";
import "../src/NFT_Staking/Staking.sol";
import "../src/NFT_Staking/RewardToken.sol";

contract StakingTest is Test {
    NFT public nft;
    Staking public staking;
    RewardToken public token;

    address public contractsOwner = vm.addr(10);

    function setUp() public {
        nft = new NFT("StakeMe", "STKMI");
        staking = Staking(nft.staking());
        token = RewardToken(staking.token());
    }

    function testBase() public {
        assertEq(nft.name(), "StakeMe", "should return StakeMe");
        assertEq(nft.symbol(), "STKMI", "should return STKMI");
        assertEq(address(staking), nft.staking(), "staking contract should have address returned by NFT contract");
        assertEq(address(token), staking.token(), "ERC20 token contract should have address returned by STAKING contract");
    }

    
}