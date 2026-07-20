// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Reputation {

    struct UserReputation {
        uint256 totalRatings;
        uint256 ratingCount;
        uint256 completedDeliveries;
    }

    mapping(address => UserReputation)
        public reputations;

    event DeliveryRated(
        address indexed user,
        uint256 rating
    );

    event DeliveryCompleted(
        address indexed user
    );

    function addRating(
        address user,
        uint256 rating
    ) external {

        require(
            user != address(0),
            "Invalid user address"
        );

        require(
            rating >= 1 && rating <= 5,
            "Rating must be between 1 and 5"
        );

        reputations[user].totalRatings += rating;

        reputations[user].ratingCount += 1;

        emit DeliveryRated(
            user,
            rating
        );
    }

    function recordDelivery(
        address user
    ) external {

        require(
            user != address(0),
            "Invalid user address"
        );

        reputations[user].completedDeliveries += 1;

        emit DeliveryCompleted(
            user
        );
    }

    function getAverageRating(
        address user
    ) public view returns (uint256) {

        if (
            reputations[user].ratingCount == 0
        ) {
            return 0;
        }

        return
            reputations[user].totalRatings
            /
            reputations[user].ratingCount;
    }

    function getReputation(
        address user
    )
        external
        view
        returns (
            uint256 averageRating,
            uint256 completedDeliveries
        )
    {
        return (
            getAverageRating(user),
            reputations[user].completedDeliveries
        );
    }
}
