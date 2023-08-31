// SPDX-License-Identifier: MIT

pragma solidity 0.8.21;

import {IERC721Receiver} from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

contract Staking is IERC721Receiver{
    address private immutable _nftContractAddress;

    constructor() {
        nftAddress = msg.sender;
    }

    function onERC721Received(address operator,address from,uint tokenId,bytes memory data) external returns(bytes4){
        return IERC721Receiver.onERC721Received.selector;
    }

    function nftContractAddress() public view returns(address contractAddress){
        contractAddress = _nftContractAddress;
    }
}