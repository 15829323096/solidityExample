## solidity项目部署流程

参考：[Solidity的Truffle框架实战(手把手)](https://www.jianshu.com/p/8794afea1996) 

### 1. 安装`truffle`
```
$ npm install truffle
```


### 2.创建项目
```
$ mkdir fomo3dTest
$ cd fomo3dTest
$ truffle install
```

如果项目已经存在，需在项目内执行`npm install`

**修改truffle.js**

```
module.exports = {
  // See <http://truffleframework.com/docs/advanced/configuration>
  // to customize your Truffle configuration!
  networks: {
    development: {
      host: "localhost",
      port: 8545,
      network_id: "*" // 匹配任何network id
    }
  }
};
```

###3. 安装`ganache-cli`,`web3`
```
$ npm install ganache-cli
$ npm install web3
```

### 4.编译
```
$ truffle compile
```

### 5.启动客户端
```
$ ganache-cli
```

### 6.部署合约
```
$ truffle migrate
$ truffle console
truffle(development)> 
...
truffle(development)> .exit //退出
```

### 7.当前可用来测试例子

参考：[以太坊开发框架truffle入门指南-01](https://www.jianshu.com/p/00be1bb532ae)

```

truffle(development)> Greeter.hasNetwork()
truffle(development)> let contract;
truffle(development)> Greeter.deployed().then( instance => contract = instance );
truffle(development)> contract.setGreeting("hello");
truffle(development)> contract.greet()
```

### 8.测试

参考：[【区块链】Truffle 部署和测试](https://blog.csdn.net/loy_184548/article/details/78020369)

### 9.任务
 
 compile.sh: 编译且加入合约
 build.sh: 编译且加入合约，然后打开控制台
 test.sh: 编译且加入合约，然后测试全部用例

 test(file)：测试当前打开的测试文件，前提是已经编译好了
 start service：启动服务

 注意：测试和部署前，先启动服务器