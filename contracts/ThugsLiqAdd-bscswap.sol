
pragma solidity >=0.6.2;
import "./CommonInterfaces.sol";


contract ThugsAutoLiqBuy{
    //define constants
    bool hasApproved = false;
    uint constant public INF = 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;

    address owner = msg.sender;
    address public  bscSwapRouter = address(0xd954551853F55deb4Ae31407c423e67B1621424A);
    address self = address(this);

    IThugs public thugsInterface = IThugs(0xE10e9822A5de22F8761919310DDA35CD997d63c0);
    IERC20 public pairInterface = IERC20(thugsInterface.bscSwapPair());
    BscSwap bscswapInterface = BscSwap(bscSwapRouter);
    IWBNB wbnbInterface = IWBNB(bscswapInterface.WBNB());
    
     function getPathForBNBToToken() private view returns (address[] memory) {
        address[] memory path = new address[](2);
        path[0] = bscswapInterface.WBNB();
        path[1] = address(thugsInterface);
        return path;
    }

    function DoApprove() internal {
        thugsInterface.approve(bscSwapRouter, INF); //allow pool to get tokens
        pairInterface.approve(bscSwapRouter, INF); //allow pool to get tokens
        wbnbInterface.approve(bscSwapRouter,INF);//Allow router to use WBNB
    }
    
    function getThugsBalance() public view returns (uint256){
       return getTokenBalance(address(thugsInterface));
    }
    
    function getWBNBBalance() public view returns (uint256){
        return getTokenBalance(bscswapInterface.WBNB());
    }
    
    receive() external payable {
        deposit();
    }

    function deposit() public payable{
        if(!hasApproved){
            DoApprove();
        }
        //Convert bnb to WBNB
        wbnbInterface.deposit{value:msg.value}();
        convertWBNBToThugs();
        addLiq(msg.sender);
        //Send back the bnb dust given from refund
        if(getWBNBBalance() > 0){
            wbnbInterface.transfer(msg.sender,getWBNBBalance());
        }
    }

    function convertWBNBToThugs() internal {
        bscswapInterface.swapExactTokensForTokensSupportingFeeOnTransferTokens(getWBNBBalance() / 2,1,getPathForBNBToToken(),self,INF);
    }

    function getTokenBalance(address tokenAddress) public view returns (uint256){
       return IERC20(tokenAddress).balanceOf(address(this));
    }
    
    function recoverERC20(address tokenAddress) public {
        IERC20(tokenAddress).transfer(owner, getTokenBalance(tokenAddress));
    }

    function addLiq(address dest) internal {
        //finally add liquidity
        bscswapInterface.addLiquidity(address(thugsInterface),bscswapInterface.WBNB(),getThugsBalance(),getWBNBBalance(),1,1,dest,INF);
    }
    
    function withdrawFunds() public {
        recoverERC20(bscswapInterface.WBNB());
        recoverERC20((address(thugsInterface)));
    }
} 



