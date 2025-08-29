# FHE Private DeFi Lending

This is a demo DeFi lending/borrowing dApp built on **Zama's FHEVM**.  
All loan amounts, interest rates, and collateral values are encrypted end-to-end.

## Features
- Encrypted lending positions (collateral, loan, rate)
- Transparent settlement with encrypted data
- Privacy-preserving DeFi infrastructure demo

## Contracts
- `contracts/Lending.sol` — stores and manages encrypted positions

## Why
Traditional DeFi is fully transparent, which leaks private positions. With **Fully Homomorphic Encryption (FHE)**, we can compute on encrypted data and keep users' financial details confidential.

## How it works (high level)
1. User submits encrypted collateral and loan request.
2. Smart contract stores ciphertext and emits events.
3. Tally/health checks are computed with FHE primitives (per FHEVM model).
4. Only aggregate outcomes are revealed; raw numbers never leak.

## Roadmap
- Frontend demo (submit/read ciphertext, decode client-side)
- Pooled liquidity + encrypted interest accrual
- Risk scoring via encrypted inputs

## Disclaimer
This is a non-production demo to showcase patterns for **FHEVM**.  
