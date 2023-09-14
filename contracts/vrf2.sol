// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";

// Uncomment this line to use console.log
// import "hardhat/console.sol";

contract MyNFT is ERC721, VRFConsumerBase {
    // Contract code goes here
    string public baseTokenURI;
    uint public tokenIdCounter;

    // CHAINLINK VRF NEEDED VALUES - Gotten from my ChainLink Subscription
    address private vrfCoordinator = 0x2ca8e0c643bde4c2e08ab1fa0da3401adad7734d;
    address private linkToken = 0x326c977e6efc84e512bb9c30f76e30c160ed06fb;
    bytes32 private keyHash =
        0x79d3d8832d904592c0bf9818b621522c988bb8b0c05cdc3b15aea1b6e8db0c15;
    uint fee = 150 gwei;

    struct Traits {
        string name;
        uint energy;
        uint speed;
        uint experience;
        uint health;
        uint gem;
        bool rare;
    }

    mapping(uint => Traits) tokenTraits;

    // Events
    event Minted(
        uint indexed tokenId,
        address indexed owner,
        string name,
        uint energy,
        uint speed,
        uint experience,
        uint health,
        uint gem,
        bool rare
    );

    // constructor() ERC721("DummyNFT", "NFT") {
    //     baseTokenURI = "";
    // }

    // function mintTo(address recipient) external returns (uint256) {
    //     require(recipient != address(0), "Cannot mint to address zero");
    //     _safeMint(recipient, 1);
    //     return 1;
    // }

    constructor(
        uint64 subscriptionId
    )
        ERC721("CHAINLINK_NFT", "CNFT")
        VRFConsumerBase(vrfCoordinator, linkToken)
    {
        // Constructor code goes here
    }

    function mint(address recepient) external {
        require(recepient != address(0), "Cannot mint to address zero");
        require(LINK.balanceOf(address(this)) >= fee, "Not enough LINK tokens");
        // uint tokenId = totalSupply() + 1;
        _safeMint(recepient, tokenIdCounter);
        requestRandomTraits(tokenIdCounter);
    }

    function requestRandomTraits(uint256 tokenId) internal returns (bytes32) {
        require(LINK.balanceOf(address(this)) >= fee, "Not enough LINK tokens");
        bytes32 requestId = requestRandomness(keyHash, fee);
        // Store the requestId for later use
        return requestId;
    }

    function fulfillRandomness(
        bytes32 requestId,
        uint randomness
    ) internal override {
        // Generate the traits based on the randomness
        // Store the traits for the corresponding tokenId

        require(
            msg.sender == vrfCoordinator,
            "Only VRF coordinator can fulfill"
        );
        uint energy = randomness % 101; // Random number between 0 and 100
        uint speed = randomness % 101; // Another random number between 0 and 100
        uint health = randomness % 101;
        uint gem = randomness % 10;
        bool rare = false;
        uint experience = 0;

        // Create a new NFT with these traits
        Traits memory attributes = Traits(
            energy,
            speed,
            experience,
            health,
            gem,
            rare
        );
        tokenTraits[tokenIdCounter] = attributes;
        _mint(msg.sender, tokenIdCounter);
        emit Minted(
            tokenIdCounter,
            msg.sender,
            energy,
            speed,
            experience,
            health,
            gem,
            rare
        );
        tokenIdCounter++;
    }

    function getTraits(uint256 tokenId) external view returns (Traits memory) {
        return tokenTraits[tokenId];
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return baseTokenURI;
    }

    function setBaseTokenURI(string memory _baseTokenURI) public {
        baseTokenURI = _baseTokenURI;
    }
}