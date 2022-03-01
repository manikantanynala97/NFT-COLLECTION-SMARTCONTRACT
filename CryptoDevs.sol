//SPDX-License-Identifier:MIT

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./IWhitelist.sol";

contract CryptoDevs is ERC721Enumerable,Ownable{

  string _baseTokenURI; // Token_URI = _baseTokenURI + Token_ID
  bool public _paused; // _paused is to pause the contract in case of emergency
  bool public presaleStarted; // boolean to keep track of when presale started
  uint256 public presaleEnded; // Timestamp when the presale ends
  uitn256 public _price = 0.01 ether; // price of one NFT Token
  uint256 public maxTokenIds; // max number of CrytoDevs NFTS available
  uint256 public tokenIds; // Keep track of Token Ids minted
  IWhitelist whitelist; // Whitelist contract instance

  modifier onlyWhenNotPaused {
          require(!_paused, "Contract currently paused");
          _;
      }

  constructor (string memory baseURI, address whitelistContract) ERC721("Crypto Devs", "CD") {
          _baseTokenURI = baseURI;
          whitelist = IWhitelist(whitelistContract);
      }

  function startPresale() public onlyOwner   
{
   presaleStarted = true;
   presaleEnded = block.timestamp + 300 minutes ;
}

function presaleMint() public payable onlyWhenNotPaused
{
    require(presaleStarted && block.timestamp <= presaleEnded , "Presale didnot start yet");
    require(whitelist.whitelistedAddresses(msg.sender),"You are not whitelisted");
    require(tokenIds < maxTokenIds , "Exceeded maximum Crypto Devs supply");
    require(msg.value>= _price , "Send minimum amount of ether properly");

    tokenIds+=1;
    _safeMint(msg.sender,tokenIds);
}

function mint() public payable onlyWhenNotPaused
{
  require(presaleStarted && block.timestamp > presaleEnded , "Presale has not ended");
  require(tokenIds < maxTokenIds , "Exceeded maximum Crypto Devs supply");
  require(msg.value>= _price , "Send minimum amount of ether properly");

  tokenIds+=1;
  _safeMint(msg.sender,tokenIds);
}


   function _baseURI() internal view virtual override returns (string memory) {
          return _baseTokenURI;
      }



   function setPaused(bool val) public onlyOwner {
          _paused = val;
      }



  function withdraw() public onlyOwner 
 {
      address payable _owner = owner(); // This function owner() taken from Ownable.sol
      uint256 amount = address(this).balance ;// This basically gives amount of ether in this smart contract
      (bool sent,) = _owner.call{value:amount}("");// money is sent from this contract to owner address
      require(sent,"Failed to Send Ether"); // If sent is false then we get the message as Failed to Send Ether
 }



}


