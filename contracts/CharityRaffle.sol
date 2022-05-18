// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "@chainlink/contracts/src/v0.8/interfaces/KeeperCompatibleInterface.sol";
import "hardhat/console.sol";

error Raffle__UpkeepNotNeeded(uint256 currentBalance, uint256 numPlayers, uint256 raffleState);
error Raffle__TransferFailed();
error Raffle__SendMoreToEnterRaffle();
error Raffle__RaffleNotOpen();
error Raffle__RaffleNotClosed();
error Raffle__MustBeFunder();

contract Raffle is VRFConsumerBaseV2, KeeperCompatibleInterface {
    /* Type declarations */
    enum RaffleState {
        OPEN,
        CALCULATING,
        CLOSED
    }
    /* State variables */
    // Chainlink VRF Variables
    VRFCoordinatorV2Interface private immutable i_vrfCoordinator;
    uint16 private constant REQUEST_CONFIRMATIONS = 3;
    uint32 private constant NUM_WORDS = 1;
    uint32 private immutable i_callbackGasLimit;
    uint64 private immutable i_subscriptionId;
    bytes32 private immutable i_gasLane;

    // Lottery Variables
    uint256 private immutable i_interval;
    uint256 private immutable i_entranceFee;
    uint256 private s_highestDonations;
    address private s_recentWinner;
    address payable private immutable i_charity1;
    address payable private immutable i_charity2;
    address payable private immutable i_charity3;
    address private immutable i_fundingWallet;
    address payable private s_charityWinner;
    
    address payable[] private s_players;
    RaffleState private s_raffleState;

    mapping (address => uint256) donations;

    /* Events */
    event RequestedRaffleWinner(uint256 indexed requestId);
    event RaffleEnter(address indexed player);
    event WinnerPicked(address indexed player);
    event CharityWinnerPicked(address charity);

    /* Functions */
    constructor(
        address vrfCoordinatorV2,
        uint64 subscriptionId,
        bytes32 gasLane, // keyHash
        uint256 interval,
        uint256 entranceFee,
        uint32 callbackGasLimit,
        address charity1,
        address charity2,
        address charity3,
        address fundingWallet
    ) VRFConsumerBaseV2(vrfCoordinatorV2) {
        i_vrfCoordinator = VRFCoordinatorV2Interface(vrfCoordinatorV2);
        i_gasLane = gasLane;
        i_interval = interval;
        i_subscriptionId = subscriptionId;
        i_entranceFee = entranceFee;
        s_raffleState = RaffleState.OPEN;
        i_callbackGasLimit = callbackGasLimit;
        i_charity1 = charity1;
        i_charity2 = charity2;
        i_charity3 = charity3;
        i_fundingWallet = fundingWallet;
    }

    function enterRaffle(uint256 charityChoice) public payable {
        if (msg.value < i_entranceFee) {
            revert Raffle__SendMoreToEnterRaffle();
        }
        if (s_raffleState != RaffleState.OPEN) {
            revert Raffle__RaffleNotOpen();
        }
        if (charityChoice == 1) {
            (bool success, ) = i_charity1.call{value: msg.value}("");
            if (!success) {
                revert Raffle__TransferFailed();
            }
            donations[i_charity1]++;
        }
         if (charityChoice == 2) {
            (bool success, ) = i_charity2.call{value: msg.value}("");
            if (!success) {
                revert Raffle__TransferFailed();
            }
            donations[i_charity2]++;
        }
         if (charityChoice == 3) {
            (bool success, ) = i_charity3.call{value: msg.value}("");
            if (!success) {
                revert Raffle__TransferFailed();
            }
            donations[i_charity3]++;
        }
        s_players.push(payable(msg.sender));
        emit RaffleEnter(msg.sender);
    }

    /*
     * This is the function that the Chainlink Keeper nodes call
     * they look for `upkeepNeeded` to return True.
     * the following should be true for this to return true:
     * 1. The time interval has passed between raffle runs.
     * 2. The lottery is open.
     * 3. The contract has ETH.
     * 4. Implicity, your subscription is funded with LINK.
     */
    function checkUpkeep(bytes memory /* checkData */) public view override returns (bool upkeepNeeded, bytes memory /* performData */)
    {
        bool isOpen = RaffleState.OPEN == s_raffleState;
        bool hasPlayers = s_players.length > 0;
        bool hasBalance = address(this).balance > 0;
        upkeepNeeded = (isOpen && hasBalance && hasPlayers);
    }

    function performUpkeep(bytes calldata /* performData */) external override {
        (bool upkeepNeeded, ) = checkUpkeep("");
        if (!upkeepNeeded) {
            revert Raffle__UpkeepNotNeeded(
                address(this).balance,
                s_players.length,
                uint256(s_raffleState)
            );
        }
        s_raffleState = RaffleState.CALCULATING;
        uint256 requestId = i_vrfCoordinator.requestRandomWords(
            i_gasLane,
            i_subscriptionId,
            REQUEST_CONFIRMATIONS,
            i_callbackGasLimit,
            NUM_WORDS
        );
        emit RequestedRaffleWinner(requestId);
    }

    function fulfillRandomWords(uint256, /* requestId */ uint256[] memory randomWords) internal override {
        uint256 indexOfWinner = randomWords[0] % s_players.length;
        address payable recentWinner = s_players[indexOfWinner];
        s_recentWinner = recentWinner;
        s_players = new address payable[](0);
        s_raffleState = RaffleState.CLOSED;
        (bool success, ) = recentWinner.call{value: address(this).balance}("");
        if (!success) {
            revert Raffle__TransferFailed();
        }
        if (donations[i_charity1] > donations[i_charity2] && donations[i_charity1] > donations[i_charity3]) {
            s_highestDonations = donations[i_charity1];
            s_charityWinner = i_charity1;
            donations[i_charity1] = 0;
            donations[i_charity2] = 0;
            donations[i_charity3] = 0;
            emit CharityWinnerPicked(i_charity1);
        }
        if (donations[i_charity2] > donations[i_charity1] && donations[i_charity2] > donations[i_charity3]) {
            s_highestDonations = donations[i_charity2];
            s_charityWinner = i_charity2;
            donations[i_charity1] = 0;
            donations[i_charity2] = 0;
            donations[i_charity3] = 0;
            emit CharityWinnerPicked(i_charity2);
        }
        if (donations[i_charity3] > donations[i_charity1] && donations[i_charity3] > donations[i_charity1]) {
            s_highestDonations = donations[i_charity3];
            s_charityWinner = i_charity3;
            donations[i_charity1] = 0;
            donations[i_charity2] = 0;
            donations[i_charity3] = 0;
            emit CharityWinnerPicked(i_charity3);
        }
         emit WinnerPicked(recentWinner);
    }

    function matchDonations() external {
        if (s_raffleState != RaffleState.CLOSED) {
            revert Raffle__RaffleNotClosed();
        }
        if (msg.sender != i_fundingWallet) {
            revert Raffle__MustBeFunder();
        }
        uint256 mostDonations = s_highestDonations;
        s_highestDonations = 0;
        (bool success, ) = payable(address(this)).call{value: mostDonations * i_entranceFee}("");
        if (!success) {
            revert Raffle__TransferFailed();
        }
    }

    /** Getter Functions */

    function getRaffleState() public view returns (RaffleState) {
        return s_raffleState;
    }

    function getNumWords() public pure returns (uint256) {
        return NUM_WORDS;
    }

    function getRequestConfirmations() public pure returns (uint256) {
        return REQUEST_CONFIRMATIONS;
    }

    function getRecentWinner() public view returns (address) {
        return s_recentWinner;
    }

    function getPlayer(uint256 index) public view returns (address) {
        return s_players[index];
    }

    function getLastTimeStamp() public view returns (uint256) {
        return s_lastTimeStamp;
    }

    function getInterval() public view returns (uint256) {
        return i_interval;
    }

    function getEntranceFee() public view returns (uint256) {
        return i_entranceFee;
    }

    function getNumberOfPlayers() public view returns (uint256) {
        return s_players.length;
    }
}
