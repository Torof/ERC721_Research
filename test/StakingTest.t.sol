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

    function setup() public {
        nft = new NFT("StakeMe", "STKMI");
        staking = nft.staking();
        token = staking.token();
    }
}