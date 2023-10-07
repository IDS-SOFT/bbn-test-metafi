// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract MetaFiLendingPlatform {
    // Address of the token used for lending and borrowing
    IERC20 public token;

    // Mapping to track user balances
    mapping(address => uint256) public balances;

    // Mapping to track user borrowings
    mapping(address => uint256) public borrowings;

    // Mapping to track the allowed borrowers
    mapping(address => mapping(address => uint256)) public allowedBorrowers;

    // Interest rate (annual percentage rate)
    uint256 public interestRate;

    // Minimum collateral ratio required
    uint256 public minCollateralRatio;

    // Contract owner
    address public owner;

    event CheckBalance(uint amount);

    constructor(
        address _tokenAddress,
        uint256 _interestRate,
        uint256 _minCollateralRatio
    ) {
        token = IERC20(_tokenAddress);
        interestRate = _interestRate;
        minCollateralRatio = _minCollateralRatio;
        owner = msg.sender;
    }

    // Allow users to deposit tokens into the MetaFi platform
    function deposit(uint256 amount) external {
        require(amount > 0, "Amount must be greater than 0");
        require(
            token.transferFrom(msg.sender, address(this), amount),
            "Token transfer failed"
        );

        balances[msg.sender] += amount;
    }

    // Allow users to withdraw their deposited tokens
    function withdraw(uint256 amount) external {
        require(balances[msg.sender] >= amount, "Insufficient balance");
        balances[msg.sender] -= amount;

        require(token.transfer(msg.sender, amount), "Token transfer failed");
    }

    // Allow users to borrow tokens against their collateral
    function borrow(uint256 amount) external {
        require(amount > 0, "Amount must be greater than 0");
        require(
            (balances[msg.sender] - borrowings[msg.sender]) >= amount,
            "Insufficient collateral"
        );

        uint256 interest = (amount * interestRate) / 100;
        uint256 totalAmount = amount + interest;

        require(
            token.transfer(msg.sender, amount),
            "Token transfer to borrower failed"
        );
        require(
            token.transfer(owner, interest),
            "Token transfer of interest to owner failed"
        );

        borrowings[msg.sender] += totalAmount;
    }

    // Allow borrowers to repay their borrowings
    function repay(uint256 amount) external {
        require(borrowings[msg.sender] >= amount, "Insufficient borrowings");

        borrowings[msg.sender] -= amount;

        require(
            token.transferFrom(msg.sender, address(this), amount),
            "Token transfer failed"
        );
    }

    // Set the minimum collateral ratio required
    function setMinCollateralRatio(uint256 _minCollateralRatio) external {
        require(msg.sender == owner, "Only the owner can set the ratio");
        minCollateralRatio = _minCollateralRatio;
    }

    // Set the interest rate
    function setInterestRate(uint256 _interestRate) external {
        require(msg.sender == owner, "Only the owner can set the interest rate");
        interestRate = _interestRate;
    }

    // Allow borrowers to request an increase in their borrowing limit
    function requestBorrowingLimitIncrease(address borrower, uint256 amount)
        external
    {
        require(borrower != address(0), "Invalid address");
        require(msg.sender == owner, "Only the owner can approve limit increase");
        allowedBorrowers[borrower][msg.sender] = amount;
    }

    // Check if a borrower is allowed to borrow more
    function isAllowedToBorrow(address borrower, uint256 amount)
        external
        view
        returns (bool)
    {
        require(borrower != address(0), "Invalid address");
        return
            (balances[borrower] - borrowings[borrower]) >=
            (amount + allowedBorrowers[borrower][msg.sender]);
    }

    function getBalance(address user_account) external returns (uint){
       uint user_bal = user_account.balance;
       emit CheckBalance(user_bal);
       return (user_bal);
    }
}
