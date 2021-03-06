pragma solidity ^0.4.23;

contract Coin {
    //关键字“public”使变量能从合约外部访问。
    address public minter;
    mapping (address => uint) public balances;

    //事件让轻客户端能高效的对变化做出反应。
    event Sent(address from, address to, uint amount);

    //这个构造函数的代码仅仅只在合约创建的时候被运行。
    constructor() public {
        minter = msg.sender;
    }
    function mint(address receiver, uint amount) public {
        if (msg.sender != minter) return;
        balances[receiver] += amount;
    }
    function send(address receiver, uint amount) public {
        if (balances[msg.sender] < amount) return;
        balances[msg.sender] -= amount;
        balances[receiver] += amount;
        emit Sent(msg.sender, receiver, amount);
    }
}