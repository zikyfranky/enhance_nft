// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract Masks is ERC721, Pausable, AccessControl {
    
    string baseURI;
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant WALLET_ROLE = keccak256("WALLET_ROLE");
    uint256 public totalSupply = 0;
    uint256 private _tokenIdCounter = 251;
    uint256 private MAX_BUY = 5;
    uint256 private pricePerMask = 1 ether;
    address private feeReceiver;

    constructor(string memory __baseURI, address _feeReceiver) ERC721("Masks", "MM") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(PAUSER_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
        _grantRole(WALLET_ROLE, msg.sender);
        baseURI = __baseURI;
        feeReceiver = _feeReceiver;
    }

    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }

    function pause() public onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    function claimMask() public payable whenNotPaused {
        uint256 nftCount = msg.value / pricePerMask;
        require(nftCount >= 1, "Can only purchase max of 1 per transaction");
        require(nftCount <= MAX_BUY, "Can only purchase max of 5 per transaction");
        require(msg.value - (nftCount*1 ether) == 0, "Not a round number");

        feeReceiver.call{value:msg.value}("");

        for (uint256 index = 0; index < nftCount; index++) {
            uint256 tokenId = _tokenIdCounter;
            _tokenIdCounter+=1;
            _safeMint(msg.sender, tokenId);
        }
    }

    function changeFeeReceiver(address _newReceiver) external onlyRole(WALLET_ROLE){
        feeReceiver = _newReceiver;
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
        internal
        whenNotPaused
        override
    {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    // The following functions are overrides required by Solidity.
    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
