// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract Mytoken is ERC20 {
    constructor() ERC20("MyToken", "MTK") {
        _mint(msg.sender, 1000);
    }
}

contract MyNFT is ERC721 {
    constructor() ERC721("MyNFT", "MNFT") {
        for (uint256 id = 0; id < 10; id++) {
            _safeMint(msg.sender, id);
        }
    }
    function _baseURI() internal pure override returns (string memory) {
        return "https://nft.example.com/";
    }
}