// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.21;

/// @title NFT contract with merkletree whitelist, royalties for sales, and ERC20 reward for custodial NFT staking
/// @author torof
/// @notice 
/// @dev 

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {ERC2981} from "@openzeppelin/contracts/token/common/ERC2981.sol";
import {Ownable2Step} from "@openzeppelin/contracts/access/Ownable2Step.sol";
import {Staking} from "./Staking.sol";

contract NFT is ERC721, ERC2981, Ownable2Step {
    uint8 public constant MAX_SUPPLY = 20;
    uint8 private _totalSupply;
    address private immutable _stakingAddress;

    constructor(string memory name, string memory symbol) ERC721(name, symbol){
        _stakingAddress = new Staking();
    }

    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    /// @param Documents a parameter just like in doxygen (must be followed by parameter name)
    /// @return Documents the return variables of a contract’s function state variable
    /// @inheritdoc	Copies all missing tags from the base function (must be followed by the contract name)
    function supportsInterface(bytes4 interfaceId) external pure returns (bool) {
        interfaceId == type(IERC721).interfaceId ||
        type(IER165).interfaceId;
    }

    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    /// @param Documents a parameter just like in doxygen (must be followed by parameter name)
    /// @return Documents the return variables of a contract’s function state variable
    /// @inheritdoc	Copies all missing tags from the base function (must be followed by the contract name)
    function mint() external payable {}

    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    /// @param Documents a parameter just like in doxygen (must be followed by parameter name)
    /// @return Documents the return variables of a contract’s function state variable
    /// @inheritdoc	Copies all missing tags from the base function (must be followed by the contract name)
    function staking() external view returns (address stakingAddress_){
        stakingAddress_ = _stakingAddress;
    }

    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    /// @param Documents a parameter just like in doxygen (must be followed by parameter name)
    /// @return Documents the return variables of a contract’s function state variable
    /// @inheritdoc	Copies all missing tags from the base function (must be followed by the contract name)
    function withrawFunds() external onlyOwner() {}
}
