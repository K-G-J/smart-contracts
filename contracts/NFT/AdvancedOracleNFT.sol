pragma solidity ^0.6.6;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@chainlink/contracts/src/v0.6/VRFConsumerBase.sol";

contract AdvancedCollectible is ERC721, VRFConsumerBase {
    uint256 public tokenCounter;
    enum Breed{PUG, SHIBI_INU, BRENARD}
    mapping(bytes32 => address) public requestIdToSender;
    mapping(bytes32 => string) public requestIdToTokenURI;
    mapping(uint256 => Breed) public tokenIdToBreed;
    mapping(bytes32 => uint256) public requestIdToTokenId;
    event requestedCollectible(bytes32 indexed requestId);
     event ReturnedCollectible(bytes32 indexed requestId, uint256 randomNumber);

    bytes32 internal keyHash; // identify proper oracle
    uint256 internal fee; // LINK token for oracle gas fee
    uint256 public randomResult;

    constructor(address _VRFCoordinator, address _LinkToken, bytes32 _keyhash) 
    public VRFConsumerBase(_VRFCoordinator, _LinkToken) ERC721("Dogie", "DOG") 
    {
        tokenCounter = 0;
        keyHash = _keyhash;
        fee = 0.1 * 10 ** 18; 
    }
    
    function createCollectible(string memory tokenURI, uint256 userProvidedSeed) public returns (bytes32) {
        bytes32 requestId = requestRandomness(keyHash, fee, userProvidedSeed); // cryptographically proven random number
        requestIdToSender[requestId] = msg.sender;
        requestIdToTokenURI = tokenURI;
        emit requestedCollectible(requestId);
    }

    function fulfillRandomness(bytes32 requestId, uint256 randomNumber) internal override {
        address dogOwner = requestIdToSender[requestId];
        string memory TokenURI = requestIdToTokenURI[requestId];
        uint256 newItemId = tokenCounter;
        _safeMint(dogOwner, newItemId);
        _setTokenURI(newItemId, tokenURI);
        Breed breed = Breed(randomNumber % 3); // random number between 0 and 2
        tokenIdToBreed[newItemId] = breed;
        requestIdToTokenId[requestId] = newItemId;
        tokenCounter = tokenCounter + 1;
        emit ReturnedCollectible(requestId, randomNumber);
    }
    
    function setTokenURI(uint256 tokenId, string memory _tokenURI) public {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _setTokenURI(tokenId, _tokenURI);
    }
}