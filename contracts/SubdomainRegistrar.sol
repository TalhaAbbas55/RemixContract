// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface INameWrapper {
    function setSubnodeOwner(bytes32 parentNode, string calldata label, address owner, uint32 fuses, uint64 expiry) external;
    function setSubnodeRecord(bytes32 parentNode, string calldata label, address owner, address resolver, uint64 ttl, uint32 fuses, uint64 expiry) external;
    function setApprovalForAll(address operator, bool approved) external;
    function wrapETH2LD(string calldata label, address wrappedOwner, uint16 ownerControlledFuses, address resolver) external;
}

interface IERC20 {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
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

    event LogPaymentDetails(uint256 msgValue, uint256 registrationFee);
    event SubdomainRegistered(bytes32 indexed parentNode, string label, address indexed owner);

    constructor(
        address _nameWrapper,
        address _ensRegistrar,
        address _resolver,
        bytes32 _parentNode,
        uint256 _registrationFee,
        address _feeRecipient
    ) payable {
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
        emit LogPaymentDetails(msg.value, registrationFee);
        require(msg.value >= registrationFee, "Insufficient registration fee");

        if (registrationFee > 0) {
            payable(feeRecipient).transfer(registrationFee);
        }

        uint32 fuses = 327680;
        uint64 expiry = uint64(block.timestamp + 31536000);

        nameWrapper.setSubnodeRecord(parentNode, label, msg.sender, resolver, 0, fuses, expiry);
        emit SubdomainRegistered(parentNode, label, msg.sender);
    }

    function setRegistrationFee(uint256 _registrationFee) external onlyOwner {
        registrationFee = _registrationFee;
    }

    function setFeeRecipient(address _feeRecipient) external onlyOwner {
        feeRecipient = _feeRecipient;
    }

    // 👇 Wrap the domain "talha.eth"
    function wrapDomain() external onlyOwner {
        nameWrapper.wrapETH2LD("talha", address(this), 0, resolver);
    }

    // 👇 Approve NameWrapper contract to take over the domain
    function approveWrapperForDomain() external onlyOwner {
        ensRegistrar.setApprovalForAll(address(nameWrapper), true);
    }
}
