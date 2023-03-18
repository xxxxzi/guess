// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

contract Guess {
    address public creator;
    uint public guessNumber;
    uint public condition;
    mapping (address => uint) public playerGuess;
    mapping (address => uint) public playerStake;
    address[] playerAddresses;
    uint public prizePool;

    enum Conditions {
        LessThan,
        Equal,
        GreaterThan
    }

    constructor() {
        creator = msg.sender;
    }

    function setGuessNumber(uint _guessNumber) public {
        require(msg.sender == creator, "Only the creator can set the guess number.");
        guessNumber = _guessNumber;
    }

    function setCondition(Conditions _condition) public {
        require(msg.sender == creator, "Only the creator can set the condition.");
        condition = uint(_condition);
    }

    function participate(uint _guess) public payable {
        require(msg.value > 0, "You must stake a positive value.");
        playerGuess[msg.sender] = _guess;
        playerStake[msg.sender] = msg.value;
        prizePool += msg.value;
        playerAddresses.push(msg.sender);
    }

    function trigger() public {
        require(msg.sender == creator, "Only the creator can trigger the distribution of the prize pool.");

        address[] memory winners = new address[](1);
        uint j = 0;
        for (uint i = 0; i < playerAddresses.length; i++) {
            address playerAddress = playerAddresses[i];
            if (condition == uint(Conditions.LessThan) && playerGuess[playerAddress] < guessNumber) {
                winners[j] = playerAddress;
                j++;
            } else if (condition == uint(Conditions.Equal) && playerGuess[playerAddress] == guessNumber) {
                winners[j] = playerAddress;
                j++;
            } else if (condition == uint(Conditions.GreaterThan) && playerGuess[playerAddress] > guessNumber) {
                winners[j] = playerAddress;
                j++;
            }
        }
        uint winnerCount = winners.length;
        for (uint i = 0; i < winnerCount; i++) {
            address payable winnerAddress = payable(winners[i]);
            winnerAddress.transfer(prizePool / winnerCount);
        }
    }
}
