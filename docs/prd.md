# PRD: Inventory & Order Management Frontends — Customer App and Admin/Warehouse Dashboard

## Problem Statement

Customers have no way to browse the catalog, manage a cart, place orders, or follow their order's
progress — all of that currently requires direct API calls. Administrators and warehouse staff
have no interface to manage products, monitor stock and reservations, or move orders through the
fulfillment pipeline. Until these exist, the platform cannot be used by real people.

## Solution

Two applications on top of the existing backend:

1. **Customer app** — a mobile-first application where customers register, browse and search the
   catalog, manage a shopping cart, place orders with a 15-minute payment reservation, pay,
   track their orders live, and review their history.
2. **Admin & Warehouse dashboard** — a web application where administrators manage the product
   catalog and inventory, inspect stock vs. reserved quantities, view and filter all orders,
   drill into full change history, and where warehouse staff process the fulfillment queue
   (ship → deliver). Status changes appear in real time without refresh.

Both apps speak to the same published API contract and share a consistent look, terminology, and
behavior.

## User Stories

### Customer app

#### Onboarding & account
1. As a new customer, I want to create an account with a username, email, and password, so that I can shop and my orders are tied to me.
2. As a customer, I want clear feedback when my chosen username/email already exists or my password is too weak, so that I can correct my registration.
3. As a returning customer, I want to log in with my credentials, so that I can access my cart and orders.
4. As a logged-in customer, I want to remain logged in across app restarts, so that I don't re-enter credentials constantly.
5. As a customer whose session expired, I want the app to renew it automatically, so that I am not interrupted mid-shopping.
6. As a customer, I want to see who I'm logged in as and my profile basics, so that I can confirm the right account is active.
7. As a customer, I want to log out, so that I can secure my account on a shared device.

#### Catalog discovery
8. As a customer, I want to see a browsable list of available products, so that I can discover what's for sale.
9. As a customer, I want infinite scroll or pagination through the catalog, so that browsing stays smooth with large catalogs.
10. As a customer, I want to search products by name/description, so that I can find what I want quickly.
11. As a customer, I want to filter products by category, so that I can narrow down choices.
12. As a customer, I want to open a product detail page with price, description, category, and stock availability, so that I can make an informed decision.
13. As a customer, I want to see when a product is out of stock, so that I don't waste time trying to buy it.
14. As a customer, I want the catalog to refresh (pull-to-refresh), so that I always see current prices and availability.

#### Cart
15. As a customer, I want to add a product with a quantity to my cart, so that I can prepare a purchase.
16. As a customer, I want to see all my cart items with quantities and line totals, so that I understand what I'm about to buy.
17. As a customer, I want to change item quantities in the cart, so that I can buy more or less.
18. As a customer, I want to remove items from the cart, so that I can drop unwanted products.
19. As a customer, I want to see my cart total, so that I know what I'll pay before checkout.
20. As a customer, I want immediate UI feedback when cart actions succeed or fail, so that the app feels responsive and trustworthy.

#### Checkout & payment
21. As a customer, I want to check out directly from my cart, so that placing an order is one step.
22. As a customer, I want to receive an order confirmation with an order number immediately after checkout, so that I can reference it later.
23. As a customer, I want a visible countdown showing the time left to pay (15 minutes from order placement), so that I know how long I have.
24. As a customer, I want to pay for a pending order, so that the reservation becomes a confirmed purchase.
25. As a customer, I want to cancel a pending unpaid order, so that I can change my mind before paying.
26. As a customer, I want to be warned when the reservation expires while I'm still on the payment screen, so that I understand why payment failed instead of seeing a cryptic error.
27. As a customer, I want a clear explanation when payment fails, so that I know what went wrong and what to do next.

#### Order tracking & history
28. As a customer, I want to see my order status (PENDING, PAID, SHIPPED, DELIVERED, CANCELLED), so that I know where my order stands.
29. As a customer, I want status changes pushed to my screen in real time (paid → shipped → delivered), so that I don't have to refresh or poll.
30. As a customer, I want to browse my past orders with dates and totals, so that I can track purchases.
31. As a customer, I want to open one of my orders and see its items, amounts, and lifecycle timeline, so that I understand exactly what happened.
32. As a customer, I want to be restricted to viewing only my own orders, so that my purchases stay private.

### Admin & Warehouse dashboard

#### Access
33. As an administrator, I want to log into the dashboard with admin credentials, so that administrative functions are protected.
34. As a warehouse worker, I want to log into the dashboard with staff credentials, so that I get the fulfillment tools without admin powers.
35. As any dashboard user, I want actions I lack permission for to be hidden or clearly denied, so that the UI doesn't mislead me.

#### Product & inventory management (admin)
36. As an administrator, I want to add new products (name, description, price, currency, stock, category), so that they become sellable.
37. As an administrator, I want to edit product details and stock, so that the catalog stays accurate.
38. As an administrator, I want form validation feedback on product fields, so that I can't accidentally save invalid data.
39. As an administrator, I want to browse/search/filter the full catalog, so that I can find products to manage quickly.
40. As an administrator, I want to see current stock alongside reserved quantities and true availability per product, so that I understand how much stock is actually free.
41. As an administrator, I want low-stock indicators based on configurable thresholds, so that I can spot products needing restock at a glance.
42. As an administrator, I want to view the audit trail of a product's stock changes (who, when, old→new), so that discrepancies are explainable.

#### Order monitoring & pipeline (admin)
43. As an administrator, I want to list all orders filtered by status and/or customer, so that I can monitor the whole pipeline.
44. As an administrator, I want to open any order and see items, totals, customer, and lifecycle state, so that I can support customers effectively.
45. As an administrator, I want the complete revision history of an order (who changed what and when, ADD/MODIFY events), so that I can investigate disputes and issues.
46. As an administrator, I want order status changes appearing in real time, so that the pipeline view is always current.

#### Fulfillment (warehouse)
47. As a warehouse worker, I want a queue of PAID orders ready to ship, so that I know exactly what to pick and pack next.
48. As a warehouse worker, I want to mark an order as shipped, so that the customer sees progress.
49. As a warehouse worker, I want to mark a shipped order as delivered, so that fulfillment is complete.
50. As a warehouse worker, I want invalid transitions blocked with clear errors (e.g., shipping an unpaid order), so that I don't corrupt the pipeline.
51. As a warehouse worker, I want the queue updating live as orders are paid elsewhere, so that new work appears without manual refresh.

## Implementation Decisions

- **Two applications, one contract**: the customer app and the dashboard are separate apps but
  consume the same versioned OpenAPI contract (`docs/api-contract/openapi.yaml`) and WebSocket
  contract (`docs/api-contract/asyncapi-ws.md`). Frontends are driven by generated clients from
  those contracts, never by reading backend code.
- **Roles map 1:1 to screens**: CUSTOMER sees only the customer app; WAREHOUSE gets fulfillment
  sections; ADMIN gets everything. Authorization failures surface as friendly denials, not crashes.
- **Real-time is a hint layer**: WebSocket pushes trigger UI updates, but screens always
  re-fetch authoritative data over REST after receiving a push.
- **Payments are simulated**: "Pay" calls the backend payment endpoint; no external gateway.
- **Reservation UX contract**: checkout screens render `reservationSecondsRemaining` from the
  server (never a client-clock calculation) and must react to `RESERVATION_EXPIRED` /
  `PAYMENT_FAILED` pushes by disabling payment and explaining why.
- **Deployment targets**: customer app ships to mobile devices; dashboard ships as a static web
  build served over HTTPS against a deployed backend (see deployment docs).

## Testing Decisions

- Tests verify **user-visible behavior**, not widget internals: given a state or action, the user
  sees the right thing and the right API call happens.
- Each app has three test layers:
  - *Unit* — pure logic (countdown formatting, totals, role-based visibility rules).
  - *Component/widget* — screens render correctly for loading / success / error / empty states.
  - *Flow/integration* — end-to-end journeys against a real or mocked backend: login → browse →
    cart → checkout → pay; login → queue → ship → deliver.
- Prior art: the backend suite's integration tests exercise every journey above through public
  APIs; frontend tests mirror the same scenarios at the UI level.
- Real-time behavior is tested by asserting UI transitions when a simulated push arrives.

## Out of Scope

- Production payment gateway integration (payments stay simulated).
- Push notifications (real-time is in-app only).
- Offline-first mode with conflict resolution (simple caching of read-heavy screens is fine).
- Multi-language support (English only).
- Advanced analytics/charting beyond tables, badges, and simple indicators.
- Backend feature changes — anything the current contract cannot express becomes a backend task first.
- iOS release logistics (Android/web first).

## Further Notes

- Epic derivation: the natural epic seams are the story groups above — Account, Catalog, Cart,
  Checkout & Payment, Order Tracking (customer app); Access, Inventory Management, Order
  Monitoring, Fulfillment Queue (dashboard).
- Story numbering here is independent of the backend PRD (`docs/prd.md`) numbering; this file is
  the frontend source of truth.
- Any story found unsupported by the current contract must be resolved by changing the backend
  first (as happened with the warehouse fulfillment queue), keeping frontends contract-driven.
