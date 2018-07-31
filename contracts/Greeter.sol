pragma solidity ^0.4.23;

contract Greeter {
    address creator;     
    string greeting;     

    constructor() public   
    {
        creator = msg.sender;
        greeting = "";
    }

    function greet() view public returns (string)          
    {
        return greeting;
    }
    
    function setGreeting(string _newgreeting) public
    {
        greeting = _newgreeting;
    }
    
     /**********
     Standard kill() function to recover funds 
     **********/
    
    function kill() public
    { 
        if (msg.sender == creator)
            selfdestruct(creator);  // kills this contract and sends remaining funds back to creator
    }
}