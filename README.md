# AgentTip

Tip any Agent ID holder by their `.ai` name — no wallet address needed.

Built for the [Agent ID Hackathon](https://www.bnbchain.org/en/blog/agent-id-hackathon) (Binance Wallet × BNB Chain).

## What it does

Type a name like `tesla666`, enter an amount in BNB, hit send. The BNB goes
straight to that Agent ID holder's wallet. The sender must also hold an Agent ID,
so every tip is an interaction between two Agent ID holders.

- **Pay by name, not address.** The contract resolves handles on-chain via
  `ownerOfHandle()` on the SPACE ID Agent ID contract
  (`0x60b9262456de011f7d15a54cdd8c48baaa8b022f`).
- **Both sides verified on-chain.** `tip()` reverts unless the sender holds an
  Agent ID (`balanceOf > 0`) and the recipient handle resolves to an address
  that holds one too.
- **No fees, no owner, no admin.** 100% of every tip is forwarded to the
  recipient in the same call. The contract holds no funds and cannot be
  paused, upgraded, or changed. Self-tips are rejected to prevent wash volume.

## Contract

- Network: BNB Smart Chain (chain id 56)
- Address: `0x6350375929E627176D905c1dD54e794E66DEbB8F` ([BscScan](https://bscscan.com/address/0x6350375929E627176D905c1dD54e794E66DEbB8F))
- Source: [`AgentTip.sol`](AgentTip.sol) (Solidity 0.8.26, MIT)

## Functions

| Function | Description |
|---|---|
| `tip(string recipientHandle, string message)` | Tip by handle, e.g. `tip("tesla666", "thanks!")` |
| `tipByAddress(address recipient, string message)` | Tip directly by wallet address |
| `resolveHandle(string handle)` | Resolve a handle to its wallet address |
| `getHandle(address account)` | Get the handle of a wallet address |
| `isAgentIDHolder(address account)` | Check whether an address holds an Agent ID |

Events: `Tipped(sender, recipient, senderHandle, recipientHandle, amount, message, timestamp)`.
Counters: `totalTips`, `totalVolume`.

## How to use

Open the web app (link coming soon), connect your Binance Wallet (you need an
Agent ID — claim one free in the Binance App: Wallet → banner → Agent ID),
type the recipient's `.ai` name and the amount, and send.

## Development

```bash
# compile (solc 0.8.26)
solcjs --bin --abi --optimize --optimize-runs 200 AgentTip.sol
```

## License

MIT
