// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.21;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {ERC2981} from "@openzeppelin/contracts/token/common/ERC2981.sol";

contract NFT is ERC721, ERC2981 {
    uint8 public constant MAX_SUPPLY = 20;

    constructor(string memory name, string memory symbol) ERC721(name, symbol){}

    function mint() external {}
}
