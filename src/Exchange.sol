// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

error Null_Address();
error Insufficient_Amount();
error ShouldBe_GreaterThanZero();
error ReservesMust_BeGreaterThanZero();
error EthReceived_LessThanMinExpected();
error TokensReceived_LessThanMinExpected();

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract Exchange is ERC20, ReentrancyGuard {
    using SafeERC20 for ERC20;
    address public tokenAddress;

    event LiquidityAdded(
        address indexed user,
        uint256 ethAmount,
        uint256 tokenAmount,
        uint256 lpTokensMinted
    );
    event LiquidityRemoved(
        address indexed user,
        uint256 ethAmount,
        uint256 tokenAmount,
        uint256 lpTokensBurned
    );
    event SwapExecuted(
        address indexed user,
        uint256 inputAmount,
        uint256 outputAmount,
        bool isEthToToken
    );

    constructor(address token) ERC20("ETH TOKEN LP Token", "lpETHTOKEN") {
        if (token == address(0)) {
            revert Null_Address();
        }
        tokenAddress = token;
    }

    //getReserve to return the token balance held by this contract
    function getReserve() public view returns (uint256) {
        return ERC20(tokenAddress).balanceOf(address(this));
    }

    //addLiquidity to the exchange
    function addLiquidity(
        uint256 amountOfToken
    ) public payable nonReentrant returns (uint256) {
        uint256 lpTokensToMint;
        uint256 ethReserveBalance = address(this).balance;
        uint256 tokenReserveBalance = getReserve();

        ERC20 token = ERC20(tokenAddress);

        //if the rserve is empty, take any user supplied value for initial liquidity
        if (tokenReserveBalance == 0) {
            //transfer the token from the user to the exchange
            token.safeTransferFrom(msg.sender, address(this), amountOfToken);

            //lpTokensToMint = ethReserveBalance = msg.value
            lpTokensToMint = ethReserveBalance;

            //mint LP tokens to the user
            _mint(msg.sender, lpTokensToMint);

            emit LiquidityAdded(
                msg.sender,
                msg.value,
                amountOfToken,
                lpTokensToMint
            );
            return lpTokensToMint;
        }

        //if the reserve is not empty, calaculater the amount of LP tokens to be minted
        uint256 ethReservePriorToFunctionCall = ethReserveBalance - msg.value;
        uint256 minTokenAmountRequired = (msg.value * tokenReserveBalance) /
            ethReservePriorToFunctionCall;

        if (amountOfToken < minTokenAmountRequired) {
            revert Insufficient_Amount();
        }

        //transfer the tokrn from the user to the exchange
        token.safeTransferFrom(msg.sender, address(this), minTokenAmountRequired);

        //calculate the amount of LP tokens to be minted
        lpTokensToMint =
            (totalSupply() * msg.value) /
            ethReservePriorToFunctionCall;

        //mint LP tokens to the user
        _mint(msg.sender, lpTokensToMint);

        emit LiquidityAdded(
            msg.sender,
            msg.value,
            minTokenAmountRequired,
            lpTokensToMint
        );

        return lpTokensToMint;
    }

    //removeLiquidity allows users to remove liquidity from the exchange
    function removeLiquidity(
        uint256 amountOfLPTokens
    ) public nonReentrant returns (uint256, uint256) {
        //check the amount of LP tokens to be removed is >0
        if (amountOfLPTokens == 0) {
            revert ShouldBe_GreaterThanZero();
        }

        uint256 ethReserveBalance = address(this).balance;
        uint256 lpTokenTotalSupply = totalSupply();

        //calculate the amount of ETH and tokens to return to the user
        uint256 ethToReturn = (ethReserveBalance * amountOfLPTokens) /
            lpTokenTotalSupply;
        uint256 tokenToReturn = (getReserve() * amountOfLPTokens) /
            lpTokenTotalSupply;

        //Burn the LP from the user, and transfer the ETH anad tokens to the user
        _burn(msg.sender, amountOfLPTokens);
        payable(msg.sender).transfer(ethToReturn);
        ERC20(tokenAddress).safeTransfer(msg.sender, tokenToReturn);

        emit LiquidityRemoved(msg.sender, ethToReturn, tokenToReturn, amountOfLPTokens);
        return (ethToReturn, tokenToReturn);
    }

    //getOutputAmountFromSwap calculated the amount of output tokens to be received (xy = (x + dx)(y + dy))
    function getOutputAmountFromSwap(
        uint256 inputAmount,
        uint256 inputReserve,
        uint256 outputReserve
    ) public pure returns (uint256) {
        if (inputReserve <= 0 || outputReserve <= 0) {
            revert ReservesMust_BeGreaterThanZero();
        }

        uint256 inputAmountWithFee = inputAmount * 99;

        uint256 numerator = inputAmountWithFee * outputReserve;
        uint256 denominator = (inputReserve * 100) + inputAmountWithFee;

        return numerator / denominator;
    }

    // ethToTokenSwap allows users to swap ETH for tokens
    function ethToTokenSwap(uint256 minTokensToReceive) public payable nonReentrant {
        uint256 tokenReserveBalance = getReserve();
        uint256 tokensToReceive = getOutputAmountFromSwap(
            msg.value,
            address(this).balance - msg.value,
            tokenReserveBalance
        );

        if (tokensToReceive < minTokensToReceive) {
            revert TokensReceived_LessThanMinExpected();
        }

        ERC20(tokenAddress).safeTransfer(msg.sender, tokensToReceive);
        emit SwapExecuted(msg.sender, msg.value, tokensToReceive, true);
    }

    // tokenToETHSwap allows users to swap tokens for ETH
    function tokenToETHSwap(
        uint256 tokensToSwap,
        uint256 minEthToReceive
    ) public nonReentrant{
        uint256 tokenReserveBalance = getReserve();
        uint256 ethToReceive = getOutputAmountFromSwap(
            tokensToSwap,
            tokenReserveBalance,
            address(this).balance
        );

        if (ethToReceive < minEthToReceive) {
            revert EthReceived_LessThanMinExpected();
        }

        ERC20(tokenAddress).safeTransferFrom(
            msg.sender,
            address(this),
            tokensToSwap
        );

        payable(msg.sender).transfer(ethToReceive);
        emit SwapExecuted(msg.sender, tokensToSwap, ethToReceive, false);
    }
}


