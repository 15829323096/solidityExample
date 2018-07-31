pragma solidity ^0.4.23;

contract SimpleAuction {
    // 拍卖的参数。
   // 时间要么为unix绝对时间戳（自1970-01-01以来的秒数），
   // 或者是以秒为单位的出块时间
    address public beneficiary;
    uint public auctionStart;
    uint public biddingTime;

    //当前的拍卖状态
    address public highestBidder;
    uint public highestBid;

   //在结束时设置为true来拒绝任何改变
    bool ended;

   //当改变时将会触发的Event
    event HighestBidIncreased(address bidder, uint amount);
    event AuctionEnded(address winner, uint amount);

    //下面是一个叫做natspec的特殊注释，
    //由3个连续的斜杠标记，当询问用户确认交易事务时将显示。

    ///创建一个简单的合约使用`_biddingTime`表示的竞拍时间，
   /// 地址`_beneficiary`.代表实际的拍卖者
    constructor(uint _biddingTime, address _beneficiary) public {
        beneficiary = _beneficiary;
        auctionStart = now;
        biddingTime = _biddingTime;
    }

    ///对拍卖的竞拍保证金会随着交易事务一起发送，
    ///只有在竞拍失败的时候才会退回
    function bid() payable public {

       //不需要任何参数，所有的信息已经是交易事务的一部分
        if (now > auctionStart + biddingTime)
            //当竞拍结束时撤销此调用
            // throw;
            revert();
        if (msg.value <= highestBid)
            //如果出价不是最高的，发回竞拍保证金。
            // throw;
            revert();
        if (highestBidder != 0)
            // highestBidder.send(highestBid);
            highestBidder.transfer(highestBid);
        highestBidder = msg.sender;
        highestBid = msg.value;
        emit HighestBidIncreased(msg.sender, msg.value);
    }

   ///拍卖结束后发送最高的竞价到拍卖人
    function auctionEnd() public{
        if (now <= auctionStart + biddingTime)
            // throw; 
            revert();
            //拍卖还没有结束
        if (ended)
            // throw; 
            revert();
     //这个收款函数已经被调用了
        emit AuctionEnded(highestBidder, highestBid);
        //发送合约拥有所有的钱，因为有一些保证金可能退回失败了。

        // beneficiary.send(this.balance);
        beneficiary.transfer(address(this).balance);
        ended = true;
    }

    function () public{
        //这个函数将会在发送到合约的交易事务包含无效数据
        //或无数据的时执行，这里撤销所有的发送，
        //所以没有人会在使用合约时因为意外而丢钱。
        // throw;
        revert();
    }
}