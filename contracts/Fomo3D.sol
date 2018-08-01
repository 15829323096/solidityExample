pragma solidity ^0.4.23;

///////////////////////////////////////
// SafeMath
// version: v0.1.9
///////////////////////////////////////
library SafeMath {
    /**
    * 乘法
    */
    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        if (a == 0) return 0;
        c = a * b;
        // 反向验证
        require(c / a == b, "SafeMath mul failed");
        return c;
    }

    /**
    * 减法 溢出则抛出异常
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        // a >= b
        require(b <= a, "SafeMath sub failed");
        return a - b;
    }

    /**
    * 加法 溢出则抛出异常
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a + b;
        require(c >= a, "SafeMath add failed");
        return c;
    }

    /**
     * @dev 开方
     */
    function sqrt(uint256 x) internal pure returns (uint256 y) {
        uint256 z = ((add(x,1)) / 2);
        y = x;
        while (z < y) {
            y = z;
            z = ((add((x / z),z)) / 2);
        }
    }
    
    /**
     * @dev x*x 平方
     */
    function sq(uint256 x) internal pure returns (uint256){
        return (mul(x,x));
    }
    
    /**
     * @dev x 的 y 次幂
     */
    function pwr(uint256 x, uint256 y) internal pure returns (uint256)
    {
        if (x==0)
            return (0);
        else if (y==0)
            return (1);
        else {
            uint256 z = x;
            for (uint256 i = 1; i < y; i++)
                z = mul(z,x);
            return (z);
        }
    }
}


///////////////////////////////////////
// NameFilter
// 过滤名称
///////////////////////////////////////

library NameFilter {
    function nameFilter(string _input) internal pure returns(bytes32) {
        bytes memory _temp = bytes(_input);
        uint256 _length = _temp.length;

        require (_length <= 32 && _length > 0, "字符串长度必须是1-32");
        require(_temp[0] != 0x20 && _temp[_length-1] != 0x20, "字符串首尾不能有空格");

        if (_temp[0] == 0x30){
            require(_temp[1] != 0x78, "字符串不能以'0x'开头");
            require(_temp[1] != 0x58, "字符串不能以'0X'开头");
        }

        bool _hasNonNumber;//是否有非数字的字符

        for (uint256 i = 0; i < _length; i++) {
            // 大写A-Z
            if (_temp[i] > 0x40 && _temp[i] < 0x5b){
                // 转化为小写 a-z
                _temp[i] = byte(uint(_temp[i]) + 32);
                
                // 有非数字字符
                if (_hasNonNumber == false) _hasNonNumber = true;
            } else {
                // 空格 或者 小写 或者 数字0-9
                require (_temp[i] == 0x20 || (_temp[i] > 0x60 && _temp[i] < 0x7b) || (_temp[i] > 0x2f && _temp[i] < 0x3a), "字符串包含非法字符");
                // 确保不包含连续的空格字符
                if (_temp[i] == 0x20) require(_temp[i+1] != 0x20, "字符串不能包含连续的空格字符");
                
                // 如果不是数字字符
                if (_hasNonNumber == false && (_temp[i] < 0x30 || _temp[i] > 0x39)) _hasNonNumber = true;    
            }
        }

    }
}

///////////////////////////////////////
// 一些接口
// 
///////////////////////////////////////
interface otherFoMo3D {
    function potSwap() external payable;
}

interface F3DexternalSettingsInterface {
    function getFastGap() external returns(uint256);
    function getLongGap() external returns(uint256);
    function getFastExtra() external returns(uint256);
    function getLongExtra() external returns(uint256);
}

interface DiviesInterface {
    function deposit() external payable;
}

interface JIincForwarderInterface {
    function deposit() external payable returns(bool);
    function status() external view returns(address, address, bool);
    function startMigration(address _newCorpBank) external returns(bool);
    function cancelMigration() external returns(bool);
    function finishMigration() external returns(bool);
    function setup(address _firstCorpBank) external;
}

interface PlayerBookInterface {
    function getPlayerID(address _addr) external returns (uint256);
    function getPlayerName(uint256 _pID) external view returns (bytes32);
    function getPlayerLAff(uint256 _pID) external view returns (uint256);
    function getPlayerAddr(uint256 _pID) external view returns (address);
    function getNameFee() external view returns (uint256);
    function registerNameXIDFromDapp(address _addr, bytes32 _name, uint256 _affCode, bool _all) external payable returns(bool, uint256);
    function registerNameXaddrFromDapp(address _addr, bytes32 _name, address _affCode, bool _all) external payable returns(bool, uint256);
    function registerNameXnameFromDapp(address _addr, bytes32 _name, bytes32 _affCode, bool _all) external payable returns(bool, uint256);
}


///////////////////////////////////////
// F3DKeysCalcLong
// key的计算方法
///////////////////////////////////////

library F3DKeysCalcLong {
    using SafeMath for *;

    /**
    * 通过被给的eth计算存在多少key
     */
    function keys(uint256 _eth) internal pure returns(uint256){
        return (((((
            (_eth).mul(1000000000000000000)).mul(312500000000000000000000000))
            .add(5624988281256103515625000000000000000000000000000000000000000000)).sqrt())
            .sub(74999921875000000000000000000000)) / (156250000);
    }

    /**
    * 通过合约中被给的key的数量计算存在多少eth
     */
    function eth(uint256 _keys) internal pure returns(uint256) {
        return ((78125000).mul(_keys.sq()).add(((149999843750000).mul(_keys.mul(1000000000000000000))) / (2))) / ((1000000000000000000).sq());
    }

    /**
    * 计算花费的eth存在的key的数量
     */
    function keysRec(uint256 _curEth, uint256 _newEth) internal pure returns (uint256) {
        return(keys((_curEth).add(_newEth)).sub(keys(_curEth)));
    }

    /**
    * 计算卖掉key后存在的eth的数量
     */
    function ethRec(uint256 _curKeys, uint256 _sellKeys) internal pure returns (uint256) {
        return((eth(_curKeys)).sub(eth(_curKeys.sub(_sellKeys))));
    }
}

///////////////////////////////////////
// F3Ddatasets
// 数据集
///////////////////////////////////////

library F3Ddatasets {
    struct EventReturns {
        uint256 compressedData;
        uint256 compressedIDs;
        address winnerAddr;         // 赢家地址
        bytes32 winnerName;         // 赢家姓名
        uint256 amountWon;          // 赢的次数
        uint256 newPot;             // 在新奖池中的数量
        uint256 P3DAmount;          // 分配给p3d的数量
        uint256 genAmount;          // 分配给玩家的数量
        uint256 potAmount;          // 加入到新奖池中的数量
    }
    struct Player {
        address addr;   // 玩家地址
        bytes32 name;   // 玩家姓名
        uint256 win;    // 赢的金库
        uint256 gen;    // 普通的金库
        uint256 aff;    // 会员的金库
        uint256 lrnd;   // 上一轮游戏
        uint256 laff;   // 上一次使用的会员id
    }
    struct PlayerRounds {
        uint256 eth;    // eth玩家已经加入的回合(用于eth限制器)
        uint256 keys;   // 钥匙
        uint256 mask;   // 玩家掩码
        uint256 ico;    // 投入的eth的数量
    }
    struct Round {
        uint256 plyr;   // 带头的玩家的pID
        uint256 team;   // 团队的tID
        uint256 end;    // 结束的时间/已经结束的时间
        bool ended;     // 该回合是否已经结束
        uint256 strt;   // 该回合开始时间
        uint256 keys;   // 钥匙
        uint256 eth;    // 总共的eth数量
        uint256 pot;    // 在奖池中的eth数量 (回合期间) / 最终支付给玩家的数量 (回合结束后)
        uint256 mask;   // 全局掩码
        uint256 ico;    // ICO期间总共发送的eth数量
        uint256 icoGen; // ICO期间eth的总数
        uint256 icoAvg; // ICO阶段每个key的均价
    }
    struct TeamFee {
        uint256 gen;    // 支付给本轮持有key的玩家分成比例
        uint256 p3d;    // 支付给p3d持有人的分成比例
    }
    struct PotSplit {
        uint256 gen;    // 支付给本轮持有key的玩家分成比例
        uint256 p3d;    // 支付给p3d持有人的分成比例
    }
}

///////////////////////////////////////
// F3Devents
// 事件
///////////////////////////////////////

contract F3Devents {
    // 只要玩家注册了名字就会触发该事件
    event onNewName
    (
        uint256 indexed playerID,
        address indexed playerAddress,
        bytes32 indexed playerName,
        bool isNewPlayer,
        uint256 affiliateID,
        address affiliateAddress,
        bytes32 affiliateName,
        uint256 amountPaid,
        uint256 timeStamp
    );
    
    // 在购买和重载后触发该事件
    event onEndTx
    (
        uint256 compressedData,     
        uint256 compressedIDs,      
        bytes32 playerName,
        address playerAddress,
        uint256 ethIn,
        uint256 keysBought,
        address winnerAddr,
        bytes32 winnerName,
        uint256 amountWon,
        uint256 newPot,
        uint256 P3DAmount,
        uint256 genAmount,
        uint256 potAmount,
        uint256 airDropPot
    );
    
	// 提款时触发该事件
    event onWithdraw
    (
        uint256 indexed playerID,
        address playerAddress,
        bytes32 playerName,
        uint256 ethOut,
        uint256 timeStamp
    );
    
    // 当提款最后一轮将要开始时触发该事件
    event onWithdrawAndDistribute
    (
        address playerAddress,
        bytes32 playerName,
        uint256 ethOut,
        uint256 compressedData,
        uint256 compressedIDs,
        address winnerAddr,
        bytes32 winnerName,
        uint256 amountWon,
        uint256 newPot,
        uint256 P3DAmount,
        uint256 genAmount
    );
    
    // (fomo3d long only) 当回合时间归零后玩家尝试购买时造成最后一轮开始时触发
    event onBuyAndDistribute
    (
        address playerAddress,
        bytes32 playerName,
        uint256 ethIn,
        uint256 compressedData,
        uint256 compressedIDs,
        address winnerAddr,
        bytes32 winnerName,
        uint256 amountWon,
        uint256 newPot,
        uint256 P3DAmount,
        uint256 genAmount
    );
    
    // (fomo3d long only) 当回合时间归零后玩家尝试刷新时造成最后一轮开始时触发
    event onReLoadAndDistribute
    (
        address playerAddress,
        bytes32 playerName,
        uint256 compressedData,
        uint256 compressedIDs,
        address winnerAddr,
        bytes32 winnerName,
        uint256 amountWon,
        uint256 newPot,
        uint256 P3DAmount,
        uint256 genAmount
    );
    
    // 会员付款是触发该事件
    event onAffiliatePayout
    (
        uint256 indexed affiliateID,
        address affiliateAddress,
        bytes32 affiliateName,
        uint256 indexed roundID,
        uint256 indexed buyerID,
        uint256 amount,
        uint256 timeStamp
    );
    
    // 收到一个奖池的交换存款
    event onPotSwapDeposit
    (
        uint256 roundID,
        uint256 amountAddedToPot
    );
}

///////////////////////////////////////
// F3Devents
// 合约
///////////////////////////////////////
contract modularLong is F3Devents {}

///////////////////////////////////////
// FoMo3Dlong
// 合约
//
// modifier isActivated() 是否被激活
// modifier isHuman() 是否为人工操作
// modifier isWithinLimits(uint256 _eth) 判断eth是否超过上下限
//
// function() isActivated() isHuman() isWithinLimits(msg.value) public payable
// function buyXid(uint256 _affCode, uint256 _team) isActivated() isHuman() isWithinLimits(msg.value) public payable
// function buyXaddr(address _affCode, uint256 _team) isActivated() isHuman() isWithinLimits(msg.value) public payable
// function buyXname(bytes32 _affCode, uint256 _team) isActivated() isHuman() isWithinLimits(msg.value) public payable
// function reLoadXid(uint256 _affCode, uint256 _team, uint256 _eth) isActivated() isHuman() isWithinLimits(_eth) public
// function reLoadXaddr(address _affCode, uint256 _team, uint256 _eth) isActivated() isHuman() isWithinLimits(_eth) public
// function reLoadXname(bytes32 _affCode, uint256 _team, uint256 _eth) isActivated() isHuman() isWithinLimits(_eth) public
// function withdraw() isActivated() isHuman() public
// function registerNameXID(string _nameString, uint256 _affCode, bool _all) isHuman() public payable
// function registerNameXaddr(string _nameString, address _affCode, bool _all) isHuman() public payable
// function registerNameXname(string _nameString, bytes32 _affCode, bool _all) isHuman() public payable
//
// function getBuyPrice() public view returns(uint256)
// function getTimeLeft() public view returns(uint256)
// function getPlayerVaults(uint256 _pID) public view returns(uint256 ,uint256, uint256)
// function getPlayerVaultsHelper(uint256 _pID, uint256 _rID) private view returns(uint256)
// function getCurrentRoundInfo() public view returns(uint256, uint256, uint256, uint256, uint256, uint256, uint256, address, bytes32, uint256, uint256, uint256, uint256, uint256)
// function getPlayerInfoByAddress(address _addr) public view returns(uint256, bytes32, uint256, uint256, uint256, uint256, uint256)
//
// function buyCore(uint256 _pID, uint256 _affID, uint256 _team, F3Ddatasets.EventReturns memory _eventData_) private
// function reLoadCore(uint256 _pID, uint256 _affID, uint256 _team, uint256 _eth, F3Ddatasets.EventReturns memory _eventData_) private
// function core(uint256 _rID, uint256 _pID, uint256 _eth, uint256 _affID, uint256 _team, F3Ddatasets.EventReturns memory _eventData_) private
// 
// function calcUnMaskedEarnings(uint256 _pID, uint256 _rIDlast) private view returns(uint256)
// function calcKeysReceived(uint256 _rID, uint256 _eth) public view returns(uint256)
// function iWantXKeys(uint256 _keys) public view returns(uint256)
//
// function receivePlayerInfo(uint256 _pID, address _addr, bytes32 _name, uint256 _laff) external
// function receivePlayerNameList(uint256 _pID, bytes32 _name) external
// function determinePID(F3Ddatasets.EventReturns memory _eventData_) private returns (F3Ddatasets.EventReturns)
// function verifyTeam(uint256 _team) private pure returns (uint256)
// function managePlayer(uint256 _pID, F3Ddatasets.EventReturns memory _eventData_) private returns (F3Ddatasets.EventReturns)
// function endRound(F3Ddatasets.EventReturns memory _eventData_) private returns (F3Ddatasets.EventReturns)
// function updateGenVault(uint256 _pID, uint256 _rIDlast) private 
// function updateTimer(uint256 _keys, uint256 _rID) private
// function airdrop() private view returns(bool)
// function distributeExternal(uint256 _rID, uint256 _pID, uint256 _eth, uint256 _affID, uint256 _team, F3Ddatasets.EventReturns memory _eventData_) private returns(F3Ddatasets.EventReturns)
// function potSwap() external payable
// function distributeInternal(uint256 _rID, uint256 _pID, uint256 _eth, uint256 _team, uint256 _keys, F3Ddatasets.EventReturns memory _eventData_) private returns(F3Ddatasets.EventReturns)
// function updateMasks(uint256 _rID, uint256 _pID, uint256 _gen, uint256 _keys) private returns(uint256)
// function withdrawEarnings(uint256 _pID) private returns(uint256)
// function endTx(uint256 _pID, uint256 _team, uint256 _eth, uint256 _keys, F3Ddatasets.EventReturns memory _eventData_) private
// 
// function activate() public
// function setOtherFomo(address _otherF3D) public
///////////////////////////////////////

contract FoMo3Dlong is modularLong {
    using SafeMath for *;
    using NameFilter for string;
    using F3DKeysCalcLong for uint256;

    //===============================
    // 外部合约
    //===============================
    otherFoMo3D private otherF3D_;
    DiviesInterface constant private Divies = DiviesInterface(0xc7029Ed9EBa97A096e72607f4340c34049C7AF48);
    JIincForwarderInterface constant private Jekyll_Island_Inc = JIincForwarderInterface(0xdd4950F977EE28D2C132f1353D1595035Db444EE);
    PlayerBookInterface constant private PlayerBook = PlayerBookInterface(0xD60d353610D9a5Ca478769D371b53CEfAA7B6E4c);
    F3DexternalSettingsInterface constant private extSettings = F3DexternalSettingsInterface(0x32967D6c142c2F38AB39235994e2DDF11c37d590);

    //===============================
    // 游戏设置
    //===============================
    string constant public name = "FoMo3D Long Official";
    string constant public symbol = "F3D";
    uint256 private rndExtra_ = extSettings.getLongExtra();     // ICO的长度
    uint256 private rndGap_ = extSettings.getLongGap();         // ICO阶段的长度，EOS设定为1年
    uint256 constant private rndInit_ = 1 hours;                // 一回合的初始时间
    uint256 constant private rndInc_ = 30 seconds;              // 购买的每一把钥匙都会给计时器增加这么多时间
    uint256 constant private rndMax_ = 24 hours;                // 一回合的最大时间

    //===============================
    // 用于存储更改的游戏信息的数据
    //===============================
    uint256 public airDropPot_;             // 获得空投的人赢得了这个奖池的一部分
    uint256 public airDropTracker_ = 0;     // 每次“合格”tx发生时递增， 用于确定获胜的空投
    uint256 public rID_;                    // 回合id数量 / 已经发生的回合的总数

    //===============================
    // 玩家数据
    //===============================
    mapping (address => uint256) public pIDxAddr_;          // (addr => pID) 通过地址返回玩家id
    mapping (bytes32 => uint256) public pIDxName_;          // (name => pID) 通过玩家名称返回玩家id
    mapping (uint256 => F3Ddatasets.Player) public plyr_;   // (pID => data) player data
    mapping (uint256 => mapping (uint256 => F3Ddatasets.PlayerRounds)) public plyrRnds_; // (pID => rID => data) 通过玩家id和回合id返回回合数据
    mapping (uint256 => mapping (bytes32 => bool)) public plyrNames_; // (pID => name => bool) 玩家名称.  (使用这个就可以在您拥有的任何设备中更改您的显示名称)

    //===============================
    // 回合数据
    //===============================
    mapping (uint256 => F3Ddatasets.Round) public round_;   // (rID => data) 通过回合id获取回合数据
    mapping (uint256 => mapping(uint256 => uint256)) public rndTmEth_;  // (rID => tID => data) 通过回合id和队伍id获取各队的eth的数量

    //===============================
    // 队伍费用数据
    //===============================
    mapping (uint256 => F3Ddatasets.TeamFee) public fees_;          // (team => fees) 按团队分配费用
    mapping (uint256 => F3Ddatasets.PotSplit) public potSplit_;     // (team => fees) 按团队分配的奖池

    //===============================
    // 其他数据
    //===============================
    bool public activated_ = false;     // 是否已经激活

    //===============================
    // 构造函数
    // 合同部署时的初始数据设置
    //===============================
    constructor() public {
        // 团队分配结构
        // 0 = whales 鲸
        // 1 = bears 熊
        // 2 = sneks 蛇
        // 3 = bulls 牛

        // 团队分配百分比
        fees_[0] = F3Ddatasets.TeamFee(30,6);   //下一轮 50%, 佣金奖励 10%, 基金社区 2%, 奖池互换 1%, 空投 1%
        fees_[1] = F3Ddatasets.TeamFee(43,0);   //下一轮 43%, 佣金奖励 10%, 基金社区 2%, 奖池互换 1%, 空投 1%
        fees_[2] = F3Ddatasets.TeamFee(56,10);  //下一轮 20%, 佣金奖励 10%, 基金社区 2%, 奖池互换 1%, 空投 1%
        fees_[3] = F3Ddatasets.TeamFee(43,8);   //下一轮 35%, 佣金奖励 10%, 基金社区 2%, 奖池互换 1%, 空投 1%

        // 当队伍赢了之后瓜分奖池的策略
        potSplit_[0] = F3Ddatasets.PotSplit(15,10);  //赢家 48%, 下一轮 25%, 基金社区 2%
        potSplit_[1] = F3Ddatasets.PotSplit(25,0);   //赢家 48%, 下一轮 25%, 基金社区 2%
        potSplit_[2] = F3Ddatasets.PotSplit(20,20);  //赢家 48%, 下一轮 10%, 基金社区 2%
        potSplit_[3] = F3Ddatasets.PotSplit(30,10);  //赢家 48%, 下一轮 10%, 基金社区 2%
    }

    //===============================
    // 安全检查
    //===============================

    /**
    * 与合约交互时先检查它是否已经被激活
     */
    modifier isActivated() {
        require(activated_ == true, "还没有准备好"); 
        _;
    }

    /**
    * 防止合约与fomo3d交互
    */
    modifier isHuman() {
        address _addr = msg.sender;
        uint256 _codeLength;

        assembly {_codeLength := extcodesize(_addr)}
        require(_codeLength == 0, "抱歉，必须是人工操作。。。");
        _;
    }

    /**
    * 检查交易上下限
     */
    modifier isWithinLimits(uint256 _eth) {
        require(_eth >= 1000000000, "提示: 不是有效的货币");
        require(_eth <= 100000000000000000000000, "数量太大了");
        _;    
    }

    //===============================
    // OtherFomo
    //===============================

    /**
    * 激活合约
     */
    function activate() public {
        // 只有团队才能激活
        require(
            msg.sender == 0x18E90Fc6F70344f53EBd4f6070bf6Aa23e2D748C ||
            msg.sender == 0x8b4DA1827932D71759687f925D17F81Fc94e3A9D ||
            msg.sender == 0x8e0d985f3Ec1857BEc39B76aAabDEa6B31B67d53 ||
            msg.sender == 0x7ac74Fcc1a71b106F12c55ee8F802C9F672Ce40C ||
			msg.sender == 0xF39e044e1AB204460e06E87c6dca2c6319fC69E3,
            "只有团队才能激活"
        );

		// 确保它已被链接
        require(address(otherF3D_) != address(0), "必须先链接 other FoMo3D");
        
        // 只能被运次一次
        require(activated_ == false, "fomo3d 已经激活");
        
        // 激活合约
        activated_ = true;
        
        // 启动第一回合
        rID_ = 1;
        round_[1].strt = now + rndExtra_ - rndGap_;
        round_[1].end = now + rndInit_ + rndExtra_;
    }

    /**
    * 设置other Fomo
     */
    function setOtherFomo(address _otherF3D) public {
        require(
            msg.sender == 0x18E90Fc6F70344f53EBd4f6070bf6Aa23e2D748C ||
            msg.sender == 0x8b4DA1827932D71759687f925D17F81Fc94e3A9D ||
            msg.sender == 0x8e0d985f3Ec1857BEc39B76aAabDEa6B31B67d53 ||
            msg.sender == 0x7ac74Fcc1a71b106F12c55ee8F802C9F672Ce40C ||
			msg.sender == 0xF39e044e1AB204460e06E87c6dca2c6319fC69E3,
            "只有团队才能激活"
        );

        // 确保它已被联系起来
        require(address(otherF3D_) == address(0), "已经做了");
        
        // 设置other fomo3d进行奖池互换
        otherF3D_ = otherFoMo3D(_otherF3D);
    }

    //===============================
    // 计算
    //===============================

    /**
    * 计算未屏蔽的收入（只计算，不更新掩码）
     */
    function calcUnMaskedEarnings(uint256 _pID, uint256 _rIDlast) private view returns(uint256){
        return(  (((round_[_rIDlast].mask).mul(plyrRnds_[_pID][_rIDlast].keys)) / (1000000000000000000)).sub(plyrRnds_[_pID][_rIDlast].mask)  );
    }
    
    /**
    * 返回给出一定数量eth的钥匙数量
    * 回合id
    * 发送的eth数量
     */
    function calcKeysReceived(uint256 _rID, uint256 _eth) public view returns(uint256) {
        uint256 _now = now;
        
        // 判断是否在回合中
        if (_now > round_[_rID].strt + rndGap_ && (_now <= round_[_rID].end || (_now > round_[_rID].end && round_[_rID].plyr == 0)))
            return ( (round_[_rID].eth).keysRec(_eth) );
        else // 回合结束了. 需要新一轮的钥匙
            return ( (_eth).keys() );
    }

    /**
    * 根据所需的钥匙数返回需要发送的eth数量
    * */
    function iWantXKeys(uint256 _keys) public view returns(uint256) {
        uint256 _rID = rID_;
        uint256 _now = now;
        
        // 判断是否在回合中
        if (_now > round_[_rID].strt + rndGap_ && (_now <= round_[_rID].end || (_now > round_[_rID].end && round_[_rID].plyr == 0)))
            return ( (round_[_rID].keys.add(_keys)).ethRec(_keys) );
        else // 回合结束了. 需要新一轮的价格
            return ( (_keys).eth() );
    }

    //===============================
    // 玩家信息 & 收入 & 分配
    //===============================
    /**
    * 从名称合约中获取名称/玩家信息
     */
    function receivePlayerInfo(uint256 _pID, address _addr, bytes32 _name, uint256 _laff) external {
        require (msg.sender == address(PlayerBook), "不是玩家姓名合约");
        if (pIDxAddr_[_addr] != _pID)
            pIDxAddr_[_addr] = _pID;
        if (pIDxName_[_name] != _pID)
            pIDxName_[_name] = _pID;
        if (plyr_[_pID].addr != _addr)
            plyr_[_pID].addr = _addr;
        if (plyr_[_pID].name != _name)
            plyr_[_pID].name = _name;
        if (plyr_[_pID].laff != _laff)
            plyr_[_pID].laff = _laff;
        if (plyrNames_[_pID][_name] == false)
            plyrNames_[_pID][_name] = true;
    }

    /**
    * 接收整个玩家名单
     */
    function receivePlayerNameList(uint256 _pID, bytes32 _name) external {
        require (msg.sender == address(PlayerBook), "不是玩家姓名合约");
        if(plyrNames_[_pID][_name] == false) plyrNames_[_pID][_name] = true;
    }

    /**
    * 获得现有或注册新的pID，当玩家可能是新手时调用此方法
     */
    function determinePID(F3Ddatasets.EventReturns memory _eventData_) private returns (F3Ddatasets.EventReturns) {
        uint256 _pID = pIDxAddr_[msg.sender];
        // 如果玩家是这个版本的fomo3d的新手
        if (_pID == 0) {
            // 获取来着玩家姓名合约的玩家id，姓名和最后的成员id
            _pID = PlayerBook.getPlayerID(msg.sender);
            bytes32 _name = PlayerBook.getPlayerName(_pID);
            uint256 _laff = PlayerBook.getPlayerLAff(_pID);
            
            // 设置玩家账号
            pIDxAddr_[msg.sender] = _pID;
            plyr_[_pID].addr = msg.sender;
            
            if (_name != ""){
                pIDxName_[_name] = _pID;
                plyr_[_pID].name = _name;
                plyrNames_[_pID][_name] = true;
            }
            
            if (_laff != 0 && _laff != _pID)
                plyr_[_pID].laff = _laff;
            
            // 将新玩家标志设置为true
            _eventData_.compressedData = _eventData_.compressedData + 1;
        } 
        return (_eventData_);
    }

    /**
    * 检查以确保用户选择了一个有效的团队。 如果没有设置团队
     */
    function verifyTeam(uint256 _team) private pure returns (uint256) {
        if (_team < 0 || _team > 3)
            return(2);
        else
            return(_team);
    }

    /**
    * 将任何未经掩盖的收入移至金库。 更新收入掩码
     */
    function updateGenVault(uint256 _pID, uint256 _rIDlast) private {
        uint256 _earnings = calcUnMaskedEarnings(_pID, _rIDlast);
        if (_earnings > 0) {
            // 将收入加入金库
            plyr_[_pID].gen = _earnings.add(plyr_[_pID].gen);
            // 通过更新掩码将收入归零
            plyrRnds_[_pID][_rIDlast].mask = _earnings.add(plyrRnds_[_pID][_rIDlast].mask);
        }
    }

    /**
    * 决定是否结束该回合并开始新的回合，如果玩家以前玩过的回合的为掩码的收益需要被移动
     */
    function managePlayer(uint256 _pID, F3Ddatasets.EventReturns memory _eventData_) private returns (F3Ddatasets.EventReturns) {
        // 如果玩家已经玩过上一轮，则将他们未被掩盖的收益从该轮转移到金库
        if (plyr_[_pID].lrnd != 0)
            updateGenVault(_pID, plyr_[_pID].lrnd);
            
        // 更新玩家的最后一轮回合的id
        plyr_[_pID].lrnd = rID_;
            
        // 设置玩家加入该回合的标志为true
        _eventData_.compressedData = _eventData_.compressedData + 10;
        
        return(_eventData_);
    }

    /**
    * 结束这一回合。 管理支付赢家/拆分奖池
     */
    function endRound(F3Ddatasets.EventReturns memory _eventData_) private returns (F3Ddatasets.EventReturns) {
        uint256 _rID = rID_;
        
        // 获取获胜玩家的id和该玩家所属队伍的id
        uint256 _winPID = round_[_rID].plyr;
        uint256 _winTID = round_[_rID].team;
        
        // 获取奖池的eth数量
        uint256 _pot = round_[_rID].pot;
        
        // 计算 赢家份额, 基金社区份额, 普通份额, p3d 份额, and 流入下一轮奖池的份额
        uint256 _win = (_pot.mul(48)) / 100;
        uint256 _com = (_pot / 50);
        uint256 _gen = (_pot.mul(potSplit_[_winTID].gen)) / 100;
        uint256 _p3d = (_pot.mul(potSplit_[_winTID].p3d)) / 100;
        uint256 _res = (((_pot.sub(_win)).sub(_com)).sub(_gen)).sub(_p3d);
        
        // 计算回合掩码的 ppt
        uint256 _ppt = (_gen.mul(1000000000000000000)) / (round_[_rID].keys);
        uint256 _dust = _gen.sub((_ppt.mul(round_[_rID].keys)) / 1000000000000000000);
        if (_dust > 0)
        {
            _gen = _gen.sub(_dust);
            _res = _res.add(_dust);
        }
        
        // 支付给赢家
        plyr_[_winPID].win = _win.add(plyr_[_winPID].win);
        
        // 社区奖励
        if (!address(Jekyll_Island_Inc).call.value(_com)(bytes4(keccak256("deposit()")))) {
            // 这样可以确保Team Just不会通过破坏传出事务来影响FoMo3D与银行迁移的结果。
            // 我们永远不会做的事情。 但那不是重点。
            // 我们花了2000美元用于重新部署，只是为了修补它，我们坚信我们创造的一切都应该是无信任的。
            // JUST团队，你不应该信任的名字。
            _p3d = _p3d.add(_com);
            _com = 0;
        }
        
        // 将gen部分分配给钥匙持有者
        round_[_rID].mask = _ppt.add(round_[_rID].mask);
        
        // 将p3d的份额发送给开发者
        if (_p3d > 0)
            Divies.deposit.value(_p3d)();
            
        // 准备事件数据
        _eventData_.compressedData = _eventData_.compressedData + (round_[_rID].end * 1000000);
        _eventData_.compressedIDs = _eventData_.compressedIDs + (_winPID * 100000000000000000000000000) + (_winTID * 100000000000000000);
        _eventData_.winnerAddr = plyr_[_winPID].addr;
        _eventData_.winnerName = plyr_[_winPID].name;
        _eventData_.amountWon = _win;
        _eventData_.genAmount = _gen;
        _eventData_.P3DAmount = _p3d;
        _eventData_.newPot = _res;
        
        // 开启下一回合
        rID_++;
        _rID++;
        round_[_rID].strt = now;
        round_[_rID].end = now.add(rndInit_).add(rndGap_);
        round_[_rID].pot = _res;
        
        return(_eventData_);
    }

    /**
    * 根据购买的全部钥匙数量更新回合计时器
     */
    function updateTimer(uint256 _keys, uint256 _rID) private {
        uint256 _now = now;
        
        // 根据购买的钥匙数计算时间
        uint256 _newTime;
        if (_now > round_[_rID].end && round_[_rID].plyr == 0)
            _newTime = (((_keys) / (1000000000000000000)).mul(rndInc_)).add(_now);
        else
            _newTime = (((_keys) / (1000000000000000000)).mul(rndInc_)).add(round_[_rID].end);
        
        // 与最大值比较并设置新的结束时间
        if (_newTime < (rndMax_).add(_now))
            round_[_rID].end = _newTime;
        else
            round_[_rID].end = rndMax_.add(_now);
    }

    /**
    * 生成0-99之间的随机数，并检查是否导致空投获胜
     */
    function airdrop() private view returns(bool) {
        uint256 seed = uint256(
            keccak256(
                abi.encodePacked((block.timestamp).add(block.difficulty).add((uint256(keccak256(abi.encodePacked(block.coinbase)))) / (now))
        .add(block.gaslimit).add((uint256(keccak256(abi.encodePacked(msg.sender)))) / (now)).add(block.number))));

        if((seed - ((seed / 1000) * 1000)) < airDropTracker_)
            return(true);
        else
            return(false);
    }

    /**
    * 根据对com，aff和p3d的费用分配eth
     */
    function distributeExternal(uint256 _rID, uint256 _pID, uint256 _eth, uint256 _affID, uint256 _team, F3Ddatasets.EventReturns memory _eventData_) 
        private returns(F3Ddatasets.EventReturns) {

        // 支付 2% 的社区奖励
        uint256 _com = _eth / 50;
        uint256 _p3d;
        if (!address(Jekyll_Island_Inc).call.value(_com)(bytes4(keccak256("deposit()")))) {
            _p3d = _com;
            _com = 0;
        }
        
        // 支付 1% 给 FoMo3D
        uint256 _long = _eth / 100;
        otherF3D_.potSwap.value(_long)();
        
        // 10%的佣金份额
        uint256 _aff = _eth / 10;
        
        // 决定如何处理会员分担费用
        // 会员必须不是自己, 并且必须要有一个已经注册的名称
        if (_affID != _pID && plyr_[_affID].name != "") {
            plyr_[_affID].aff = _aff.add(plyr_[_affID].aff);
            emit F3Devents.onAffiliatePayout(_affID, plyr_[_affID].addr, plyr_[_affID].name, _rID, _pID, _aff, now);
        } else {
            _p3d = _aff;
        }
        
        // 支付给 p3d
        _p3d = _p3d.add((_eth.mul(fees_[_team].p3d)) / (100));
        if (_p3d > 0)
        {
            // 存入划分合约
            Divies.deposit.value(_p3d)();
            
            // 设置事件数据
            _eventData_.P3DAmount = _p3d.add(_eventData_.P3DAmount);
        }
        
        return(_eventData_);
    }

    /**
    * 奖池互换
     */
    function potSwap() external payable {
        uint256 _rID = rID_ + 1;
        
        round_[_rID].pot = round_[_rID].pot.add(msg.value);
        emit F3Devents.onPotSwapDeposit(_rID, msg.value);
    }

    /**
     * @dev 购买钥匙时更新回合和玩家的掩码
     */
    function updateMasks(uint256 _rID, uint256 _pID, uint256 _gen, uint256 _keys) private returns(uint256) {
        /* MASKING NOTES
           收入掩码对人们来说是一个棘手的事情。这里要理解的基本内容。 将会有一个基于每轮利润的全局跟踪器，它与份额供应增加的相关比例增加。
           玩家将有一个额外的掩码基本上说“根据回合掩码，我的份额，我已经撤回了多少，还欠我多少？”
        */
        
        // 根据此次购买计算每一把钥匙的利润和掩码
        uint256 _ppt = (_gen.mul(1000000000000000000)) / (round_[_rID].keys);
        round_[_rID].mask = _ppt.add(round_[_rID].mask);
            
        // 计算玩家从他们自己购买的收入（仅基于他们刚购买的钥匙）。 并更新玩家收入掩码
        uint256 _pearn = (_ppt.mul(_keys)) / (1000000000000000000);
        plyrRnds_[_pID][_rID].mask = (((round_[_rID].mask.mul(_keys)) / (1000000000000000000)).sub(_pearn)).add(plyrRnds_[_pID][_rID].mask);
        
        // 计算 & 返回 dust
        return(_gen.sub((_ppt.mul(round_[_rID].keys)) / (1000000000000000000)));
    }


    function distributeInternal(uint256 _rID, uint256 _pID, uint256 _eth, uint256 _team, uint256 _keys, F3Ddatasets.EventReturns memory _eventData_)
        private returns(F3Ddatasets.EventReturns) {
        // 计算普通份额
        uint256 _gen = (_eth.mul(fees_[_team].gen)) / 100;
        
        // 1% 给空投奖池
        uint256 _air = (_eth / 100);
        airDropPot_ = airDropPot_.add(_air);
        
        // 更新eth余额 (eth = eth - (com share + pot swap share + aff share + p3d share + airdrop pot share))
        uint256 _eth0 = _eth.sub(((_eth.mul(14)) / 100).add((_eth.mul(fees_[_team].p3d)) / 100));
        
        // 计算奖池
        uint256 _pot = _eth0.sub(_gen);
        
        // 分配gen份额（这就是updateMasks（）所做的）并调整尘埃的余额
        uint256 _dust = updateMasks(_rID, _pID, _gen, _keys);
        if (_dust > 0)
            _gen = _gen.sub(_dust);
        
        // 将eth加入奖池
        round_[_rID].pot = _pot.add(_dust).add(round_[_rID].pot);
        
        
        // 设置事件数据

        _eventData_.genAmount = _gen.add(_eventData_.genAmount);
        _eventData_.potAmount = _pot;
        
        return(_eventData_);
    }

    /**
     * @dev 加上未加掩码的收入和金库收入，将它们全部设为0
     */
    function withdrawEarnings(uint256 _pID) private returns(uint256) {
        // 更新金库
        updateGenVault(_pID, plyr_[_pID].lrnd);
        
        // 来着金库
        uint256 _earnings = (plyr_[_pID].win).add(plyr_[_pID].gen).add(plyr_[_pID].aff);
        if (_earnings > 0) {
            plyr_[_pID].win = 0;
            plyr_[_pID].gen = 0;
            plyr_[_pID].aff = 0;
        }

        return(_earnings);
    }

    /**
     * @dev 准备压缩数据并触发事件以进行购买或重新加载交易
     */
    function endTx(uint256 _pID, uint256 _team, uint256 _eth, uint256 _keys, F3Ddatasets.EventReturns memory _eventData_) private {
        _eventData_.compressedData = _eventData_.compressedData + (now * 1000000000000000000) + (_team * 100000000000000000000000000000);
        _eventData_.compressedIDs = _eventData_.compressedIDs + _pID + (rID_ * 10000000000000000000000000000000000000000000000000000);
        
        emit F3Devents.onEndTx
        (
            _eventData_.compressedData,
            _eventData_.compressedIDs,
            plyr_[_pID].name,
            msg.sender,
            _eth,
            _keys,
            _eventData_.winnerAddr,
            _eventData_.winnerName,
            _eventData_.amountWon,
            _eventData_.newPot,
            _eventData_.P3DAmount,
            _eventData_.genAmount,
            _eventData_.potAmount,
            airDropPot_
        );
    }

    //===============================
    // 核心代码
    //===============================

    /**
    * 这是在回合中发生的任何购买/重新加载的核心逻辑
     */
    function core(uint256 _rID, uint256 _pID, uint256 _eth, uint256 _affID, uint256 _team, F3Ddatasets.EventReturns memory _eventData_) private {

        F3Ddatasets.EventReturns memory _eventData0_ = _eventData_;
        uint256 _eth0 = _eth;
        if (plyrRnds_[_pID][_rID].keys == 0)
            _eventData0_ = managePlayer(_pID, _eventData_);
        
        // 早期的回合限制器
        if (round_[_rID].eth < 100000000000000000000 && plyrRnds_[_pID][_rID].eth.add(_eth0) > 1000000000000000000) {
            uint256 _availableLimit = (1000000000000000000).sub(plyrRnds_[_pID][_rID].eth);
            uint256 _refund = _eth0.sub(_availableLimit);
            plyr_[_pID].gen = plyr_[_pID].gen.add(_refund);
            _eth0 = _availableLimit;
        }
        
        // 如果允许留下来的eth大雨最小的eth数量
        if (_eth0 > 1000000000) {
            
            // 生成新的钥匙
            uint256 _keys = (round_[_rID].eth).keysRec(_eth0);
            
            // 如果他们至少买了一把钥匙
            if (_keys >= 1000000000000000000) {
                updateTimer(_keys, _rID);

                // 设置新的领导者
                if (round_[_rID].plyr != _pID)
                    round_[_rID].plyr = _pID;  
                if (round_[_rID].team != _team)
                    round_[_rID].team = _team; 
                
                // 设置新领导者的标志为true
                _eventData0_.compressedData = _eventData0_.compressedData + 100;
            }
                
            // 管理空投
            if (_eth0 >= 100000000000000000) {
                airDropTracker_++;
                if (airdrop() == true) {
                    // gib muni
                    uint256 _prize;
                    if (_eth0 >= 10000000000000000000) {
                        // 计算奖金并将其交给获胜者
                        _prize = ((airDropPot_).mul(75)) / 100;
                        plyr_[_pID].win = (plyr_[_pID].win).add(_prize);
                        
                        // 调整空投奖池
                        airDropPot_ = (airDropPot_).sub(_prize);
                        
                        // 让事件知道获得了三等奖
                        _eventData0_.compressedData += 300000000000000000000000000000000;
                    } else if (_eth0 >= 1000000000000000000 && _eth0 < 10000000000000000000) {
                        // 计算奖金并将其交给获胜者
                        _prize = ((airDropPot_).mul(50)) / 100;
                        plyr_[_pID].win = (plyr_[_pID].win).add(_prize);
                        
                        // 调整空投奖池
                        airDropPot_ = (airDropPot_).sub(_prize);
                        
                        // 让事件知道获得了二等奖
                        _eventData0_.compressedData += 200000000000000000000000000000000;
                    } else if (_eth >= 100000000000000000 && _eth < 1000000000000000000) {
                        // 计算奖金并将其交给获胜者
                        _prize = ((airDropPot_).mul(25)) / 100;
                        plyr_[_pID].win = (plyr_[_pID].win).add(_prize);
                        
                        // 调整空投奖池
                        airDropPot_ = (airDropPot_).sub(_prize);
                        
                        // 让事件知道获得了三等奖
                        _eventData0_.compressedData += 300000000000000000000000000000000;
                    }
                    // 设置空投发生标志为true
                    _eventData0_.compressedData += 10000000000000000000000000000000;
                    // 让事件知道赢了多少
                    _eventData0_.compressedData += _prize * 1000000000000000000000000000000000;
                    
                    // 重置空投跟踪器
                    airDropTracker_ = 0;
                }
            }
    
            // 存储空投跟踪器编号（自上次空投以来的购买次数）
            _eventData0_.compressedData = _eventData0_.compressedData + (airDropTracker_ * 1000);
            
            // 跟新玩家数据
            plyrRnds_[_pID][_rID].keys = _keys.add(plyrRnds_[_pID][_rID].keys);
            plyrRnds_[_pID][_rID].eth = _eth0.add(plyrRnds_[_pID][_rID].eth);
            
            // 更新回合数据
            round_[_rID].keys = _keys.add(round_[_rID].keys);
            round_[_rID].eth = _eth0.add(round_[_rID].eth);
            rndTmEth_[_rID][_team] = _eth0.add(rndTmEth_[_rID][_team]);
    
            // 分配 eth
            _eventData0_ = distributeExternal(_rID, _pID, _eth0, _affID, _team, _eventData0_);
            _eventData0_ = distributeInternal(_rID, _pID, _eth0, _team, _keys, _eventData0_);
            
            // 调用endTx函数来触发结束交易事件
            endTx(_pID, _team, _eth0, _keys, _eventData0_);
        }
    }

    /**
    * 每当执行买单时，逻辑就会运行。 根据我们是否激活了回合，确定如何处理传入的eth
     */
    function buyCore(uint256 _pID, uint256 _affID, uint256 _team, F3Ddatasets.EventReturns memory _eventData_) private {
        uint256 _rID = rID_;
        uint256 _now = now;
        F3Ddatasets.EventReturns memory _eventData0_ = _eventData_;
        
        // 如果回合处于激活状态
        if (_now > round_[_rID].strt + rndGap_ && (_now <= round_[_rID].end || (_now > round_[_rID].end && round_[_rID].plyr == 0))) {
            core(_rID, _pID, msg.value, _affID, _team, _eventData0_);
        } else {
            // 检查是否需要调用结束回合的函数
            if (_now > round_[_rID].end && round_[_rID].ended == false) {
                // 结束回合，开始新的回合
                round_[_rID].ended = true;
                _eventData0_ = endRound(_eventData0_);
                
                // 构建事件数据
                _eventData0_.compressedData = _eventData0_.compressedData + (_now * 1000000000000000000);
                _eventData0_.compressedIDs = _eventData0_.compressedIDs + _pID;
                
                // 触发购买个分配事件
                emit F3Devents.onBuyAndDistribute
                (
                    msg.sender, 
                    plyr_[_pID].name, 
                    msg.value, 
                    _eventData0_.compressedData, 
                    _eventData0_.compressedIDs, 
                    _eventData0_.winnerAddr, 
                    _eventData0_.winnerName, 
                    _eventData0_.amountWon, 
                    _eventData0_.newPot, 
                    _eventData0_.P3DAmount, 
                    _eventData0_.genAmount
                );
            }
            
            // 将 eth 加入玩家的金库
            plyr_[_pID].gen = plyr_[_pID].gen.add(msg.value);
        }
    }

    /**
    * 每当执行重新加载订单时，逻辑就会运行。 根据我们是否激活了回合，确定如何处理传入的eth
     */
    function reLoadCore(uint256 _pID, uint256 _affID, uint256 _team, uint256 _eth, F3Ddatasets.EventReturns memory _eventData_) private {

        uint256 _rID = rID_;
        uint256 _now = now;
        F3Ddatasets.EventReturns memory _eventData0_ = _eventData_;

        // 如果回合处于激活状态
        if (_now > round_[_rID].strt + rndGap_ && (_now <= round_[_rID].end || (_now > round_[_rID].end && round_[_rID].plyr == 0))) 
        {
            // 从我们使用自定义safemath库获取所有金库的收入并返回未使用的普通金库。 如果玩家试图花费比他们更多的eth，将抛出异常。
            plyr_[_pID].gen = withdrawEarnings(_pID).sub(_eth);
            
            core(_rID, _pID, _eth, _affID, _team, _eventData0_);
        
        
        } else if (_now > round_[_rID].end && round_[_rID].ended == false) { // 否则调用结束回合的函数
            // 结束回合，开始新的回合
            round_[_rID].ended = true;
            _eventData0_ = endRound(_eventData0_);
                
            // 构建事件数据
            _eventData0_.compressedData = _eventData0_.compressedData + (_now * 1000000000000000000);
            _eventData0_.compressedIDs = _eventData0_.compressedIDs + _pID;
                
            // 将 eth 加入玩家的金库
            emit F3Devents.onReLoadAndDistribute
            (
                msg.sender, 
                plyr_[_pID].name, 
                _eventData0_.compressedData, 
                _eventData0_.compressedIDs, 
                _eventData0_.winnerAddr, 
                _eventData0_.winnerName, 
                _eventData0_.amountWon, 
                _eventData0_.newPot, 
                _eventData0_.P3DAmount, 
                _eventData0_.genAmount
            );
        }
    }

    //===============================
    // UI & 在etherscan查看
    //===============================

    /**
    * 返回下一次购买key的价格
     */
    function getBuyPrice() public view returns(uint256) {  
        uint256 _rID = rID_;
        uint256 _now = now;
        
        // 是否在回合中
        if (_now > round_[_rID].strt + rndGap_ && (_now <= round_[_rID].end || (_now > round_[_rID].end && round_[_rID].plyr == 0)))
            return ( (round_[_rID].keys.add(1000000000000000000)).ethRec(1000000000000000000) );
        else // 回合结束.  需要新回合的购买价格
            return ( 75000000000000 ); // 初始化
    }

    /**
    * 获取剩余时间
     */
    function getTimeLeft() public view returns(uint256) {
        uint256 _rID = rID_;
        uint256 _now = now;

        if (_now < round_[_rID].end)
            if (_now > round_[_rID].strt + rndGap_)
                return( (round_[_rID].end).sub(_now) );
            else
                return( (round_[_rID].strt + rndGap_).sub(_now) );
        else
            return(0);
    }

    /**
    *   ...
     */
    function getPlayerVaultsHelper(uint256 _pID, uint256 _rID) private view returns(uint256) {
        return(  ((((round_[_rID].mask).add(((((round_[_rID].pot).mul(potSplit_[round_[_rID].team].gen)) / 100).mul(1000000000000000000)) / (round_[_rID].keys))).mul(plyrRnds_[_pID][_rID].keys)) / 1000000000000000000)  );
    }

    function getPlayerVaults(uint256 _pID) public view returns(uint256 ,uint256, uint256) {
        // setup local rID
        uint256 _rID = rID_;
        
        // if round has ended.  but round end has not been run (so contract has not distributed winnings)
        if (now > round_[_rID].end && round_[_rID].ended == false && round_[_rID].plyr != 0)
        {
            // if player is winner 
            if (round_[_rID].plyr == _pID)
            {
                return
                (
                    (plyr_[_pID].win).add( ((round_[_rID].pot).mul(48)) / 100 ),
                    (plyr_[_pID].gen).add(  getPlayerVaultsHelper(_pID, _rID).sub(plyrRnds_[_pID][_rID].mask)   ),
                    plyr_[_pID].aff
                );
            // if player is not the winner
            } else {
                return
                (
                    plyr_[_pID].win,
                    (plyr_[_pID].gen).add(  getPlayerVaultsHelper(_pID, _rID).sub(plyrRnds_[_pID][_rID].mask)  ),
                    plyr_[_pID].aff
                );
            }
            
        // if round is still going on, or round has ended and round end has been ran
        } else {
            return
            (
                plyr_[_pID].win,
                (plyr_[_pID].gen).add(calcUnMaskedEarnings(_pID, plyr_[_pID].lrnd)),
                plyr_[_pID].aff
            );
        }
    }
}