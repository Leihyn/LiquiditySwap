// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "forge-std/Script.sol";
import "../src/Token.sol";
import "../src/Exchange.sol";

contract Interact is Script {
    function run() external {
        //source CAs from env variables
        address tokenAddress = vm.envAddress("TOKEN_CONTRACT_ADDRESS");
        address exchangeAddress = vm.envAddress("EXCHANGE_CONTRACT_ADDRESS");

        //init token and exchange contracts
        Token token = Token(tokenAddress);
        Exchange exchange = Exchange(exchangeAddress);

        //amount of tokens to approve
        uint256 amountToApprove = 10000000 * 1e18;
        //amount of ETH as liquidity
        uint256 ethAmount = 0.1 ether;
        //amount of tokens to add
        uint256 tokenAmount = 1000000 * 1e18;
        //amount of ETH for ETHtoToken swap
        uint256 swapEthAmount = 0.01 ether;
        //amount of tokens for TokentoETh swap
        uint256 swapTokenAmount = 10000 * 1e18;
        //min tokens to receive in ETHtoToken swap
        uint256 minTokensToReceive = 0;
        //min ETH to receive in TokentoETH swap
        uint256 minEthToReceive = 0;
        //amount of LP tokens to remove
        uint256 lpTokensToRemove = 5000000000000;

        //broadcast
        vm.startBroadcast();

        //approving the exchange contract to spend tokens 
        token.approve(exchangeAddress, amountToApprove);

        //adding liquidity(ETH + tokens) to the exchange
        exchange.addLiquidity{value: ethAmount}(tokenAmount);

        //swap eth for tokens
        exchange.ethToTokenSwap{value: swapEthAmount}(minTokensToReceive);
        
        //swap tokens for eth
        exchange.tokenToETHSwap(swapTokenAmount, minEthToReceive);

        //removal of lioquidity from the exchange
        exchange.removeLiquidity(lpTokensToRemove);
        
        vm.stopBroadcast();
    }
}