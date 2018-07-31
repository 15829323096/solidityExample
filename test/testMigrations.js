

var Migrations = artifacts.require("./Migrations.sol");
contract("Migrations", function(accounts){
    it("say Migrations", function(){

        // let contract = Migrations.deployed();

        // contract.setCompleted(23);
        var compile = 23;
        var contract;
        return Migrations.deployed().then(function(instance){
            contract = instance;
            return contract.setCompleted(compile);
        }).then(function(){
            return contract.getCompleted.call();
        }).then(function(last_completed_migration){
            
            assert.equal(last_completed_migration, compile, "completed doesn't match!");

        });

    });
});