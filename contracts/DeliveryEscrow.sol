// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title CarryChain Delivery Escrow
 * @notice USDC escrow system for decentralized parcel delivery
 */
contract DeliveryEscrow {

    enum DeliveryStatus {
        Created,
        Accepted,
        Delivered,
        Completed,
        Cancelled
    }

    struct Delivery {
        uint256 id;
        address sender;
        address traveler;
        address receiver;
        uint256 reward;
        string pickupLocation;
        string deliveryLocation;
        DeliveryStatus status;
    }

    uint256 public nextDeliveryId;

    mapping(uint256 => Delivery) public deliveries;

    event DeliveryCreated(
        uint256 indexed deliveryId,
        address indexed sender,
        address receiver,
        uint256 reward
    );

    event DeliveryAccepted(
        uint256 indexed deliveryId,
        address indexed traveler
    );

    event DeliveryCompleted(
        uint256 indexed deliveryId,
        address indexed traveler,
        uint256 reward
    );

    function createDelivery(
        address receiver,
        string memory pickupLocation,
        string memory deliveryLocation
    ) external payable {

        require(msg.value > 0, "Reward must be greater than zero");

        deliveries[nextDeliveryId] = Delivery({
            id: nextDeliveryId,
            sender: msg.sender,
            traveler: address(0),
            receiver: receiver,
            reward: msg.value,
            pickupLocation: pickupLocation,
            deliveryLocation: deliveryLocation,
            status: DeliveryStatus.Created
        });

        emit DeliveryCreated(
            nextDeliveryId,
            msg.sender,
            receiver,
            msg.value
        );

        nextDeliveryId++;
    }

    function acceptDelivery(uint256 deliveryId) external {

        Delivery storage delivery = deliveries[deliveryId];

        require(
            delivery.status == DeliveryStatus.Created,
            "Delivery is not available"
        );

        require(
            msg.sender != delivery.sender,
            "Sender cannot be traveler"
        );

        delivery.traveler = msg.sender;
        delivery.status = DeliveryStatus.Accepted;

        emit DeliveryAccepted(
            deliveryId,
            msg.sender
        );
    }

    function confirmDelivery(uint256 deliveryId) external {

        Delivery storage delivery = deliveries[deliveryId];

        require(
            msg.sender == delivery.receiver,
            "Only receiver can confirm delivery"
        );

        require(
            delivery.status == DeliveryStatus.Accepted,
            "Delivery is not accepted"
        );

        delivery.status = DeliveryStatus.Completed;

        payable(delivery.traveler).transfer(
            delivery.reward
        );

        emit DeliveryCompleted(
            deliveryId,
            delivery.traveler,
            delivery.reward
        );
    }

    function getDelivery(
        uint256 deliveryId
    )
        external
        view
        returns (Delivery memory)
    {
        return deliveries[deliveryId];
    }
}
