// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract airbnb is Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private counter;
  

    struct rentalInfo {
        string name;
        string city;
        string lat;
        string long;
        string firstDescription;
        string secondDescription;
        string imgUrl;
        uint256 maxGuests;
        uint256 pricePerDay;
        string[] datesBooked;
        uint256 id;
        address renter;
    }

    event rentalCreated (
        string name,
        string city,
        string lat,
        string long,
        string firstDescription,
        string secondDescription,
        string imgUrl,
        uint256 maxGuests,
        uint256 pricePerDay,
        string[] datesBooked,
        uint256 id,
        address renter
    );

    event newDatesBooked (
        string[] datesBooked,
        uint256 id,
        address booker,
        string city,
        string imgUrl
    );

    mapping(uint256 => rentalInfo) private rentals;
    uint256[] public rentalIds;

    function addRentals(
        string memory name,
        string memory city,
        string memory lat,
        string memory long,
        string memory firstDescription,
        string memory secondDescription,
        string memory imgUrl,
        uint256 maxGuests,
        uint256 pricePerDay,
        string[] memory datesBooked
    ) public onlyOwner {
        rentalInfo storage newRental = rentals[counter];
        newRental.name = name;
        newRental.city = city;
        newRental.lat = lat;
        newRental.long = long;
        newRental.firstDescription = firstDescription;
        newRental.secondDescription = secondDescription;
        newRental.imgUrl = imgUrl;
        newRental.maxGuests = maxGuests;
        newRental.pricePerDay = pricePerDay;
        newRental.datesBooked = datesBooked;
        newRental.id = counter;
        newRental.renter = owner;
        rentalIds.push(counter);
        emit rentalCreated(
            name,
            city,
            lat,
            long,
            firstDescription,
            secondDescription,
            imgUrl,
            maxGuests,
            pricePerDay,
            datesBooked,
            counter,
            owner
        );
        counter.increment();
    }
    
    function checkBookings(uint256 id, string[] memory newBookings) private view returns (bool) {
        for(uint i = 0; i < newBookings.length; i++) {
            for(uint j = 0; j < rentals[id].datesBooked.length; j++) {
                if (keccak256(abi.encodePacked(rentals[id].datesBooked[j])) == keccak256(abi.encodePacked(newBookings[i]))) {
                    return false;
                }
            }
        }
        return true;
    }

    function addDatesBooked(uint256 id, string[] memory newBookings) public payable {
        require( id < counter, "No such Rental");
        require(checkBookings(id, newBookings), "Already Booked For Requested Date");
        require(msg.value == (rentals[id].pricePerDay * 1 ether * newBookings.length), "Please submit the asking price in order to complete the purchase");
        for(uint i = 0; i < newBookings.length; i++) {
            rentals[id].datesBooked.push(newBookings[i]);
        }
        (bool success, ) = payable(owner).call{value: msg.value}("");
        require(success, "Owner must recieve payment");
        emit newDatesBooked(newBookings, id, msg.sender, rentals[id].city, rentals[id].imgUrl);
    }

    function getRental(uint256 id) public view returns(string memory, uint256, string[] memory) {
        require( id < counter, "No such Rental");
        rentalInfo storage s = rentals[id];
        return(s.name, s.pricePerDay, s.datesBooked);
    }
}