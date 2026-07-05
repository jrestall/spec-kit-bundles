## Overview

The shared store owns the cross-repo contract. The web app implements the checkout interaction and the API server implements order creation.

## Technical Approach

- `web-app` keeps only an OpenSpec store pointer, so commands run there act on `team-planning`.
- `api-server` keeps its own OpenSpec root for backend-specific changes and declares `team-planning` as a reference.
- The shared checkout capability is stored in `planning/openspec/specs/checkout/spec.md`.

## Open Questions

- The exact request and response schema can be refined in a repo-local API design change.
