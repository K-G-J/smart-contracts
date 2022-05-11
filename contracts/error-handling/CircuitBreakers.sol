// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract CircuitBreakers {
    bool private stopped = false;
    address private owner;

    modifier isAdmin() {
        require(msg.sender == owner);
        _;
    }

    function toggleContractActive() isAdmin public {
        stopped = !stopped;
    }

    modifier stopInEmergency {if (!stopped) _;}
    modifier onlyInEmergency { if (stopped) _;}

    function deposit() stopInEmergency public {
        // some code
    } 

    function withdraw() onlyInEmergency public {
        // some code 
    }
}