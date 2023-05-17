// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract GabrielNFTs is ERC721, ERC721Enumerable, Pausable, Ownable {
    using Counters for Counters.Counter;
    uint256 maxSupply = 2000;

    bool public publicMintOpen = false;
    bool public allowListMintOpen = false;

    mapping(address => bool) public allowList;

    Counters.Counter private _tokenIdCounter;

    constructor() ERC721("GabrielNFTs", "GNFTS") {}

    function _baseURI() internal pure override returns (string memory) {
        return "ipfs://QmY5rPqGTN1rZxMQg2ApiSZc7JiBNs1ryDzXPZpQhC1ibm/";
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function editMintWindows(
        bool _publicMintOpen,
        bool _allowListMintOpen
    ) external onlyOwner {
        publicMintOpen = _publicMintOpen;
        allowListMintOpen = _allowListMintOpen;
    }

    // require only the allowList people to mint
    // add publicMint and allowListMintOpen variables
    function allowListMint() public payable {
        require(allowListMintOpen, "Allowlist mint closed");
        require(allowList[msg.sender], "you are not on the allow list");
        require(msg.value == 0.001 ether, "Not enough funds!");
        internalMint();
    }
    // Add Payment
    // Add limiting supply
    function publicMint() public payable {
        require(publicMintOpen, "Public mint closed");
        require(msg.value == 0.01 ether, "Not enough funds!");
        internalMint();
    }

    function internalMint() internal {
        require(totalSupply() < maxSupply, "We sold out!");
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(msg.sender, tokenId);
    }

    function withdraw(address _addr) external onlyOwner {
        // get the balance of the contract
        uint256 balance = address(this).balance;
        payable(_addr).transfer(balance);
    }

    // populate the allow list
    function setAllowList(address[] calldata addreses) external onlyOwner {
        for(uint256 i = 0; i < addreses.length; i++){
            allowList[addreses[i]] = true;
        }
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId, uint256 batchSize)
        internal
        whenNotPaused
        override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    // The following functions are overrides required by Solidity.

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}