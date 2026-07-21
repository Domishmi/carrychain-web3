// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/**
 * @title CarryChain Delivery Escrow
 * @notice USDC escrow system for decentralized parcel delivery
 */
contract DeliveryEscrow is ReentrancyGuard {

    IERC20 public immutable usdc;

    enum DeliveryStatus {
        Created,
        Accepted,
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
        address indexed receiver,
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

    event DeliveryCancelled(
        uint256 indexed deliveryId,
        uint256 refund
    );

    constructor(address usdcAddress) {
        require(
            usdcAddress != address(0),
            "Invalid USDC address"
        );

        usdc = IERC20(usdcAddress);
    }

    function createDelivery(
        address receiver,
        uint256 reward,
        string calldata pickupLocation,
        string calldata deliveryLocation
    ) external {

        require(
            receiver != address(0),
            "Invalid receiver"
        );

        require(
            reward > 0,
            "Reward must be greater than zero"
        );

        bool success = usdc.transferFrom(
            msg.sender,
            address(this),
            reward
        );

        require(
            success,
            "USDC transfer failed"
        );

        deliveries[nextDeliveryId] = Delivery({
            id: nextDeliveryId,
            sender: msg.sender,
            traveler: address(0),
            receiver: receiver,
            reward: reward,
            pickupLocation: pickupLocation,
            deliveryLocation: deliveryLocation,
            status: DeliveryStatus.Created
        });

        emit DeliveryCreated(
            nextDeliveryId,
            msg.sender,
            receiver,
            reward
        );

        nextDeliveryId++;
    }

    function acceptDelivery(
        uint256 deliveryId
    ) external {

        Delivery storage delivery =
            deliveries[deliveryId];

        require(
            delivery.status ==
            DeliveryStatus.Created,
            "Delivery is not available"
        );

        require(
            msg.sender != delivery.sender,
            "Sender cannot be traveler"
        );

        require(
            msg.sender != delivery.receiver,
            "Receiver cannot be traveler"
        );

        delivery.traveler = msg.sender;

        delivery.status =
            DeliveryStatus.Accepted;

        emit DeliveryAccepted(
            deliveryId,
            msg.sender
        );
    }

    function confirmDelivery(
        uint256 deliveryId
    ) external nonReentrant {

        Delivery storage delivery =
            deliveries[deliveryId];

        require(
            msg.sender == delivery.receiver,
            "Only receiver can confirm delivery"
        );

        require(
            delivery.status ==
            DeliveryStatus.Accepted,
            "Delivery is not accepted"
        );

        delivery.status =
            DeliveryStatus.Completed;

        bool success = usdc.transfer(
            delivery.traveler,
            delivery.reward
        );

        require(
            success,
            "USDC payment failed"
        );
emit DeliveryCompleted(
            deliveryId,
            delivery.traveler,
            delivery.reward
        );
    }

    function cancelDelivery(
        uint256 deliveryId
    ) external nonReentrant {

        Delivery storage delivery =
            deliveries[deliveryId];

        require(
            msg.sender == delivery.sender,
            "Only sender can cancel"
        );

        require(
            delivery.status ==
            DeliveryStatus.Created,
            "Cannot cancel delivery"
        );

        delivery.status =
            DeliveryStatus.Cancelled;

        bool success = usdc.transfer(
            delivery.sender,
            delivery.reward
        );

        require(
            success,
            "Refund failed"
        );

        emit DeliveryCancelled(
            deliveryId,
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
