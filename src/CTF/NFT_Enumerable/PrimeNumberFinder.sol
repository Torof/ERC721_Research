// SPDX-License-Identifier: MIT

pragma solidity 0.8.21;

//import openzeppelin IERC721Enumerable
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";

contract PrimeNumberFinder {
    address public immutable nftEnumerableAddress;

    constructor(address _nftEnumerableAddress) {
        nftEnumerableAddress = _nftEnumerableAddress;
    }

    function primeNumberOwned(address _address) public view returns (uint256) {
        uint256 _primeNumberOwned;
        uint256 ownerSupply = IERC721Enumerable(nftEnumerableAddress).balanceOf(_address);
        for (uint256 i = 0; i < ownerSupply; i++) {
            uint256 tokenId = IERC721Enumerable(nftEnumerableAddress).tokenOfOwnerByIndex(_address, i);
            if (_isPrime(tokenId) && IERC721Enumerable(nftEnumerableAddress).ownerOf(tokenId) == _address) {
                _primeNumberOwned++;
            }
        }
        return _primeNumberOwned;
    }

    function _isPrime(uint256 _number) internal pure returns (bool) {
        if (_number <= 3) {
            return _number > 1;
        } else if (_number % 2 == 0 || _number % 3 == 0) {
            return false;
        } else {
            uint256 i = 5;
            while (i * i <= _number) {
                if (_number % i == 0 || _number % (i + 2) == 0) {
                    return false;
                }
                i += 6;
            }
            return true;
        }
    }

}