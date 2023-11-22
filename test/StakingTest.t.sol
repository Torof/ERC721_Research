// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.21;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/NFT_Staking/NFT.sol";
import "../src/NFT_Staking/Staking.sol";
import "../src/NFT_Staking/RewardToken.sol";

contract StakingTest is Test {
    bytes4 public IERC1155_i = 0x9c7d30a0;
    bytes4 public IERC721_i = 0x80ac58cd;
    bytes4 public IERC721Receiver_i = 0x73b5f132;
    bytes4 public IERC1155Receiver_i = 0xf23a6e61;
    bytes4 public IERC165_i = 0x01ffc9a7;

    bytes public emptyHelper;
    NFT public nft;
    Staking public staking;
    RewardToken public token;

    address public contractsOwner = vm.addr(10);
    address public wh_addr_1 = vm.addr(101);
    address public wh_addr_2 = vm.addr(102);
    address public n_wh_addr_1 = vm.addr(103);
    

    function setUp() public {
        vm.startPrank(contractsOwner);
        nft = new NFT(emptyHelper, "StakeMe", "STKMI");
        staking = Staking(nft.stakingContract());
        token = RewardToken(staking.tokenContract());

        vm.deal(wh_addr_1, 5 ether);
        vm.deal(wh_addr_2, 5 ether);
        vm.deal(n_wh_addr_1, 5 ether);
    }

    function testBase() public {
        assertEq(nft.name(), "StakeMe", "should return StakeMe");
        assertEq(nft.symbol(), "STKMI", "should return STKMI");
        assertEq(address(staking), nft.stakingContract(), "staking contract should have address returned by NFT contract");
        assertEq(address(token), staking.tokenContract(), "ERC20 token contract should have address returned by STAKING contract");
    }
    
    //SUCCESS supports interface 
    function testSupportsInterface(bytes4 wrongByte4) public {
        assertTrue(nft.supportsInterface(IERC721_i));
        assertTrue(nft.supportsInterface(IERC165_i));
        assertFalse(nft.supportsInterface(wrongByte4));

        // assertTrue(staking.supportsInterface(IERC721Receiver_i));
        assertTrue(staking.supportsInterface(IERC165_i));
        assertFalse(staking.supportsInterface(wrongByte4));
    }

    //REVERT caller is not staking contract
    function testRevertMintERC20NotStakingContract() public {
        vm.expectRevert(abi.encodePacked("only staking contract can mint"));
        token.mint(wh_addr_1, 10 * 10 ** 18);
    }

    //SUCCESS whitelistmint
    function testWhitelistMint() public {
        assertTrue(nft.presale(), "sale is not in presale");
        vm.prank(wh_addr_1);
        nft.whitelistMint{value: 0.5 ether}();

        assertEq(nft.totalSupply(), 1);
    }

    //SUCCESS close presale
    function testClosePresale() public {
        assertTrue(nft.presale(), "sale is not in presale");
        vm.prank(contractsOwner);
        nft.closePresale();
        assertFalse(nft.presale(), "sale is still in presale");
    }

    //REVERT presale already closed
    function testRevertPresaleAlreadyClosed() public {
        vm.startPrank(contractsOwner);
        nft.closePresale();
        vm.expectRevert(abi.encodePacked("presale already closed"));
        nft.closePresale();
    }


    //REVERT whitelistmint presale closed
    function testRevertWhitelistMintIfPresaleClosed() public {
        vm.prank(wh_addr_1);
        nft.whitelistMint{value: 0.5 ether}();

        vm.prank(contractsOwner);
        nft.closePresale();

        assertFalse(nft.presale(), "sale still in presale");
        vm.prank(wh_addr_1);
        vm.expectRevert(abi.encodePacked("presale is closed"));
        nft.whitelistMint{value: 0.5 ether}();
    }

    //REVERT whitlist mint if price not right
    function testRevertWhitelistMintIfPriceNotRight() public {
        vm.prank(wh_addr_1);
        vm.expectRevert(abi.encodePacked("price not right"));
        nft.whitelistMint{value: 0.6 ether}();
    }

    //REVERT whitelist mint if max cap reached 
    function testRevertWhitelistMintIfMaxCapReached() public {
        vm.deal(wh_addr_1, 15 ether);

        //mint 20 times
        for(uint8 i = 0; i < 20; i++){
        vm.prank(wh_addr_1);
        nft.whitelistMint{value: 0.5 ether}();
        }

        //mint 21st time, should revert
        vm.prank(wh_addr_1);
        vm.expectRevert(abi.encodePacked("max cap reached"));
        nft.whitelistMint{value: 0.5 ether}();
    }

    //SUCCESS close presale

    //SUCCESS mint NFT
    function testMint() public {
        vm.prank(wh_addr_1);
        nft.whitelistMint{value: 0.5 ether}();

        //close presale
        vm.prank(contractsOwner);
        nft.closePresale();

        //normal mint
        vm.prank(n_wh_addr_1);
        nft.mint{value: 1 ether}();
        assertEq(nft.totalSupply(), 2, "total supply should be 2");
    }

    //REVERT mint if price not right
    function testRevertMintIfPriceNotRight() public {
        vm.prank(wh_addr_1);
        nft.whitelistMint{value: 0.5 ether}();

        //close presale
        vm.prank(contractsOwner);
        nft.closePresale();

        //normal mint with wrong price, should revert
        vm.prank(n_wh_addr_1);
        vm.expectRevert(abi.encodePacked("price not right"));
        nft.mint{value: 1.1 ether}();
    }

    //REVERT mint if presale not closed
    function testRevertMintIfPresaleNotClosed() public {
        vm.prank(wh_addr_1);
        nft.whitelistMint{value: 0.5 ether}();

        //normal mint with presale not closed, should revert
        vm.prank(n_wh_addr_1);
        vm.expectRevert(abi.encodePacked("presale not closed"));
        nft.mint{value: 1 ether}();
    }

    //REVERT mint if max cap reached
    function testRevertMintIfMaxCapReached() public {
        vm.deal(wh_addr_1, 15 ether);

        //mint 20 times
        for(uint8 i = 0; i < 20; i++){
        vm.prank(wh_addr_1);
        nft.whitelistMint{value: 0.5 ether}();
        }

        //close presale
        vm.prank(contractsOwner);
        nft.closePresale();

        //mint 21st time, should revert
        vm.prank(n_wh_addr_1);
        vm.expectRevert(abi.encodePacked("max cap reached"));
        nft.mint{value: 1 ether}();
    }

    //SUCCESS withdraw funds
    function testWithdrawFunds() public {
        vm.deal(wh_addr_1, 15 ether);

        //mint 20 times
        for(uint8 i = 0; i < 20; i++){
            vm.prank(wh_addr_1);
            nft.whitelistMint{value: 0.5 ether}();
            }

        uint256 balanceBefore = address(contractsOwner).balance;
        vm.prank(contractsOwner);
        nft.withrawFunds();
        uint256 balanceAfter = address(contractsOwner).balance;

        assertEq(address(nft).balance, 0, "balance should be 0");
        assertEq(balanceAfter - balanceBefore, 10 ether, "balance should be 10 ether");
    }

    //SUCCESS stake
    function testStake() public {
        vm.prank(wh_addr_1);
        nft.whitelistMint{value: 0.5 ether}();

        //close presale
        vm.prank(contractsOwner);
        nft.closePresale();

        //normal mint
        vm.prank(n_wh_addr_1);
        nft.mint{value: 1 ether}();

        //stake
        vm.prank(n_wh_addr_1);
        nft.safeTransferFrom(n_wh_addr_1, address(staking), 2);
        assertEq(nft.totalSupply(), 2, "total supply should be 2");

        (uint8 stakedNum, uint64 lastClaim) = staking.userStake(n_wh_addr_1);

        assertEq(stakedNum, 1, "stakedNum should be 1");
        assertEq(lastClaim, uint64(block.timestamp), "lastClaim should be block.timestamp");
        assertEq(staking.tokenIdByIndex(0, n_wh_addr_1), 2, "tokenId should be 1");
    }

    //REVERT onERC721Received if not from NFT contract
    function testRevertOnERC721ReceivedIfNotFromNFTContract() public {
        NFT nft2 = new NFT(emptyHelper, "StakeMe2", "STKMI2");
        vm.prank(wh_addr_1);
        nft2.whitelistMint{value: 0.5 ether}();

        //close presale
        vm.prank(contractsOwner);
        nft2.closePresale();

        //normal mint
        vm.prank(n_wh_addr_1);
        nft2.mint{value: 1 ether}();

        
        //stake
        vm.prank(n_wh_addr_1);
        vm.expectRevert(abi.encodePacked("Only registered address"));
        nft2.safeTransferFrom(n_wh_addr_1, address(staking), 2);
    }


    //REVERT if index out of bounds
    function testRevertTokenIdByIndex() public {
        vm.prank(wh_addr_1);
        nft.whitelistMint{value: 0.5 ether}();

        vm.expectRevert(abi.encodePacked("Index out of bounds"));
        staking.tokenIdByIndex(2,wh_addr_1);

        vm.expectRevert(abi.encodePacked("Index out of bounds"));
        staking.tokenIdByIndex(1,n_wh_addr_1);
    }

    //SUCCESS claim
    function testClaim() public {
        //close presale
        vm.prank(contractsOwner);
        nft.closePresale();

        //normal mint
        vm.prank(n_wh_addr_1);
        nft.mint{value: 1 ether}();

        //stake
        vm.prank(n_wh_addr_1);
        nft.safeTransferFrom(n_wh_addr_1, address(staking), 1);

        //wrap 1 day
        skip(1 days + 1);

        //claim
        vm.prank(n_wh_addr_1);
        staking.claim();
        assertGt(token.balanceOf(n_wh_addr_1), 10 * 10 ** 18, "balance should be more than 10 tokens");
    }

    //REVERT claim if no NFT staked
    function testRevertClaimIfNoNFTStaked() public {
        //close presale
        vm.prank(contractsOwner);
        nft.closePresale();

        //normal mint
        vm.prank(n_wh_addr_1);
        nft.mint{value: 1 ether}();

        //claim
        vm.prank(n_wh_addr_1);
        vm.expectRevert(abi.encodePacked("No NFT staked"));
        staking.claim();
    }


    //SUCCESS unstake
    function testUnstake() public {
        //close presale
        vm.prank(contractsOwner);
        nft.closePresale();

        //normal mint
        vm.prank(n_wh_addr_1);
        nft.mint{value: 1 ether}();

        //stake
        vm.startPrank(n_wh_addr_1);
        nft.safeTransferFrom(n_wh_addr_1, address(staking), 1);

        (uint8 stakedNum, ) = staking.userStake(n_wh_addr_1);
        assertEq(stakedNum, 1, "stakedNum should be 1");
        assertEq(staking.ownerOf(1), n_wh_addr_1, "owner of 1 should be n_wh_addr_1");
        assertEq(nft.ownerOf(1), address(staking), "owner of 1 should be staking contract");

        //unstake
        staking.unStake(0);
        (stakedNum, ) = staking.userStake(n_wh_addr_1);
        assertEq(stakedNum, 0, "stakedNum should be 0");
        vm.expectRevert(abi.encodePacked("Index out of bounds"));
        staking.tokenIdByIndex(1, n_wh_addr_1);

        //verify that owner of 1 is n_wh_addr_1 and has custody again
        address ownerOf = nft.ownerOf(1);
        assertEq(ownerOf, n_wh_addr_1, "owner of 1 should be n_wh_addr_1");
    }

        //REVERT unstake if not index out of bounds
        function testRevertUnstakeIfIndexOutOfBounds() public {
            //close presale
            vm.prank(contractsOwner);
            nft.closePresale();
    
            //normal mint
            vm.prank(n_wh_addr_1);
            nft.mint{value: 1 ether}();
    
            //stake
            vm.startPrank(n_wh_addr_1);
            nft.safeTransferFrom(n_wh_addr_1, address(staking), 1);
    
            (uint8 stakedNum, ) = staking.userStake(n_wh_addr_1);
            assertEq(stakedNum, 1, "stakedNum should be 1");
            assertEq(staking.ownerOf(1), n_wh_addr_1, "owner of 1 should be n_wh_addr_1");
            
            //unstake
            vm.startPrank(n_wh_addr_1);
            vm.expectRevert(abi.encodePacked("Index out of bounds"));
            staking.unStake(1);
            vm.stopPrank();
        }


    function testClaimable() public {
        //close presale
        vm.prank(contractsOwner);
        nft.closePresale();

        //normal mint
        vm.prank(n_wh_addr_1);
        nft.mint{value: 1 ether}();

        //stake
        vm.startPrank(n_wh_addr_1);
        nft.safeTransferFrom(n_wh_addr_1, address(staking), 1);

        //wrap 1 day
        skip(1 days + 1);

        //claim
        vm.prank(n_wh_addr_1);
        uint claimable = staking.claimable();
        assertGt(claimable, 10 * 10 ** 18, "balance should be more than 10 tokens");
    }

}