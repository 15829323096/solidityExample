pragma solidity ^0.4.23;

//教程 | Solidity 中 revert(), assert() 和 require() 的使用方法 : https://ethfans.org/posts/when-to-use-revert-assert-and-require-in-solidity

/// @title Voting with delegation.
 /// @title 授权投票
contract Ballot
{
    // 这里声明了复杂类型
    // 将会在被后面的参数使用
    // 代表一个独立的投票人。
    struct Voter
    {
        uint weight; // 累积的权重。
        bool voted;  // 如果为真，则表示该投票人已经投票。
        address delegate; // 委托的投票代表
        uint vote;   // 投票选择的提案索引号
    }

    // 这是一个独立提案的类型
    struct Proposal
    {
        bytes32 name;   // 短名称（32字节）
        uint voteCount; // 累计获得的票数
    }
    address public chairperson;
  //这里声明一个状态变量，保存每个独立地址的`Voter` 结构
    mapping(address => Voter) public voters;
    //一个存储`Proposal`结构的动态数组
    Proposal[] public proposals;

    // 创建一个新的投票用于选出一个提案名`proposalNames`.
    constructor(bytes32[] proposalNames) public
    {
        chairperson = msg.sender;
        voters[chairperson].weight = 1;

        //对提供的每一个提案名称，创建一个新的提案
        //对象添加到数组末尾
        for (uint i = 0; i < proposalNames.length; i++)
            //`Proposal({...})` 创建了一个临时的提案对象，
            //`proposal.push(...)`添加到了提案数组`proposals`末尾。
            proposals.push(Proposal({
                name: proposalNames[i],
                voteCount: 0
            }));
    }

     //给投票人`voter`参加投票的投票权，
    //只能由投票主持人`chairperson`调用。
    function giveRightToVote(address voter) public
    {
        if (msg.sender != chairperson || voters[voter].voted)
            //`throw`会终止和撤销所有的状态和以太改变。
            //如果函数调用无效，这通常是一个好的选择。
            //但是需要注意，这会消耗提供的所有gas。
            // throw;
            revert();
        voters[voter].weight = 1;
    }

    // 委托你的投票权到一个投票代表 `to`。
    function delegate(address to) public
    {
        // 指定引用
        Voter storage sender = voters[msg.sender];
        if (sender.voted)
            // throw;
            revert();
        address _to = to;
        //当投票代表`to`也委托给别人时，寻找到最终的投票代表
        while (voters[_to].delegate != address(0) &&
               voters[_to].delegate != msg.sender)
            _to = voters[_to].delegate;
        // 当最终投票代表等于调用者，是不被允许的。
        if (_to == msg.sender)
            // throw;
            revert();
        //因为`sender`是一个引用，
        //这里实际修改了`voters[msg.sender].voted`
        sender.voted = true;
        sender.delegate = _to;
        Voter storage _delegate = voters[_to];
        if (_delegate.voted)
            //如果委托的投票代表已经投票了，直接修改票数
            proposals[_delegate.vote].voteCount += sender.weight;
        else
            //如果投票代表还没有投票，则修改其投票权重。
            _delegate.weight += sender.weight;
    }

    ///投出你的选票（包括委托给你的选票）
    ///给 `proposals[proposal].name`。
    function vote(uint proposal) public
    {
        Voter storage sender = voters[msg.sender];
        if (sender.voted) 
            // throw;
            revert();
        sender.voted = true;
        sender.vote = proposal;
        //如果`proposal`索引超出了给定的提案数组范围
        //将会自动抛出异常，并撤销所有的改变。
        proposals[proposal].voteCount += sender.weight;
    }

   ///@dev 根据当前所有的投票计算出当前的胜出提案
    function winningProposal() view public returns (uint _winningProposal)
    {
        uint winningVoteCount = 0;
        for (uint p = 0; p < proposals.length; p++)
        {
            if (proposals[p].voteCount > winningVoteCount)
            {
                winningVoteCount = proposals[p].voteCount;
                _winningProposal = p;
            }
        }
    }
}