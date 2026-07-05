## ADDED Requirements

### Requirement: Checkout creates an accepted order
The system SHALL create an accepted order when a valid cart is submitted from the web app.

#### Scenario: Valid cart is submitted
- **WHEN** the web app sends a valid cart identifier to the API server
- **THEN** the API server responds with an accepted order and a stable order id
