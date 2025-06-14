// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import { AggregatorV3Interface } from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

library PriceConverter {
    function getPrice() internal view returns(uint256) {
        // Address 0x694AA1769357215DE4FAC081bf1f309aDC325306
        // ABI
        AggregatorV3Interface priceFeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        (, int256 price, , , ) = priceFeed.latestRoundData();
        // Price of ETH in terms of USD
        // price == 2566.00000000   <--- int256
        // msg.value == 2566000000000000000   <--- uint256

        return uint256(price * 1e10);

    }

    function getConversionRate(uint256 ethAmount) internal view returns(uint256) {
        uint256 ethPrice = getPrice();
        // 1000000000000000000 * 1000000000000000000 = (1 * 10^36)
        // Need to divide by 1e18 to get back to  (1 * 10^18)
        // Only whole numbers work in Solidity(multiple BEFORE divide!)
        uint256 ethAmountInUsd = (ethPrice * ethAmount) / 1e18;
        return ethAmountInUsd;
    }

    function getVersion() internal view returns (uint256) {
        return AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306).version();
    }
}
