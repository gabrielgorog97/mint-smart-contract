// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract myFirstNFT is ERC721, Ownable {

    using Strings for uint256;

    uint256 public constant MAX_TOKENS = 10000;
    uint256 private constant TOKENS_RESERVED = 5;
    uint256 public price = 50000000000000000;
    uint256 public constant MAX_MINT_PER_TX = 10;

    bool public isSaleActive;
    uint256 public totalSupply;
    mapping(address => uint256) private mintedPerWallet;

    string public baseUri;
    string public baseExtension = ".json";

    constructor() ERC721("MygreatNFTs", "MGRNFTS") {
        baseUri = "ipfs://xxxxxxxxxxxxxxxx";
        for (uint256 i = 1; i <= TOKENS_RESERVED; ++i) {
            _safeMint(msg.sender, i);
        }
        totalSupply = TOKENS_RESERVED;
    }

    function mint(uint256 _numTokens) external payable {
        require(isSaleActive, "the sale is paused.");
        require(_numTokens <= MAX_MINT_PER_TX, "you can only mint a max of 10 nfts per transaction.");
        require(mintedPerWallet[msg.sender] + _numTokens <= 10, "you can only mint 10 per wallet");
        uint256 curTotalSupply = totalSupply;
        require(curTotalSupply + _numTokens <= MAX_TOKENS, "exceeds MAX_TOKENS");
        require(_numTokens * price <= msg.value, "insufficient funds. add more ETH!");

        for (uint256 i = 1; i <= _numTokens; ++i) {
            _safeMint(msg.sender, curTotalSupply + i);
        }
        mintedPerWallet[msg.sender] += _numTokens;
        totalSupply += _numTokens;
    }

    function flipSaleState() external onlyOwner {
        isSaleActive = !isSaleActive;
    }

    function setBaseUri(string memory _baseUri) external onlyOwner {
        baseUri = _baseUri;
    }

    function setPrice(uint256 _price) external onlyOwner {
        price = _price;
    }

    function withdrawAll() external payable onlyOwner {
        uint256 balance = address(this).balance;
        uint256 balanceOne = balance * 50 / 100;
        uint256 balanceTwo = balance * 50 / 100;
        (bool transferOne, ) = payable(0x1b1bcCd2160d8da10Cd37471D0241351fA2B9F0C).call{value: balanceOne}("");
        (bool transferTwo, ) = payable(0x1b1bcCd2160d8da10Cd37471D0241351fA2B9F0C).call{value: balanceTwo}("");
        require(transferOne && transferTwo, "transfer failed.");
    }
}
