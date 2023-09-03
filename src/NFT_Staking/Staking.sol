// SPDX-License-Identifier: MIT

pragma solidity 0.8.21;

/// @title A title that should describe the contract/interface
/// @author The name of the author
/// @notice Explain to an end user what this does
/// @dev Explain to a developer any extra details

import {IERC721Receiver} from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import {IERC165} from "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import {RewardToken} from "./RewardToken.sol";

contract Staking is IERC721Receiver, IERC165 {

    /// @notice Explain to an end user what this does
    address private immutable _nftContractAddress;

    /// @notice Explain to an end user what this does
    RewardToken private immutable _rewardToken;

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

    event ReceivedandStaked(address operator,address indexed from,uint indexed tokenId,bytes data);
    event UnstakedAndSent();
    event Claimed();

    constructor() {
        _nftContractAddress = msg.sender;
        _rewardToken = new RewardToken();
    }

    /// @notice verifies if an interface is supported. see {IERC165}
    /// @param interfaceId the bytes4 selector of an interfaceId
    /// @return bool true if the interface is supported
    function supportsInterface(bytes4 interfaceId) external pure returns (bool) {
        return interfaceId == type(IERC721Receiver).interfaceId ||
        interfaceId == type(IERC165).interfaceId;
    }

    /// @notice allows to handle reception of ERC721 tokens
    /// @dev MUST only accept registered collection through safeTranferFrom
    /// @param operator bla
    /// @param from bla
    /// @param tokenId bla
    /// @param data bla
    /// @return bytes4 returns the IERC721.onERC721Received selector
    function onERC721Received(address operator,address from,uint tokenId,bytes memory data) external returns(bytes4){
        require(operator == nft(), "Only registered address");
        _stake(tokenId, from);
        emit ReceivedandStaked(operator, from, tokenId, data);
        return IERC721Receiver.onERC721Received.selector;
    }

    /// @notice gives the address of the NFT contract tied to this staking protocol
    /// @return contractAddress of NFT contract
    function nft() public view returns(address contractAddress){
        contractAddress = _nftContractAddress;
    }

    function _calculateReward() internal returns(uint256 reward){}

    function _stake(uint256 tokenId, address from) private {}

    function claim() public {}

    function unStake(uint8 index) external {}

    /// @notice Explain to an end user what this does
    /// @return rewardToken address of the ERC20 token reward
    function token() public view returns (address rewardToken) {
        rewardToken = address(_rewardToken);
    }

    function claimable() public view returns (uint256 rewards){}
}