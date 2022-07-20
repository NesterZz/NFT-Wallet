// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract BuildToken is ERC20 {
    constructor(string memory name, string memory symbol) ERC20(name, symbol) {
        // Mint 100 tokens to msg.sender
        _mint(msg.sender, 100 * 10**uint(decimals()));
    }
}

contract IFSMay is ERC721, ERC721Enumerable, Ownable {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;

    uint256 public maxTokenSupply;

    uint256 public constant MAX_MINTS_PER_TXN = 3;
    uint public count=0;
    uint256 public mintPrice = 10000 gwei; // 0.00001 ETH
    string public count_S;
    bool public saleIsActive = false;

    string public baseURI = "https://gateway.pinata.cloud/ipfs/QmbBEGvoEAJwFApyVFYvWMFYhhrJeppbTePWry3ddtxsjb";
    
    constructor(string memory name, string memory symbol) ERC721(name, symbol) {
        maxTokenSupply = 3;
    }

    function setMaxTokenSupply(uint256 maxMAYTokenSupply) public onlyOwner {
        maxTokenSupply = maxMAYTokenSupply;
    }

    function setMintPrice(uint256 newPrice) public onlyOwner {
        mintPrice = newPrice;
    }

    /*
    * Pause sale if active, make active if paused.
    */
    function flipSaleState() public onlyOwner {
        saleIsActive = !saleIsActive;
    }

    /*
    * Mint NFTs
    */
    function mint(uint256 numberOfTokens) public payable {
        require(saleIsActive, "Sale must be active");
        require(numberOfTokens <= MAX_MINTS_PER_TXN, "You can only adopt 3 IFSMay at a time");
        require(totalSupply() + numberOfTokens <= maxTokenSupply, "Purchase would exceed max available IFSMay");
        require(mintPrice * numberOfTokens <= msg.value, "Ether value sent is not correct");
        baseURI = "https://gateway.pinata.cloud/ipfs/QmbBEGvoEAJwFApyVFYvWMFYhhrJeppbTePWry3ddtxsjb";
        for(uint256 i = 0; i < numberOfTokens; i++) {
            uint256 mintIndex = _tokenIdCounter.current() + 1;
            if (mintIndex <= maxTokenSupply) {
                _safeMint(msg.sender, mintIndex);
                _tokenIdCounter.increment();
            }
            count=i+1;
            count_S= Strings.toString(mintIndex);
            
        }
        baseURI = string.concat(baseURI,"/",count_S,".json");

    }

    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }

    function addLine() public {
        baseURI = string.concat(baseURI,".json");
    }

    function setBaseURI(string memory newBaseURI) public onlyOwner {
        baseURI = newBaseURI;
    }

    function withdraw(address to) public onlyOwner {
        uint256 balance = address(this).balance;
        payable(to).transfer(balance);
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
     require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
     return baseURI;
 }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC721Enumerable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

}