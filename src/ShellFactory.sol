// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// This program is disstributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

pragma solidity ^0.5.0;

// Finds new Shells! logs their addresses and provides `isShell(address) -> (bool)`

import "./Component.sol";

import "./CHIDiscounter.sol";

contract ShellFactory is CHIDiscounter {

    address private cowri;

    event NewShell(address indexed caller, address indexed shell);

    event CowriSet(address indexed caller, address indexed cowri);

    mapping(address => bool) private _isShell;

    function isShell(address _shell) external view returns (bool) {

        return _isShell[_shell];

    }

    function newShell(
        address[] memory _assets,
        uint[] memory _assetWeights,
        address[] memory _derivativeAssimilators
    ) public discountCHI returns (Component) {
        
        if (msg.sender != cowri) revert("Shell/must-be-cowri");

        Component shell = new Shell(
            _assets,
            _assetWeights,
            _derivativeAssimilators,
            chi
        );

        shell.transferOwnership(msg.sender);

        _isShell[address(shell)] = true;

        emit NewShell(msg.sender, address(shell));

        return shell;

    }


    constructor(IFreeFromUpTo _chi) public CHIDiscounter(_chi) {

        cowri = msg.sender;

        emit CowriSet(msg.sender, msg.sender);

    }

    function getCowri () external view returns (address) {

        return cowri;

    }

    function setCowri (address _c) external {

        require(msg.sender == cowri, "Shell/must-be-cowri");

        emit CowriSet(msg.sender, _c);

        cowri = _c;

    }

}