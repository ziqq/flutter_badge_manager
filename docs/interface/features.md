# Platform Interface Features

## Responsibilities

- define the shared plugin contract
- protect the contract with `PlatformInterface` verification
- provide a fail-fast missing implementation path

## Non-responsibilities

- no platform channels
- no badge rendering logic
- no launcher-specific or Darwin-specific behavior
