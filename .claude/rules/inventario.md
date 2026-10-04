---
paths:
  - "app/**/*inventor*"
  - "app/**/*inventor*/**"
  - "vendor/javascript/jsqr.js"
---

**Inventario** (nav "Inventario", formerly the disabled "Logística" entry): `Inventory` → `InventoryItem` → `InventoryMovement`. Stock is never written by hand — `InventoryItem#adjust!` creates a movement and the movement writes `quantity` back, so the number and the history can't disagree; correct a mistake with the opposite movement. An item's `code` (`MAT-0042`, prefix derived from the inventory name) is both its QR payload and its `to_param`, so `/articulos/MAT-0042` is what a scan resolves to (through `inventory_items#lookup`, which also serves the typed-code form and hand scanners). Camera scanning uses `vendor/javascript/jsqr.js` (Safari has no BarcodeDetector); `rqrcode` renders the on-screen QR (SVG) and the printable label sheet (PNG into Prawn). Everyone in logística adjusts stock and adds items; only full access and the logistics director create or delete whole inventories.
