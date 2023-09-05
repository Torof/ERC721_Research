// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.21;

/// @title NFT contract with merkletree whitelist, royalties for sales, and ERC20 reward for custodial NFT staking
/// @author torof
/// @notice This contract is a part of the NFT_Staking project.

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

    //add 2.5% royalty for the artist
    // uint256 private constant _royalty = 250;
    // uint256 private constant _royaltyBase = 10000;

    uint8 public constant MAX_SUPPLY = 20;
    uint8 private _totalSupply;
    Staking private immutable _stakingContract;

    event Withdrawal(uint256 amount);

    constructor(bytes memory root_, string memory name, string memory symbol) ERC721(name, symbol){
        _stakingContract = new Staking();
        _root = root_;
        presale = true;
    }

    // function royaltyInfo(uint256, uint256 salePrice) external view override returns (address receiver, uint256 royaltyAmount) {
    //     //TODO add royalty
    //     // receiver = owner();
    //     // royaltyAmount = (salePrice * _royalty) / _royaltyBase;
    // }

    function supportsInterface(bytes4 interfaceId) public override(ERC2981, ERC721) pure returns (bool) {
        return interfaceId == type(IERC721).interfaceId ||
        interfaceId == type(IERC165).interfaceId;
    }

    function closePresale() external onlyOwner() {
        require(presale, "presale already closed");
        presale = false;
    }

    function mint() external payable {
        require(msg.value == MINT_PRICE, "price not right");
        require(!presale, "presale not closed");
        require(_totalSupply < MAX_SUPPLY, "max cap reached");
        _totalSupply++;
        _safeMint(msg.sender, _totalSupply);
    }

    function whitelistMint() external payable {
        //TODO merkleroot verify
        require(msg.value == WHITELIST_MINT_PRICE, "price not right");
        require(presale, "presale is closed");
        require(_totalSupply < MAX_SUPPLY, "max cap reached");
        _totalSupply++;
        _safeMint(msg.sender, _totalSupply);
    }

    function stakingContract() external view returns (address stakingAddress_){
        stakingAddress_ = address(_stakingContract);
    }

    
    function withrawFunds() external onlyOwner() {
        uint256 amount = address(this).balance;
        payable(owner()).transfer(amount);
        emit Withdrawal(amount);
    }

    function totalSupply() public view returns(uint256){
        return _totalSupply;
    }
}
