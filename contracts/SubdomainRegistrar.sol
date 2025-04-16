// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;


// interface INameWrapper {
//     function setSubnodeOwner(bytes32 parentNode, string calldata label, address owner, uint32 fuses, uint64 expiry) external;
//     function setSubnodeRecord(bytes32 parentNode, string calldata label, address owner, address resolver, uint64 ttl, uint32 fuses, uint64 expiry) external;
//     function setApprovalForAll(address operator, bool approved) external;
// }

contract SubdomainRegistrar {
    // Placeholder for real ENS interaction
    // INameWrapper public nameWrapper;
    address public resolver;
    uint256 public registrationFee;
    address public feeRecipient;
    address private owner;
    bytes32 private parentNode;

    event RegisterCalled(string message);
    event DebugInfo(string label, address sender, uint256 fee);
    event FeeTransferred(address from, address to, uint256 amount);

    constructor(
        // address _nameWrapper, 
        address _resolver, 
        bytes32 _parentNode, 
        uint256 _registrationFee, 
        address _feeRecipient
    ) payable  {
        // nameWrapper = INameWrapper(_nameWrapper);
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
        emit DebugInfo(label, msg.sender, msg.value);

        require(msg.value >= registrationFee, "Insufficient registration fee");

        // Send ETH to feeRecipient
        payable(feeRecipient).transfer(registrationFee);
        emit FeeTransferred(msg.sender, feeRecipient, registrationFee);

        // Placeholder for ENS interaction
        emit RegisterCalled("registering here");
    }

    function setRegistrationFee(uint256 _registrationFee) external onlyOwner {
        registrationFee = _registrationFee;
    }

    function setFeeRecipient(address _feeRecipient) external onlyOwner {
        feeRecipient = _feeRecipient;
    }
}
