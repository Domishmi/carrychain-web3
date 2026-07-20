// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title CarryChain Reward Token
 * @notice CARRY token rewards travelers for successful deliveries
 */
contract CarryToken {

    string public name = "CarryChain Token";
    string public symbol = "CARRY";
    uint8 public decimals = 18;

    uint256 public totalSupply;

    address public owner;

    mapping(address => uint256) public balanceOf;

    mapping(address => mapping(address => uint256))
        public allowance;

    event Transfer(
        address indexed from,
        address indexed to,
        uint256 value
    );

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    modifier onlyOwner() {
        require(
            msg.sender == owner,
            "Only owner can perform this action"
        );
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    /**
     * @notice Mint CARRY tokens as delivery rewards
     */
    function mint(
        address recipient,
        uint256 amount
    ) external onlyOwner {

        require(
            recipient != address(0),
            "Invalid recipient"
        );

        balanceOf[recipient] += amount;
        totalSupply += amount;

        emit Transfer(
            address(0),
            recipient,
            amount
        );
    }

    /**
     * @notice Transfer CARRY tokens
     */
    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool) {

        require(
            balanceOf[msg.sender] >= amount,
            "Insufficient balance"
        );

        balanceOf[msg.sender] -= amount;
        balanceOf[recipient] += amount;

        emit Transfer(
            msg.sender,
            recipient,
            amount
        );

        return true;
    }

    /**
     * @notice Approve another address to spend tokens
     */
    function approve(
        address spender,
        uint256 amount
    ) external returns (bool) {

        allowance[msg.sender][spender] = amount;

        emit Approval(
            msg.sender,
            spender,
            amount
        );

        return true;
    }

    /**
     * @notice Transfer tokens from another account
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool) {

        require(
            balanceOf[sender] >= amount,
            "Insufficient balance"
        );

        require(
            allowance[sender][msg.sender] >= amount,
            "Allowance exceeded"
        );

        balanceOf[sender] -= amount;
        balanceOf[recipient] += amount;

        allowance[sender][msg.sender] -= amount;

        emit Transfer(
            sender,
            recipient,
            amount
        );

        return true;
    }
}
