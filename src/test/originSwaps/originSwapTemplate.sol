
pragma solidity ^0.5.0;

import "abdk-libraries-solidity/ABDKMath64x64.sol";

import "../../interfaces/IAssimilator.sol";

import "../setup/setup.sol";

import "../setup/methods.sol";

contract OriginSwapTemplate is Setup {

    using ABDKMath64x64 for uint;
    using ABDKMath64x64 for int128;

    using ShellMethods for Shell;

    Shell s;
    Shell s2;

    event log_int(bytes32, int);
    event log_uint(bytes32, uint);

    function noSlippage_balanced_10DAI_to_USDC_300Proportional () public returns (uint256 targetAmount_) {

       s.proportionalDeposit(300e18, 1e50);

        targetAmount_ = s.originSwap(
            address(dai),
            address(usdc),
            10e18
        );

    }

    function noSlippage_lightlyUnbalanced_10USDC_to_USDT_with_80DAI_100USDC_85USDT_35SUSD () public returns (uint256 targetAmount_) {

       s.deposit(
            address(dai), 80e18,
            address(usdc), 100e6,
            address(usdt), 85e6,
            address(susd), 35e6
        );

        uint256 gas = gasleft();

        targetAmount_ = s.originSwap(
            address(usdc),
            address(usdt),
            10e6
        );

        emit log_uint("gas", gas - gasleft());

    }

    function noSlippage_balanced_10PctWeight_to_30PctWeight () public returns (uint256 targetAmount_) {

       s.proportionalDeposit(300e18, 1e50);

        targetAmount_ = s.originSwap(
            address(susd),
            address(usdt),
            4e6
        );

    }

    function partialUpperAndLowerSlippage_unbalanced_10PctWeight_to_30PctWeight () public returns (uint256 targetAmount_) {

       s.deposit(
            address(dai), 65e18,
            address(usdc), 90e6,
            address(usdt), 90e6,
            address(susd), 30e6
        );

        uint256 gas = gasleft();

        targetAmount_ = s.originSwap(
            address(susd),
            address(dai),
            8e6
        );

        emit log_uint("gas used for swap", gas - gasleft());

    }

    function noSlippage_balanced_30PctWeight_to_30PctWeight () public returns (uint256 targetAmount_) {

       s.proportionalDeposit(300e18, 1e50);

        targetAmount_ = s.originSwap(
            address(dai),
            address(usdc),
            10e18
        );

    }

    function noSlippage_lightlyUnbalanced_30PctWeight_to_10PctWeight () public returns (uint256 targetAmount_) {

       s.deposit(
            address(dai), 80e18,
            address(usdc), 80e6,
            address(usdt), 85e6,
            address(susd), 35e6
        );

        targetAmount_ = s.originSwap(
            address(usdc),
            address(susd),
            3e6
        );

    }

    function partialUpperAndLowerSlippage_balanced_40USDC_to_DAI () public returns (uint256 targetAmount_) {

       s.proportionalDeposit(300e18, 1e50);

        targetAmount_ = s.originSwap(
            address(usdc),
            address(dai),
            40e6
        );

    }

    function partialUpperAndLowerSlippage_balanced_30PctWeight_to_10PctWeight () public returns (uint256 targetAmount_) {

       s.proportionalDeposit(300e18, 1e50);

        targetAmount_ = s.originSwap(
            address(dai),
            address(susd),
            15e18
        );

    }
    
    function fullUpperAndLowerSlippage_unbalanced_30PctWeight () public returns (uint256 targetAmount_) {

       s.deposit(
            address(dai), 135e18,
            address(usdc), 90e6,
            address(usdt), 60e6,
            address(susd), 30e6
        );

        targetAmount_ = s.originSwap(
            address(dai),
            address(usdt),
            5e18
        );

    }

    function fullUpperAndLowerSlippage_unbalanced_30PctWeight_CDAI_to_AUSDT () public returns (uint256 targetAmount_) {

       s.deposit(
            address(dai), 135e18,
            address(usdc), 90e6,
            address(usdt), 60e6,
            address(susd), 30e6
        );

        uint cdaiOf5Numeraire = IAssimilator(cdaiAssimilator).viewRawAmount(uint(5e18).divu(1e18));

        targetAmount_ = s.originSwap(
            address(cdai),
            address(ausdt),
            cdaiOf5Numeraire
        );

    }

    function fullUpperAndLowerSlippage_unbalanced_30PctWeight_to_10PctWeight () public returns (uint256 targetAmount_) {

       s.deposit(
            address(dai), 135e18,
            address(usdc), 90e6,
            address(usdt), 65e6,
            address(susd), 25e6
        );

        targetAmount_ = s.originSwap(
            address(dai),
            address(susd),
            3e18
        );

    }

    function fullUpperAndLowerSlippage_unbalanced_30PctWeight_to_10PctWeight_ADAI_to_ASUSD () public returns (uint256 targetAmount_) {

       s.deposit(
            address(dai), 135e18,
            address(usdc), 90e6,
            address(usdt), 65e6,
            address(susd), 25e6
        );

        targetAmount_ = s.originSwap(
            address(adai),
            address(asusd),
            3e18
        );

    }

    function fullUpperAndLowerSlippage_unbalanced_30PctWeight_to_10PctWeight_CDAI_to_ASUSD () public returns (uint256 targetAmount_) {

       s.deposit(
            address(dai), 135e18,
            address(usdc), 90e6,
            address(usdt), 65e6,
            address(susd), 25e6
        );

        uint cdaiOf3Numeraire = IAssimilator(cdaiAssimilator).viewRawAmount(uint(3e18).divu(1e18));

        targetAmount_ = s.originSwap(
            address(cdai),
            address(asusd),
            cdaiOf3Numeraire
        );

    }

    function fullUpperAndLowerSlippage_unbalanced_10PctWeight_to_30PctWeight () public returns (uint256 targetAmount_) {

       s.deposit(
            address(dai), 90e18,
            address(usdc), 55e6,
            address(usdt), 90e6,
            address(susd), 35e6
        );

        uint gas = gasleft();

        targetAmount_ = s.originSwap(
            address(susd),
            address(usdc),
            2.8e6
        );

        emit log_uint("gas used", gas - gasleft());

    }

    function partialUpperAndLowerAntiSlippage_unbalanced_30PctWeight () public returns (uint256 targetAmount_) {

       s.deposit(
            address(dai), 135e18,
            address(usdc), 60e6,
            address(usdt), 90e6,
            address(susd), 30e6
        );

        targetAmount_ = s.originSwap(
            address(usdc),
            address(dai),
            30e6
        );

    }

    function partialUpperAndLowerAntiSlippage_unbalanced_30PctWeight_to_ADAI () public returns (uint256 targetAmount_) {

       s.deposit(
            address(dai), 135e18,
            address(usdc), 60e6,
            address(usdt), 90e6,
            address(susd), 30e6
        );

        targetAmount_ = s.originSwap(
            address(usdc),
            address(adai),
            30e6
        );

    }

    function partialUpperAndLowerAntiSlippage_unbalanced_10PctWeight_to_30PctWeight () public returns (uint256 targetAmount_) {

       s.deposit(
            address(dai), 135e18,
            address(usdc), 90e6,
            address(usdt), 90e6,
            address(susd), 25e6
        );

        targetAmount_ = s.originSwap(
            address(susd),
            address(dai),
            10e6
        );

    }

    function partialUpperAndLowerAntiSlippage_unbalanced_30PctWeight_to_10PctWeight () public returns (uint256 targetAmount_) {

       s.deposit(
            address(dai), 90e18,
            address(usdc), 90e6,
            address(usdt), 58e6,
            address(susd), 40e6
        );

        targetAmount_ = s.originSwap(
            address(usdt),
            address(susd),
            10e6
        );

    }

    function partialUpperAndLowerAntiSlippage_unbalanced_30PctWeight_to_10PctWeight_CUSDT_to_ASUSD () public returns (uint256 targetAmount_) {

       s.deposit(
            address(dai), 90e18,
            address(usdc), 90e6,
            address(usdt), 58e6,
            address(susd), 40e6
        );
        
        uint cusdtOf10Numeraire = IAssimilator(cusdtAssimilator).viewRawAmount(uint(10e6).divu(1e6));

        targetAmount_ = s.originSwap(
            address(usdt),
            address(susd),
            10e6
        );

    }

    function fullUpperAndLowerAntiSlippage_unbalanced_30PctWeight () public returns (uint256 targetAmount_) {

       s.deposit(
            address(dai), 90e18,
            address(usdc), 135e6,
            address(usdt), 60e6,
            address(susd), 30e6
        );

        targetAmount_ = s.originSwap(
            address(usdt),
            address(usdc),
            5e6
        );

    }

    function fullUpperAndLowerAntiSlippage_unbalanced_30PctWeight_CUSDT_to_AUSDC () public returns (uint256 targetAmount_) {

       s.deposit(
            address(dai), 90e18,
            address(usdc), 135e6,
            address(usdt), 60e6,
            address(susd), 30e6
        );
        
        uint cusdtOf5Numeraire = IAssimilator(cusdtAssimilator).viewRawAmount(uint(5e6).divu(1e6));

        targetAmount_ = s.originSwap(
            address(cusdt),
            address(ausdc),
            cusdtOf5Numeraire   
        );

    }

    function fullUpperAndLowerAntiSlippage_10PctWeight_to30PctWeight_ASUSD_to_AUSDT () public returns (uint256 targetAmount_) {

       s.deposit(
            address(dai), 90e18,
            address(usdc), 90e6,
            address(usdt), 135e6,
            address(susd), 25e6
        );

        targetAmount_ = s.originSwap(
            address(asusd),
            address(ausdt),
            3.6537e6
        );

    }

    function fullUpperAndLowerAntiSlippage_10PctWeight_to30PctWeight () public returns (uint256 targetAmount_) {

       s.deposit(
            address(dai), 90e18,
            address(usdc), 90e6,
            address(usdt), 135e6,
            address(susd), 25e6
        );

        uint256 gas = gasleft();

        targetAmount_ = s.originSwap(
            address(susd),
            address(usdt),
            3.6537e6
        );

        emit log_uint("gas used for swap", gas - gasleft());

    }

    function fullUpperAndLowerAntiSlippage_30pctWeight_to_10Pct () public returns (uint256 targetAmount_) {

       s.deposit(
            address(dai), 58e18,
            address(usdc), 90e6,
            address(usdt), 90e6,
            address(susd), 40e6
        );

        targetAmount_ = s.originSwap(
            address(dai),
            address(asusd),
            2.349e18
        );

    }

    function upperHaltCheck_30PctWeight () public returns (bool success_) {

       s.deposit(
            address(dai), 90e18,
            address(usdc), 135e6,
            address(usdt), 90e6,
            address(susd), 30e6
        );

        ( success_, ) = address(s).call(abi.encodeWithSignature(
            "originSwap(address,address,uint256,uint256,uint256)",
            address(usdc),
            address(usdt),
            30e6,
            0,
            1e50
        ));

    }

    function lowerHaltCheck_30PctWeight () public returns (bool success_) {

       s.deposit(
            address(dai), 60e18,
            address(usdc), 90e6,
            address(usdt), 90e6,
            address(susd), 30e6
        );

        ( success_, ) = address(s).call(abi.encodeWithSignature(
            "originSwap(address,address,uint256,uint256,uint256)",
            address(usdc),
            address(dai),
            30e6,
            0,
            1e50
        ));

    }

    function upperHaltCheck_10PctWeight () public returns (bool success_) {

       s.proportionalDeposit(300e18, 1e50);

        ( success_, ) = address(s).call(abi.encodeWithSignature(
            "originSwap(address,address,uint256,uint256,uint256)",
            address(susd),
            address(usdt),
            20e6,
            0,
            1e50
        ));

    }

    function lowerhaltCheck_10PctWeight () public returns (bool success_) {

       s.proportionalDeposit(300e18, 1e50);

        ( success_, ) = address(s).call(abi.encodeWithSignature(
            "originSwap(address,address,uint256,uint256,uint256)",
            address(dai),
            address(susd),
            20e6,
            0,
            1e50
        ));

    }

    function megaLowerToUpperUpperToLower_30PctWeight () public returns (uint256 targetAmount_) {

       s.deposit(
            address(dai), 55e18,
            address(usdc), 90e6,
            address(usdt), 125e6,
            address(susd), 30e6
        );

        targetAmount_ = s.originSwap(
            address(dai),
            address(usdt),
            70e18
        );

    }


    function megaLowerToUpper_10PctWeight_to_30PctWeight () public returns (uint256 targetAmount_) {

       s.deposit(
            address(dai), 90e18,
            address(usdc), 90e6,
            address(usdt), 100e6,
            address(susd), 20e6
        );

        targetAmount_ = s.originSwap(
            address(susd),
            address(usdt),
            20e6
        );

    }

    function megaUpperToLower_30PctWeight_to_10PctWeight () public returns (uint256 targetAmount_) {

       s.deposit(
            address(dai), 80e18,
            address(usdc), 100e6,
            address(usdt), 80e6,
            address(susd), 40e6
        );

        targetAmount_ = s.originSwap(
            address(dai),
            address(susd),
            20e18
        );

    }

    function greaterThanBalance_30Pct () public {

       s.deposit(
            address(dai), 46e18,
            address(usdc), 134e6,
            address(usdt), 75e6,
            address(susd), 45e6
        );

       s.originSwap(
            address(usdt),
            address(dai),
            50e6
        );

    }

    function greaterThanBalance_10Pct () public {

       s.proportionalDeposit(300e18, 1e50);

       s.originSwap(
            address(usdc),
            address(susd),
            31e6
        );

    }

    function smartHalt_upper () public returns (bool success_) {

       s.proportionalDeposit(300e18, 1e50);

        usdc.transfer(address(s), 110e6);

        success_ = s.originSwapSuccess(
            address(usdc),
            address(dai),
            1e6
        );

    }

    function smartHalt_upper_unrelated () public returns (bool success_) {

       s.proportionalDeposit(300e18, 1e50);

        usdc.transfer(address(s), 110e6);

        success_ = s.originSwapSuccess(
            address(usdt),
            address(susd),
            1e6
        );

    }

    function smartHalt_lower_outOfBounds_to_outOfBounds () public returns (bool success_) {

       s.proportionalDeposit(67e18, 1e50);

        dai.transfer(address(s), 70e18);

        usdt.transfer(address(s), 70e6);

        susd.transfer(address(s), 23e6);

        success_ = s.originSwapSuccess(
            address(usdc),
            address(dai),
            1e6
        );

    }

    function smartHalt_lower_outOfBounds_to_inBounds () public returns (bool success_) {

       s.proportionalDeposit(67e18, 1e50);

        dai.transfer(address(s), 70e18);

        usdt.transfer(address(s), 70e6);

        susd.transfer(address(s), 23e6);

        success_ = s.originSwapSuccess(
            address(usdc),
            address(dai),
            40e6
        );

    }

    function smartHalt_lower_unrelated () public returns (bool success_) {

       s.proportionalDeposit(67e18, 1e50);

        dai.transfer(address(s), 70e18);

        usdt.transfer(address(s), 70e6);

        susd.transfer(address(s), 23e6);

        success_ = s.originSwapSuccess(
            address(usdt),
            address(susd),
            1e6
        );

    }


    function monotonicity_mutuallyInBounds_to_mutuallyOutOfBounds_noHalts () public returns (uint256 targetAmount_) {

       s.deposit(
            address(dai), 2000e18 / 100,
            address(usdc), 5000e6 / 100,
            address(usdt), 5000e6 / 100,
            address(susd), 800e6 / 100
        );

        //l.TEST_setTestHalts(false);

        targetAmount_ = s.originSwap(
            address(usdc),
            address(usdt),
            4900e6 / 100
        );

    }

    function monotonicity_mutuallyInBounds_to_mutuallyOutOfBounds_halts () public returns (uint256 targetAmount_) {

       s.deposit(
            address(dai), 2000e18,
            address(usdc), 5000e6,
            address(usdt), 5000e6,
            address(susd), 800e6
        );

        targetAmount_ = s.originSwap(
            address(usdc),
            address(usdt),
            4900e6
        );

    }

    function monotonicity_outOfBand_mutuallyOutOfBounds_to_mutuallyOutOfBounds_noHalts_omegaUpdate () public returns (uint256 targetAmount_) {

       s.proportionalDeposit(300e18, 1e50);

        usdt.transfer(address(s), 4910e6);

        

        //l.TEST_setTestHalts(false);

        targetAmount_ = s.originSwap(
            address(usdt),
            address(dai),
            1e6
        );

    }

    function monotonicity_outOfBand_mutuallyOutOfBounds_to_mutuallyOutOfBounds_noHalts_noOmegaUpdate () public returns (uint256 targetAmount_) {

       s.proportionalDeposit(300e18, 1e50);

        usdt.transfer(address(s), 4910e6);

        //l.TEST_setTestHalts(false);

        targetAmount_ = s.originSwap(
            address(usdt),
            address(dai),
            1e6
        );

    }

    function monotonicity_outOfBand_mutuallyOutOfBounds_to_mutuallyInBounds_noHalts_updateOmega () public returns (uint256 targetAmount_) {

       s.proportionalDeposit(300e18, 1e50);

        usdc.transfer(address(s), 4910e6);
        usdt.transfer(address(s), 9910e6);
        susd.transfer(address(s), 1970e6);

        susd.transfer(address(s), 1970e18);
        asusd.transfer(address(s), 1970e18);

        //l.TEST_setTestHalts(false);

        

        targetAmount_ = s.originSwap(
            address(dai),
            address(usdt),
            5000e18
        );

    }

    function monotonicity_outOfBand_mutuallyOutOfBounds_to_mutuallyInBounds_noHalts_noUpdateOmega () public returns (uint256 targetAmount_) {

       s.proportionalDeposit(300e18, 1e50);

        usdc.transfer(address(s), 4910e6);
        usdt.transfer(address(s), 9910e6);
        susd.transfer(address(s), 1970e6);

        //l.TEST_setTestHalts(false);

        targetAmount_ = s.originSwap(
            address(dai),
            address(usdt),
            5000e18
        );

    }

    function monotonicity_outOfBand_mutuallyOutOfBound_towards_mutuallyInBound_noHalts_omegaUpdate () public returns (uint256 targetAmount_) {

       s.proportionalDeposit(300e18, 1e50);

        susd.transfer(address(s), 4970e6);

        

        //l.TEST_setTestHalts(false);

        targetAmount_ = s.originSwap(
            address(usdt),
            address(susd),
            1e6
        );

    }

    function monotonicity_outOfBand_mutuallyOutOfBound_zero_noHalts_omegaUpdate () public returns (uint256 targetAmount_) {

       s.proportionalDeposit(300e18, 1e50);

        susd.transfer(address(s), 4970e6);

        

        //l.TEST_setTestHalts(false);

        targetAmount_ = s.originSwap(
            address(usdt),
            address(susd),
            0
        );

    }

}