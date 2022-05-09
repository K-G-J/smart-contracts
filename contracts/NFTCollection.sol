// SPDX-License-Identifier: MIT LICENSE

pragma solidity 0.8.4;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Counters.sol";


contract NFTCollection is ERC721Enumerable, Ownable, ReentrancyGuard {

  struct TokenInfo {
     IERC20 paytoken;
     uint256 costvalue;
  }

  TokenInfo[] public AllowedCrypto;

  using Strings for uint256;
  using Counters for Counters.Counter;
  Counters.Counter public mintedIds; // total number of NFTs in collection 
  string public baseURI;
  string public baseExtension = ".json";
  uint256 public maxSupply = 1000; // max supply of NFTs in collection
  uint256 public maxMintAmount = 5; // max amount per mint call
  uint256 cost = 15 ether; // native cost for Ethereum
  bool public paused = false;

  constructor() ERC721("NFT Collection", "NFC") {}

  function addCurrency (IERC20 _paytoken, uint256 _costvalue) public onlyOwner {
    AllowedCrypto.push(TokenInfo(_paytoken,_costvalue));
  }
  
  // internal func to get collection baseURI from ipfs
  function _baseURI() internal view virtual override returns (string memory) {
      return "ipfs://EE5MmqVp5MmqVp7ZRMBBizicVh9ficVh9fjUofWicVh9f/";
    }
  
  // public minting for native token
  function mint(address _to, uint256 _mintAmount) public payable {
    uint256 _mintedIds = mintedIds.current();
    require(!paused, "minting is not enabled");
    require(_mintAmount > 0, "need to submit a mint amount");
    require(_mintAmount <= maxMintAmount, "execeeded max mint amount");
    require(_mintedIds + _mintAmount <= maxSupply, "exceeded max NFT supply");
    
    // owner can mint without fee
    if (msg.sender != owner()) {
      require(msg.value == cost * _mintAmount, "Need to send correct amount of ether!");
      }
      for (uint256 i = 1; i <= _mintAmount; i++) {
        _safeMint(_to, _mintedIds + i); 
        mintedIds.increment();
        }
      }

      // public minting for allowed token
      function mintpid(address _to, uint256 _mintAmount, uint256 _pid) public payable {
        uint256 _mintedIds = mintedIds.current();
        require(!paused, "minting is not enabled");
        require(_mintAmount > 0, "need to submit a mint amount");
        require(_mintAmount <= maxMintAmount, "execeeded max mint amount");
        require(_mintedIds + _mintAmount <= maxSupply, "exceeded max NFT supply");
        TokenInfo storage tokens = AllowedCrypto[_pid];
        IERC20 paytoken = tokens.paytoken;
        uint256 _cost = tokens.costvalue;

        if(msg.sender != owner()) {
          require(msg.value == _cost * _mintAmount, "Not enough balance to complete transaction.");

          for (uint256 i = 1; i <= _mintAmount; i ++) {
            paytoken.transferFrom(msg.sender, address(this), _cost);
            _safeMint(_to, _mintedIds + i);
            mintedIds.increment();
          }
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
      function setmaxMintAmount(uint256 _newmaxMintAmount) public onlyOwner {
        maxMintAmount = _newmaxMintAmount;
      }

      // change base tokenURI (only owner)
      function setBaseURI(string memory _newBaseURI) public onlyOwner {
        baseURI = _newBaseURI;
      }
      
      // change base extension on token URI (only owner)
      function setBaseExtension(string memory _newBaseExtension) public onlyOwner {
        baseExtension = _newBaseExtension;
      }
      
      // pause minting (only owner)
      function pause(bool _state) public onlyOwner {
        paused = _state;
      }

      // get the cost of the NFT in choosen currency 
       function getNFTCost(uint256 _pid) public view virtual returns(uint256) {
        TokenInfo storage tokens = AllowedCrypto[_pid];
        uint256 _cost = tokens.costvalue;
        return _cost;
      }

      // get choosen currency token address
      function getCryptotoken(uint256 _pid) public view virtual returns(IERC20) {
        TokenInfo storage tokens = AllowedCrypto[_pid];
        IERC20 paytoken = tokens.paytoken;
        return paytoken;
      }
      
      // Withdraw funds from contract (only owner)
      function withdraw(uint256 _pid) public payable onlyOwner nonReentrant {
        TokenInfo storage tokens = AllowedCrypto[_pid];
        IERC20 paytoken = tokens.paytoken;
        (bool success, ) = payable(msg.sender).call{value: paytoken.balanceOf(address(this))}("");
        require(success, "Funds were not withdrawn");
      }

}