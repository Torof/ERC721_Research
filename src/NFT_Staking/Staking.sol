// SPDX-License-Identifier: MIT

pragma solidity 0.8.21;

/// @title A title that should describe the contract/interface
/// @author The name of the author
/// @notice Explain to an end user what this does
/// @dev Explain to a developer any extra details

import {IERC721Receiver} from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import {IERC165} from "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import {RewardToken} from "./RewardToken.sol";

contract Staking is IERC721Receiver, IERC165, ReentrancyGuard {

    /// @notice address of the NFT contract linked to this staking protocol
    address private immutable _nftContractAddress;

    /// @notice address of the ERC20 token reward linked to this staking protocol
    RewardToken private immutable _rewardToken;

    /// @notice stores the owner of a token of tokenId of the registered NFT contract
    mapping(uint256 => address) _ownerOf;

    /// @notice Staking information of a user
    mapping(address => StakingMetrics) private _userStake;

    struct StakingMetrics {
        ///The number of NFT staked by the user
        uint8 stakedNum;

        ///Last time reward was claimed
        uint64 lastClaim;

        /// a list of tokenIds by index. Use stakedNum to enumerate all tokenIds in staking.
        mapping(uint8 => uint256) tokenIds;
    }

    /// emits a {ReceivedandStaked} event when an NFT is staked
    event ReceivedandStaked(address operator,address indexed from,uint indexed tokenId,bytes data);
    
    /// emits a {UnstakedAndSent} event when an NFT is unstaked
    event UnstakedAndSent();

    /// emits a {Claimed} event when a user claims their reward
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
    /// @param operator EOAs or contracts that are approved to make the transfer
    /// @param from the address of the user staking the NFT
    /// @param tokenId the tokenId to stake
    /// @param data additional data with no specified format
    /// @return bytes4 returns the IERC721.onERC721Received selector
    /// emits a {ReceivedandStaked} event when an NFT is staked
    function onERC721Received(address operator,address from,uint tokenId,bytes memory data) external returns(bytes4){
        require(msg.sender == nft(), "Only registered address");
        _stake(tokenId, from);
        emit ReceivedandStaked(operator, from, tokenId, data);
        return IERC721Receiver.onERC721Received.selector;
    }

    /// @notice gives the address of the NFT contract tied to this staking protocol
    /// @return contractAddress of NFT contract
    function nft() public view returns(address contractAddress){
        contractAddress = _nftContractAddress;
    }

    /**
    *@notice used to calculate the reward for a user. It generates 10 ERC20 tokens per NFT staked per 24 hours and can be claimed at any moment.
    */
    function _calculateReward(address user) internal view returns(uint256 reward){
        uint256 generationPerSecond = uint256(10**18 * 10) / uint256(86400);
        uint256 timePassed = block.timestamp - _userStake[user].lastClaim;
        //each NFT staked generates 10 tokens per day
        reward = _userStake[user].stakedNum * generationPerSecond * timePassed;
    }

    /**
    *@notice used to stake an NFT
    *@param tokenId the tokenId to stake
    *@param from the address of the user staking the NFT
    */
    function _stake(uint256 tokenId, address from) private nonReentrant() {
        _ownerOf[tokenId] = from; //register owner of tokenId for custody by the contract
        StakingMetrics storage metrics = _userStake[from];
        //make sure the user has claimed their reward before staking
        if(metrics.stakedNum != 0) _claim(from);
        metrics.tokenIds[metrics.stakedNum] = tokenId; //starts at 0
        metrics.stakedNum++;
        metrics.lastClaim = uint64(block.timestamp);
    }

    /**
    *@notice used to claim the reward for a user at any given time without unstaking
    */
    function claim() public {
        require(_userStake[msg.sender].stakedNum > 0, "No NFT staked");
        _claim(msg.sender);
    }

    /**
    *@dev the resetting of lastClaim is done in each use case separately
    *@notice used to claim the reward for a user at any given time without unstaking
    *@param user the user to claim the reward for
    */
    function _claim(address user) internal {
        uint256 reward = _calculateReward(user);
        _rewardToken.mint(user, reward);
        emit Claimed();
    }

    /**
    *@dev last claim time MUST be modified after the claim
    *@notice used to unstake an NFT
    *@param index the index at which the tokenId is stored
    */
    function unStake(uint8 index) external nonReentrant() {
        uint256 tokenId = _userStake[msg.sender].tokenIds[index];
        uint8 stakedNftNum = _userStake[msg.sender].stakedNum;

        //only check needed
        require(index < stakedNftNum, "Index out of bounds");

        //revoke custody of the NFT by the contract
        _ownerOf[tokenId] = address(0);

        //swap the tokenId to unstake with the last tokenId in the list
        _userStake[msg.sender].tokenIds[index] = _userStake[msg.sender].tokenIds[stakedNftNum];
        _userStake[msg.sender].tokenIds[stakedNftNum] = 0;

        //update stakedNum
        _userStake[msg.sender].stakedNum--;

        //transfer the NFT back to the user
        (bool success,) = _nftContractAddress.call(abi.encodeWithSignature("safeTransferFrom(address,address,uint256)", address(this), msg.sender, tokenId));
        require(success, "Transfer failed");
        
        _claim(msg.sender);
        if(_userStake[msg.sender].stakedNum == 0)_userStake[msg.sender].lastClaim = 0;
        else _userStake[msg.sender].lastClaim = uint64(block.timestamp);
        emit UnstakedAndSent();
    }

    /**
    *@notice used to check the address of the ERC20 token reward
    *@return rewardToken the address of the ERC20 token reward
    */
    function tokenContract() public view returns (address rewardToken) {
        rewardToken = address(_rewardToken);
    }

    /**
    *@notice used to check the amount of rewards claimable by a user
    *@return rewards the amount of rewards claimable by a user
    */
    function claimable() public view returns (uint256 rewards){
        rewards = _calculateReward(msg.sender);
    }

    /**
    *@notice used to check the number of NFTs staked by a user
    *@param user the user to call for verification of possessions
    *@return stakedNum the number of NFTs staked by the user
    */
    function userStake(address user) external view returns (uint8 stakedNum, uint64 lastClaim){
        stakedNum = _userStake[user].stakedNum;
        lastClaim = _userStake[user].lastClaim;
    }

    /**
    *@notice used to check what tokenIds are staked by a user
    *@dev to use with stakedNftNum for enumeration.
    *@dev WARNING index 0 is empty
    *@param _index the index at which the tokenId is stored
    *@param _user the user to call for verification of possessions
    *@return tokenId the tokenId at the index
     */
    function tokenIdByIndex(uint8 _index, address _user) external view returns(uint){
        require(_index < _userStake[_user].stakedNum, "Index out of bounds");
        return _userStake[_user].tokenIds[_index];
    }

    /**
    *@notice used to check the owner of a tokenId
    *@param tokenId the tokenId to check
    *@return owner the owner of the tokenId
     */
    function ownerOf(uint256 tokenId) external view returns(address){
        return _ownerOf[tokenId];
    }
}