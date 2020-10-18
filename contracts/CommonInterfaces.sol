pragma solidity >=0.6.2;
//Import IERC20
import "@openzeppelin/contracts/Token/ERC20/IERC20.sol";

import "./IBscSwap.sol";
import "./IPancakeSwap.sol";

interface IThugs is IERC20{
  function bscSwapPair (  ) external view returns ( address );
}

interface IWBNB is IERC20{
  function deposit (  ) external payable;
  function withdraw(uint) external;
}
library tokenHelper {
  function getTokenBalance(address tokenAddress) public view returns (uint256){
    return IERC20(tokenAddress).balanceOf(address(this));
  }

  function recoverERC20(address tokenAddress,address receiver) internal {
    IERC20(tokenAddress).transfer(receiver, getTokenBalance(tokenAddress));
  }
}
