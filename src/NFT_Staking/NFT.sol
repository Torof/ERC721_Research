// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.21;

/// @title NFT contract with merkletree whitelist, royalties for sales, and ERC20 reward for custodial NFT staking
/// @author torof
/// @notice 
/// @dev 

import {Staking} from "./Staking.sol";
import {ERC2981} from "@openzeppelin/contracts/token/common/ERC2981.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import {Ownable2Step} from "@openzeppelin/contracts/access/Ownable2Step.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract NFT is ERC721, ERC2981, Ownable2Step {
    bytes private _root;
    bool public presale;

    uint256 constant public MINT_PRICE = 1 ether;
    uint256 constant public WHITELIST_MINT_PRICE = 0.5 ether;


    uint8 public constant MAX_SUPPLY = 20;
    uint8 private _totalSupply;
    Staking private immutable _stakingContract;

    constructor(string memory name, string memory symbol) ERC721(name, symbol){
        _stakingContract = new Staking();
        _root = root_;
        presale = true;
    }

    function supportsInterface(bytes4 interfaceId) public override(ERC2981, ERC721) pure returns (bool) {
        return interfaceId == type(IERC721).interfaceId ||
        interfaceId == type(IERC165).interfaceId;
    }

    function closePresale() external onlyOwner() {
        require(presale);
        presale = false;
    }

    function mint() external payable {
        require(totalSupply() < MAX_SUPPLY);
    }

    function whitelistMint() external payable {
        require(presale);
    }

    function staking() external view returns (address stakingAddress_){
        stakingAddress_ = address(_stakingContract);
    }

    function withrawFunds() external onlyOwner() {}
}
