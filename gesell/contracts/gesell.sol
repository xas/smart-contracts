// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

import "./safeMath.sol";
import "./interface.sol";
import "./dai.sol";

/**
 * @title Gesell Token
 * Author : https://github.com/xas
 * Version : 0.6 Proof Of Concept edition
*/
contract Gesell is ERC20 {
    using SafeMath for uint256;

    // Dai interface
    DaiToken _daitoken;
    address payable _creator;

    // balances for an address
    mapping (address => uint256) public balances;
    mapping (address => uint256) public transferAge;
    // approved balance for an address
    mapping (address => mapping (address => uint256)) public allowed;

    // Event fired when a transfer is executed
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    // Event fired when an approval is executed
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    // Event fired when tokens are burned
    event Buy(address indexed _buyer, uint256 _value);
    // Event fired when tokens are burned
    event Burned(uint256 _value);

    // Returns the name of the token
    string private _name;
    function name() public view returns (string memory) { return _name; }
    // Returns the symbol of the token
    string private _symbol;
    function symbol() public view returns (string memory) { return _symbol; }
    // Returns the number of decimals the token uses - e.g. 8, means to divide the token amount by 100000000 to get its user representation.
    function decimals() public pure returns (uint8) { return 18; }
    // Returns the total token supply. 10M here.
    uint256 private _totalSupply;
    function totalSupply() public view override returns (uint256) { return _totalSupply; }

    /**
    * @dev Default constructor
    * Initialize all the tokens to the creator
    * DAI on kovan 0x4F96Fe3b7A6Cf9725f59d353F723c1bDb64CA6Aa
    */
    constructor(address _daiAddress) {
        _totalSupply = 10000000 ether;
        _name = "Gesell";
        _symbol = "GSLT";
        _creator = msg.sender;
        require(_daiAddress != address(0), "Address of Dai token is zero");
        require(_daiAddress != msg.sender, "Address of Dai token is a no");
        _daitoken = DaiToken(_daiAddress);
    }

    /**
    * @dev Gets the balance of the specified address.
    * @param _owner The address to query the the balance of.
    * @return An uint256 representing the amount owned by the passed address.
    */
    function balanceOf(address _owner) public view override returns (uint256) {
        return balances[_owner];
    }

    /**
    * @dev transfer token for a specified address
    * @param _to The address to transfer to.
    * @param _value The amount to be transferred.
    */
    function transfer(address _to, uint256 _value) public override returns (bool) {
        require(_to != address(0), "Refuse to send to zero address");
        require(_value > 1, "Refuse to transfer less than 2 tokens");
        require(_value <= balances[msg.sender], "You can't transfer more than your balance");

        return _transfer(msg.sender, _to, _value);
    }

    /**
    * @dev Transfer tokens from one address to another
    * @param _from address The address which you want to send tokens from
    * @param _to address The address which you want to transfer to
    * @param _value uint256 the amount of tokens to be transferred
    */
    function transferFrom (address _from, address _to, uint256 _value) public override returns (bool)
    {
        require(_to != address(0), "Refuse to send to zero address");
        require(_value > 1, "Refuse to transfer less than 2 tokens");
        require(_value <= balances[_from], "You can't transfer more than your balance");
        require(_value <= allowed[_from][msg.sender], "You can't transfer more than allowed");

        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        return _transfer(_from, _to, _value);
    }

    /**
    * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
    *
    * Beware that changing an allowance with this method brings the risk that someone may use both the old
    * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
    * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
    * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
    * @param _spender The address which will spend the funds.
    * @param _value The amount of tokens to be spent.
    */
    function approve(address _spender, uint256 _value) public override returns (bool) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    /**
    * @dev Function to check the amount of tokens that an owner allowed to a spender.
    * @param _owner address The address which owns the funds.
    * @param _spender address The address which will spend the funds.
    * @return A uint256 specifying the amount of tokens still available for the spender.
    */
    function allowance(address _owner, address _spender) public view override returns (uint256) {
        return allowed[_owner][_spender];
    }

    /**
    * @dev Function to compute how much token will be burnt by the transfer method
    * @param _origin address. The address which will transfer the funds
    * @return A uint8 specifying the amount of tokens to burn before the tansfer
    */
    function computeBurn(address _origin) internal view returns (uint8) {
        if (block.timestamp > transferAge[_origin] + 4 * 1 weeks) {
            return 250;
        }
        if (block.timestamp > transferAge[_origin] + 3 * 1 weeks) {
            return 100;
        }
        if (block.timestamp > transferAge[_origin] + 2 * 1 weeks) {
            return 50;
        }
        if (block.timestamp > transferAge[_origin] + 1 * 1 weeks) {
            return 10;
        }
        return 1;
    }

    function _transfer(address _from, address _to, uint256 _amount) internal returns (bool) {
         // Burn by age of last transfer
        uint256 _toBurn = computeBurn(_from);
        uint256 _newValue = _amount.sub(_toBurn, "Burn : Amount smaller than burnt");
        _totalSupply = _totalSupply.sub(_toBurn, "Burn : Total supply smaller than burnt");

        balances[_from] = balances[_from].sub(_amount, "Transfer : Balance smaller than amount");
        balances[_to] = balances[_to].add(_newValue);

        transferAge[_from] = block.timestamp;
        transferAge[_to] = block.timestamp;
        
        emit Burned(_toBurn);
        emit Transfer(_from, address(0), _toBurn);
        emit Transfer(_from, _to, _newValue);

        return true;
   }

   function buy(uint256 _amount) public returns (bool) {
        balances[msg.sender] = balances[msg.sender].add(_amount);
        transferAge[msg.sender] = block.timestamp;
        _daitoken.transferFrom(msg.sender, _creator, _amount);
        emit Buy(msg.sender, _amount);
        return true;
   }

   receive() external payable {
        balances[msg.sender] = balances[msg.sender].add(msg.value);
        transferAge[msg.sender] = block.timestamp;
        _creator.transfer(msg.value);
        emit Buy(msg.sender, msg.value);
   }
}