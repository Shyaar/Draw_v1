// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

library LotteryEvents {
    event RoundStarted(uint256 indexed roundId, uint256 endTimestamp);
    event TicketBought(
        address indexed buyer,
        uint256 ethAmount,
        uint256 sharesReceived
    );
    event RandomnessRequested(uint256 requestId);
    event RoundClosed(
        uint256 indexed roundId,
        address indexed winner,
        uint256 prizeAmount
    );
    event PrizeRedeemed(
        uint256 indexed roundId,
        uint256 sharesRedeemed,
        uint256 amountRedeemed
    );
    event PrincipalClaimed(address indexed user, uint256 amount);
    event PrizeClaimed(address indexed winner, uint256 amount);
    event RoundDurationUpdated(uint256 _time);
    event CooldownUpdated(uint256 _time);
}
