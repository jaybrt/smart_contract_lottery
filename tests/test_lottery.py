from web3 import Web3
from brownie import Lottery, accounts, config, network

# 50 usd ~= 0.013 eth


def test_get_enterance_fee():
    expected_eth = Web3.toWei(0.013, "ether")
    account = accounts[0]
    lottery = Lottery.deploy(
        config["networks"][network.show_active()].get("eth_usd_price_feed"),
        {"from": account},
    )
    enterance_fee = lottery.getEnteranceFee()

    assert abs(enterance_fee - expected_eth) < Web3.toWei(0.005, "ether")
