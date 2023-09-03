// SPDX-License-Identifier: MIT

pragma solidity 0.8.21;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract RewardToken is ERC20("RewardToken","rTKN") {
    /// @notice
    address public immutable stakingContract;

    constructor() {
        stakingContract = msg.sender;
    }

    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    /// @param Documents a parameter just like in doxygen (must be followed by parameter name)
    /// @return Documents the return variables of a contract’s function state variable
    /// @inheritdoc	Copies all missing tags from the base function (must be followed by the contract name)
    function mint(address to, uint256 amount) external {
        require(msg.sender == stakingContract, "only staking contract can mint");
        _mint(to, amount);
    }
}