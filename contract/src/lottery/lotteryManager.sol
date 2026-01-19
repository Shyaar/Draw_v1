// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


/**
 * @title LotteryManager
 * @notice Orchestrates a no-loss lottery using USDC deposits and a yield vault.
 *
 * @dev High-level responsibilities:
 * - Manages lottery rounds (start, close, cooldown scheduling)
 * - Accepts USDC deposits, forwards them into a yield-generating vault
 * - Tracks user shares and ticket ownership per round
 * - Requests randomness externally and selects a winner
 * - Redeems only yield as prize, while preserving user principal
 * - Allows users to reclaim principal after round ends
 *
 * @dev What this contract does NOT do:
 * - It does not generate randomness (handled by `randomifier`)
 * - It does not implement yield logic (handled by `TokenVault` + strategy)
 * - It does not custody funds permanently (users always reclaim principal)
 *
 * @dev Funds flow:
 * User USDC → LotteryManager → TokenVault → Strategy
 * Yield → redeemed → winner
 * Principal → redeemed → users
 */


contract LotteryManager is ReentrancyGuard, Ownable {


    // Round state
    bool public roundActive;
    uint256 public roundId;
    uint256 public roundEndTimestamp;

    // Principal / prize accounting
    uint256 public totalPrincipal;
    uint256 public prizeAmountRedeemed;
    uint256 public prizeSharesRedeemed;

    // Randomness
    address public randomifier;
    uint256 public pendingRequestId;
    bool public awaitingRandomness;

    // Winner tracking
    address public winner;
    bool public prizeClaimed;

    // Entries & shares
    address[] public entries;
    mapping(address => uint256) public sharesOf;
    mapping(address => bool) public principalClaimed;

    // Ticket tracking
    struct Ticket {
        uint256 ticketId;
        uint256 roundEndTimestamp;
        uint256 principal;
        address owner;
    }

    uint256 public nextTicketId = 1;
    mapping(address => uint256[]) public userTickets;
    mapping(uint256 => Ticket) public tickets;

    // Scheduling (auto-start / auto-close)
    uint256 public roundDuration;      // seconds (owner configurable)
    uint256 public cooldownPeriod;     // seconds between rounds (owner configurable)
    uint256 public nextRoundStartTime; // earliest timestamp when keeper can start next round


    // -------------------------------
    // Modifiers
    // -------------------------------
    modifier onlyActive() {
        if (!roundActive) revert LotteryErrors.RoundNotActive();
        _;
    }

    modifier onlyEnded() {
        if (roundActive || roundEndTimestamp == 0 || awaitingRandomness)
            revert LotteryErrors.RoundNotEndedOrAwaiting();
        _;
    }

    modifier onlyRandomifier() {
        if (msg.sender != randomifier) revert LotteryErrors.OnlyRandomifier();
        _;
    }


 constructor() Ownable(msg.sender) {
        
    }


// -------------------------------
    // Owner Functions
    // -------------------------------
    function setRandomifier(address _randomifier) external onlyOwner {
        randomifier = _randomifier;
    }

    // Owner-facing manual start (keeps previous behavior for owner)
    function startRound(uint256 durationSeconds) external onlyOwner {
        _startRound(durationSeconds);
    }

    // Owner manual close (keeps previous behavior for owner)
    function closeRound() external onlyOwner {
        _closeRound();
    }

    function resetRoundState() external onlyOwner {
        if (roundActive) revert LotteryErrors.RoundActive();

        delete entries;

        winner = address(0);
        prizeClaimed = false;
        prizeAmountRedeemed = 0;
        prizeSharesRedeemed = 0;
        totalPrincipal = 0;
        roundEndTimestamp = 0;
        awaitingRandomness = false;
        pendingRequestId = 0;

        // Reset tickets
        nextTicketId = 1;
    }

    // Owner can update roundDuration at any time
    function setRoundDuration(uint256 _seconds) external onlyOwner {
        if (_seconds == 0) revert LotteryErrors.InvalidDuration();
        roundDuration = _seconds;
        emit LotteryEvents.RoundDurationUpdated(_seconds);
    }

    // Owner can update cooldown between rounds
    function setCooldownPeriod(uint256 _seconds) external onlyOwner {
        cooldownPeriod = _seconds;
        emit LotteryEvents.CooldownUpdated(_seconds);
    }


}
