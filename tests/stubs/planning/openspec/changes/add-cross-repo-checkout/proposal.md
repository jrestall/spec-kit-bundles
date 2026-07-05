## Why

Checkout work touches both the user-facing flow and the backend order boundary. A shared planning store keeps the product requirement in one place before either repo implements its slice.

## What Changes

- Add a checkout order creation requirement owned by the planning store.
- Let `web-app` use the planning store as its default OpenSpec root.
- Let `api-server` keep local OpenSpec work while referencing the planning store for shared requirements.

## Capabilities

### New Capabilities
- `checkout`: Shared checkout behavior spanning web order submission and API order acceptance.

### Modified Capabilities

## Impact

- `web-app/src/App.tsx` will call the backend order API.
- `api-server/src/server.ts` will accept order creation requests.
- OpenSpec planning artifacts live in `planning/openspec/`.
