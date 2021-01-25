pragma solidity ^0.5.0;

import "./Assimilators.sol";

import "./ComponentStorage.sol";

import "./ComponentMath.sol";

import "./UnsafeMath64x64.sol";

import "abdk-libraries-solidity/ABDKMath64x64.sol";


library SelectiveLiquidity {

    using ABDKMath64x64 for int128;
    using UnsafeMath64x64 for int128;

    event Transfer(address indexed from, address indexed to, uint256 value);

    int128 constant ONE = 0x10000000000000000;

    function selectiveDeposit (
        ComponentStorage.Component storage component,
        address[] calldata _derivatives,
        uint[] calldata _amounts,
        uint _minComponents
    ) external returns (
        uint components_
    ) {

        (   int128 _oGLiq,
            int128 _nGLiq,
            int128[] memory _oBals,
            int128[] memory _nBals ) = getLiquidityDepositData(component, _derivatives, _amounts);

        int128 _components = ComponentMath.calculateLiquidityMembrane(component, _oGLiq, _nGLiq, _oBals, _nBals);

        components_ = _components.mulu(1e18);

        require(_minComponents < components_, "Component/under-minimum-components");

        mint(component, msg.sender, components_);

    }

    function viewSelectiveDeposit (
        ComponentStorage.Component storage component,
        address[] calldata _derivatives,
        uint[] calldata _amounts
    ) external view returns (
        uint components_
    ) {

        (   int128 _oGLiq,
            int128 _nGLiq,
            int128[] memory _oBals,
            int128[] memory _nBals ) = viewLiquidityDepositData(component, _derivatives, _amounts);

        int128 _components = ComponentMath.calculateLiquidityMembrane(component, _oGLiq, _nGLiq, _oBals, _nBals);

        components_ = _components.mulu(1e18);

    }

    function selectiveWithdraw (
        ComponentStorage.Component storage component,
        address[] calldata _derivatives,
        uint[] calldata _amounts,
        uint _maxComponents
    ) external returns (
        uint256 components_
    ) {

        (   int128 _oGLiq,
            int128 _nGLiq,
            int128[] memory _oBals,
            int128[] memory _nBals ) = getLiquidityWithdrawData(component, _derivatives, msg.sender, _amounts);

        int128 _components = ComponentMath.calculateLiquidityMembrane(component, _oGLiq, _nGLiq, _oBals, _nBals);

        _components = _components.neg().us_mul(ONE + component.epsilon);

        components_ = _components.mulu(1e18);

        require(components_ < _maxComponents, "Component/above-maximum-components");

        burn(component, msg.sender, components_);

    }

    function viewSelectiveWithdraw (
        ComponentStorage.Component storage component,
        address[] calldata _derivatives,
        uint[] calldata _amounts
    ) external view returns (
        uint components_
    ) {

        (   int128 _oGLiq,
            int128 _nGLiq,
            int128[] memory _oBals,
            int128[] memory _nBals ) = viewLiquidityWithdrawData(component, _derivatives, _amounts);

        int128 _components = ComponentMath.calculateLiquidityMembrane(component, _oGLiq, _nGLiq, _oBals, _nBals);

        _components = _components.neg().us_mul(ONE + component.epsilon);

        components_ = _components.mulu(1e18);

    }

    function getLiquidityDepositData (
        ComponentStorage.Component storage component,
        address[] memory _derivatives,
        uint[] memory _amounts
    ) private returns (
        int128 oGLiq_,
        int128 nGLiq_,
        int128[] memory,
        int128[] memory
    ) {

        uint _length = component.weights.length;
        int128[] memory oBals_ = new int128[](_length);
        int128[] memory nBals_ = new int128[](_length);

        for (uint i = 0; i < _derivatives.length; i++) {

            ComponentStorage.Assimilator memory _assim = component.assimilators[_derivatives[i]];

            require(_assim.addr != address(0), "Component/unsupported-derivative");

            if ( nBals_[_assim.ix] == 0 && 0 == oBals_[_assim.ix]) {

                ( int128 _amount, int128 _balance ) = Assimilators.intakeRawAndGetBalance(_assim.addr, _amounts[i]);

                nBals_[_assim.ix] = _balance;

                oBals_[_assim.ix] = _balance.sub(_amount);

            } else {

                int128 _amount = Assimilators.intakeRaw(_assim.addr, _amounts[i]);

                nBals_[_assim.ix] = nBals_[_assim.ix].add(_amount);

            }

        }

        return completeLiquidityData(component, oBals_, nBals_);

    }

    function getLiquidityWithdrawData (
        ComponentStorage.Component storage component,
        address[] memory _derivatives,
        address _rcpnt,
        uint[] memory _amounts
    ) private returns (
        int128 oGLiq_,
        int128 nGLiq_,
        int128[] memory,
        int128[] memory
    ) {

        uint _length = component.weights.length;
        int128[] memory oBals_ = new int128[](_length);
        int128[] memory nBals_ = new int128[](_length);

        for (uint i = 0; i < _derivatives.length; i++) {

            ComponentStorage.Assimilator memory _assim = component.assimilators[_derivatives[i]];

            require(_assim.addr != address(0), "Component/unsupported-derivative");

            if ( nBals_[_assim.ix] == 0 && 0 == oBals_[_assim.ix]) {

                ( int128 _amount, int128 _balance ) = Assimilators.outputRawAndGetBalance(_assim.addr, _rcpnt, _amounts[i]);

                nBals_[_assim.ix] = _balance;
                oBals_[_assim.ix] = _balance.sub(_amount);

            } else {

                int128 _amount = Assimilators.outputRaw(_assim.addr, _rcpnt, _amounts[i]);

                nBals_[_assim.ix] = nBals_[_assim.ix].add(_amount);

            }

        }

        return completeLiquidityData(component, oBals_, nBals_);

    }

    function viewLiquidityDepositData (
        ComponentStorage.Component storage component,
        address[] memory _derivatives,
        uint[] memory _amounts
    ) private view returns (
        int128 oGLiq_,
        int128 nGLiq_,
        int128[] memory,
        int128[] memory
    ) {

        uint _length = component.assets.length;
        int128[] memory oBals_ = new int128[](_length);
        int128[] memory nBals_ = new int128[](_length);

        for (uint i = 0; i < _derivatives.length; i++) {

            ComponentStorage.Assimilator memory _assim = component.assimilators[_derivatives[i]];

            require(_assim.addr != address(0), "Component/unsupported-derivative");

            if ( nBals_[_assim.ix] == 0 && 0 == oBals_[_assim.ix]) {

                ( int128 _amount, int128 _balance ) = Assimilators.viewNumeraireAmountAndBalance(_assim.addr, _amounts[i]);

                nBals_[_assim.ix] = _balance.add(_amount);

                oBals_[_assim.ix] = _balance;

            } else {

                int128 _amount = Assimilators.viewNumeraireAmount(_assim.addr, _amounts[i]);

                nBals_[_assim.ix] = nBals_[_assim.ix].add(_amount);

            }

        }

        return completeLiquidityData(component, oBals_, nBals_);

    }

    function viewLiquidityWithdrawData (
        ComponentStorage.Component storage component,
        address[] memory _derivatives,
        uint[] memory _amounts
    ) private view returns (
        int128 oGLiq_,
        int128 nGLiq_,
        int128[] memory,
        int128[] memory
    ) {

        uint _length = component.assets.length;
        int128[] memory oBals_ = new int128[](_length);
        int128[] memory nBals_ = new int128[](_length);

        for (uint i = 0; i < _derivatives.length; i++) {

            ComponentStorage.Assimilator memory _assim = component.assimilators[_derivatives[i]];

            require(_assim.addr != address(0), "Component/unsupported-derivative");

            if ( nBals_[_assim.ix] == 0 && 0 == oBals_[_assim.ix]) {

                ( int128 _amount, int128 _balance ) = Assimilators.viewNumeraireAmountAndBalance(_assim.addr, _amounts[i]);

                nBals_[_assim.ix] = _balance.sub(_amount);

                oBals_[_assim.ix] = _balance;

            } else {

                int128 _amount = Assimilators.viewNumeraireAmount(_assim.addr, _amounts[i]);

                nBals_[_assim.ix] = nBals_[_assim.ix].sub(_amount);

            }

        }

        return completeLiquidityData(component, oBals_, nBals_);

    }

    function completeLiquidityData (
        ComponentStorage.Component storage component,
        int128[] memory oBals_,
        int128[] memory nBals_
    ) private view returns (
        int128 oGLiq_,
        int128 nGLiq_,
        int128[] memory,
        int128[] memory
    ) {

        uint _length = oBals_.length;

        for (uint i = 0; i < _length; i++) {

            if (oBals_[i] == 0 && 0 == nBals_[i]) {

                nBals_[i] = oBals_[i] = Assimilators.viewNumeraireBalance(component.assets[i].addr);
                
            }

            oGLiq_ += oBals_[i];
            nGLiq_ += nBals_[i];

        }

        return ( oGLiq_, nGLiq_, oBals_, nBals_ );

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