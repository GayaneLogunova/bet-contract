// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract GameContract {

    address[] players;
    mapping (address => uint) private players2decision;

    uint public gameContractStartTime;
    uint private constant VOTING_DURATION = 30;

    event winnerChoosed(address _winner);

    constructor(address[] memory _players) {
        players = _players;
        gameContractStartTime = block.timestamp;
    }

    modifier gameIsActive() {
        require(!this.isGameFinished(), "Game finished!");
        _;
    }

    modifier gameFinished() {
        require(this.isGameFinished(), "Game is not finished yet!");
        _;
    }

    modifier hasNoDecisionYet() {
        require(players2decision[msg.sender] == 0, "You already made a decision!");
        _;
    }

    function makeADecision() external payable gameIsActive hasNoDecisionYet {
        players2decision[msg.sender] = msg.value;
    }

    function getWinner() external gameFinished returns(address) {
        uint total = 0;
        address winner = players[0];
        for (uint i = 0; i < players.length; i++) {
            total = total + players2decision[players[i]];
            if (players2decision[players[i]] > players2decision[winner]) {
                winner = players[i];
            }
        }
        emit winnerChoosed(winner);
        return winner;
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