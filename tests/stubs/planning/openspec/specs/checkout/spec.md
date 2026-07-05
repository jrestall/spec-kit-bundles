# Checkout Specification

## Purpose

Define the shared checkout behavior consumed by the web app and API server.

## Requirements

### Requirement: Checkout submits an order
The system SHALL let a shopper submit a cart as an order.

#### Scenario: Order accepted
- **WHEN** the web app submits a valid cart
- **THEN** the API server returns an accepted order with an order id
