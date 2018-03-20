pragma experimental ABIEncoderV2;


contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) constant returns (uint256);
  function transfer(address to, uint256 value);
  event Transfer(address indexed from, address indexed to, uint256 value);
  function transferMessage(address to, string message);
  event TransferMessage(uint tstamp,address indexed from, address indexed to, string message);
}

contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) constant returns (uint256);
  function transferFrom(address from, address to, uint256 value);
  function approve(address spender, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

library SafeMath {
  function mul(uint256 a, uint256 b) internal returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}


contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;
  mapping(address => mapping(address => uint)) blkd;

  struct messageLog {
    string ipfsHash;
    address _to;
    uint timestamp;
  }

  mapping(address => messageLog[]) chatLog;
  
  modifier blkdStatus(address _from, address _to) {
      require(blkd[_from][_to]==0 && blkd[_to][_from]==0);
      _;
  }

  function transfer(address _to, uint256 _value) blkdStatus(msg.sender,_to) {
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
  }

  function balanceOf(address _owner) constant returns (uint256 balance) {
    return balances[_owner];
  }

  function transferMessage(address _to, string _ipfsHash) blkdStatus(msg.sender,_to) {
    //TransferMessage(now,msg.sender,_to,_message);
    chatLog[msg.sender].push(messageLog(_ipfsHash,_to,now));
  }

  function getMessage() returns (messageLog[]) {
    return chatLog[msg.sender];
  }
  
  function blockPerson(address _to) {
      blkd[msg.sender][_to]=1;
  }
  
  function unblockPerson(address _to) {
      blkd[msg.sender][_to]=0;
  }

}


contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) allowed;

  function transferFrom(address _from, address _to, uint256 _value) {
    var _allowance = allowed[_from][msg.sender];
    balances[_to] = balances[_to].add(_value);
    balances[_from] = balances[_from].sub(_value);
    allowed[_from][msg.sender] = _allowance.sub(_value);
    Transfer(_from, _to, _value);
  }

  function approve(address _spender, uint256 _value) {
    if ((_value != 0) && (allowed[msg.sender][_spender] != 0)) throw;
    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
  }

  function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }

}


contract FuncToken is StandardToken {

  string public name = "Func Token";
  string public symbol = "FUNC";
  uint256 public decimals = 18;
  uint256 public INITIAL_SUPPLY = 100000000 * 1 ether;

  function FuncToken() {
    totalSupply = INITIAL_SUPPLY;
    balances[msg.sender] = INITIAL_SUPPLY;
  }

}