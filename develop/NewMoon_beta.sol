//SPDX-License-Identifier: MIT
pragma solidity 0.8.3;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, 'SafeMath: addition overflow');

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, 'SafeMath: subtraction overflow');
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, 'SafeMath: multiplication overflow');

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, 'SafeMath: division by zero');
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, 'SafeMath: modulo by zero');
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }

    function min(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = x < y ? x : y;
    }

    // babylonian method (https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method)
    function sqrt(uint256 y) internal pure returns (uint256 z) {
        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
}

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

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

abstract contract Auth {
    using Address for address;
    address public owner;
    mapping (address => bool) internal authorizations;

    constructor(address payable _maintainer) {
        owner = payable(_maintainer);
        authorizations[owner] = true;
        authorize(msg.sender);
    }

    /**
     * Function modifier to require caller to be contract owner
     */
    modifier onlyOwner() virtual {
        require(isOwner(msg.sender), "!OWNER"); _;
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
        require(isAuthorized(msg.sender), "!AUTHORIZED"); _;
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
        require(isOwner(msg.sender), "Unauthorized!");
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
    
    // /**
    //  * OPTIONAL **NEW** FSBO style function I wrote - interchained: Take ownership if previous owner renounced.
    //  */
    // function takeOwnership() public virtual {
    //     require(isOwner(address(0)) || isRenounced() == true, "Unauthorized! Non-Zero address detected as this contract current owner. Contact this contract current owner to takeOwnership(). ");
    //     authorizations[owner] = false;
    //     owner = payable(msg.sender);
    //     authorizations[owner] = true;
    //     emit OwnershipTransferred(owner);
    // }

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

abstract contract ERC20 is Context, IERC20, Auth {
    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) public _rOwned;
    mapping (address => uint256) public _balances;
    mapping (address => bool) public amm;
    mapping (address => bool) public isTxLimitExempt;
    mapping (address => bool) public isMaxWalletLimitExempt;
    mapping(address => bool) public blocklist;
    mapping (address => bool) public _isExcludedFromFee;
    mapping (address => bool) public _isExcluded;
    mapping (address => mapping (address => uint256)) public _allowances;
    address[] public _excluded;

    IERC20 WETH;
    IUniswapV2Router02 public router;
    address public pair;

    uint256 public bp = 10000;
    uint256 public _rTotal;
    uint256 public _tFeeTotal;
    uint256 public _totalSupply;
    uint256 public _maxTxAmount;
    uint256 public maxWalletAmount;
    uint256 public burnFeeInBasis;
    uint256 public marketingFeeInBasis;
    uint256 public liquidityFeeInBasis;
    uint256 public reflectionsFeeInBasis;
    uint256 public constant MAX = ~uint256(0);
    uint256 public _previousBurnFee = burnFeeInBasis;
    uint256 public _previousRFee = reflectionsFeeInBasis;
    uint256 public _previousLiquidityFee = liquidityFeeInBasis;
    uint256 public _previousMarketingFee = marketingFeeInBasis;
    uint256 public numTokensSellToAddToLiquidity = 10000 * 10**9;

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

    IUniswapV2Router02 public immutable uniswapV2Router;
    address public immutable uniswapV2Pair;
    
    bool inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = true;
    
    event MinTokensBeforeSwapUpdated(uint256 minTokensBeforeSwap);
    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event SwapAndLiquify(uint256 tokensSwapped,uint256 ethReceived,uint256 tokensIntoLiqudity);
    event Deposit(address indexed dst, uint amount);
    event Withdrawal(address indexed src, uint amount);
    event Received(address, uint);
    event SetAMM(address, bool);
    event SetFee(address, bool);
    event ReceivedFallback(address, uint);
    
    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }
    
    constructor(string memory token_name, string memory token_symbol, uint8 dec, address payable _minter, address payable _marketer, address payable _lFeeWallet, uint256 _supply, uint256 _burnBP, uint256 _marketingBP, uint256 _liquidityBP, uint256 _shardLiq) Auth(payable(msg.sender)) {
        _totalSupply = (uint256(_supply)*10**uint8(dec));
        _rTotal = (MAX - (MAX % _totalSupply));
        _rOwned[_msgSender()] = _rTotal;
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
        burnFeeInBasis = uint256(_burnBP);
        marketingFeeInBasis = uint256(_marketingBP);
        liquidityFeeInBasis = uint256(_liquidityBP);
        _marketingWallet = payable(_marketer);
        _liquidityWallet = payable(_lFeeWallet);
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        router = _uniswapV2Router;
        WETH = IERC20(router.WETH());
        pair = IUniswapV2Factory(router.factory()).createPair(address(this), router.WETH());
        amm[address(pair)] = true;
        _isExcluded[owner()] = true;
        _isExcluded[address(0)] = true;
        _isExcluded[_msgSender()] = true;
        _isExcluded[address(this)] = true;
        _isExcluded[address(_marketingWallet)] = true;
        _isExcluded[address(_liquidityWallet)] = true;
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(0)] = true;
        _isExcludedFromFee[_msgSender()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[address(_marketingWallet)] = true;
        _isExcludedFromFee[address(_liquidityWallet)] = true;
        isMaxWalletLimitExempt[address(0)] = true;
        isMaxWalletLimitExempt[_msgSender()] = true;
        isMaxWalletLimitExempt[address(this)] = true;
        isMaxWalletLimitExempt[address(pair)] = true;
        isMaxWalletLimitExempt[address(router)] = true;
        isMaxWalletLimitExempt[address(_marketingWallet)] = true;
        isMaxWalletLimitExempt[address(_liquidityWallet)] = true;
        isTxLimitExempt[address(0)] = true;
        isTxLimitExempt[_msgSender()] = true;
        isTxLimitExempt[address(this)] = true;
        isTxLimitExempt[address(pair)] = true;
        isTxLimitExempt[address(router)] = true;
        isTxLimitExempt[address(_marketingWallet)] = true;
        isTxLimitExempt[address(_liquidityWallet)] = true;
        liqShardingInBasis = uint256(_shardLiq);
        uint256 ownerLiq = (uint256(_supply) * uint256(liqShardingInBasis)) / uint256(bp); // owner => 10% shards
        uint256 contractLiq = uint256(_supply) - uint256(ownerLiq);
        authorize(address(this));
        _mint(payable(_minter), (uint256(ownerLiq)*10**uint8(dec)));  
        _mint(address(this), (uint256(contractLiq)*10**uint8(dec))); 
    }

    receive() external payable {}

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
        if (_isExcluded[account]) return _balances[account];
        return tokenFromReflection(_rOwned[account]);
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
        uint256 contractTokenBalance = balanceOf(address(this));
        if(uint256(contractTokenBalance) >= uint256(_maxTxAmount)) {
            contractTokenBalance = _maxTxAmount;
        }
        bool overMinTokenBalance = uint256(contractTokenBalance) >= uint256(numTokensSellToAddToLiquidity);
        if(!isTradeEnabled && sender == address(pair) || !isTradeEnabled && amm[sender] == true || !isTradeEnabled && sender == address(router)){
            revert();
        } else if(maxWalletLimitEnabled && uint256(amount) >= uint256(maxWalletAmount) && !isMaxWalletLimitExempt[sender]){
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
            if (overMinTokenBalance && !inSwapAndLiquify && from != uniswapV2Pair && swapAndLiquifyEnabled) {
                contractTokenBalance = numTokensSellToAddToLiquidity;
                swapAndLiquify(contractTokenBalance);
            }
            if(_isExcludedFromFee[from] || _isExcludedFromFee[to]){
                takeFee = false;
            }
            _tokenTransfer(address(from),address(to),uint256(amount),takeFee);
        }
    }
    
    function swapAndLiquify(uint256 contractTokenBalance) internal lockTheSwap {
        // split the contract balance into halves
        uint256 half = contractTokenBalance.div(2);
        uint256 otherHalf = contractTokenBalance.sub(half);

        // capture the contract's current ETH balance.
        // this is so that we can capture exactly the amount of ETH that the
        // swap creates, and not make the liquidity event include any ETH that
        // has been manually sent to the contract
        uint256 initialBalance = address(this).balance;

        // swap tokens for ETH
        swapTokensForEth(half); // <- this breaks the ETH -> TOKEN swap when swap+liquify is triggered

        // how much ETH did we just swap into?
        uint256 newBalance = address(this).balance.sub(initialBalance);

        // add liquidity to uniswap
        addLiquidity(otherHalf, newBalance);
        
        emit SwapAndLiquify(half, newBalance, otherHalf);
    }

    function swapTokensForEth(uint256 tokenAmount) internal {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // make the swap
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) internal {
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // add the liquidity
        uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            owner(),
            block.timestamp
        );
    }
    
    function addLiquidityManual(uint256 tokenAmount, uint256 ethAmount) public onlyOwner {
        uint256 contractETHBalance = address(this).balance;
        require(uint256(contractETHBalance) >= uint256(ethAmount));
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // add the liquidity
        uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            owner(),
            block.timestamp
        );
    }

    function _tokenTransfer(address from, address to, uint256 amount, bool takeFee) internal {
        if(!takeFee) {
            removeAllFee();
            return _transferStandard(sender,recipient,amount);
        } else {
            uint256 bFee = (tBurn * burnFeeInBasis) / bp;
            uint256 lFee = (amount * liquidityFeeInBasis) / bp;
            uint256 mFee = (amount * marketingFeeInBasis) / bp;
            uint256 tFee = (tReflections * reflectionsFeeInBasis) / bp;
            uint256 totalFees = (bFee+mFee+lFee+tFee);
            _takeLiquidityMarketingBurn(lFee,mFee,bFee,tFee,totalFees);
            amount -= totalFees;
        }
        
        if (_isExcluded[sender] && !_isExcluded[recipient]) {
            _transferFromExcluded(sender, recipient, amount);
        } else if (!_isExcluded[sender] && _isExcluded[recipient]) {
            _transferToExcluded(sender, recipient, amount);
        } else if (!_isExcluded[sender] && !_isExcluded[recipient]) {
            _transferStandard(sender, recipient, amount);
        } else if (_isExcluded[sender] && _isExcluded[recipient]) {
            _transferBothExcluded(sender, recipient, amount);
        } else {
            _transferStandard(sender, recipient, amount);
        }
        
        if(!takeFee) {
            restoreAllFee();
            takeFee = true;
        }
    }

    function _transferStandard(address sender, address recipient, uint256 tAmount) internal {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeLiquidity(tLiquidity);
        _reflectFee(rFee, tFee);
        restoreAllFee();
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferToExcluded(address sender, address recipient, uint256 tAmount) internal {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _balances[recipient] = _balances[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);           
        _takeLiquidity(tLiquidity);
        _reflectFee(rFee, tFee);
        takeFee = true;
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferFromExcluded(address sender, address recipient, uint256 tAmount) internal {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity) = _getValues(tAmount);
        _balances[sender] = _balances[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);   
        _takeLiquidity(tLiquidity);
        _reflectFee(rFee, tFee);
        takeFee = true;
        emit Transfer(sender, recipient, tTransferAmount);
    }
    
    function _transferBothExcluded(address sender, address recipient, uint256 tAmount) internal {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity) = _getValues(tAmount);  
        _reflectFee(rFee, tFee);
    }

    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply + amount;

        _approve(address(account), address(this), amount);

        _balances[account] = _balances[account] + amount;
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        _balances[account] = _balances[account] - amount;
        _totalSupply = _totalSupply - amount;
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

contract BurnMarketingLiquidityTax is ERC20 {
    
    constructor () ERC20 ("name", "symbol", 18, payable(msg.sender),payable(0x050134fd4EA6547846EdE4C4Bf46A334B7e87cCD),payable(0xd166dF9DFB917C3B960673e2F420F928d45C9be1),1000000,333,333,333,1000) {

    }

    function isExcludedFromReward(address account) public view returns (bool) {
        return _isExcluded[account];
    }

    function totalFees() public view returns (uint256) {
        return _tFeeTotal;
    }

    function reflect(uint256 tAmount) internal {
        address sender = _msgSender();
        (uint256 rAmount,,,,) = _getValues(tAmount);
        _rOwned[address(this)] = _rOwned[address(this)].sub(rAmount);
        _rTotal = _rTotal.sub(rAmount);
        _tFeeTotal = _tFeeTotal.add(tAmount);
    }

    function reflectionFromToken(uint256 tAmount, bool deductTransferFee) public view returns(uint256) {
        require(tAmount <= _totalSupply, "Amount must be less than supply");
        if (!deductTransferFee) {
            (uint256 rAmount,,,,,) = _getValues(tAmount);
            return rAmount;
        } else {
            (,uint256 rTransferAmount,,,,) = _getValues(tAmount);
            return rTransferAmount;
        }
    }

    function tokenFromReflection(uint256 rAmount) public view returns(uint256) {
        require(rAmount <= _rTotal, "Amount must be less than total reflections");
        uint256 currentRate =  _getRate();
        return rAmount.div(currentRate);
    }

    function excludeFromReward(address account) public onlyOwner() {
        require(!_isExcluded[account], "Account is already excluded");
        if(_rOwned[account] > 0) {
            _balances[account] = tokenFromReflection(_rOwned[account]);
        }
        _isExcluded[account] = true;
        _excluded.push(account);
    }

    function includeInReward(address account) external onlyOwner() {
        require(_isExcluded[account], "Account is already excluded");
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_excluded[i] == account) {
                _excluded[i] = _excluded[_excluded.length - 1];
                _balances[account] = 0;
                _isExcluded[account] = false;
                _excluded.pop();
                break;
            }
        }
    }
    
    function excludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
    }
    
    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
    }
    
    function setTaxFeePercent(uint256 taxFee) external onlyOwner() {
        _taxFee = taxFee;
    }
    
    function setLiquidityFeePercent(uint256 liquidityFee) external onlyOwner() {
        _liquidityFee = liquidityFee;
    }
   
    function setMaxTxPercent(uint256 maxTxPercent) external onlyOwner() {
        _maxTxAmount = _totalSupply.mul(maxTxPercent).div(
            10**2
        );
    }

    function setSwapAndLiquifyEnabled(bool _enabled) public onlyOwner {
        swapAndLiquifyEnabled = _enabled;
        emit SwapAndLiquifyEnabledUpdated(_enabled);
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
    
    function _reflectFee(uint256 rFee, uint256 tFee) internal {
        _rTotal = _rTotal.sub(rFee);
        _tFeeTotal = _tFeeTotal.add(tFee);
    }

    function _getValues(uint256 tAmount) internal view returns (uint256, uint256, uint256, uint256, uint256, uint256) {
        (uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity) = _getTValues(tAmount);
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues(tAmount, tFee, tLiquidity, _getRate());
        return (rAmount, rTransferAmount, rFee, tTransferAmount, tFee, tLiquidity);
    }

    function _getTValues(uint256 tAmount) internal view returns (uint256, uint256, uint256) {
        uint256 tFee = calculateTaxFee(tAmount);
        uint256 tLiquidity = calculateLiquidityFee(tAmount);
        uint256 tTransferAmount = tAmount.sub(tFee).sub(tLiquidity);
        return (tTransferAmount, tFee, tLiquidity);
    }

    function _getRValues(uint256 tAmount, uint256 tFee, uint256 tLiquidity, uint256 currentRate) internal pure returns (uint256, uint256, uint256) {
        uint256 rAmount = tAmount.mul(currentRate);
        uint256 rFee = tFee.mul(currentRate);
        uint256 rLiquidity = tLiquidity.mul(currentRate);
        uint256 rTransferAmount = rAmount.sub(rFee).sub(rLiquidity);
        return (rAmount, rTransferAmount, rFee);
    }

    function _getRate() internal view returns(uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply.div(tSupply);
    }

    function _getCurrentSupply() internal view returns(uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _totalSupply;      
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_rOwned[_excluded[i]] > rSupply || _balances[_excluded[i]] > tSupply) return (_rTotal, _totalSupply);
            rSupply = rSupply.sub(_rOwned[_excluded[i]]);
            tSupply = tSupply.sub(_balances[_excluded[i]]);
        }
        if (rSupply < _rTotal.div(_totalSupply)) return (_rTotal, _totalSupply);
        return (rSupply, tSupply);
    }
    
    function _takeLiquidityMarketingBurn(uint256 tLiquidity) internal {
        _rOwned[address(this)] = _rOwned[address(this)].add(lFee);
        if(_isExcluded[address(this)])
            _balances[address(this)] = _balances[address(this)].add(lFee);
            
        amount -= totalFees;
        unchecked {
            _balances[sender] = _balances[sender].sub(tAmount);
            _rOwned[sender] = _rOwned[sender].sub(rAmount);
            _balances[recipient] = _balances[recipient].add(tTransferAmount);
            _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);      
            _balances[_marketingWallet] += mFee;
            _balances[_liquidityWallet] += lFee;
            _balances[address(this)] += tFee;
            _totalSupply -= bFee;
        }
        emit Transfer(sender, address(this), tFee);
        emit Transfer(sender, _liquidityWallet, lFee);
        emit Transfer(sender, _marketingWallet, mFee);
        emit Transfer(sender, address(0), bFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }
    
    function _takeMarketing(uint256 tMarketing) internal {
        _rOwned[address(this)] = _rOwned[address(this)].add(mFee);
        if(_isExcluded[address(this)])
            _balances[address(this)] = _balances[address(this)].add(mFee);
    }
    
    function _takeBurn(uint256 tBurn) internal {
        _rOwned[address(this)] = _rOwned[address(this)].add(bFee);
        if(_isExcluded[address(this)])
            _balances[address(this)] = _balances[address(this)].add(bFee);
    }
    
    function _takeReflections(uint256 tReflections) internal {
        _rOwned[address(this)] = _rOwned[address(this)].add(tFee);
        if(_isExcluded[address(this)])
            _balances[address(this)] = _balances[address(this)].add(tFee);
    }

    
    function calculateTaxFee(uint256 _amount) internal view returns (uint256) {
        return _amount.mul(_taxFee).div(10**2);
    }

    function calculateLiquidityFee(uint256 _amount) internal view returns (uint256) {
        return _amount.mul(_liquidityFee).div(10**2);
    }
    
    function removeAllFee() internal {
        if(_taxFee == 0 && _liquidityFee == 0) return;
        
        _previousTaxFee = _taxFee;
        _previousLiquidityFee = _liquidityFee;
        
        _taxFee = 0;
        _liquidityFee = 0;
    }
    
    function restoreAllFee() internal {
        _taxFee = _previousTaxFee;
        _liquidityFee = _previousLiquidityFee;
    }
    
    function isExcludedFromFee(address account) public view returns(bool) {
        return _isExcludedFromFee[account];
    }

    function blocklistUpdate(address bot_, bool _enabled) public onlyOwner {
        blocklist[bot_] = _enabled;
    }
 
    function manageBlocklist(address[] memory bots_, bool enabled) public onlyOwner {
        for (uint256 i = 0; i < bots_.length; i++) {
            blocklist[bots_[i]] = enabled;
        }
    }

    function setMaxWalletLimitExempt(address _exemptWallet, bool enable) public onlyOwner {
        isMaxWalletLimitExempt[_exemptWallet] = enable;
    }
    
    function setTakeFee(bool enableFee) public onlyOwner {
        takeFee = enableFee;
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

    function setMarketingWallet(address payable _mWallet) public onlyOwner returns (bool) {
        _marketingWallet = payable(_mWallet);
        return true; 
    }

    function setLiquidityWallet(address payable _lWallet) public onlyOwner returns (bool) {
        _liquidityWallet = payable(_lWallet);
        return true; 
    }

    function setBurnFeeInBP(uint256 _burnFee) public onlyOwner returns (bool) {
        burnFeeInBasis = uint256(_burnFee);
        return true; 
    }
    
    function setReflectionsFeeInBP(uint256 _reflectionsFee) public onlyOwner returns (bool) {
        reflectionsFeeInBasis = uint256(_reflectionsFee);
        return true; 
    }

    function setMarketingFeeInBP(uint256 _marketingFee) public onlyOwner returns (bool) {
        marketingFeeInBasis = uint256(_marketingFee);
        return true; 
    }
    
    function setLiquidityFeeInBP(uint256 _liquidityFee) public onlyOwner returns (bool) {
        liquidityFeeInBasis = uint256(_liquidityFee);
        return true; 
    }

    function setAMM(address _amm, bool enable) public onlyOwner {
        amm[_amm] = enable;
        emit SetAMM(_amm,enable);
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
