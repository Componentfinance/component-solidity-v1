pragma solidity ^0.5.0;

import "./Assimilators.sol";

import "./ComponentStorage.sol";

import "./UnsafeMath64x64.sol";

import "./ComponentMath.sol";


library ProportionalLiquidity {

    using ABDKMath64x64 for uint;
    using ABDKMath64x64 for int128;
    using UnsafeMath64x64 for int128;

    event Transfer(address indexed from, address indexed to, uint256 value);

    int128 constant ONE = 0x10000000000000000;
    int128 constant ONE_WEI = 0x12;

    function proportionalDeposit (
        ComponentStorage.Component storage component,
        uint256 _deposit
    ) external returns (
        uint256 components_,
        uint[] memory
    ) {

        int128 __deposit = _deposit.divu(1e18);

        uint _length = component.assets.length;

        uint[] memory deposits_ = new uint[](_length);
        
        ( int128 _oGLiq, int128[] memory _oBals ) = getGrossLiquidityAndBalances(component);

        if (_oGLiq == 0) {

            for (uint i = 0; i < _length; i++) {

                deposits_[i] = Assimilators.intakeNumeraire(component.assets[i].addr, __deposit.mul(component.weights[i]));

            }

        } else {

            int128 _multiplier = __deposit.div(_oGLiq);

            for (uint i = 0; i < _length; i++) {

                deposits_[i] = Assimilators.intakeNumeraire(component.assets[i].addr, _oBals[i].mul(_multiplier));

            }

        }
        
        int128 _totalComponents = component.totalSupply.divu(1e18);
        
        int128 _newComponents = _totalComponents > 0
            ? __deposit.div(_oGLiq).mul(_totalComponents)
            : __deposit;

        requireLiquidityInvariant(
            component,
            _totalComponents,
            _newComponents,
            _oGLiq, 
            _oBals
        );        

        mint(component, msg.sender, components_ = _newComponents.mulu(1e18));

        return (components_, deposits_);

    }
    
    
    function viewProportionalDeposit (
        ComponentStorage.Component storage component,
        uint256 _deposit
    ) external view returns (
        uint components_,
        uint[] memory
    ) {

        int128 __deposit = _deposit.divu(1e18);

        uint _length = component.assets.length;

        ( int128 _oGLiq, int128[] memory _oBals ) = getGrossLiquidityAndBalances(component);

        uint[] memory deposits_ = new uint[](_length);

        if (_oGLiq == 0) {

            for (uint i = 0; i < _length; i++) {

                deposits_[i] = Assimilators.viewRawAmount(
                    component.assets[i].addr,
                    __deposit.mul(component.weights[i])
                );

            }

        } else {

            int128 _multiplier = __deposit.div(_oGLiq);

            for (uint i = 0; i < _length; i++) {

                deposits_[i] = Assimilators.viewRawAmount(
                    component.assets[i].addr,
                    _oBals[i].mul(_multiplier)
                );

            }

        }
        
        int128 _totalComponents = component.totalSupply.divu(1e18);
        
        int128 _newComponents = _totalComponents > 0
            ? __deposit.div(_oGLiq).mul(_totalComponents)
            : __deposit;
        
        components_ = _newComponents.mulu(1e18);

        return (components_, deposits_ );

    }

    function proportionalWithdraw (
        ComponentStorage.Component storage component,
        uint256 _withdrawal
    ) external returns (
        uint[] memory
    ) {

        uint _length = component.assets.length;

        ( int128 _oGLiq, int128[] memory _oBals ) = getGrossLiquidityAndBalances(component);

        uint[] memory withdrawals_ = new uint[](_length);
        
        int128 _totalComponents = component.totalSupply.divu(1e18);
        int128 __withdrawal = _withdrawal.divu(1e18);

        int128 _multiplier = __withdrawal
            .mul(ONE - component.epsilon)
            .div(_totalComponents);

        for (uint i = 0; i < _length; i++) {

            withdrawals_[i] = Assimilators.outputNumeraire(
                component.assets[i].addr,
                msg.sender,
                _oBals[i].mul(_multiplier)
            );

        }

        requireLiquidityInvariant(
            component,
            _totalComponents,
            __withdrawal.neg(), 
            _oGLiq, 
            _oBals
        );
        
        burn(component, msg.sender, _withdrawal);

        return withdrawals_;

    }
    
    function viewProportionalWithdraw (
        ComponentStorage.Component storage component,
        uint256 _withdrawal
    ) external view returns (
        uint[] memory
    ) {

        uint _length = component.assets.length;

        ( int128 _oGLiq, int128[] memory _oBals ) = getGrossLiquidityAndBalances(component);

        uint[] memory withdrawals_ = new uint[](_length);

        int128 _multiplier = _withdrawal.divu(1e18)
            .mul(ONE - component.epsilon)
            .div(component.totalSupply.divu(1e18));

        for (uint i = 0; i < _length; i++) {

            withdrawals_[i] = Assimilators.viewRawAmount(component.assets[i].addr, _oBals[i].mul(_multiplier));

        }

        return withdrawals_;

    }

    function getGrossLiquidityAndBalances (
        ComponentStorage.Component storage component
    ) internal view returns (
        int128 grossLiquidity_,
        int128[] memory
    ) {
        
        uint _length = component.assets.length;

        int128[] memory balances_ = new int128[](_length);
        
        for (uint i = 0; i < _length; i++) {

            int128 _bal = Assimilators.viewNumeraireBalance(component.assets[i].addr);
            
            balances_[i] = _bal;
            grossLiquidity_ += _bal;
            
        }
        
        return (grossLiquidity_, balances_);

    }
    
    function requireLiquidityInvariant (
        ComponentStorage.Component storage component,
        int128 _components,
        int128 _newComponents,
        int128 _oGLiq,
        int128[] memory _oBals
    ) private {
    
        ( int128 _nGLiq, int128[] memory _nBals ) = getGrossLiquidityAndBalances(component);
        
        int128 _beta = component.beta;
        int128 _delta = component.delta;
        int128[] memory _weights = component.weights;
        
        int128 _omega = ComponentMath.calculateFee(_oGLiq, _oBals, _beta, _delta, _weights);

        int128 _psi = ComponentMath.calculateFee(_nGLiq, _nBals, _beta, _delta, _weights);

        ComponentMath.enforceLiquidityInvariant(_components, _newComponents, _oGLiq, _nGLiq, _omega, _psi);
        
    }

    function burn (ComponentStorage.Component storage component, address account, uint256 amount) private {

        component.balances[account] = burn_sub(component.balances[account], amount);

        component.totalSupply = burn_sub(component.totalSupply, amount);

        emit Transfer(msg.sender, address(0), amount);

    }

    function mint (ComponentStorage.Component storage component, address account, uint256 amount) private {

        component.totalSupply = mint_add(component.totalSupply, amount);

        component.balances[account] = mint_add(component.balances[account], amount);

        emit Transfer(address(0), msg.sender, amount);

    }

    function mint_add(uint x, uint y) private pure returns (uint z) {

        require((z = x + y) >= x, "Component/mint-overflow");

    }

    function burn_sub(uint x, uint y) private pure returns (uint z) {

        require((z = x - y) <= x, "Component/burn-underflow");

    }


}