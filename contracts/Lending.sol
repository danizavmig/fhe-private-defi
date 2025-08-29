// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * Demo-only contract to illustrate how a DeFi lending flow could
 * store and manage ENCRYPTED (ciphertext) values on an FHE-enabled EVM.
 * In a real FHEVM environment, ciphertext types and FHE ops would be used.
 * Here we use bytes to represent ciphertext placeholders.
 */
contract Lending {
    struct EncryptedPosition {
        address user;
        bytes encryptedCollateral; // ciphertext for collateral amount
        bytes encryptedLoan;       // ciphertext for loan amount
        bytes encryptedRate;       // ciphertext for interest rate
        uint256 createdAt;
        bool active;
    }

    // Position id => data
    mapping(uint256 => EncryptedPosition) public positions;
    uint256 public nextId;

    // Simple aggregates (plaintext counters, encrypted values are in events/storage)
    uint256 public activeCount;
    uint256 public closedCount;

    event PositionOpened(
        uint256 indexed id,
        address indexed user,
        bytes encryptedCollateral,
        bytes encryptedLoan,
        bytes encryptedRate
    );

    event PositionUpdated(
        uint256 indexed id,
        bytes newEncryptedLoan,
        bytes newEncryptedRate
    );

    event PositionClosed(
        uint256 indexed id,
        bytes encryptedRepayAmount // ciphertext for repayment
    );

    /// @notice Open a new encrypted lending position
    function openPosition(
        bytes calldata _encryptedCollateral,
        bytes calldata _encryptedLoan,
        bytes calldata _encryptedRate
    ) external returns (uint256 id) {
        id = nextId++;
        positions[id] = EncryptedPosition({
            user: msg.sender,
            encryptedCollateral: _encryptedCollateral,
            encryptedLoan: _encryptedLoan,
            encryptedRate: _encryptedRate,
            createdAt: block.timestamp,
            active: true
        });
        activeCount += 1;

        emit PositionOpened(id, msg.sender, _encryptedCollateral, _encryptedLoan, _encryptedRate);
    }

    /// @notice Update encrypted loan parameters (e.g., refinancing)
    function updatePosition(
        uint256 id,
        bytes calldata _newEncryptedLoan,
        bytes calldata _newEncryptedRate
    ) external {
        EncryptedPosition storage p = positions[id];
        require(p.user == msg.sender, "Not owner");
        require(p.active, "Closed");
        p.encryptedLoan = _newEncryptedLoan;
        p.encryptedRate = _newEncryptedRate;

        emit PositionUpdated(id, _newEncryptedLoan, _newEncryptedRate);
    }

    /// @notice Close the position with an encrypted repayment amount
    function closePosition(uint256 id, bytes calldata _encryptedRepayAmount) external {
        EncryptedPosition storage p = positions[id];
        require(p.user == msg.sender, "Not owner");
        require(p.active, "Already closed");
        p.active = false;
        activeCount -= 1;
        closedCount += 1;

        emit PositionClosed(id, _encryptedRepayAmount);
    }

    /// @notice Lightweight view to help UIs know which positions are still active
    function isActive(uint256 id) external view returns (bool) {
        return positions[id].active;
    }
}
