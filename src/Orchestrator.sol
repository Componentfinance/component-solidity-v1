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

import "./Assimilators.sol";

import "./ComponentMath.sol";

import "./ComponentStorage.sol";

import "abdk-libraries-solidity/ABDKMath64x64.sol";

library Orchestrator {

    using ABDKMath64x64 for int128;
    using ABDKMath64x64 for uint256;

    int128 constant ONE_WEI = 0x12;

    event ParametersSet(uint256 alpha, uint256 beta, uint256 delta, uint256 epsilon, uint256 lambda);

    event AssetIncluded(address indexed numeraire, address indexed reserve, uint weight);

    event AssimilatorIncluded(address indexed derivative, address indexed numeraire, address indexed reserve, address assimilator);

    function setParams (
        ComponentStorage.Component storage component,
        uint256 _alpha,
        uint256 _beta,
        uint256 _feeAtHalt,
        uint256 _epsilon,
        uint256 _lambda
    ) external {

        require(0 < _alpha && _alpha < 1e18, "Component/parameter-invalid-alpha");

        require(0 <= _beta && _beta < _alpha, "Component/parameter-invalid-beta");

        require(_feeAtHalt <= .5e18, "Component/parameter-invalid-max");

        require(0 <= _epsilon && _epsilon <= .01e18, "Component/parameter-invalid-epsilon");

        require(0 <= _lambda && _lambda <= 1e18, "Component/parameter-invalid-lambda");

        int128 _omega = getFee(component);

        component.alpha = (_alpha + 1).divu(1e18);

        component.beta = (_beta + 1).divu(1e18);

        component.delta = ( _feeAtHalt ).divu(1e18).div(uint(2).fromUInt().mul(component.alpha.sub(component.beta))) + ONE_WEI;

        component.epsilon = (_epsilon + 1).divu(1e18);

        component.lambda = (_lambda + 1).divu(1e18);

        component.sigma = (_sigma + 1).divu(1e18);

        component.protocol = _protocol;
        
        int128 _psi = getFee(component);
        
        require(_omega >= _psi, "Component/parameters-increase-fee");

        emit ParametersSet(_alpha, _beta, component.delta.mulu(1e18), _epsilon, _lambda);

    }

    function getFee (
        ComponentStorage.Component storage component
    ) private view returns (
        int128 fee_
    ) {

        int128 _gLiq;

        int128[] memory _bals = new int128[](component.assets.length);

        for (uint i = 0; i < _bals.length; i++) {

            int128 _bal = Assimilators.viewNumeraireBalance(component.assets[i].addr);

            _bals[i] = _bal;

            _gLiq += _bal;

        }

        fee_ = ComponentMath.calculateFee(_gLiq, _bals, component.beta, component.delta, component.weights);

    }
    
 
    function initialize (
        ComponentStorage.Component storage component,
        address[] storage numeraires,
        address[] storage reserves,
        address[] storage derivatives,
        address[] calldata _assets,
        uint[] calldata _assetWeights,
        address[] calldata _derivativeAssimilators
    ) external {
        
        for (uint i = 0; i < _assetWeights.length; i++) {

            uint ix = i*5;
        
            numeraires.push(_assets[ix]);
            derivatives.push(_assets[ix]);

            reserves.push(_assets[2+ix]);
            if (_assets[ix] != _assets[2+ix]) derivatives.push(_assets[2+ix]);
            
            includeAsset(
                component,
                _assets[ix],   // numeraire
                _assets[1+ix], // numeraire assimilator
                _assets[2+ix], // reserve
                _assets[3+ix], // reserve assimilator
                _assets[4+ix], // reserve approve to
                _assetWeights[i]
            );
            
        }
        
        for (uint i = 0; i < _derivativeAssimilators.length / 5; i++) {
            
            uint ix = i * 5;

            derivatives.push(_derivativeAssimilators[ix]);

            includeAssimilator(
                component,
                _derivativeAssimilators[ix],   // derivative
                _derivativeAssimilators[1+ix], // numeraire
                _derivativeAssimilators[2+ix], // reserve
                _derivativeAssimilators[3+ix], // assimilator
                _derivativeAssimilators[4+ix]  // derivative approve to
            );

        }

    }

    function includeAsset (
        ComponentStorage.Component storage component,
        address _numeraire,
        address _numeraireAssim,
        address _reserve,
        address _reserveAssim,
        address _reserveApproveTo,
        uint256 _weight
    ) private {

        require(_numeraire != address(0), "Component/numeraire-cannot-be-zeroth-adress");

        require(_numeraireAssim != address(0), "Component/numeraire-assimilator-cannot-be-zeroth-adress");

        require(_reserve != address(0), "Component/reserve-cannot-be-zeroth-adress");

        require(_reserveAssim != address(0), "Component/reserve-assimilator-cannot-be-zeroth-adress");

        require(_weight < 1e18, "Component/weight-must-be-less-than-one");

        if (_numeraire != _reserve) safeApprove(_numeraire, _reserveApproveTo, uint(-1));

        ComponentStorage.Assimilator storage _numeraireAssimilator = component.assimilators[_numeraire];

        _numeraireAssimilator.addr = _numeraireAssim;

        _numeraireAssimilator.ix = uint8(component.assets.length);

        ComponentStorage.Assimilator storage _reserveAssimilator = component.assimilators[_reserve];

        _reserveAssimilator.addr = _reserveAssim;

        _reserveAssimilator.ix = uint8(component.assets.length);

        int128 __weight = _weight.divu(1e18).add(uint256(1).divu(1e18));

        component.weights.push(__weight);

        component.assets.push(_numeraireAssimilator);

        emit AssetIncluded(_numeraire, _reserve, _weight);

        emit AssimilatorIncluded(_numeraire, _numeraire, _reserve, _numeraireAssim);

        if (_numeraireAssim != _reserveAssim) {

            emit AssimilatorIncluded(_reserve, _numeraire, _reserve, _reserveAssim);

        }

    }
    
    function includeAssimilator (
        ComponentStorage.Component storage component,
        address _derivative,
        address _numeraire,
        address _reserve,
        address _assimilator,
        address _derivativeApproveTo
    ) private {

        require(_derivative != address(0), "Component/derivative-cannot-be-zeroth-address");

        require(_numeraire != address(0), "Component/numeraire-cannot-be-zeroth-address");

        require(_reserve != address(0), "Component/numeraire-cannot-be-zeroth-address");

        require(_assimilator != address(0), "Component/assimilator-cannot-be-zeroth-address");
        
        safeApprove(_numeraire, _derivativeApproveTo, uint(-1));

        ComponentStorage.Assimilator storage _numeraireAssim = component.assimilators[_numeraire];

        component.assimilators[_derivative] = ComponentStorage.Assimilator(_assimilator, _numeraireAssim.ix);

        emit AssimilatorIncluded(_derivative, _numeraire, _reserve, _assimilator);

    }

    function safeApprove (
        address _token,
        address _spender,
        uint256 _value
    ) private {

        ( bool success, bytes memory returndata ) = _token.call(abi.encodeWithSignature("approve(address,uint256)", _spender, _value));

        require(success, "SafeERC20: low-level call failed");

    }

    function viewComponent(
        ComponentStorage.Component storage component
    ) external view returns (
        uint alpha_,
        uint beta_,
        uint delta_,
        uint epsilon_,
        uint lambda_
    ) {

        alpha_ = component.alpha.mulu(1e18);

        beta_ = component.beta.mulu(1e18);

        delta_ = component.delta.mulu(1e18);

        epsilon_ = component.epsilon.mulu(1e18);

        lambda_ = component.lambda.mulu(1e18);

    }

}