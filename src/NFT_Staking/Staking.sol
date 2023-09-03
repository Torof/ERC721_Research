// SPDX-License-Identifier: MIT

pragma solidity 0.8.21;

/// @title A title that should describe the contract/interface
/// @author The name of the author
/// @notice Explain to an end user what this does
/// @dev Explain to a developer any extra details

import {IERC721Receiver} from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import {IERC165} from "@openzepplin/contracts/utils/introspection/IERC165.sol";
import {RewardToken} from "./RewardToken.sol";

contract Staking is IERC721Receiver, IERC165 {

    /// @notice Explain to an end user what this does
    address private immutable _nftContractAddress;

    /// @notice Explain to an end user what this does
    address private immutable _rewardTokenAddress;

    /// @notice Explain to an end user what this does
    mapping(uint256 => address) _ownerOf;

    /// @notice Staking information of a user
    mapping(address => StakingMetrics) public userStake;

    struct StakingMetrics {
        ///The number of NFT staked by the user
        uint8 stakedNum;

        ///Last time reward was claimed
        uint64 lastClaim;

        /// a list of tokenIds by index. Use stakedNum to enumerate all tokenIds in staking.
        mapping(uint8 => uint256) tokenIds;
    }

    constructor() {
        _nftContractAddress = msg.sender;
        _rewardTokenAddress = new RewardToken();
    }

    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    /// @param Documents a parameter just like in doxygen (must be followed by parameter name)
    /// @return Documents the return variables of a contract’s function state variable
    /// @inheritdoc	Copies all missing tags from the base function (must be followed by the contract name)
    function supportsInterface(bytes4 interfaceId) external pure returns (bool) {
        interfaceId == type(IERC721Receiver).interfaceId ||
        type(IER165).interfaceId;
    }

    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    /// @param Documents a parameter just like in doxygen (must be followed by parameter name)
    /// @return Documents the return variables of a contract’s function state variable
    /// @inheritdoc	Copies all missing tags from the base function (must be followed by the contract name)
    function onERC721Received(address operator,address from,uint tokenId,bytes memory data) external returns(bytes4){
        _stake(tokenId, from);
        return IERC721Receiver.onERC721Received.selector;
    }

    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    /// @param Documents a parameter just like in doxygen (must be followed by parameter name)
    /// @return Documents the return variables of a contract’s function state variable
    /// @inheritdoc	Copies all missing tags from the base function (must be followed by the contract name)
    function nftContractAddress() public view returns(address contractAddress){
        contractAddress = _nftContractAddress;
    }

    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    /// @param Documents a parameter just like in doxygen (must be followed by parameter name)
    /// @return Documents the return variables of a contract’s function state variable
    /// @inheritdoc	Copies all missing tags from the base function (must be followed by the contract name)
    function _calculateReward() internal returns(uint256 reward){}

    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    /// @param Documents a parameter just like in doxygen (must be followed by parameter name)
    /// @return Documents the return variables of a contract’s function state variable
    /// @inheritdoc	Copies all missing tags from the base function (must be followed by the contract name)
    function _stake(uint256 tokenId, address from) private {}

    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    /// @param Documents a parameter just like in doxygen (must be followed by parameter name)
    /// @return Documents the return variables of a contract’s function state variable
    /// @inheritdoc	Copies all missing tags from the base function (must be followed by the contract name)
    function claim() public {}

    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    /// @param Documents a parameter just like in doxygen (must be followed by parameter name)
    /// @return Documents the return variables of a contract’s function state variable
    /// @inheritdoc	Copies all missing tags from the base function (must be followed by the contract name)
    function unStake(uint8 index) external {}

    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    /// @param Documents a parameter just like in doxygen (must be followed by parameter name)
    /// @return Documents the return variables of a contract’s function state variable
    /// @inheritdoc	Copies all missing tags from the base function (must be followed by the contract name)
    function token() public view returns (address rewardToken) {
        rewardToken = _rewardTokenAddress;
    }

    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    /// @param Documents a parameter just like in doxygen (must be followed by parameter name)
    /// @return Documents the return variables of a contract’s function state variable
    /// @inheritdoc	Copies all missing tags from the base function (must be followed by the contract name)
    function claimable() public view returns (uint256 rewards){}
}