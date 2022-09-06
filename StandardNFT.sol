// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

contract StandardNFT is ERC721, ERC721Enumerable, Ownable {
    string private _baseURIextended; // Used within the OpenZeppelin `_baseURI` override. Only settable by the Owner.
    uint256 public immutable MAX_SUPPLY; // This cannot be changed once the contract is deployed.
    uint256 public currentPrice; // Price used within the `mint` function. Only settable by the Owner.
    bool public saleIsActive = true; // Switch that determines whether anything other than the owner can mint new NFTs. Only settable by the Owner.

    // This constructor is pulled directly from the OpenZeppelin ERC721 implementation wizard
    // https://wizard.openzeppelin.com/#erc721
    // Select Mintable and Enumerable
    // `price` and `MAX_SUPPLY` have been added for sale functionality, and to limit the max number of NFTs. This is the
    // only place that `MAX_SUPPLY` can be set, and `currentPrice` can only be set by the Owner using OpenZeppelins Ownable extension.
    constructor(
        string memory _name,
        string memory _symbol,
        string memory _uri,
        uint256 price,
        uint256 maxSupply
    ) ERC721(_name, _symbol) {
        _baseURIextended = _uri;
        MAX_SUPPLY = maxSupply;
        currentPrice = price;
    }

    // `mint` is the only custom function callable by anybody other than the owner. All it
    // does is make three checks, then uses OpenZeppelins built in `_safeMint` function
    function mint(uint256 amount) external payable {
        uint256 ts = totalSupply(); // `totalSupply` is saved here just to reduce gas. There are no effects or chain interactions.
        require(saleIsActive, "Sale must be active to mint tokens"); // `saleIsActive` is only settable by the Owner.
        require(ts + amount <= MAX_SUPPLY, "Purchase would exceed max tokens"); // `MAX_SUPPLY` is immutable, so cannot be changed once deployed.
        require(
            currentPrice * amount <= msg.value,
            "Value sent is not correct"
        ); // `currentPrice` is only settable by the Owner.

        for (uint256 i = 0; i < amount; i++) {
            _safeMint(msg.sender, ts + i);
        }
    }

    // This provides a way for the owner to mint `n` NFTs.
    // Only callable by the owner (using OpenZeppelin's Ownable extension)
    function reserve(uint256 n) external onlyOwner {
        uint256 supply = totalSupply();
        require(supply + n <= MAX_SUPPLY, "Purchase would exceed max tokens");
        for (uint256 i = 0; i < n; i++) {
            _safeMint(msg.sender, supply + i);
        }
    }

    // This function allows the owner to withdraw ether that is within the contract.
    // Only callable by the owner (using OpenZeppelin's Ownable extension)
    function withdraw() external onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

    // Simple setter that is only callable by the owner (using OpenZeppelin's Ownable extension)
    function setBaseURI(string memory baseURI_) external onlyOwner {
        _baseURIextended = baseURI_;
    }

    // Simple setter that is only callable by the owner (using OpenZeppelin's Ownable extension)
    function setSaleIsActive(bool isActive) external onlyOwner {
        saleIsActive = isActive;
    }

    // Simple setter that is only callable by the owner (using OpenZeppelin's Ownable extension)
    function setCurrentPrice(uint256 price) external onlyOwner {
        currentPrice = price;
    }

    // This override is based on the OpenZeppelin ERC721 implementation wizard.
    // Instead of returning a constant string, it returns a private string that is only settable
    // by the owner.
    function _baseURI() internal view virtual override returns (string memory) {
        return _baseURIextended;
    }

    // This override is pulled directly from the OpenZeppelin ERC721 implementation wizard
    // https://wizard.openzeppelin.com/#erc721
    // Select Mintable and Enumerable
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    // This override is pulled directly from the OpenZeppelin ERC721 implementation wizard
    // https://wizard.openzeppelin.com/#erc721
    // Select Mintable and Enumerable
    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}

