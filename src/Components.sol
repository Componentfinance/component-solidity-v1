// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

pragma solidity ^0.5.0;

import "./ComponentStorage.sol";

import "./Assimilators.sol";

import "abdk-libraries-solidity/ABDKMath64x64.sol";

library Components {

    using ABDKMath64x64 for int128;

    event Approval(address indexed _owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);

    function add(uint x, uint y, string memory errorMessage) private pure returns (uint z) {
        require((z = x + y) >= x, errorMessage);
    }

    function sub(uint x, uint y, string memory errorMessage) private pure returns (uint z) {
        require((z = x - y) <= x, errorMessage);
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(ComponentStorage.Component storage component, address recipient, uint256 amount) external returns (bool) {
        _transfer(component, msg.sender, recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(ComponentStorage.Component storage component, address spender, uint256 amount) external returns (bool) {
        _approve(component, msg.sender, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20};
     *
     * Requirements:
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for `sender`'s tokens of at least
     * `amount`
     */
    function transferFrom(ComponentStorage.Component storage component, address sender, address recipient, uint256 amount) external returns (bool) {
        _transfer(component, sender, recipient, amount);
        _approve(component, sender, msg.sender, sub(component.allowances[sender][msg.sender], amount, "Component/insufficient-allowance"));
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(ComponentStorage.Component storage component, address spender, uint256 addedValue) external returns (bool) {
        _approve(component, msg.sender, spender, add(component.allowances[msg.sender][spender], addedValue, "Component/approval-overflow"));
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(ComponentStorage.Component storage component, address spender, uint256 subtractedValue) external returns (bool) {
        _approve(component, msg.sender, spender, sub(component.allowances[msg.sender][spender], subtractedValue, "Component/allowance-decrease-underflow"));
        return true;
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is public function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(ComponentStorage.Component storage component, address sender, address recipient, uint256 amount) private {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        component.balances[sender] = sub(component.balances[sender], amount, "Component/insufficient-balance");
        component.balances[recipient] = add(component.balances[recipient], amount, "Component/transfer-overflow");
        emit Transfer(sender, recipient, amount);
    }


    /**
     * @dev Sets `amount` as the allowance of `spender` over the `_owner`s tokens.
     *
     * This is public function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `_owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(ComponentStorage.Component storage component, address _owner, address spender, uint256 amount) private {
        require(_owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        component.allowances[_owner][spender] = amount;
        emit Approval(_owner, spender, amount);
    }

}