pragma solidity ^0.6.0;

import "openzeppelin-solidity/contracts/math/SafeMath.sol"; // opens directly from the node_modules directory

contract Token { //code for the smart contract goes inside here
	using SafeMath for uint;

	string public name = "Medallo Token"; //declaring state variable - need to specify data type of the variable on declaring. Need the 'public' to ensure that this variable is visible outside of the smart contract
	string public symbol = "MED";
	uint256 public decimals = 18;
	uint256 public totalSupply;

	// Track balances - stores how much someone owns on the blockchain
	//  Send tokens - deduct balance from one account and adding to another
	mapping(address => uint256) public balanceOf; // mapping is a hash or dictionary where you associate key-value pairs - in this case the address with the account balance
	// the mapping variable balanceOf will therefore at the same time create a state variable and a function to get this variable
	mapping(address => mapping(address => uint256)) public allowance; // for each address, it maps to all other addresses the allowances that that particular address has approved to them
	
	//Events
	event Transfer(address indexed from, address indexed to, uint256 value); // indexed allows to subscribe to events only pertaining to us, or a specific address
	event Approval(address indexed owner, address indexed spender, uint256 value); 

	constructor() public {
		totalSupply = 1000000 * (10 ** decimals);
		balanceOf[msg.sender] = totalSupply; // this is altering the value at 'msg.sender' as would be the case in Python dictionaries
		// msg.sender is the address of the person that is deploying the smart contract
	}	

	function transfer(address _to, uint256 _value) public returns (bool success) {
		require(balanceOf[msg.sender] >= _value); // if this returns false then code execution will stop and an exception will be thrown
		_transfer(msg.sender, _to, _value);
		return true;

	}

	function _transfer(address _from, address _to, uint256 _value) internal {
		require(_to != address(0)); // address (x) is an inbuilt function? 
		balanceOf[_from] = balanceOf[_from].sub(_value);
		balanceOf[_to] = balanceOf[_to].add(_value);
		emit Transfer(_from, _to, _value);
	}

	// Approve tokens
	function approve(address _spender, uint256 _value) public returns (bool success) {
		require(_spender != address(0)); 
		allowance[msg.sender][_spender] = _value;
		emit Approval(msg.sender, _spender, _value);
		return true;

	}
	
	// Transfer from 
	function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
		require(balanceOf[_from] >= _value);
		require(allowance[_from][msg.sender] >= _value);
		allowance[_from][msg.sender] = allowance[_from][msg.sender].sub(_value);
		_transfer(_from, _to, _value);
		return true;
	}
}	