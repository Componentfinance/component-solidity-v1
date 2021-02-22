# Component Protocol version 1

Component Protocol is an automated market maker for assets of the same numeraire. It is ideal for stablecoin to stablecoin trades, and other assets like BTC on ETH and staking derivatives.

## Contracts

Component Protocol is currently deployed to mainnet at the following addresses

* [Component 50% USDP,25% USDC,25% USDT Pool](https://etherscan.io/address/0x49519631B404E06ca79C9C7b0dC91648D86F08db)
* [Component 50% USDP,25% DAI,25% sUSD Pool](https://etherscan.io/address/0x6477960dd932d29518d7e8087d5ea3d11e606068)
* [Component 50% USDP,25% WXDAI,25% USDC Pool](https://blockscout.com/poa/xdai/address/0x53De001bbfAe8cEcBbD6245817512F8DBd8EEF18)
* [Component 50% WXDAI,50% Dai(bsc) Pool](https://blockscout.com/poa/xdai/address/0xF82fc0ecBf3ff8e253a262447335d3d8A72CD028)
* [Component 25% DAI(bsc),25% USDC(bsc),25% USDC,25% WXDAI Pool](https://blockscout.com/poa/xdai/address/0xfbbd0F67cEbCA3252717E66c1Ed1E97ad8B06377)
* Assimilator Contracts on Ethereum
  * [USDP Assimilator](https://etherscan.io/address/0x70f648c442eFa7007E7e4323e14e7Bdc800Bd0cf#code)
  * [USDC Assimilator](https://etherscan.io/address/0xAD6E6594e2E9Cca9326dd80BFFD7BaEf4e2a10F1#code)
  * [USDT Assimilator](https://etherscan.io/address/0x57813e8D1E77c069e66d0BCE3729288Ac4d6f0c8#code)
  * [DAI Assimilator](https://etherscan.io/address/0x2f4184f73634775cd929c081d6e15ca8f3ff5fab#code)
  * [SUSD Assimilator](https://etherscan.io/address/0x721e5380627e8aB1a3636eDeAB05994fc0406beD#code)
* Assimilator Contracts on xDai
  * [USDP Assimilator](https://blockscout.com/poa/xdai/address/0xEAc13bda20A0A81f5Cb0ADdC4a091d00344C2E1b/contracts) 0xFe7ed09C4956f7cdb54eC4ffCB9818Db2D7025b8
  * [USDC Assimilator](https://blockscout.com/poa/xdai/address/0x990107a31d2A3eC03390c44f6250438484E1B7A3/contracts) 0xDDAfbb505ad214D7b80b1f830fcCc89B60fb7A83
  * [WXDAI Assimilator](https://blockscout.com/poa/xdai/address/0x238139bF999f389063444e397cDfadF780ec57DB/contracts) 0xe91D153E0b41518A2Ce8Dd3D7944Fa863463a97d
  * [DAI(bsc) Assimilator](https://blockscout.com/poa/xdai/address/0xc1b303C0A40b02395bBDBf20fCEe21796dbC5f61/contracts) 0xFc8B2690F66B46fEC8B3ceeb95fF4Ac35a0054BC
  * [USDC(bsc) Assimilator](https://blockscout.com/poa/xdai/address/0xc7e06837595336559ee2A23045fdc9713B2E3037/contracts) 0xD10Cc63531a514BBa7789682E487Add1f15A51E2


## Security

Shell Protocol v1 (from which this repo has been forked) has been audited by Consensys Diligence and ABDK Consulting. Audit reports will be available soon.

## Documentation

Documentation for Component will be available soon.

## Development

### Prerequisites

Install Nix: https://nixos.org/download.html

Install dapp.tools (provides `dapp`, `seth`, `hevm` executables):

```bash
nix-env -iA dapp -f https://github.com/dapphub/dapptools/archive/afbb707102baa77eac6ad70873fcd3c59a2ff53c.tar.gz
```

(older releases, including 0.31.1, have library deployment bugs)

Install dependencies:

```bash
# in the repo root dir:
dapp update
```

Install compiler:

```bash
nix-env -f https://github.com/dapphub/dapptools/archive/master.tar.gz -iA solc-static-versions.solc_0_5_15
```

### Build

```bash
dapp --use solc:0.5.15 build
```

*build is non-incremental

### Local test

Use `local_testing` branch. Local tests require compiler upgrade, this change is yet to be merged into master.
