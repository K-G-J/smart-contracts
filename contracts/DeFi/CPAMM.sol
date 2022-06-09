// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

    /* 
    Constant product AMM 
    XY = K 
    */

 contract CPAMM {
     IERC20 public immutable token0;
     IERC20 public immutable token1;

     uint256 public reserve0;
     uint256 public reserve1;
     uint256 public totalSupply;

     mapping(address => uint256) public balanceOf;

     constructor(address _token0, address _token1) {
         token0 = IERC20(_token0);
         token1 = IERC20(_token1);
     }

     function _mint(address _to, uint256 _amount) private {
         balanceOf[_to] += _amount;
         totalSupply += _amount;
     }

     function _burn(address _from, uint256 _amount) private {
         balanceOf[_from] -= _amount;
         totalSupply -= _amount;
     }

     function _update(uint256 _res0, uint256 _res1) private {
         reserve0 = _res0;
         reserve1 = _res1;
     }

     function swap(address _tokenIn, uint256 _amountIn) external returns (uint amountOut) {
         require(_tokenIn == address(token0) || _tokenIn == address(token1), "invalid token");

         bool isToken0 = _tokenIn == address(token0);

         (IERC20 tokenIn, IERC20 tokenOut, uint256 reserveIn, uint256 reserveOut) = isToken0
         ? (token0, token1, reserve0, reserve1)
         : (token1, token0, reserve1, reserve0);

         tokenIn.transferFrom(msg.sender, address(this), _amountIn);
         uint256 amountIn = tokenIn.balanceOf(address(this)) - reserveIn;

        /*
        xy = k
        (x + dx)(y - dy) = k
        y - dy = k / (x + dx)
        y - k / (x + dx) = dy
        y - xy / (x + dx) = dy
        (yx + ydx - xy) / (x + dx) = dy
        ydx / (x + dx) = dy
        */
        // 0.3% fee
        uint256 amountInWithFee = (amountIn * 997) / 1000;
        amountOut = (reserveOut * amountInWithFee) / (reserveIn + amountInWithFee);

        (uint256 res0, uint256 res1) = isToken0
        ? (reserveIn + amountIn, reserveOut - amountOut)
        : (reserveOut - amountOut, reserveIn + amountIn);

        _update(res0, res1);
        tokenOut.transfer(msg.sender, amountOut);
     }

     function addLiquidity(uint256 _amount0, uint256 _amount1) external returns (uint shares) {
         token0.transferFrom(msg.sender, address(this), _amount0);
         token1.transferFrom(msg.sender, address(this), _amount1);

         uint256 bal0 = token0.balanceOf(address(this));
         uint256 bal1 = token1.balanceOf(address(this));

         uint256 d0 = bal0 - reserve0;
         uint256 d1 = bal1 - reserve1;

        /*
        xy = k
        (x + dx)(y + dy) = k'

        No price change, before and after adding liquidity
        x / y = (x + dx) / (y + dy)

        x(y + dy) = y(x + dx)
        x * dy = y * dx

        x / y = dx / dy
        dy = y / x * dx
        */
        if (reserve0 > 0 || reserve1 > 0) {
            require(reserve0 * d1 == reserve1 * d0, "x / y != dx /dy");
        }

        /*
         (L1 - L0) / L0 = dx / x = dy / y
         */
         if (totalSupply > 0) {
             shares = _min((d0 * totalSupply) / reserve0, (d1 * totalSupply) / reserve1);
         } else {
             shares = _sqrt(d0 * d1);
         }
         require(shares > 0, "shares = 0");
         _mint(msg.sender, shares);
         _update(bal0, bal1);
     }

     function removeLiquidity(uint256 _shares) external returns (uint256 amount0, uint256 amount1) {
         /* Claim
          dy = s / T * y
          */
          amount0 = (_shares * reserve0) / totalSupply;
          amount1 = (_shares * reserve1) / totalSupply;

          _burn(msg.sender, _shares);
          _update(reserve0 - amount0, reserve1 - amount1);

          if (amount0 > 0) {
              token0.transfer(msg.sender, amount0);
          } 
          if (amount1 > 0) {
              token1.transfer(msg.sender, amount1);
          }
     }

     function _sqrt(uint256 y) private pure returns (uint256 z) {
         if (y > 3) {
             z = y;
             uint256 x = y / 2 + 1;
             while (x < z) {
                 z = x;
                 x = (y / x + x) / 2;
             } 
         } else if ( y != 0) {
             z = 1;
        }
     }

     function _min(uint256 x, uint256 y) private pure returns (uint256) {
         return x <= y ? x : y;
     }
 }

 interface IERC20 {
    function totalSupply() external view returns (uint);

    function balanceOf(address account) external view returns (uint);

    function transfer(address recipient, uint amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint amount);
    event Approval(address indexed owner, address indexed spender, uint amount);
}