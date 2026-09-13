CREATE TABLE customers (
  loyalty_number INTEGER PRIMARY KEY,
  first_name TEXT,
  last_name TEXT,
  pass_hash TEXT,
  address_line_1 TEXT,
  address_line_2 TEXT,
  city TEXT,
  postcode TEXT,
  phone_number TEXT,
  email TEXT,
  stamps INTEGER,
  registered_time TEXT,
  status TEXT,
  flagged_at TEXT,
  suspended_at TEXT,
  deleted_at TEXT,
  suspension_reason_id INTEGER,
  deletion_reason_id INTEGER,
  FOREIGN KEY(suspension_reason_id) REFERENCES suspension_reasons(id),
  FOREIGN KEY(deletion_reason_id) REFERENCES deletion_reasons(id)
);

CREATE TABLE employees (
  username TEXT PRIMARY KEY,
  first_name TEXT,
  last_name TEXT,
  email TEXT,
  pass_hash TEXT,
  role TEXT,
  registered_time TEXT,
  deleted_at TEXT
);

CREATE TABLE orders (
  order_unique_id INTEGER PRIMARY KEY,
  loyalty_number INTEGER,
  date_placed TEXT,
  cost REAL,
  price REAL,
  tracking_id INTEGER,
  reference_id TEXT,
  barista TEXT,
  delivered INTEGER,
  order_fulfilment TEXT, --Incomplete, Completed, Collected
  status TEXT, --Paid, Unpaid, Owed, Refunded
  discount_code_used TEXT,
  percentage_off INTEGER,
  payment_method INTEGER,
  net_price REAL,
  FOREIGN KEY (payment_method) REFERENCES payment_methods(id)
);

CREATE TABLE payment_methods (
  id INTEGER PRIMARY KEY,
  payment_method TEXT
);

CREATE TABLE item_in_orders (
  item_in_order_id INTEGER PRIMARY KEY,
  item_id INTEGER,
  order_unique_id INTEGER,
  price_for_one REAL,
  quantity INTEGER,
  size_id INTEGER,
  milk_id INTEGER,
  refunded INTEGER, -- 0: Not Refunded 1: Refunded 
  FOREIGN KEY (order_unique_id) REFERENCES orders(order_unique_id),
  FOREIGN KEY (item_id, size_id, milk_id) REFERENCES product_variants(product_id, size_id, milk_id)
);

CREATE TABLE login_times (
  login_id INTEGER PRIMARY KEY,
  loyalty_number INTEGER,
  login_time TEXT
);

CREATE TABLE favourites (
  favourite_id INTEGER PRIMARY KEY,
  loyalty_number INTEGER,
  item_id INTEGER,
  name TEXT,
  time_favourited TEXT
);

CREATE TABLE recent_views (
  view_id INTEGER PRIMARY KEY,
  loyalty_number INTEGER,
  item_id INTEGER,
  time_viewed TEXT,
  name TEXT
);

CREATE TABLE profile_updates (
  update_id INTEGER PRIMARY KEY,
  loyalty_number INTEGER,
  field_updated TEXT,
  old_value TEXT,
  new_value TEXT,
  time_updated TEXT
);

CREATE TABLE sizes (
  id INTEGER PRIMARY KEY,
  size TEXT
);

CREATE TABLE milk_options (
  id INTEGER PRIMARY KEY,
  milk TEXT
);

CREATE TABLE countries (
  id INTEGER PRIMARY KEY,
  country TEXT
);

CREATE TABLE roast_levels (
  id INTEGER PRIMARY KEY,
  roast_level TEXT
);

CREATE TABLE products (
  product_id INTEGER PRIMARY KEY,
  type TEXT,
  name TEXT,
  stock_level INTEGER,
  availability INTEGER,
  origin INTEGER,
  roast_level INTEGER,
  description TEXT,
  image_path TEXT,
  FOREIGN KEY (origin) REFERENCES countries(id),
  FOREIGN KEY (roast_level) REFERENCES roast_levels(id)
);

CREATE TABLE product_variants (
  product_id INTEGER,
  size_id INTEGER,
  milk_id INTEGER,
  price REAL,
  cost REAL,
  PRIMARY KEY(product_id, size_id, milk_id),
  FOREIGN KEY (product_id) REFERENCES products(product_id),
  FOREIGN KEY (size_id) REFERENCES sizes(id),
  FOREIGN KEY (milk_id) REFERENCES milk_options(id)
);

CREATE TABLE eligible_purchase_types (
  id INTEGER PRIMARY KEY,
  type TEXT
);

CREATE TABLE eligible_rules (
  id INTEGER PRIMARY KEY,
  rule TEXT
);

CREATE TABLE discount_codes (
  discount_code TEXT PRIMARY KEY,
  campaign_name TEXT,
  percentage_off INTEGER,
  eligible_type INTEGER,
  eligible_rule INTEGER,
  eligible_min REAL,
  valid_purchase_date_from TEXT,
  valid_purchase_date_to TEXT,
  code_expiry_date TEXT,
  is_active INTEGER,
  FOREIGN KEY (eligible_type) REFERENCES eligible_purchase_types(id),
  FOREIGN KEY (eligible_rule) REFERENCES eligible_rules(id)
);

CREATE TABLE discount_redemptions (
  loyalty_number INTEGER,
  code TEXT,
  is_redeemed INTEGER,
  PRIMARY KEY (loyalty_number, code),
  FOREIGN KEY (loyalty_number) REFERENCES customers(loyalty_number) DEFERRABLE INITIALLY DEFERRED,
  FOREIGN KEY (code) REFERENCES discount_codes(discount_code)
);

CREATE TABLE free_coffee_redemptions (
  redemption_number INTEGER PRIMARY KEY,
  redeem_timestamp TEXT,
  order_unique_id INTEGER,
  item_in_order_id INTEGER,
  loyalty_number INTEGER,
  product_id INTEGER,
  size_id INTEGER,
  milk_id INTEGER,
  FOREIGN KEY (product_id, size_id, milk_id) 
  REFERENCES product_variants(product_id, size_id, milk_id)
);

CREATE TABLE basket_items (
  basket_item_id INTEGER PRIMARY KEY,
  loyalty_number INTEGER NOT NULL,
  product_id INTEGER NOT NULL,
  milk_id INTEGER NOT NULL,
  size_id INTEGER NOT NULL,
  quantity INTEGER
);

CREATE TABLE complaints (
  complaint_id INTEGER PRIMARY KEY,
  loyalty_number INTEGER,
  complaint_text TEXT NOT NULL,
  status TEXT,
  created_at TEXT
);

CREATE TABLE order_status_audits (
  audit_id INTEGER PRIMARY KEY,
  order_unique_id INTEGER,
  old_status TEXT,
  new_status TEXT,
  reason_note TEXT,
  changed_by TEXT,
  changed_at TEXT
);

CREATE TABLE promotions (
  promotion_id INTEGER PRIMARY KEY,
  loyalty_number INTEGER,
  sent_at TEXT
);

CREATE TABLE promotion_items (
  promotion_item_id INTEGER PRIMARY KEY,
  promotion_id INTEGER,
  item_id INTEGER,
  size_id INTEGER,
  milk_id INTEGER,
  FOREIGN KEY (promotion_id) REFERENCES promotions(promotion_id)
);

CREATE TABLE refunds (
  refund_id INTEGER PRIMARY KEY,
  loyalty_number INTEGER,
  refund_reason TEXT NOT NULL,
  status TEXT, --Pending, Resolved, Denied 
  order_id INTEGER,
  item_id INTEGER,
  created_at TEXT,
  FOREIGN KEY (order_id) REFERENCES orders(order_unique_id),
  FOREIGN KEY (item_id) REFERENCES item_in_orders(item_in_order_id)
);

CREATE TABLE suspension_reasons (
  id INTEGER PRIMARY KEY,
  reason TEXT
);

CREATE TABLE deletion_reasons (
  id INTEGER PRIMARY KEY,
  reason TEXT
);
