// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

/// @title AgentTip - Tip any Agent ID holder by their .ai name
/// @notice Send BNB to any Agent ID holder using their handle (e.g. "tesla666").
///         Both sender and recipient must hold an Agent ID (SPACE ID Agent ID,
///         0x60b9262456de011f7d15a54cdd8c48baaa8b022f on BNB Chain).
///         No owner, no admin, no fees: 100% of every tip goes to the recipient.
///         Self-tips are rejected to prevent wash volume.
interface IAgentID {
    function balanceOf(address account) external view returns (uint256);
    function ownerOfHandle(string calldata handle) external view returns (address);
    function handleOf(address account) external view returns (string memory);
}

contract AgentTip {
    IAgentID public immutable agentId;

    uint256 public totalTips;
    uint256 public totalVolume;

    event Tipped(
        address indexed sender,
        address indexed recipient,
        string senderHandle,
        string recipientHandle,
        uint256 amount,
        string message,
        uint256 timestamp
    );

    error NotAgentIDHolder();
    error InvalidHandle();
    error SelfTipNotAllowed();
    error NoValue();
    error TransferFailed();

    constructor(address _agentId) {
        agentId = IAgentID(_agentId);
    }

    /// @notice Tip an Agent ID holder by handle (without the ".ai" suffix).
    /// @param recipientHandle e.g. "tesla666" for tesla666.ai
    /// @param message Optional message shown with the tip (may be empty).
    function tip(string calldata recipientHandle, string calldata message) external payable {
        address recipient = agentId.ownerOfHandle(recipientHandle);
        _tip(recipient, recipientHandle, message);
    }

    /// @notice Tip an Agent ID holder directly by wallet address.
    function tipByAddress(address recipient, string calldata message) external payable {
        _tip(recipient, agentId.handleOf(recipient), message);
    }

    function _tip(address recipient, string memory recipientHandle, string memory message) internal {
        if (msg.value == 0) revert NoValue();
        if (agentId.balanceOf(msg.sender) == 0) revert NotAgentIDHolder();
        if (recipient == address(0)) revert InvalidHandle();
        if (recipient == msg.sender) revert SelfTipNotAllowed();
        if (agentId.balanceOf(recipient) == 0) revert NotAgentIDHolder();

        totalTips += 1;
        totalVolume += msg.value;

        (bool ok, ) = recipient.call{value: msg.value}("");
        if (!ok) revert TransferFailed();

        emit Tipped(
            msg.sender,
            recipient,
            agentId.handleOf(msg.sender),
            recipientHandle,
            msg.value,
            message,
            block.timestamp
        );
    }

    /// @notice Resolve a handle (e.g. "tesla666") to its wallet address.
    function resolveHandle(string calldata handle) external view returns (address) {
        return agentId.ownerOfHandle(handle);
    }

    /// @notice Get the handle of a wallet address ("" if it holds no Agent ID).
    function getHandle(address account) external view returns (string memory) {
        return agentId.handleOf(account);
    }

    /// @notice Check whether an address holds an Agent ID.
    function isAgentIDHolder(address account) external view returns (bool) {
        return agentId.balanceOf(account) > 0;
    }

    // The contract never holds funds: every tip is forwarded in the same call.
    // No receive() / fallback() on purpose, so BNB cannot get stuck here.
}
