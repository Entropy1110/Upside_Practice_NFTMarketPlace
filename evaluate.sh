#!/bin/bash

# These private keys are only for testing.
# DO NOT USE this private key on other purpose.
export MNEMONIC=test test test test test test test test test test test junk
export PRIVATE_KEY_1=0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
export PRIVATE_KEY_2=0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d
export PRIVATE_KEY_3=0x5de4111afa1a4b94908f83103eb1f1706367c2e68ca870fc3fb9a804cdab365a
export PRIVATE_KEY_4=0x7c852118294e51e653712a81e05800f419141751be58f605c371e15141b007a6

forge clean
forge script ./script/Assessment.s.sol:Assessment --fork-url http://localhost:8545 --skip-simulation
# forge script ./script/problems/UpgradeableProblem.s.sol:UpgradeableProblem --fork-url http://localhost:8545 --skip-simulation
