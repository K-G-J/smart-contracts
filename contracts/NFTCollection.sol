// SPDX-License-Identifier: MIT LICENSE

pragma solidity 0.8.4;
import "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract NFTCollection is ERC721Enumerable, Ownable {
  using Strings for uint256;
  string public baseURI;
  string public baseExtension = ".json";
  uint256 public cost = 0.001 ether; // cost to mint 
  uint256 public maxSupply = 100000; // max supply of NFTs in collection
  uint256 public maxMintAmount = 5; // max amount per mint call
  bool public paused = false;

  constructor() ERC721("NFT Collection", "NFC") {}
  
  // internal func to get collection baseURI from ipfs
  function _baseURI() internal view virtual override returns (string memory) {
      return "ipfs://EE5MmqVp5MmqVp7ZRMBBizicVh9ficVh9fjUofWicVh9f/";
    }
  
  // public minting
  function mint(address _to, uint256 _mintAmount) public payable {
    uint256 supply = totalSupply();
    require(!paused);
    require(_mintAmount > 0);
    require(_mintAmount <= maxMintAmount);
    require(supply + _mintAmount <= maxSupply);
    
    // owner can mint without fee
    if (msg.sender != owner()) {
      require(msg.value == cost * _mintAmount, "Need to send correct amount of ether!");
      }
      for (uint256 i = 1; i <= _mintAmount; i++) {
        _safeMint(_to, supply + i);
        }
      }

    // returns token IDs owned by address  
    function walletOfOwner(address _owner) public view returns (uint256[] memory)
      {
        uint256 ownerTokenCount = balanceOf(_owner);
        uint256[] memory tokenIds = new uint256[](ownerTokenCount);
        for (uint256 i; i < ownerTokenCount; i++) {
          tokenIds[i] = tokenOfOwnerByIndex(_owner, i);
        }
        return tokenIds;
      }
    
    // returns tokenURI of tokenId
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
        string memory currentBaseURI = _baseURI();
        return bytes(currentBaseURI).length > 0 ? string(abi.encodePacked(currentBaseURI, tokenId.toString(), baseExtension)): "";
      }
      
      // change max mint amount (only owner)
      function setmaxMintAmount(uint256 _newmaxMintAmount) public onlyOwner() {
        maxMintAmount = _newmaxMintAmount;
      }

      // change base tokenURI (only owner)
      function setBaseURI(string memory _newBaseURI) public onlyOwner() {
        baseURI = _newBaseURI;
      }
      
      // change base extension on token URI (only owner)
      function setBaseExtension(string memory _newBaseExtension) public onlyOwner() {
        baseExtension = _newBaseExtension;
      }
      
      // pause minting (only owner)
      function pause(bool _state) public onlyOwner() {
        paused = _state;
      }
      
      // Withdraw funds from contract (only owner)
      function withdraw() public payable onlyOwner() {
        (bool success, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(success, "Funds were not withdrawn");
      }
}