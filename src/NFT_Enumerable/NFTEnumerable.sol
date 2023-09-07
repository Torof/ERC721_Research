// SPDX-License-Identifier: MIT

pragma solidity 0.8.21;

//import openzeppelin ERC721Enumerable


import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";


contract NFTEnumerable is ERC721Enumerable {
    uint16 public constant MAX_NFT_SUPPLY = 20;
    uint16 private _totalSupply;

    constructor() ERC721("NFTEnumerable", "NFTEnumerable") {}

    function mint() public {
        require(totalSupply() < MAX_NFT_SUPPLY, "NFTEnumerable: tokenId exceeds max supply");
        _totalSupply++;
        _safeMint(msg.sender, _totalSupply);
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }
}


