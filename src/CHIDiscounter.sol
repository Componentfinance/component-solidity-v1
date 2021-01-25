pragma solidity ^0.5.0;

import "./interfaces/IFreeFromUpTo.sol";


/**
 * @title CHIDiscounter adds the ability to burn some CHI tokens and get a gas rebate
 */
contract CHIDiscounter {
    IFreeFromUpTo public constant MAINNET_CHI = IFreeFromUpTo(0x0000000000004946c0e9F43F4Dee607b0eF1fA1c);

    IFreeFromUpTo public chi;   // TODO immutable

    modifier discountCHI {
        uint256 gasStart = gasleft();

        _;

        if (address(0) != address(chi)) {
            uint256 gasSpent = 21000 + gasStart - gasleft() + 16 * msg.data.length;
            chi.freeFromUpTo(msg.sender, (gasSpent + 14154) / 41130);
        }
    }

    /**
     * @dev Init discounter
     * @param _chi address of the CHI token, use 0 to disable rebate
     */
    constructor(IFreeFromUpTo _chi) public {
        chi = _chi;
    }
}
