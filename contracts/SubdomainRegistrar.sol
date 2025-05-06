// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface INameWrapper {
    function setSubnodeOwner(bytes32 parentNode, string calldata label, address owner, uint32 fuses, uint64 expiry) external;
    function setApprovalForAll(address operator, bool approved) external;
    function wrapETH2LD(string calldata label, address wrappedOwner, uint16 ownerControlledFuses, address resolver) external;
}

interface IENSRegistrar {
    function setApprovalForAll(address operator, bool approved) external;
}

contract SubdomainRegistrar {
    INameWrapper public nameWrapper;
    IENSRegistrar public ensRegistrar;
    address public resolver;

    uint256 public registrationFee;
    address public feeRecipient;

    address private owner;
    bytes32 private parentNode;

    event SubdomainRegistered(bytes32 indexed parentNode, string label, address indexed owner);

    constructor(
        address _nameWrapper,
        address _ensRegistrar,
        address _resolver,
        bytes32 _parentNode,
        uint256 _registrationFee,
        address _feeRecipient
    ) {
        nameWrapper = INameWrapper(_nameWrapper);
        ensRegistrar = IENSRegistrar(_ensRegistrar);
        resolver = _resolver;
        parentNode = _parentNode;
        registrationFee = _registrationFee;
        feeRecipient = _feeRecipient;
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    function register(string calldata label) external payable {
        require(msg.value >= registrationFee, "Insufficient registration fee");

        if (msg.value > 0) {
            payable(feeRecipient).transfer(msg.value);
        }

        uint32 fuses = 327680;
        uint64 expiry = uint64(block.timestamp + 31536000); // 1 year expiry

        nameWrapper.setSubnodeOwner(parentNode, label, msg.sender, fuses, expiry);
        emit SubdomainRegistered(parentNode, label, msg.sender);
    }

    function setRegistrationFee(uint256 _registrationFee) external onlyOwner {
        registrationFee = _registrationFee;
    }

    function setFeeRecipient(address _feeRecipient) external onlyOwner {
        feeRecipient = _feeRecipient;
    }

    function approveWrapperForDomain() external onlyOwner {
        ensRegistrar.setApprovalForAll(address(nameWrapper), true);
    }

    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes calldata
    ) external pure returns (bytes4) {
        return this.onERC1155Received.selector;
    }

    function supportsInterface(bytes4 interfaceId) public pure returns (bool) {
        return interfaceId == 0x4e2312e0;
    }
}