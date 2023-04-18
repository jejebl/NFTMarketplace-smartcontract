//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.9;

import "hardhat/console.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract NFTMarketplace is ERC721URIStorage {

    using Counters for Counters.Counter;
    //_tokenIds variable has the most recent minted tokenId
    Counters.Counter private _tokenIds;
    //owner is the contract address that created the smart contract
    address payable ownerSmartContract;

    //The structure to store info about a listed nft
    struct NFT {
        uint256 tokenId;
        address payable owner;
        uint256 price;
        bool forSale;
    }

    //the event emitted when a nft is successfully listed
    event NFTSuccess (
        uint256 indexed tokenId,
        address payable owner,
        uint256 price,
        bool forSale
    );

    //This mapping maps tokenId to nft
    mapping(uint256 => NFT) private tokenIdToNft;

    constructor() ERC721("NFTMarketplace", "NFTM") {
        ownerSmartContract = payable(msg.sender);
    }

    function updateForSale(uint256 tokenId, uint256 price) public payable {
        require(tokenIdToNft[tokenId].owner== msg.sender);
        tokenIdToNft[tokenId].forSale = true;
        tokenIdToNft[tokenId].price = price;
    }

    function removeFromSale(uint256 tokenId) public payable {
        require(tokenIdToNft[tokenId].owner== msg.sender);
        tokenIdToNft[tokenId].forSale = false;
    }

    function getLatestTokenIdToNft() public view returns (NFT memory) {
        uint256 currentTokenId = _tokenIds.current();
        return tokenIdToNft[currentTokenId];
    }

    function getNftForTokenId(uint256 tokenId) public view returns (NFT memory) {
        return tokenIdToNft[tokenId];
    }

    function getCurrentToken() public view returns (uint256) {
        return _tokenIds.current();
    }

    //The first time a nft is created, it is listed here
    function mintNft(string memory tokenURI) public payable {
        //Increment the tokenId counter, which is keeping track of the number of minted NFTs
        _tokenIds.increment();
        uint256 newTokenId = _tokenIds.current();

        //Mint the NFT with tokenId newTokenId to the address who called createNft
        _safeMint(msg.sender, newTokenId);

        //Map the tokenId to the tokenURI (which is an IPFS URL with the NFT metadata)
        _setTokenURI(newTokenId, tokenURI);

        createNft(newTokenId);
    }

    function createNft(uint256 tokenId) private {
        //Update the mapping of tokenId's to Token details
        tokenIdToNft[tokenId] = NFT(
            tokenId,
            payable(msg.sender),
            0,
            false
        );

        emit NFTSuccess(
            tokenId,
            payable(msg.sender),
            0,
            false
        );
    }
    
    //This will return all the NFTs
    function getAllNFTs() public view returns (NFT[] memory) {
        uint nftCount = _tokenIds.current();
        NFT[] memory nfts = new NFT[](nftCount);
        uint currentIndex = 0;

        for(uint i=0;i<nftCount;i++)
        {
            uint currentId = i + 1;
            NFT storage currentItem = tokenIdToNft[currentId];
            nfts[currentIndex] = currentItem;
            currentIndex += 1;
        }
        //the array 'nfts' has the list of all NFTs in the marketplace
        return nfts;
    }
    
    //Returns all the NFTs that the current user is owner
    function getMyNFTs() public view returns (NFT[] memory) {
        uint totalItemCount = _tokenIds.current();
        uint itemCount = 0;
        uint currentIndex = 0;
        
        //Important to get a count of all the NFTs that belong to the user before we can make an array for them
        for(uint i=0; i < totalItemCount; i++)
        {
            if(tokenIdToNft[i+1].owner == msg.sender){
                itemCount += 1;
            }
        }

        //Once you have the count of relevant NFTs, create an array then store all the NFTs in it
        NFT[] memory nfts = new NFT[](itemCount);
        for(uint i=0; i < totalItemCount; i++) {
            if(tokenIdToNft[i+1].owner == msg.sender) {
                uint currentId = i+1;
                NFT storage currentItem = tokenIdToNft[currentId];
                nfts[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }
        return nfts;
    }

    function executeSale(uint256 tokenId) public payable {
        require(tokenIdToNft[tokenId].forSale);
        uint price = tokenIdToNft[tokenId].price;
        address owner = tokenIdToNft[tokenId].owner;
        require(msg.value == price, "Please submit the asking price in order to complete the purchase");

        _transfer(owner, msg.sender, tokenId);
        payable(owner).transfer(msg.value);

        tokenIdToNft[tokenId].forSale = false;
        tokenIdToNft[tokenId].owner = payable(msg.sender);
    }
}