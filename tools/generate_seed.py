#!/usr/bin/env python3
"""Generate sql/02_seed.sql for the Nusantara Living case study.

The data is synthetic and deterministic: the same seed always produces the same
rows, so the expected results in expected/ stay valid. Patterns built in on
purpose, because the exercises ask about them:

  - revenue grows month over month, with a promo peak in March and a December peak
  - Jakarta is the biggest warehouse, Makassar the smallest and the one that
    cancels most orders
  - marketplace orders carry a lower margin than web and app orders
  - the Decor category declines through 2026, Lighting keeps the best margin
  - a few products are never ordered, a few customers never order
  - voucher_code is NULL on most orders, so NULL handling shows up in the answers
"""
import random
from datetime import date, timedelta

SEED = 20260912
random.seed(SEED)

START = date(2025, 1, 1)
END = date(2026, 6, 30)

WAREHOUSES = {
    "Jakarta": {"weight": 0.42, "cancel": 0.05, "return": 0.04},
    "Surabaya": {"weight": 0.26, "cancel": 0.06, "return": 0.05},
    "Medan": {"weight": 0.19, "cancel": 0.07, "return": 0.05},
    "Makassar": {"weight": 0.13, "cancel": 0.12, "return": 0.07},
}
CITIES = [
    ("Jakarta", "DKI Jakarta", "Jakarta"), ("Bekasi", "Jawa Barat", "Jakarta"),
    ("Depok", "Jawa Barat", "Jakarta"), ("Tangerang", "Banten", "Jakarta"),
    ("Bandung", "Jawa Barat", "Jakarta"), ("Surabaya", "Jawa Timur", "Surabaya"),
    ("Malang", "Jawa Timur", "Surabaya"), ("Semarang", "Jawa Tengah", "Surabaya"),
    ("Yogyakarta", "DI Yogyakarta", "Surabaya"), ("Denpasar", "Bali", "Surabaya"),
    ("Medan", "Sumatera Utara", "Medan"), ("Palembang", "Sumatera Selatan", "Medan"),
    ("Pekanbaru", "Riau", "Medan"), ("Padang", "Sumatera Barat", "Medan"),
    ("Makassar", "Sulawesi Selatan", "Makassar"), ("Manado", "Sulawesi Utara", "Makassar"),
    ("Balikpapan", "Kalimantan Timur", "Makassar"), ("Pontianak", "Kalimantan Barat", "Makassar"),
]
SEGMENTS = [("retail", 0.70), ("reseller", 0.24), ("corporate", 0.06)]
ACQUISITION = [("organic", 0.42), ("ads", 0.40), ("referral", 0.18)]
CHANNELS = [("web", 0.34), ("app", 0.38), ("marketplace", 0.28)]
PAY_METHODS = [("va", 0.31), ("ewallet", 0.27), ("transfer", 0.16), ("cod", 0.14), ("paylater", 0.12)]

FIRST = ["Adi", "Bayu", "Citra", "Dewi", "Eka", "Fajar", "Gita", "Hana", "Indra", "Joko",
         "Kirana", "Lestari", "Maya", "Nanda", "Oka", "Putri", "Rangga", "Sinta", "Tari",
         "Umar", "Vina", "Wahyu", "Yuda", "Zahra", "Arif", "Bella", "Candra", "Dian",
         "Elang", "Fitri", "Galih", "Hesti", "Ilham", "Jasmine", "Kevin", "Laras"]
LAST = ["Pratama", "Wijaya", "Santoso", "Halim", "Nugroho", "Kusuma", "Saputra", "Hartono",
        "Maulana", "Permata", "Siregar", "Manurung", "Ardiansyah", "Rahmawati", "Setiawan",
        "Gunawan", "Lestari", "Suryani", "Mahendra", "Utami", "Firmansyah", "Anggraini"]

CATALOG = {
    "Furniture": {
        "margin": 0.22,
        "price": (1_200_000, 6_500_000),
        "items": ["Sofa Arun 2 Seat", "Sofa Arun 3 Seat", "Meja Makan Bara", "Kursi Makan Bara",
                  "Lemari Pakaian Nara", "Rak Buku Tirta", "Meja Kerja Loka", "Kursi Kerja Loka",
                  "Nakas Sindu", "Bufet TV Rimba", "Kursi Santai Padma", "Meja Kopi Bening"],
    },
    "Lighting": {
        "margin": 0.46,
        "price": (180_000, 1_900_000),
        "items": ["Lampu Gantung Bulan", "Lampu Meja Senja", "Lampu Lantai Rimbun", "Lampu Dinding Kala",
                  "Lampu Baca Titik", "Lampu Taman Surya", "Lampu Rotan Nusa", "Downlight Terang 7W",
                  "Strip LED Warna", "Lampu Tidur Kabut"],
    },
    "Kitchen": {
        "margin": 0.34,
        "price": (95_000, 2_400_000),
        "items": ["Panci Set Api", "Wajan Anti Lengket 28cm", "Pisau Dapur Tajam Set", "Talenan Kayu Jati",
                  "Rak Piring Susun", "Kontainer Makanan 6 pcs", "Teko Listrik Uap", "Blender Pusar",
                  "Timbangan Dapur Digital", "Toples Kaca Bening Set"],
    },
    "Bedding": {
        "margin": 0.38,
        "price": (150_000, 3_200_000),
        "items": ["Sprei Katun Polos King", "Sprei Katun Motif Queen", "Bed Cover Hangat King",
                  "Bantal Bulu Angsa", "Guling Lembut", "Kasur Topper 10cm", "Selimut Tebal Musim",
                  "Sarung Bantal Set 2", "Kelambu Tidur Nyaman"],
    },
    "Decor": {
        "margin": 0.41,
        "price": (75_000, 1_500_000),
        "items": ["Vas Keramik Bumi", "Cermin Bundar Kaca", "Jam Dinding Diam", "Bingkai Foto Kayu Set",
                  "Karpet Anyam Rotan", "Tanaman Artifisial Monstera", "Lilin Aroma Serai",
                  "Hiasan Dinding Anyaman", "Patung Kayu Jati Mini", "Poster Nusantara A2"],
    },
    "Storage": {
        "margin": 0.31,
        "price": (85_000, 1_800_000),
        "items": ["Kotak Penyimpanan Lipat", "Rak Serbaguna 4 Tingkat", "Keranjang Rotan Besar",
                  "Gantungan Baju Berdiri", "Laci Plastik Susun 3", "Box Container 50L",
                  "Rak Sepatu Minimalis", "Organizer Meja Bambu"],
    },
}


def pick(weighted):
    r = random.random()
    total = 0.0
    for value, weight in weighted:
        total += weight
        if r <= total:
            return value
    return weighted[-1][0]


def months(start, end):
    out = []
    y, m = start.year, start.month
    while (y, m) <= (end.year, end.month):
        out.append(date(y, m, 1))
        y, m = (y + 1, 1) if m == 12 else (y, m + 1)
    return out


MONTHS = months(START, END)


def month_factor(d):
    """Growth plus seasonality. March is the Ramadan promo peak, December the year-end peak."""
    index = MONTHS.index(date(d.year, d.month, 1))
    growth = 1.0 + 0.028 * index
    season = {3: 1.45, 4: 1.12, 6: 1.08, 11: 1.10, 12: 1.35}.get(d.month, 1.0)
    return growth * season


def rupiah(value, step=1000):
    return int(round(value / step) * step)


# ---------------------------------------------------------------- customers
customers = []
for cid in range(1, 321):
    city, province, _ = random.choice(CITIES)
    segment = pick(SEGMENTS)
    signup = START - timedelta(days=random.randint(0, 420)) if cid <= 90 else \
        START + timedelta(days=random.randint(0, (END - START).days - 30))
    name = f"{random.choice(FIRST)} {random.choice(LAST)}"
    customers.append({
        "id": cid, "name": name, "city": city, "province": province,
        "segment": segment, "signup": signup, "acq": pick(ACQUISITION),
    })

# ---------------------------------------------------------------- products
products = []
pid = 1
for category, spec in CATALOG.items():
    for item in spec["items"]:
        low, high = spec["price"]
        list_price = rupiah(random.uniform(low, high))
        cost = rupiah(list_price * (1 - spec["margin"] * random.uniform(0.85, 1.15)))
        launch = START - timedelta(days=random.randint(30, 500))
        if pid % 17 == 0:
            launch = START + timedelta(days=random.randint(120, 400))
        products.append({
            "id": pid, "name": item, "category": category, "cost": cost,
            "price": list_price, "launch": launch,
            "active": not (pid % 23 == 0),
        })
        pid += 1

never_sold = {p["id"] for p in products if p["id"] % 29 == 0}
never_ordered_customers = {c["id"] for c in customers if c["id"] % 37 == 0}

# ---------------------------------------------------------------- orders
orders, items, payments = [], [], []
order_id, item_id, payment_id = 1000, 1, 1
for m in MONTHS:
    base = 105 * month_factor(m)
    count = int(random.gauss(base, base * 0.07))
    days_in_month = (date(m.year + (m.month == 12), (m.month % 12) + 1, 1) - m).days
    for _ in range(count):
        order_id += 1
        day = random.randint(1, days_in_month)
        order_date = date(m.year, m.month, day)
        warehouse = pick([(w, s["weight"]) for w, s in WAREHOUSES.items()])
        eligible = [c for c in customers
                    if c["signup"] <= order_date and c["id"] not in never_ordered_customers]
        if not eligible:
            continue
        customer = random.choice(eligible)
        channel = pick(CHANNELS)
        if order_date >= date(2026, 1, 1) and channel == "web" and random.random() < 0.25:
            channel = "marketplace"
        spec = WAREHOUSES[warehouse]
        roll = random.random()
        if roll < spec["cancel"]:
            status = "cancelled"
        elif roll < spec["cancel"] + spec["return"]:
            status = "returned"
        elif order_date > END - timedelta(days=12):
            status = random.choice(["paid", "shipped", "shipped", "delivered"])
        else:
            status = "delivered"
        method = pick(PAY_METHODS)
        promo = m.month in (3, 12)
        voucher = None
        if promo and random.random() < 0.55:
            # the Ramadan voucher only runs in March, the year end voucher only in December
            seasonal = "RAMADAN10" if m.month == 3 else "AKHIRTAHUN15"
            voucher = random.choice([seasonal, seasonal, "GRATISONGKIR"])
        elif random.random() < 0.12:
            voucher = random.choice(["NEWUSER", "GRATISONGKIR"])
        shipping = rupiah(random.uniform(15_000, 120_000), 500)
        if voucher == "GRATISONGKIR":
            shipping = 0

        basket = {"retail": (1, 3), "reseller": (2, 5), "corporate": (3, 7)}[customer["segment"]]
        lines = random.randint(*basket)
        sellable = [p for p in products
                    if p["launch"] <= order_date and p["id"] not in never_sold
                    and (p["active"] or order_date < date(2026, 1, 1))]
        chosen = random.sample(sellable, min(lines, len(sellable)))
        order_total = 0
        for product in chosen:
            weight = 1.0
            if product["category"] == "Decor" and order_date >= date(2026, 1, 1):
                weight = 0.45
            if random.random() > weight:
                continue
            qty = 1 if customer["segment"] == "retail" else random.randint(1, 4)
            if product["category"] in ("Decor", "Kitchen", "Storage"):
                qty += random.randint(0, 2)
            unit = product["price"]
            if channel == "marketplace":
                unit = rupiah(unit * random.uniform(0.90, 0.97))
            discount = 0
            if promo and random.random() < 0.6:
                discount = rupiah(unit * qty * random.uniform(0.05, 0.18))
            elif random.random() < 0.18:
                discount = rupiah(unit * qty * random.uniform(0.03, 0.10))
            item_id += 1
            items.append({
                "id": item_id, "order": order_id, "product": product["id"],
                "qty": qty, "unit": unit, "discount": discount,
            })
            order_total += qty * unit - discount
        if order_total == 0:
            continue
        orders.append({
            "id": order_id, "customer": customer["id"], "date": order_date, "channel": channel,
            "warehouse": warehouse, "status": status, "method": method,
            "voucher": voucher, "shipping": shipping,
        })

        payment_id += 1
        amount = order_total + shipping
        if status == "cancelled":
            pay_status, paid_at = ("failed", None) if random.random() < 0.6 else ("refunded", order_date + timedelta(days=random.randint(1, 4)))
        elif status == "returned":
            pay_status, paid_at = "refunded", order_date + timedelta(days=random.randint(3, 15))
        else:
            pay_status = "settled"
            lag = {"va": 0, "ewallet": 0, "transfer": 1, "paylater": 2, "cod": 4}[method]
            paid_at = order_date + timedelta(days=lag + random.randint(0, 2))
        payments.append({
            "id": payment_id, "order": order_id, "paid_at": paid_at,
            "amount": amount, "method": method, "status": pay_status,
        })

# ---------------------------------------------------------------- targets
revenue_by_wh_month = {}
item_by_order = {}
for it in items:
    item_by_order.setdefault(it["order"], []).append(it)
for o in orders:
    if o["status"] in ("cancelled", "returned"):
        continue
    net = sum(i["qty"] * i["unit"] - i["discount"] for i in item_by_order.get(o["id"], []))
    key = (o["warehouse"], date(o["date"].year, o["date"].month, 1))
    revenue_by_wh_month[key] = revenue_by_wh_month.get(key, 0) + net

targets = []
for (warehouse, month), revenue in sorted(revenue_by_wh_month.items()):
    factor = random.uniform(0.88, 1.14)
    targets.append({"warehouse": warehouse, "month": month, "target": rupiah(revenue * factor, 100_000)})


# ---------------------------------------------------------------- write SQL
def q(value):
    if value is None:
        return "NULL"
    if isinstance(value, bool):
        return "true" if value else "false"
    if isinstance(value, (int, float)):
        return str(value)
    return "'" + str(value).replace("'", "''") + "'"


def insert_block(table, columns, rows, chunk=200):
    out = []
    for start in range(0, len(rows), chunk):
        part = rows[start:start + chunk]
        values = ",\n".join("  (" + ", ".join(q(v) for v in row) + ")" for row in part)
        out.append(f"INSERT INTO {table} ({', '.join(columns)}) VALUES\n{values};\n")
    return "\n".join(out)


parts = [
    "-- Nusantara Living case study, synthetic data.",
    f"-- Generated by tools/generate_seed.py with seed {SEED}. Do not edit by hand.",
    "",
    insert_block("customers", ["customer_id", "full_name", "city", "province", "segment", "signup_date", "acquisition"],
                 [(c["id"], c["name"], c["city"], c["province"], c["segment"], c["signup"].isoformat(), c["acq"]) for c in customers]),
    insert_block("products", ["product_id", "product_name", "category", "cost_price", "list_price", "launch_date", "is_active"],
                 [(p["id"], p["name"], p["category"], p["cost"], p["price"], p["launch"].isoformat(), p["active"]) for p in products]),
    insert_block("orders", ["order_id", "customer_id", "order_date", "channel", "warehouse", "status", "payment_method", "voucher_code", "shipping_fee"],
                 [(o["id"], o["customer"], o["date"].isoformat(), o["channel"], o["warehouse"], o["status"], o["method"], o["voucher"], o["shipping"]) for o in orders]),
    insert_block("order_items", ["order_item_id", "order_id", "product_id", "quantity", "unit_price", "discount"],
                 [(i["id"], i["order"], i["product"], i["qty"], i["unit"], i["discount"]) for i in items]),
    insert_block("payments", ["payment_id", "order_id", "paid_at", "amount", "method", "status"],
                 [(p["id"], p["order"], p["paid_at"].isoformat() if p["paid_at"] else None, p["amount"], p["method"], p["status"]) for p in payments]),
    insert_block("monthly_targets", ["warehouse", "target_month", "revenue_target"],
                 [(t["warehouse"], t["month"].isoformat(), t["target"]) for t in targets]),
]

with open("sql/02_seed.sql", "w") as f:
    f.write("\n".join(parts))

print(f"customers {len(customers)}, products {len(products)}, orders {len(orders)}, "
      f"order_items {len(items)}, payments {len(payments)}, targets {len(targets)}")
