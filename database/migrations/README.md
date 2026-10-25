# Staff invoice checkout migration

Run `20261025_staff_checkout.sql` after importing the existing clinic database, before deploying the new staff invoice screens. It adds three tables and does not modify existing invoices or payment transactions. The script is transactional and may be rerun.

New routes: `/staff/invoices`, `/staff/invoices/detail`, `/staff/invoices/checkout`, `/staff/invoices/export`.

Cash collection requires explicit staff confirmation. QR confirmation queries PayOS from the server and verifies order code and amount. Configure the existing `payos.properties` and webhook `/api/payos-webhook`; browser return parameters never confirm payment. A pending QR locks manual collection and edits until PayOS confirms payment or cancellation. Invoice preview uses the browser print dialog to print or save PDF.

Existing prescription records are preserved when a patient declines buying medicine at the counter. Pending unpaid procedures are cancelled when declined; completed or separately paid procedures cannot be removed. Finalized invoice items are snapshotted so later prescription/catalog changes do not alter printed bills.
