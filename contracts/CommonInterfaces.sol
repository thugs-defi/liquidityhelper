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

