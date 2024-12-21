// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract FlipToken is ERC20 {
    address public owner;

    constructor() ERC20("FlipToken", "FLIP") {
        _mint(msg.sender, 1000000 * 10 ** decimals()); // 1,000,000 tokens
        owner = msg.sender;
    }

    function mint(address to, uint256 amount) external {
        require(msg.sender == owner, "Only the owner can mint tokens");
        _mint(to, amount);
    }
}

contract ReferralBonus {
    FlipToken public token;
    address public owner;

    mapping(address => address) public referrals; // Referee => Referrer
    mapping(address => bool) public hasClaimed;

    event ReferralRegistered(address indexed referrer, address indexed referee);
    event BonusClaimed(address indexed referrer, address indexed referee, uint256 referrerBonus, uint256 refereeBonus);

    constructor(address tokenAddress) {
        token = FlipToken(tokenAddress);
        owner = msg.sender;
    }

    function registerReferral(address referrer) external {
        require(referrer != msg.sender, "Cannot refer yourself");
        require(referrals[msg.sender] == address(0), "Referral already registered");

        referrals[msg.sender] = referrer;
        emit ReferralRegistered(referrer, msg.sender);
    }

    function claimBonus() external {
        address referrer = referrals[msg.sender];
        require(referrer != address(0), "No referrer found");
        require(!hasClaimed[msg.sender], "Bonus already claimed");

        uint256 referrerBonus = 10 * 10 ** token.decimals(); // 10 FLIP tokens
        uint256 refereeBonus = 5 * 10 ** token.decimals(); // 5 FLIP tokens

        // Transfer tokens
        token.mint(referrer, referrerBonus);
        token.mint(msg.sender, refereeBonus);

        hasClaimed[msg.sender] = true;

        emit BonusClaimed(referrer, msg.sender, referrerBonus, refereeBonus);
    }
}