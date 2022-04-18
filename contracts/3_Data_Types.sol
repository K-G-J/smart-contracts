pragma solidity >= 0.7.0 < 0.9.0;

contract myGame {

    uint public playerCount = 0;
    mapping(address => Player) public players;

    enum Level {Novice, Intermediate, Advanced}

    struct Player {
        address playerAddress;
        Level playerLevel;
        string firstName;
        string lastName;
    }
    function addPlayer(string memory firstName, string memory lastName) public {
        players[msg.sender] = Player(msg.sender, Level.Novice, firstName, lastName);
        playerCount += 1;
    }
    function getPlayerLevel(address playerAddress) public view returns(Level) {
        return players[playerAddress].playerLevel;
    }
}