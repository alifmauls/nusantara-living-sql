-- Nusantara Living, online home and living retailer.
-- Schema for the SQL case study. Money is stored in whole rupiah (bigint).

DROP TABLE IF EXISTS payments, order_items, orders, monthly_targets, products, customers CASCADE;

CREATE TABLE customers (
    customer_id  integer PRIMARY KEY,
    full_name    varchar(60) NOT NULL,
    city         varchar(40) NOT NULL,
    province     varchar(40) NOT NULL,
    segment      varchar(20) NOT NULL,   -- retail, reseller, corporate
    signup_date  date        NOT NULL,
    acquisition  varchar(20) NOT NULL    -- organic, ads, referral
);

CREATE TABLE products (
    product_id   integer PRIMARY KEY,
    product_name varchar(80) NOT NULL,
    category     varchar(30) NOT NULL,   -- Furniture, Lighting, Kitchen, Bedding, Decor, Storage
    cost_price   bigint      NOT NULL,   -- what Nusantara Living pays the supplier, IDR
    list_price   bigint      NOT NULL,   -- catalogue price, IDR
    launch_date  date        NOT NULL,
    is_active    boolean     NOT NULL
);

CREATE TABLE orders (
    order_id       integer PRIMARY KEY,
    customer_id    integer NOT NULL REFERENCES customers (customer_id),
    order_date     date    NOT NULL,
    channel        varchar(20) NOT NULL, -- web, app, marketplace
    warehouse      varchar(20) NOT NULL, -- Jakarta, Surabaya, Medan, Makassar
    status         varchar(20) NOT NULL, -- delivered, shipped, paid, cancelled, returned
    payment_method varchar(20) NOT NULL, -- va, ewallet, transfer, cod, paylater
    voucher_code   varchar(20),          -- NULL when no voucher was used
    shipping_fee   bigint  NOT NULL      -- charged to the customer, IDR
);

CREATE TABLE order_items (
    order_item_id integer PRIMARY KEY,
    order_id      integer NOT NULL REFERENCES orders (order_id),
    product_id    integer NOT NULL REFERENCES products (product_id),
    quantity      integer NOT NULL,
    unit_price    bigint  NOT NULL,      -- price actually charged per unit, IDR
    discount      bigint  NOT NULL       -- discount on this line, IDR
);

CREATE TABLE payments (
    payment_id integer PRIMARY KEY,
    order_id   integer NOT NULL REFERENCES orders (order_id),
    paid_at    date,                     -- NULL when the payment never settled
    amount     bigint  NOT NULL,         -- items plus shipping, IDR
    method     varchar(20) NOT NULL,
    status     varchar(20) NOT NULL      -- settled, failed, refunded
);

CREATE TABLE monthly_targets (
    warehouse      varchar(20) NOT NULL,
    target_month   date        NOT NULL, -- always the first day of the month
    revenue_target bigint      NOT NULL, -- IDR
    PRIMARY KEY (warehouse, target_month)
);

CREATE INDEX ON orders (order_date);
CREATE INDEX ON orders (customer_id);
CREATE INDEX ON order_items (order_id);
CREATE INDEX ON order_items (product_id);
