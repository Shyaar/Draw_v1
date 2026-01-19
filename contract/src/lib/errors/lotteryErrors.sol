// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

library LotteryErrors {
    error RoundNotActive();
    error RoundActive();
    error RoundNotEnded();
    error OnlyRandomifier();
    error ZeroAddress();
    error InvalidDuration();
    error PreviousRoundNotCleaned();
    error MustSendUSDC();
    error NoSharesMinted();
    error RoundNotEndedOrAwaiting();
    error RandomifierNotSet();
    error NoRandomnessPending();
    error BadRequestId();
    error NoPrincipal();
    error AlreadyClaimed();
    error EthTransferFailed();
    error NotWinner();
    error PrizeAlreadyClaimed();
    error NoPrizeToClaim();
    error CannotStart();
    error CannotClose();
    error ERC20TransferFailed();
}
