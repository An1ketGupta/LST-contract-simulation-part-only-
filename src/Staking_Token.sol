// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.13;

import {
    ERC20
} from "../lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import {
    ReentrancyGuard
} from "../lib/openzeppelin-contracts/contracts/utils/ReentrancyGuard.sol";
import {
    Ownable
} from "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";

contract StakingToken is ERC20, Ownable, ReentrancyGuard {
    uint public reserve;
    uint public lastUpdateTime;
    uint public tokenValue;
    uint internal constant PRECISION = 1e18;
    constructor() ERC20("AniketCoin", "ANC") Ownable(msg.sender) {
        reserve = 0;
        lastUpdateTime = block.timestamp;
        tokenValue = PRECISION;
    }

    function AddInterestToReserve(uint currentTime) internal {
        uint elapsedTime = currentTime - lastUpdateTime;
        uint elapsedDays = (elapsedTime / 1 days);
        if (elapsedDays >= 1 && totalSupply() > 0) {
            uint interestAmount = (elapsedDays * reserve) / 100;
            reserve = reserve + interestAmount;
            lastUpdateTime += (elapsedDays * 1 days);
            tokenValue = (reserve * PRECISION) / totalSupply();
        }
    }

    function Stake(uint _amount) public payable {
        require(_amount > 0);
        AddInterestToReserve(block.timestamp);
        address payer = msg.sender;
        uint returnAmount = (_amount * PRECISION) / (tokenValue);
        reserve += _amount;
        _mint(payer, returnAmount);
    }

    function Unstake(uint _amount) public nonReentrant {
        require(_amount > 0, "No amount entered");
        address payer = msg.sender;
        require(_amount <= balanceOf(payer), "Insufficient Balance");
        AddInterestToReserve(block.timestamp);
        uint returnAmount = _amount * tokenValue;
        returnAmount = returnAmount / PRECISION;
        uint platformFees = ((returnAmount * 3) / 100);
        uint userAmount = returnAmount - platformFees;
        _burn(payer, _amount);
        require(reserve >= returnAmount);
        reserve = reserve - returnAmount;
        // Here you can sent the userAmount Eth to the user and the platform fees to the account of your choice 
        // As this is just a simulation and it not receiving real eth so the transfer here cannot be done. 
    }
}
