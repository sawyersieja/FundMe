// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import { PriceConverter } from "./PriceConverter.sol";

error NotOwner();

// constant
// immutable

contract FundMe {

    using PriceConverter for uint256;

    // 5 * (10 ** 18)
    // or 5e18
    // or 5 * 1e18
    uint256 public constant MINIMUM_USD = 5e18;

    address[] public funders;
    mapping(address funder => uint256 amountFunded) public addressToAmountFunded;

    address public immutable i_owner;

    constructor() {
        i_owner = msg.sender;
    }

    function fund() public payable {
        // Allow users to send $
        // Have a minimum $ sent $5
        // 1. How do we send ETH to this contract?

        require(msg.value.getConversionRate() >= MINIMUM_USD, "Didn't send enough ETH"); // 1e18 = 1 ETH = 1000000000000000000
        funders.push(msg.sender);
        addressToAmountFunded[msg.sender] += msg.value;
    }

    

    
    function withdraw() public onlyOwner{
        for(uint256 funderIndex = 0; funderIndex < funders.length; funderIndex++) {
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }
        funders = new address[](0);

        // transfer - sends error, reverts transaction if unsuccessful (max 2300 gas)
        // send - doesn't error, returns boolean, see `require` for reverting upon failure (max 2300 gas)
        // call - complicated, see documentation
        // CALL IS THE RECOMMENDED WAY TO SEND/RECEIVE***
        // (bool callSuccess, ) = payable(msg.sender).call{value: address(this).balance}("");
        // require(callSuccess, "Call failed");

        // msg.sender = address
        // payable(msg.sender) = payable address
        payable(msg.sender).transfer(address(this).balance);
    }
    
    modifier onlyOwner() {
        // require(msg.sender == i_owner, NotOwner());
        if(msg.sender != i_owner) { revert NotOwner();}
        _;
    }

    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }
}
