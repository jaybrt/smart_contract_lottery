// SPDX-License-Identifier: MIT

pragma solidity >=0.6.6;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Lottery is Ownable {
    address payable[] public players;
    uint256 usdEntryFee;
    AggregatorV3Interface internal ethUsdPriceFeed;
    enum LOTTERY_STATE {
        OPEN,
        CLOSED,
        CALCULATING_WINNER
    }
    LOTTERY_STATE public lottery_state;

    constructor(address _priceFeedAddress) {
        usdEntryFee = 50 * 10**18;
        ethUsdPriceFeed = AggregatorV3Interface(_priceFeedAddress);
        lottery_state = LOTTERY_STATE.CLOSED;
    }

    function enter() public payable {
        require(lottery_state == LOTTERY_STATE.OPEN, "Lotery not open");
        //$50 min
        require(msg.value >= getEnteranceFee(), "Not enough ETH");
        players.push(payable(msg.sender));
    }

    function getEnteranceFee() public view returns (uint256) {
        //get eth/usd price and convert 50 usd to eth
        (, int256 price, , , ) = ethUsdPriceFeed.latestRoundData();
        uint256 adjustedPrice = uint256(price) * 10**10;
        uint256 ethEnteranceFee = (usdEntryFee * 10**18) / adjustedPrice;
        return ethEnteranceFee;
    }

    function startLottery() public onlyOwner {
        require(
            lottery_state == LOTTERY_STATE.CLOSED,
            "Cannot start new lottery yet"
        );
        lottery_state = LOTTERY_STATE.OPEN;
    }

    function endLottery() public onlyOwner {}
}
