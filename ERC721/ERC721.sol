// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

// Reference Link: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/IERC721Receiver.sol
interface IERC721Receiver {
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

interface IERC721Metadata {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function tokenURI(uint256 tokenId) external view returns (string memory);
}

interface IERC721 {
    // Event
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);    
    // Query
    function balanceOf(address owner) external view returns (uint256 balance);
    function ownerOf(uint256 tokenId) external view returns (address owner);
    // Transfer
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
    function transferFrom(address from, address to, uint256 tokenId) external;
    // Approve
    function approve(address to, uint256 tokenId) external;
    function setApprovalForAll(address operator, bool _approved) external;
    function getApproved(uint256 tokenId) external view returns (address operator);
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}

contract ERC721 is IERC721, IERC721Metadata, IERC165 {
    mapping(address => uint256) _balances;
    mapping(uint256 => address) _owners;
    mapping(uint256 => address) _tokenApprovals;
    mapping(address => mapping(address => bool)) _operatorApprovals;
    mapping(uint256 => string) _tokenURIs;
    string _name;
    string _symbol;
    uint256 mintPrice = 800 wei;
    
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }
    
    function supportsInterface(bytes4 interfaceId) public pure returns (bool) {
        return interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            interfaceId == type(IERC165).interfaceId; 
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function tokenURI(uint256 tokenId) public view returns (string memory) {
        address owner = _owners[tokenId];
        require(owner != address(0), "ERROR: invalid token id");
        return _tokenURIs[tokenId];
    }

    function setTokenURI(uint256 tokenId, string memory URI) public {
        address owner = _owners[tokenId];
        require(owner != address(0), "ERROR: invalid token id");
        _tokenURIs[tokenId] = URI;
    }

    function balanceOf(address owner) public view returns (uint256) {
        require(owner != address(0), "ERROR: address 0 cannot be owner");
        return _balances[owner];
    }

    function ownerOf(uint256 tokenId) public view returns (address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "ERROR: tokenID is invalid");
        return owner;
    }

    function approve(address to, uint256 tokenId) public {
        address owner = _owners[tokenId];
        require(owner != to, "ERROR: owner == assigned target");
        require(owner == msg.sender || isApprovedForAll(owner, msg.sender), "ERROR: caller is not token owner or approved for all");
        _tokenApprovals[tokenId] = to;
        emit Approval(owner, to, tokenId);
    }

    function setApprovalForAll(address operator, bool _approved) public {
        require(msg.sender != operator, "ERROR: owner == operator");
        _operatorApprovals[msg.sender][operator] = _approved;
        emit ApprovalForAll(msg.sender, operator, _approved);
    }

    function getApproved(uint256 tokenId) public view returns (address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "ERROR: Token does not exist");
        return _tokenApprovals[tokenId];
    }

    function isApprovedForAll(address owner, address operator) public view returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    function _transfer(address from, address to, uint256 tokenId) internal {
        address owner = _owners[tokenId];
        require(owner == from, "Owner is not the \"from\" one");
        require(msg.sender == owner || isApprovedForAll(owner, msg.sender) || getApproved(tokenId) == msg.sender, "ERROR: caller is not authorized for transmission");
        delete _tokenApprovals[tokenId];
        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;
        emit Transfer(from, to, tokenId);
    }

    function _safeTransfer(address from, address to, uint256 tokenId, bytes memory data) internal {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, data), "ERROR: ERC721Receiver is not implemented");
    }

    function transferFrom(address from, address to, uint256 tokenId) public {
        _transfer(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) public {
        _safeTransfer(from, to, tokenId, data);        
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) public {
        _safeTransfer(from, to, tokenId, ""); 
    }

    function mint(address to, uint256 tokenId) public {
        address owner = _owners[tokenId];
        require(to != address(0), "ERROR: mint to void");
        require(owner == address(0), "ERROR: tokenId already exists");
        _balances[to] += 1;
        _owners[tokenId] = to;
        emit Transfer(address(0), to, tokenId);
    }

    function safemint(address to, uint256 tokenId, string calldata uri, bytes memory data) public {
        mint(to, tokenId);
        setTokenURI(tokenId, uri);
        require(_checkOnERC721Received(address(0), to, tokenId, data), "ERROR: ERC721Receiver is not implemented");
    }

    function safemint(address to, uint256 tokenId, string calldata uri) public {
        safemint(to, tokenId, uri, "");
    }

    function burn(uint256 tokenId) public {
        address owner = _owners[tokenId];
        require(msg.sender == owner, "ERROR, only o wner can burn");
        _balances[owner] -= 1;
        delete _owners[tokenId];
        delete _tokenApprovals[tokenId];
        emit Transfer(owner, address(0), tokenId);
    }

    // Reference Link: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/ERC721.sol
    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory data) private returns (bool) {
        if (to.code.length > 0 /* to is a contract */) {
            try IERC721Receiver(to).onERC721Received(msg.sender, from, tokenId, data) returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receover implementer");
                }
                else {
                    /// @solidity memory-safe-assembly
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        }
        else {
            return true;
        }
    }
}
