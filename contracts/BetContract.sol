// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import './GameContract.sol';

contract BetContract {

    GameContract gameContract;
    address[] public bidders = new address[](0);
    mapping (address => uint) public bidder2bet;
    mapping (address => address) private bidder2player;
    mapping (address => uint) public player2bid;

    event betAccepted(address indexed _from, uint _value);

    constructor(address gameContractAddress) public {
        gameContract = GameContract(gameContractAddress); 
    }

    modifier hasNoBetYet() {
        require(bidder2bet[msg.sender] == 0, "You already placed a bet.");
        _;
    }

    modifier playerExists(address playerAddress) {
        require(gameContract.containsPlayer(playerAddress), "This player does not exist.");
        _;
    }

    modifier gameFinished() {
        require(gameContract.isGameFinished(), "Game have to finish first.");
        _;
    }

    function placeBet(address playerAddress) external payable hasNoBetYet playerExists(playerAddress) {
        bidders.push(msg.sender);

        bidder2bet[msg.sender] = msg.value;
        bidder2player[msg.sender] = playerAddress;

        player2bid[playerAddress] = player2bid[playerAddress] + msg.value;

        emit betAccepted(msg.sender, msg.value);
    }

    function payOutWinnings() external gameFinished {
        address winner = gameContract.getWinner();
        
        for(uint i = 0; i < bidders.length; i++) {
            uint winning = address(this).balance * bidder2bet[bidders[i]] / player2bid[winner];
            address payable bidderAddress = payable(bidders[i]);
            bidderAddress.transfer(winning);
        }
    }
}