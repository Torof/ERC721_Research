// SPDX-License-Identifier: MIT

pragma solidity 0.8.21;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract RewardToken is ERC20("RewardToken","rTKN") {
    /// @notice
    address public immutable stakingContract;

    constructor() {
        stakingContract = msg.sender;
    }

    function mint(address to, uint256 amount) external {
        require(msg.sender == stakingContract, "only staking contract can mint");
        _mint(to, amount);
    }
}