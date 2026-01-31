// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract CPAMM {
    IERC20 public immutable token0;
    IERC20 public immutable token1;
    uint public reserve0;
    uint public reserve1;
    uint public totalSupply;
    mapping(address => uint) public balanceOf;

    constructor(address _token0, address _token1) {
        token0 = IERC20(_token0);
        token1 = IERC20(_token1);
    }

    function _mint(address _to, uint _amount) private {
        balanceOf[_to] += _amount;
        totalSupply += _amount;
    }

    function _burn(address _from, uint _amount) private {
        balanceOf[_from] -= _amount;
        totalSupply -= _amount;
    }

    function _update(uint _reserve0, uint _reserve1) private {
        reserve0 = _reserve0;
        reserve1 = _reserve1;
    }

    // Modificación: Agregamos 'minAmountOut' para evitar Front-Running (Slippage)
    function swap(address _tokenIn, uint _amountIn, uint _minAmountOut) external returns (uint amountOut) {
        require(_tokenIn == address(token0) || _tokenIn == address(token1), "Token invalido");
        require(_amountIn > 0, "Cantidad debe ser mayor a 0");

        bool isToken0 = _tokenIn == address(token0);
        (IERC20 tokenIn, IERC20 tokenOut, uint reserveIn, uint reserveOut) = isToken0
            ? (token0, token1, reserve0, reserve1)
            : (token1, token0, reserve1, reserve0);

        tokenIn.transferFrom(msg.sender, address(this), _amountIn);

        // --- MATEMÁTICA CON FEE (0.3%) ---
        // Uniswap V2 aplica el fee restándolo de la entrada antes de calcular la salida.
        // amountInWithFee = amountIn * 997
        // Numerador = reserveOut * amountInWithFee
        // Denominador = (reserveIn * 1000) + amountInWithFee
        
        uint amountInWithFee = _amountIn * 997;
        uint numerator = amountInWithFee * reserveOut;
        uint denominator = (reserveIn * 1000) + amountInWithFee;
        
        amountOut = numerator / denominator;

        // --- SEGURIDAD CONTRA SLIPPAGE ---
        // Si el mercado se movió y recibimos menos de lo esperado, revertimos.
        require(amountOut >= _minAmountOut, "Slippage: Insufficient Output");

        tokenOut.transfer(msg.sender, amountOut);
        
        _update(token0.balanceOf(address(this)), token1.balanceOf(address(this)));
    }

    function addLiquidity(uint _amount0, uint _amount1) external returns (uint shares) {
        token0.transferFrom(msg.sender, address(this), _amount0);
        token1.transferFrom(msg.sender, address(this), _amount1);

        if (totalSupply == 0) {
            shares = _amount0 + _amount1;
        } else {
            uint share0 = (_amount0 * totalSupply) / reserve0;
            uint share1 = (_amount1 * totalSupply) / reserve1;
            shares = share0 < share1 ? share0 : share1;
        }
        require(shares > 0, "shares = 0");
        _mint(msg.sender, shares);
        _update(token0.balanceOf(address(this)), token1.balanceOf(address(this)));
    }

    function removeLiquidity(uint _shares) external returns (uint amount0, uint amount1) {
        amount0 = (_shares * reserve0) / totalSupply;
        amount1 = (_shares * reserve1) / totalSupply;
        _burn(msg.sender, _shares);
        _update(reserve0 - amount0, reserve1 - amount1);
        token0.transfer(msg.sender, amount0);
        token1.transfer(msg.sender, amount1);
    }
}