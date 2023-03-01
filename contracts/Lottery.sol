// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
// import "truffle/console.sol";
contract Lottery {
    uint public currentRound;
    uint public currentPot;
    uint public currentMaxPlayers = 2;

    address[] public players;
    mapping(address => bool) public playerExists;
    mapping(address => uint) public playerStakes;
    mapping(address => uint) public playerHistoryStakes;
    
    event NewRound(uint round);
    event NewPlayer(address player);
    event RoundCancelled();
    event WinnerSelected(address winner, uint winnings);

    constructor() {
        newRound();
    }
    
    function newRound() private {
        players = new address[](0);
        // reset playerExists to empty
        for (uint i = 0; i < players.length; i++) {
            playerExists[players[i]] = false;
        }
        // reset playerStakes to empty
        for (uint i = 0; i < players.length; i++) {
            playerStakes[players[i]] = 0;
        }

        currentPot = 0;
        currentRound++;
        currentMaxPlayers = 2;
        // + uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty))) % 9;
        // console.log("Telephone::constructor\n\tsecret: %o", currentMaxPlayers); 

        emit NewRound(currentRound);
    }

    function joinLottery() public payable {
        require(msg.value > 0, "Minimum price is 1 wei");
        require(!playerExists[msg.sender], "You've already joined the lottery today");
        require(players.length < currentMaxPlayers, "Max number of players reached, you cant join the lottery");
        players.push(msg.sender);
        playerExists[msg.sender] = true;
        playerStakes[msg.sender] = msg.value;
        currentPot += msg.value;
        emit NewPlayer(msg.sender);
        if (players.length == currentMaxPlayers) {
            selectWinner();
        }
    }

    function leaveLottery() public {
        require(playerExists[msg.sender], "You haven't joined the lottery today");
        for (uint i = 0; i < players.length; i++) {
            if (players[i] == msg.sender) {
                players[i] = players[players.length - 1];
                players.pop();
                break;
            }
        }
        playerExists[msg.sender] = false;
        currentPot -= playerStakes[msg.sender];
        playerHistoryStakes[msg.sender] += playerStakes[msg.sender];
        playerStakes[msg.sender] = 0;
    }
    
    function selectWinner() private {
        require(players.length >= 2, "Not enough players to select a winner");

        uint totalStake = 0;
        uint[] memory probabilities = new uint[](players.length);
        for (uint i = 0; i < players.length; i++) {
            totalStake += players[i].balance;
        }
        for (uint i = 0; i < players.length; i++) {
            probabilities[i] = players[i].balance * 100 / totalStake;
        }

        uint randomNumber = uint(keccak256(abi.encodePacked(block.timestamp, block.difficulty, players)));
        uint winningProbability = randomNumber % 100;

        uint currentProbability = 0;
        uint winnerIndex = 0;
        for (uint i = 0; i < probabilities.length; i++) {
            currentProbability += probabilities[i];
            if (currentProbability > winningProbability) {
                winnerIndex = i;
                break;
            }
        }

        address winner = players[winnerIndex];

        // Call returns a boolean value indicating success or failure.
        // This is the current recommended method to use.
        (bool sent, bytes memory data) = winner.call{value: currentPot}("");
        require(sent, "Failed to send Ether");

        // Emit event to announce the winner
        emit WinnerSelected(winner, currentPot);

        // update all attended playerHistoryStakes
        for (uint i = 0; i < players.length; i++) {
            playerHistoryStakes[players[i]] += playerStakes[players[i]];
        }

        // Start a new lottery round
        newRound();
    }
    
    function cancelLottery() public {
        require(players.length < 2, "Cannot cancel lottery with 2 or more players");
        currentPot = 0;
        currentRound++;
        emit RoundCancelled();
        newRound();
    }

    // view current players and its stakes
    function getPlayers() public view returns (address[] memory) {
        return players;
    }
    // view current players and its stakes
    function getPlayerStakes() public view returns (uint[] memory) {
        uint[] memory stakes = new uint[](players.length);
        for (uint i = 0; i < players.length; i++) {
            stakes[i] = playerStakes[players[i]];
        }
        return stakes;
    }

    function getCurrentRound() public view returns (uint) {
        return currentRound;
    }

    function getCurrentMaxPlayers() public view returns (uint) {
        return currentMaxPlayers;
    }

    function getCurrentPot() public view returns (uint) {
        return currentPot;
    }

    function getPlayerHistoryStakes() public view returns (uint) {
        return playerHistoryStakes[msg.sender];
    }

    function getContractBalance() public view returns (uint) {
        return address(this).balance;
    }

    function getContractAddress() public view returns (address) {
        return address(this);
    }

    function getBlockDifficulty() public view returns (uint) {
        return block.difficulty;
    }

    function getBlockTimestamp() public view returns (uint) {
        return block.timestamp;
    }

    function getBlockNumber() public view returns (uint) {
        return block.number;
    }

    function getBlockGasLimit() public view returns (uint) {
        return block.gaslimit;
    }

    function getBlockCoinbase() public view returns (address) {
        return block.coinbase;
    }

    function getBlockHash() public view returns (bytes32) {
        return blockhash(block.number - 1);
    }
}
