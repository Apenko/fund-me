// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {PriceConverter} from "./PriceConverter.sol";

// constant, // immutable

error NotOwner();

contract FundMe {
    using PriceConverter for uint256;

    uint256 public constant MINIMUM_USD = 5e18; // 1 *10 ** 18
    // 21,415 gas - constant
    // 23,515 gas - non-constant

    address[] public funders;
    mapping(address funder => uint256 amountFunded) public addressToAmountFunded;
 
    address public immutable i_owner;
    // 21,588 gas - immutable
    // 23,644 gas - non-immutable

    constructor() {
        i_owner = msg.sender;
    }

    function fund() public payable {
        msg.value.getConversionRate();
        require(msg.value.getConversionRate() >= MINIMUM_USD, "didn't send enough ETH"); //1e18 = 1 ETH = 1000000000000000000
        funders.push(msg.sender);
        addressToAmountFunded[msg.sender]  += msg.value;
    }
    
     function withdraw() public onlyOwner {
        for(uint256 funderIndex = 0; funderIndex < funders.length; funderIndex ++) {
           address funder = funders[funderIndex]; 
           addressToAmountFunded[funder] = 0;
        }
        funders = new address[](0);
        // transfer
        // payable(msg.sender).transfer(address(this).balance);

        // send
        // bool sendSuccess = payable(msg.sender).send(address(this).balance);
        // require(sendSuccess, "Send failed");

        // call
        (bool callSuccess, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Call failed");
        revert();
    }

    modifier onlyOwner() {
        // require(msg.sender == i_owner,"sender is not owner!");
        if(msg.sender != i_owner) { revert NotOwner(); }
        _;
    }

    // What happens if someone sends this contract ETH without call the fund function

    receive() external payable {
        fund();
    }

    fallback() external payable{
        fund();
    }
}

// 1. Enums
// 2. Events
// 3. Try / Catch
// 4. Function Selectors
// 5. abi.encode / decode
// 6. Hashing
// 7. Yul / Assembly