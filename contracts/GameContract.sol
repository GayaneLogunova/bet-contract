// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract GameContract {

    address[] players;
    uint public gameContractStartTime;
    uint private constant VOTING_DURATION = 30;

    constructor(address[] memory _players) {
        players = _players;
        gameContractStartTime = block.timestamp;
    }

    modifier gameFinished() {
        require(this.isGameFinished(), "Game is not finished yet!");
        _;
    }

    function getWinner() external gameFinished returns(address) {
        return players[0];
    }

    function isGameFinished() external returns(bool) {
        return block.timestamp > gameContractStartTime + VOTING_DURATION;
    }

    function containsPlayer(address player) external returns(bool) {
        for (uint i = 0; i < players.length; i++) {
            if (players[i] == player) {
                return true;
            }
        }
        return false;
    }
}