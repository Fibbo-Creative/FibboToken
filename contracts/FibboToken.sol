// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

import "./Libraries.sol";

contract FibboToken {
    string  public name = "Fibbo Token";
    string  public symbol = "FIBBO";
    uint256 public totalSupply = 100000000000000000000000000; // 100 million tokens.
    uint8   public decimals = 18;
    address public teamWallet;
    address public daoContract;
    IDEXRouter private router; // Router address.
    address private pancakePairAddress; // Pair address.

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) private _allowances;

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    constructor(address _teamWallet, address _daoContract) {
        teamWallet = _teamWallet;
        daoContract = _daoContract;
        router = IDEXRouter(0xcCAFCf876caB8f9542d6972f87B5D62e1182767d); // TODO: TestNet
        pancakePairAddress = IPancakeFactory(router.factory()).createPair(address(this), router.WETH());

        balanceOf[teamWallet] = totalSupply;
    }

    // Modifiers
    modifier onlyOwner() {
        require(msg.sender == teamWallet, 'You must be the owner.');
        _;
    }

    /**
     * @notice Calculate the percentage of a number.
     * @param x Number.
     * @param y Percentage of number.
     * @param scale Division.
     */
    function mulScale (uint x, uint y, uint128 scale) internal pure returns (uint) {
        uint a = x / scale;
        uint b = x % scale;
        uint c = y / scale;
        uint d = y % scale;

        return a * c * scale + a * d + b * c + b * d / scale;
    }

    /**
     * @notice Function to make a transfer.
     * @param _to Recipient's address.
     * @param _value Amount of tokens to transfer.
     */
    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value);

        uint256 _feeAmount;
        if(msg.sender == pancakePairAddress) {
            // Buy
            _feeAmount = mulScale(_value, 25, 10000); // 25 basis points = 0.25%
        } else if(_to == pancakePairAddress) {
            // Sell
            _feeAmount = mulScale(_value, 100, 10000); // 100 basis points = 1%
        } else {
            // Normal Transfer
            _feeAmount = mulScale(_value, 50, 10000); // 50 basis points = 0.50%
        }
        
        uint256 _daoTokens = mulScale(_feeAmount, 7500, 10000); // 7500 basis points = 75%
        uint256 _teamTokens = _feeAmount - _daoTokens;

        uint256 _amountToSend = _value - _feeAmount;
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _amountToSend;
        balanceOf[daoContract] += _daoTokens;
        balanceOf[teamWallet] += _teamTokens;

        emit Transfer(msg.sender, _to, _amountToSend);

        return true;
    }

    /**
     * @notice Function that lets you see how many tokens you have permission to spend an address.
     * @param _owner Address of token owner.
     * @param _spender Address of token spender.
     */
    function allowance(address _owner, address _spender) public view virtual returns (uint256) {
        return _allowances[_owner][_spender];
    }

    /**
     * @notice Function that increases the allowance.
     * @param _spender Address given permission to spend tokens.
     * @param _addedValue Amount of tokens you give permission to spend.
     */
    function increaseAllowance(address _spender, uint256 _addedValue) public virtual returns (bool) {
        _approve(msg.sender, _spender, _allowances[msg.sender][_spender] + _addedValue);

        return true;
    }

    /**
     * @notice Function that decreases the allowance.
     * @param _spender Address to which permission to spend tokens is removed.
     * @param _subtractedValue Amount of tokens to be decreased from the allowed amount to spend.
     */
    function decreaseAllowance(address _spender, uint256 _subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[msg.sender][_spender];
        require(currentAllowance >= _subtractedValue, "ERC20: decreased allowance below zero");

        unchecked {
            _approve(msg.sender, _spender, currentAllowance - _subtractedValue);
        }

        return true;
    }

    /**
     * @notice Function calling the internal function _approve.
     * @param _spender Account address to which you give permission to spend your tokens.
     * @param _value Amount of tokens you give permission to spend.
     */
    function approve(address _spender, uint256 _value) public returns (bool success) {
        _approve(msg.sender, _spender, _value);

        return true;
    }

    /**
     * @notice Internal function that allows to approve another account to spend your tokens.
     * @param _owner Account address giving permission to spend your tokens.
     * @param _spender Account address to which you give permission to spend your tokens.
     * @param _amount Amount of tokens you give permission to spend.
     */
    function _approve(address _owner, address _spender, uint256 _amount) internal virtual {
        require(_owner != address(0), "ERC20: approve from the zero address");
        require(_spender != address(0), "ERC20: approve to the zero address");

        _allowances[_owner][_spender] = _amount;

        emit Approval(_owner, _spender, _amount);
    }

    /**
     * @notice Function that allows a transfer from an address.
     * @param _from Sender's address.
     * @param _to Recipient's address.
     * @param _value Amount of tokens to transfer.
     */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= balanceOf[_from]);
        require(_value <= _allowances[_from][msg.sender]);

        uint256 _feeAmount;
        if(_from == pancakePairAddress) {
            // Buy
            _feeAmount = mulScale(_value, 25, 10000); // 25 basis points = 0.25%
        } else if(_to == pancakePairAddress) {
            // Sell
            _feeAmount = mulScale(_value, 100, 10000); // 100 basis points = 1%
        } else {
            // Normal Transfer
            _feeAmount = mulScale(_value, 50, 10000); // 50 basis points = 0.50%
        }

        uint256 _daoTokens = mulScale(_feeAmount, 7500, 10000); // 7500 basis points = 75%
        uint256 _teamTokens = _feeAmount - _daoTokens;

        uint256 _amountToSend = _value - _feeAmount;
        balanceOf[_from] -= _value;
        balanceOf[_to] += _amountToSend;
        balanceOf[daoContract] += _daoTokens;
        balanceOf[teamWallet] += _teamTokens;
        _allowances[_from][msg.sender] -= _value;

        emit Transfer(_from, _to, _amountToSend);

        return true;
    }

    /**
     * @notice Public function that allows to burn tokens.
     * @param _amount Amount of tokens to be burned.
     */
    function burn(uint256 _amount) public virtual {
        _burn(msg.sender, _amount);
    }

    /**
     * @notice Internal function that allows to burn tokens.
     * @param _account Direction from which the tokens are to be burned.
     * @param _amount Amount of tokens to be burned.
     */
    function _burn(address _account, uint256 _amount) internal virtual {
        require(_account != address(0), 'No puede ser la direccion cero.');
        require(balanceOf[_account] >= _amount, 'La cuenta debe tener los tokens suficientes.');

        balanceOf[_account] -= _amount;
        totalSupply -= _amount;

        emit Transfer(_account, address(0), _amount);
    }
}