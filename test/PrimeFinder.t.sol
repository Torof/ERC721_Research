// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.21;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/NFT_Enumerable/NFTEnumerable.sol";
import "../src/NFT_Enumerable/PrimeNumberFinder.sol";

contract PrimeFinder is Test {
    
    NFTEnumerable public nftEnumerable;
    PrimeNumberFinder public primeNumberFinder;

    address public contractsOwner = vm.addr(100);
    address public user1 = vm.addr(200);
    address public user2 = vm.addr(300);
    

    function setUp() public {
        nftEnumerable = new NFTEnumerable();
        primeNumberFinder = new PrimeNumberFinder(address(nftEnumerable));
    }

    function mintANumber(address _address, uint256 amount) public {
        vm.startPrank(_address);
        for (uint256 i = 0; i < amount; i++) {
            nftEnumerable.mint();
        }
    }

    function testPrimeNumberFinder() public {
        mintANumber(user1, 10);
        mintANumber(user2, 10);
        assertEq(primeNumberFinder.primeNumberOwned(user1), 4, "user1 should have 4 prime numbers");
        assertEq(primeNumberFinder.primeNumberOwned(user2), 4, "user2 should have 4 prime numbers");
    }

    function testRevertNFTEnumerableMaxSupplyReached() public {
        mintANumber(user1, 20);

        //assert totalSupply is 20
        assertEq(nftEnumerable.totalSupply(), 20, "totalSupply should be 20");

        //mint one more & should revert
        vm.startPrank(user1);
        vm.expectRevert(abi.encodePacked("NFTEnumerable: tokenId exceeds max supply"));
        nftEnumerable.mint();
    }

}