//SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Auth is Context {
    address public owner;
    mapping (address => bool) internal authorizations;

    constructor(address payable _maintainer) {
        owner = payable(_maintainer);
        authorizations[owner] = true;
        authorize(_msgSender());
    }

    /**
     * Function modifier to require caller to be contract owner
     */
    modifier onlyOwner() virtual {
        require(isOwner(_msgSender()), "!OWNER"); _;
    }

    /**
     * Function modifier to require caller to be contract owner
     */
    modifier onlyZero() virtual {
        require(isOwner(address(0)), "!ZERO"); _;
    }

    /**
     * Function modifier to require caller to be authorized
     */
    modifier authorized() virtual {
        require(isAuthorized(_msgSender()), "!AUTHORIZED"); _;
    }
    
    /**
     * Function modifier to require caller to be authorized
     */
    modifier renounced() virtual {
        require(isRenounced(), "!RENOUNCED"); _;
    }

    /**
     * Authorize address. Owner only
     */
    function authorize(address adr) public onlyOwner {
        authorizations[adr] = true;
    }

    /**
     * Remove address' authorization. Owner only
     */
    function unauthorize(address adr) public onlyOwner {
        authorizations[adr] = false;
    }

    /**
     * Check if address is owner
     */
    function isOwner(address account) public view returns (bool) {
        if(account == owner){
            return true;
        } else {
            return false;
        }
    }

    /**
     * Return address' authorization status
     */
    function isAuthorized(address adr) public view returns (bool) {
        return authorizations[adr];
    }

    /**
     * Return address' authorization status
     */
    function isRenounced() public view returns (bool) {
        require(owner == address(0), "NOT RENOUNCED!");
        return owner == address(0);
    }

    /**
    * @dev Leaves the contract without owner. It will not be possible to call
    * `onlyOwner` functions anymore. Can only be called by the current owner.
    *
    * NOTE: Renouncing ownership will leave the contract without an owner,
    * thereby removing any functionality that is only available to the owner.
    */
    function renounceOwnership() public virtual onlyOwner {
        require(isOwner(_msgSender()), "Unauthorized!");
        emit OwnershipTransferred(address(0));
        authorizations[address(0)] = true;
        authorizations[owner] = false;
        owner = address(0);
    }

    /**
     * Transfer ownership to new address. Caller must be owner. 
     */
    function transferOwnership(address payable adr) public virtual onlyOwner returns (bool) {
        authorizations[adr] = true;
        authorizations[owner] = false;
        owner = payable(adr);
        emit OwnershipTransferred(adr);
        return true;
    }    

    event OwnershipTransferred(address owner);
}

interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);
    function approve(address spender, uint256 value) external;
    function transferFrom(address from, address to, uint256 value) external returns (bool);
    function totalSupply() external view returns (uint256);
    function balanceOf(address who) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

abstract contract ERC20 is IERC20, Auth {

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    mapping (address => bool) public isTxLimitExempt;

    mapping (address => bool) public isMaxWalletLimitExempt;

    mapping(address => bool) public blocklist;

    uint256 public marketingFeeInBasis;
    uint256 public liquidityFeeInBasis;
    uint256 public bp = 10000;
    uint256 public _totalSupply;
    uint256 public _maxTxAmount;
    uint256 public maxWalletAmount;
    
    string internal _name;
    string internal _symbol;
    uint8 internal _decimals;

    bool public takeFee;
    bool public isTradeEnabled;
    bool public isInitialized;
    bool public blockListEnabled;
    bool public maxTXLimitEnabled;
    bool public maxWalletLimitEnabled;
        
    address payable public _marketingWallet;
    address payable public _liquidityWallet;
    
    constructor(string memory token_name, string memory token_symbol, uint8 dec, address payable _minter,address payable _marketing,address payable _liquidity, uint256 _supply, uint256 _marketingBP, uint256 _liquidityBP, uint256 _shardLiq) Auth(payable(_msgSender())) {
        initialize(token_name, token_symbol, uint8(dec), payable(_marketing), payable(_liquidity), uint256(_supply), uint256(_marketingBP), uint256(_liquidityBP));
        uint256 deployerLiq = (uint256(_supply) * uint256(_shardLiq)) / uint256(bp); // owner => 10% shards
        uint256 contractLiq = uint256(_supply) - uint256(deployerLiq);
        _mint(payable(_minter), (uint256(deployerLiq)*10**uint8(dec)));  
        _mint(address(this), (uint256(contractLiq)*10**uint8(dec))); 
    }
    
    function initialize(string memory token_name, string memory token_symbol, uint8 dec, address payable _marketing,address payable _liquidity, uint256 _supply, uint256 _marketingBP, uint256 _liquidityBP) public virtual {
        maxWalletAmount = (uint256(_supply) * uint256(1000)) / uint256(bp); // 10% maxWalletAmount
        _maxTxAmount = (uint256(_supply) * uint256(500)) / uint256(bp); // 5% _maxTxAmount
        takeFee = false;
        isInitialized = false;
        isTradeEnabled = false;
        blockListEnabled = false;
        maxTXLimitEnabled = false;
        maxWalletLimitEnabled = false;
        _name = token_name;
        _symbol = token_symbol;
        _decimals = uint8(dec);
        marketingFeeInBasis = uint256(_marketingBP);
        liquidityFeeInBasis = uint256(_liquidityBP);
        _marketingWallet = payable(_marketing);
        _liquidityWallet = payable(_liquidity);
        isMaxWalletLimitExempt[address(0)] = true;
        isMaxWalletLimitExempt[_msgSender()] = true;
        isMaxWalletLimitExempt[address(this)] = true;
        isMaxWalletLimitExempt[address(_marketingWallet)] = true;
        isMaxWalletLimitExempt[address(_liquidityWallet)] = true;
        isTxLimitExempt[address(0)] = true;
        isTxLimitExempt[_msgSender()] = true;
        isTxLimitExempt[address(this)] = true;
        isTxLimitExempt[address(_marketingWallet)] = true;
        isTxLimitExempt[address(_liquidityWallet)] = true;
        authorize(address(this));
    }
    
    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public override view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public override view returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        address sender = _msgSender();
        _transfer(sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public override view returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override {
        address sender = _msgSender();
        _approve(sender, spender, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(sender, spender, amount);
        _transfer(sender, recipient, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(uint256(amount) > 0, "Transfer amount must be greater than zero");
        uint256 fromBalance = _balances[sender];
        uint256 toBalance = _balances[recipient];
        if(maxWalletLimitEnabled && uint256(amount) >= uint256(maxWalletAmount) && !isMaxWalletLimitExempt[sender]){
            revert();
        } else if(maxWalletLimitEnabled && uint256(toBalance) + uint256(amount) >= uint256(maxWalletAmount) && !isMaxWalletLimitExempt[recipient]){
            revert();
        } else if(blockListEnabled && blocklist[sender] || blockListEnabled && blocklist[recipient]) {
            revert();
        } else if(maxTXLimitEnabled && uint256(amount) >= uint256(_maxTxAmount) && !isTxLimitExempt[sender]) {
            revert();
        } else if(uint256(fromBalance) < uint256(amount)){
            revert();
        } else {
            if(takeFee){
                uint256 mFee = (amount * marketingFeeInBasis) / bp;
                uint256 lFee = (amount * liquidityFeeInBasis) / bp;
                unchecked {
                    _balances[sender] = fromBalance - amount;
                    // Overflow not possible: the sum of all balances is capped by totalSupply, and the sum is preserved by
                    // decrementing then incrementing.
                    amount -= (lFee+mFee);
                    _balances[recipient] += amount;
                    _balances[_marketingWallet] += mFee;
                    _balances[_liquidityWallet] += lFee;
                }
                emit Transfer(sender, recipient, amount);
                emit Transfer(sender, _marketingWallet, mFee);
                emit Transfer(sender, _liquidityWallet, lFee);
            } else {
                unchecked {
                    _balances[sender] = fromBalance - amount;
                    // Overflow not possible: the sum of all balances is capped by totalSupply, and the sum is preserved by
                    // decrementing then incrementing.
                    _balances[recipient] += amount;
                }
                emit Transfer(sender, recipient, amount);
            }
        }
    }

    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply + amount;

        _approve(address(account), address(this), amount);

        _balances[account] = _balances[account] +amount;
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        _balances[account] = _balances[account] - amount;
        _totalSupply = _totalSupply - amount;
        require(decreaseAllowance(address(this), amount));
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    
    /**
     * @dev Updates `owner` s allowance for `spender` based on spent `amount`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

}

contract mKEK is ERC20 {
    
    constructor () ERC20 ("mKEK", "symbol", 18, payable(_msgSender()),payable(0xC925F19cb5f22F936524D2E8b17332a6f4338751),payable(0x74b9006390BfA657caB68a04501919B72E27f49A),1000000,500,500,1000) {

    }
    
    receive() external payable {}

    function launch() public onlyOwner {
        if(isInitialized == true){
            revert();
        } else {
            takeFee = true;
            isInitialized = true;
            isTradeEnabled = true;
            blockListEnabled = true;
            maxTXLimitEnabled = true;
            maxWalletLimitEnabled = true;
        }
    }
    
    function blocklistUpdate(address bot_, bool _enabled) public onlyOwner {
        blocklist[bot_] = _enabled;
    }
 
    function manageBlocklist(address[] memory bots_, bool enabled) public onlyOwner {
        for (uint256 i = 0; i < bots_.length; i++) {
            blocklist[bots_[i]] = enabled;
        }
    }

    function setTakeFee(bool enableFee) public onlyOwner {
        takeFee = enableFee;
    }
    
    function manageMarketingWallet(address payable _mWallet) public onlyOwner {
        _marketingWallet = payable(_mWallet);
    }
    
    function manageLiquidityWallet(address payable _lWallet) public onlyOwner {
        _liquidityWallet = payable(_lWallet);
    }
    
    function manageMarketingPercentage(uint256 _mP) public onlyOwner {
        marketingFeeInBasis = uint256(_mP);
    }
    
    function manageLiquidityPercentage(uint256 _lP) public onlyOwner {
        liquidityFeeInBasis = uint256(_lP);
    }

    function setMaxWalletLimitExempt(address _exemptWallet, bool enable) public onlyOwner {
        isMaxWalletLimitExempt[_exemptWallet] = enable;
    }
    
    function setMaxTXExempt(address _exemptTX, bool enable) public onlyOwner {
        isTxLimitExempt[_exemptTX] = enable;
    }

    function setMaxWallet(uint256 _maxWalletAmount) public onlyOwner returns (bool) {
        maxWalletAmount = _maxWalletAmount;
        return true; 
    }

    function setMaxTransfer(uint256 _maxTransferAmount) public onlyOwner returns (bool) {
        _maxTxAmount = _maxTransferAmount;
        return true; 
    }

    function manageTradingStatus(bool _et) public onlyOwner returns(bool) {
        isTradeEnabled = _et;
        return isTradeEnabled;
    }

    function setMarketingFeeInBasis(uint256 _marketingFee) public onlyOwner returns (bool) {
        // 10% cap on fees in bp
        require(_marketingFee <= 1000);
        marketingFeeInBasis = _marketingFee;
        return true; 
    }
    
    function setLiquidityFeeInBasis(uint256 _liquidityFee) public onlyOwner returns (bool) {
        // 10% cap on fees in bp
        require(_liquidityFee <= 1000);
        liquidityFeeInBasis = _liquidityFee;
        return true; 
    }
    
    function setTotalFee(uint256 _marketingFee,uint256 _liquidityFee) public onlyOwner returns (bool) {
        // 10% cap on fees in bp
        require(_marketingFee <= 1000);
        require(_liquidityFee <= 1000);
        marketingFeeInBasis = _marketingFee;
        liquidityFeeInBasis = _liquidityFee;
        return true; 
    }
    
    function rescueStuckTokens(address _tok, address payable recipient, uint256 amount) public payable onlyOwner {
        uint256 contractTokenBalance = IERC20(_tok).balanceOf(address(this));
        require(amount <= contractTokenBalance, "Request exceeds contract token balance.");
        // rescue stuck tokens 
        IERC20(_tok).transfer(recipient, amount);
    }

    function rescueStuckNative(address payable recipient) public payable onlyOwner {
        // get the amount of Ether stored in this contract
        uint contractETHBalance = address(this).balance;
        // rescue Ether to recipient
        (bool success, ) = recipient.call{value: contractETHBalance}("");
        require(success, "Failed to rescue Ether");
    }
}
