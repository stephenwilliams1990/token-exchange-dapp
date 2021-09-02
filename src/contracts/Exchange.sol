pragma solidity ^0.6.0;

import "./Token.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";

//TODO: 
// [X] Set the Fee account
// [X] Deposit Ether
// [X] Withdraw Ether
// [X] Deposit Tokens
// [X] Withdraw Tokens
// [X] Check balances
// [X] Make Order
// [X] Cancel Order
// [X] Fill Order
// [X] Charge fees


contract Exchange {
	using SafeMath for uint;

	address public feeAccount; // the account which receives exchange fees
	uint256 public feePercent; // the fee percentage 
	address constant ETHER = address(0); // store Ether in tokens mapping with blank address
	mapping(address => mapping(address => uint256)) public tokens; // first key is the token address, and then for each token it lists every user address and the number of tokens they hold of that specific token	
	mapping(uint256 => _Order) public orders; // the uint256 key is the order id
	uint256 public orderCount; // count that will start at 0 and increase
	mapping(uint256 => bool) public orderCancelled; 
	mapping(uint256 => bool) public orderFilled; 	

	// Events
	event Deposit(address token, address user, uint256 amount, uint256 balance);
	event Withdraw(address token, address user, uint256 amount, uint256 balance);
	event Order(uint256 id, address user, address tokenGet, uint256 amountGet, address tokenGive, uint256 amountGive, uint256 timestamp);
	event Cancel(uint256 id, address user, address tokenGet, uint256 amountGet, address tokenGive, uint256 amountGive, uint256 timestamp);
	event Trade(uint256 id, address user, address tokenGet, uint256 amountGet, address tokenGive, uint256 amountGive, address userFill, uint256 timestamp);
	
	// Structs
	struct _Order { // this creates an object that will go into our database with the following attributes
		uint256 id;
		address user;
		address tokenGet;
		uint256 amountGet;
		address tokenGive;
		uint256 amountGive;
		uint256 timestamp;
	}
	// a way to store the order on the blockchain
	// add the order to storage

	constructor (address _feeAccount, uint256 _feePercent) public {
		feeAccount = _feeAccount; // naming convention to separate local and state variables
		feePercent = _feePercent;
	}

	// Fallback: reverts if Ether is sent to this smart contract by mistake
	fallback() external { // take this to mean that any external function not defined here will result in a reversion of funds
		revert();
	}

	function depositEther() payable public { // need the payable modifier here in order for the function to accept ether with the metadata
		tokens[ETHER][msg.sender] = tokens[ETHER][msg.sender].add(msg.value); // including the msg.value metadata is how you pass the amount of ether into the function
		emit Deposit(ETHER, msg.sender, msg.value, tokens[ETHER][msg.sender]);
	}

	function withdrawEther(uint _amount) public {
		require(tokens[ETHER][msg.sender] >= _amount);
		tokens[ETHER][msg.sender] = tokens[ETHER][msg.sender].sub(_amount); 
		msg.sender.transfer(_amount); // this transfer it back to their account
		emit Withdraw(ETHER, msg.sender, _amount, tokens[ETHER][msg.sender]);
	}

	function depositToken(address _token, uint _amount) public { // any ERC20 token will have an address that the blockchain can identify
		// Don't allow Ether deposits
		require(_token != ETHER);
		// the below transferFrom function will allow the exchange to move tokens to itself 		
		require(Token(_token).transferFrom(msg.sender, address(this), _amount)); // this will be an instance of the _token token on the network
		// Manage deposit - update balance
		tokens[_token][msg.sender] = tokens[_token][msg.sender].add(_amount);
		// Emit event
		emit Deposit(_token, msg.sender, _amount, tokens[_token][msg.sender]);
	}

	function withdrawToken(address _token, uint256 _amount) public {
		require(_token != ETHER);
		require(tokens[_token][msg.sender] >= _amount);
		tokens[_token][msg.sender] = tokens[_token][msg.sender].sub(_amount);
		require(Token(_token).transfer(msg.sender, _amount)); 
		emit Withdraw(_token, msg.sender, _amount, tokens[_token][msg.sender]);
	}

	function balanceOf(address _token, address _user) public view returns (uint256) { // public view means it is a reader function that will return a uint256 value
		return tokens[_token][_user];
	}

	function makeOrder(address _tokenGet, uint256 _amountGet, address _tokenGive, uint256 _amountGive) public {
		orderCount = orderCount.add(1);
		orders[orderCount] = _Order(orderCount, msg.sender, _tokenGet, _amountGet, _tokenGive, _amountGive, now);
		emit Order(orderCount, msg.sender, _tokenGet, _amountGet, _tokenGive, _amountGive, now);
	}

	function cancelOrder(uint256 _id) public {
		_Order storage _order = orders[_id]; // this tells Solidity that we are fetching a _Order variable type from the blockchain storage and we will be assigning it the local name _order
		require(address(_order.user) == msg.sender);
		require(_order.id == _id); // the order must exist		
		orderCancelled[_id] = true;
		emit Cancel(_order.id, msg.sender, _order.tokenGet, _order.amountGet, _order.tokenGive, _order.amountGive, now);
	}

	function fillOrder(uint256 _id) public {
		require(_id > 0 && _id <= orderCount);
		require(!orderFilled[_id]);
		require(!orderCancelled[_id]);
		_Order storage _order = orders[_id];
		_trade(_order.id, _order.user, _order.tokenGet, _order.amountGet, _order.tokenGive, _order.amountGive);
		orderFilled[_order.id] = true;


	}

	function _trade(uint256 _orderId, address _user, address _tokenGet, uint256 _amountGet, address _tokenGive, uint256 _amountGive) internal {
		// Fee is paid by the user that fills the order; i.e. msg.sender
		// fee deducted from amountGet
		uint256 _feeAmount = _amountGive.mul(feePercent).div(100);

		tokens[_tokenGet][msg.sender] = tokens[_tokenGet][msg.sender].sub(_amountGet.add(_feeAmount)); 
		tokens[_tokenGet][_user] = tokens[_tokenGet][_user].add(_amountGet); // msg.sender is the person filling the order and _user is the person who placed the order
		tokens[_tokenGet][feeAccount] = tokens[_tokenGet][feeAccount].add(_feeAmount); 
		tokens[_tokenGive][msg.sender] = tokens[_tokenGive][msg.sender].add(_amountGive); 
		tokens[_tokenGive][_user] = tokens[_tokenGive][_user].sub(_amountGive);
		
		emit Trade(_orderId, _user, _tokenGet, _amountGet, _tokenGive, _amountGive, msg.sender, now);
	}
}

