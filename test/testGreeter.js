
var Greeter = artifacts.require("./Greeter.sol");
contract("Greeter", function(accounts){
    it("say Hello", function(){

        var str = "hello";
        var contract;

        return Greeter.deployed().then(function(instance){
            contract = instance;
            return contract.setGreeting(str);
        }).then(function(){
            return contract.greet.call();
        }).then(function(last_completed_migration){
            
            assert.equal(last_completed_migration, str, "greeting doesn't match!");

        });

    });
});