// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract Marketplace is ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;
    
    struct Listing {
        address seller;
        uint256 price;
    }
    
    struct Auction {
        address seller;
        uint256 startPrice;
        uint256 duration;
        uint256 highestBid;
        address highestBidder;
        uint256 endTime;
        bool active;
    }
    
    mapping(uint256 => Listing) public listings;
    mapping(uint256 => Auction) public auctions;
    mapping(uint256 => uint256) public royalties;

    uint256 public marketplaceFee = 500;  // 5% marketplace fee
    
    event NFTListed(uint256 tokenId, address seller, uint256 price);
    event NFTPurchased(uint256 tokenId, address buyer, uint256 price);
    event AuctionStarted(uint256 tokenId, uint256 startPrice, uint256 duration);
    event NewBid(uint256 tokenId, address bidder, uint256 bidAmount);
    event AuctionEnded(uint256 tokenId, address winner, uint256 winningBid);

    constructor() ERC721("NFTMarketplace", "NFTM") {}

    function _baseURI() internal view virtual override returns (string memory) {
        return "https://api.example.com/metadata/";
    }

    function mintNFT(string memory tokenURI, uint256 price) external {
        uint256 tokenId = _tokenIdCounter.current();
        _safeMint(msg.sender, tokenId);
        _setTokenURI(tokenId, tokenURI);
        listings[tokenId] = Listing(msg.sender, price);
        _tokenIdCounter.increment();
        
        emit NFTListed(tokenId, msg.sender, price);
    }

    function listNFT(uint256 tokenId, uint256 price) external {
        require(ownerOf(tokenId) == msg.sender, "You are not the owner");
        listings[tokenId] = Listing(msg.sender, price);
        
        emit NFTListed(tokenId, msg.sender, price);
    }

    function delistNFT(uint256 tokenId) external {
        require(ownerOf(tokenId) == msg.sender, "You are not the owner");
        delete listings[tokenId];
    }

    function buyNFT(uint256 tokenId) external payable {
        Listing memory listing = listings[tokenId];
        require(listing.seller != address(0), "NFT not listed");
        require(msg.value >= listing.price, "Insufficient funds");

        uint256 fee = (msg.value * marketplaceFee) / 10000;
        uint256 payment = msg.value - fee;

        payable(listing.seller).transfer(payment);
        _transfer(listing.seller, msg.sender, tokenId);
        
        delete listings[tokenId];
        emit NFTPurchased(tokenId, msg.sender, listing.price);
    }

    function startAuction(uint256 tokenId, uint256 startPrice, uint256 duration) external {
        require(ownerOf(tokenId) == msg.sender, "You are not the owner");
        auctions[tokenId] = Auction({
            seller: msg.sender,
            startPrice: startPrice,
            duration: duration,
            highestBid: 0,
            highestBidder: address(0),
            endTime: block.timestamp + duration,
            active: true
        });

        emit AuctionStarted(tokenId, startPrice, duration);
    }

    function placeBid(uint256 tokenId) external payable {
        Auction storage auction = auctions[tokenId];
        require(auction.active, "Auction is not active");
        require(block.timestamp < auction.endTime, "Auction has ended");
        require(msg.value > auction.highestBid, "Bid is too low");

        if (auction.highestBidder != address(0)) {
            payable(auction.highestBidder).transfer(auction.highestBid); // Refund the previous highest bidder
        }

        auction.highestBid = msg.value;
        auction.highestBidder = msg.sender;

        emit NewBid(tokenId, msg.sender, msg.value);
    }

    function endAuction(uint256 tokenId) external {
        Auction storage auction = auctions[tokenId];
        require(block.timestamp >= auction.endTime, "Auction has not ended yet");
        require(auction.active, "Auction is not active");

        auction.active = false;

        if (auction.highestBidder != address(0)) {
            uint256 fee = (auction.highestBid * marketplaceFee) / 10000;
            uint256 payment = auction.highestBid - fee;

            payable(auction.seller).transfer(payment);
            _transfer(auction.seller, auction.highestBidder, tokenId);
            emit AuctionEnded(tokenId, auction.highestBidder, auction.highestBid);
        } else {
            // No bids, return the NFT
            _transfer(auction.seller, auction.seller, tokenId);
        }
    }

    function setRoyalty(uint256 tokenId, uint256 royaltyPercentage) external {
        require(ownerOf(tokenId) == msg.sender, "You are not the owner");
        require(royaltyPercentage <= 1000, "Royalty too high"); // Max 10% royalty
        royalties[tokenId] = royaltyPercentage;
    }

    function withdrawRoyalties(uint256 tokenId) external {
        require(royalties[tokenId] > 0, "No royalty set");
        uint256 royalty = royalties[tokenId];
        royalties[tokenId] = 0;

        uint256 royaltyAmount = (royalty * listings[tokenId].price) / 10000;
        payable(msg.sender).transfer(royaltyAmount);
    }

    // Update marketplace fee percentage (Admin Only)
    function updateMarketplaceFee(uint256 newFee) external onlyOwner {
        marketplaceFee = newFee;
    }
}
