-- PERTANYAAN
-- Nomor 1
-- Q: Selama transaksi yang terjadi selama 2021, pada bulan apa total nilai transaksi (after_discount) paling besar? Gunakan is_valid = 1 untuk memfilter data transaksi.
-- Source table: order_detail
SELECT EXTRACT(MONTH FROM order_date) bulan,
	SUM(after_discount) total_sales
FROM order_detail
WHERE is_valid = 1 
	AND order_date BETWEEN '2021-01-01' AND '2021-12-31' 
GROUP BY 1
ORDER BY 2 DESC
-- atau
SELECT to_char(order_date, 'month') bulan_order,
	SUM(after_discount) total_sales
FROM order_detail
WHERE is_valid = 1 
	AND to_char(order_date, 'yyyy-mm-dd') BETWEEN '2021-01-01' AND '2021-12-31' 
GROUP BY 1
ORDER BY 2 DESC

-- Nomor 2
-- Q: Selama transaksi yang terjadi selama 2021, pada bulan apa total jumlah pelanggan (unique), total order (unique) dan total jumlah kuantitas produk paling banyak? Gunakan is_valid = 1 untuk memfilter data transaksi.
-- Source table: order_detail
SELECT EXTRACT(MONTH FROM order_date) bulan_order,
	COUNT(DISTINCT customer_id) jumlah_pelanggan,
	COUNT(DISTINCT id) total_order,
	SUM(qty_ordered) jumlah_kuantitas
FROM order_detail
WHERE is_valid = 1 
	AND order_date BETWEEN '2021-01-01' AND '2021-12-31'
GROUP BY 1
ORDER BY 2 DESC

-- Nomor 3
-- Q: Selama transaksi yang terjadi selama 2022, kategori apa yang menghasilkan nilai transaksi paling besar? Gunakan is_valid = 1 untuk memfilter data transaksi.
-- Source table: order_detail, sku_detail
SELECT s.category,
	SUM(o.after_discount) total_sales
FROM order_detail o
LEFT JOIN sku_detail s
ON o.sku_id=s.id
WHERE o.is_valid = 1 
	AND o.order_date BETWEEN '2022-01-01' AND '2022-12-31'
GROUP BY 1
ORDER BY 2 DESC

-- Nomor 4
-- Q: Bandingkan nilai transaksi dari masing-masing kategori pada tahun 2021 dengan 2022. Sebutkan kategori apa saja yang mengalami peningkatan dan kategori apa yang mengalami penurunan nilai transaksi dari tahun 2021 ke 2022. Gunakan is_valid = 1 untuk memfilter data transaksi.
-- Source table: order_detail, sku_detail
SELECT s.category,
	SUM(CASE WHEN o.order_date BETWEEN '2021-01-01' AND '2021-12-31' THEN o.after_discount END) total_transactions_2021,
	SUM(CASE WHEN o.order_date BETWEEN '2022-01-01' AND '2022-12-31' THEN o.after_discount END) total_transactions_2022
FROM order_detail o
LEFT JOIN sku_detail s
ON o.sku_id=s.id
WHERE o.is_valid = 1
GROUP BY 1
ORDER BY 2 DESC

-- Nomor 5
-- Q: Tampilkan Top 10 sku_name (beserta kategorinya) berdasarkan nilai transaksi yang terjadi selama tahun 2022. Tampilkan juga total jumlah pelanggan (unique), total order (unique) dan total jumlah kuantitas. Gunakan is_valid = 1 untuk memfilter data transaksi.
-- Source table: order_detail, sku_detail
SELECT s.sku_name,
	s.category,
	SUM(o.after_discount) total_sales,
	COUNT(DISTINCT o.customer_id) total_customer,
	COUNT(DISTINCT o.id) total_order,
	SUM(o.qty_ordered) total_quantity
FROM order_detail o
LEFT JOIN sku_detail s
ON o.sku_id=s.id
WHERE o.is_valid = 1 
	AND o.order_date BETWEEN '2022-01-01' AND '2022-12-31'
GROUP BY 1, 2
ORDER BY 3 DESC
LIMIT 10


Nomor 6
Q: Tampilkan top 5 metode pembayaran yang paling populer digunakan selama 2022 (berdasarkan total unique order). Gunakan is_valid = 1 untuk memfilter data transaksi.
Source table: order_detail, payment_method
SELECT p.payment_method,
	COUNT(DISTINCT customer_id) AS total_customer
FROM order_detail o
LEFT JOIN payment_detail p
ON o.payment_id=p.id
WHERE o.is_valid = 1 
	AND o.order_date BETWEEN '2022-01-01' AND '2022-12-31'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5


-- Nomor 7
-- Q: Urutkan dari ke-5 produk ini berdasarkan nilai transaksinya. 
-- Samsung
-- Apple
-- Sony
-- Huawei
-- Lenovo
-- Gunakan is_valid = 1 untuk memfilter data transaksi.
-- Source table: order_detail, sku_detail
WITH a AS (SELECT CASE
	WHEN LOWER(s.sku_name) LIKE '%samsung%' THEN 'samsung'
	WHEN LOWER(s.sku_name) LIKE '%apple%' OR LOWER(s.sku_name) LIKE '%iphone%'  THEN 'apple'
	WHEN LOWER(s.sku_name) LIKE '%sony%' THEN 'sony'
	WHEN LOWER(s.sku_name) LIKE '%huawei%' THEN 'huawei'
	WHEN LOWER(s.sku_name) LIKE '%lenovo%' THEN 'lenovo'
	END product_name,
	SUM(o.after_discount) total_sales
FROM order_detail o
LEFT JOIN sku_detail s
ON o.sku_id=s.id
WHERE o.is_valid = 1 
	AND o.order_date BETWEEN '2022-01-01' AND '2022-12-31' 
GROUP BY 1)
SELECT * FROM a
WHERE product_name IS NOT NULL
ORDER BY 2 DESC

-- Nomor 8
-- Q: Seperti pertanyaan no. 3, buatlah perbandingan dari nilai profit tahun 2021 dan 2022 pada tiap kategori. 
-- Kemudian buatlah selisih % perbedaan profit antara 2021 dengan 2022 (profit = after_discount - (cogs*qty_ordered))
-- Gunakan is_valid = 1 untuk memfilter data transaksi.
Source table: order_detail, sku_detail
WITH b AS (WITH a AS (SELECT EXTRACT(YEAR FROM o.order_date) AS year_order,
	s.category,
	o.after_discount - (s.cogs*o.qty_ordered) AS profit
FROM order_detail o
LEFT JOIN sku_detail s
ON o.sku_id=s.id
WHERE is_valid = 1)

SELECT a.category,
	SUM(CASE WHEN year_order = '2021' THEN a.profit END) year_2021,
	SUM(CASE WHEN year_order = '2022' THEN a.profit END) year_2022
FROM a
GROUP BY 1)

SELECT b.*,
	(b.year_2022-b.year_2021)/b.year_2021 growht
FROM b
ORDER BY 4

-- Nomor 9
-- Q: Tampilkan top 5 SKU dengan kontribusi profit paling tinggi di tahun 2022 berdasarkan kategori paling besar 
-- pertumbuhan profit dari 2021 ke 2022 (berdasarkan hasil no 8).
-- Gunakan is_valid = 1 untuk memfilter data transaksi.
Source table: order_detail, sku_detail
WITH a AS (SELECT s.sku_name,
	o.after_discount - (s.cogs*o.qty_ordered) profit
FROM order_detail o
LEFT JOIN sku_detail s
ON o.sku_id=s.id
WHERE is_valid = 1 
	AND order_date BETWEEN '2022-01-01' AND '2022-12-31'
	AND s.category = 'Women Fashion')
SELECT a.sku_name,
	SUM(profit) total_profit
FROM a
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5

-- Nomor 10
-- Q: Tampilkan jumlah unique order yang menggunakan top 5 metode pembayaran (soal no 6) berdasarkan kategori produk selama tahun 2022.
-- Gunakan is_valid = 1 untuk memfilter data transaksi.
Source table: order_detail, sku_detail
SELECT s.category,
	COUNT(DISTINCT CASE WHEN p.payment_method = 'cod' THEN o.id END) cod,
	COUNT(DISTINCT CASE WHEN p.payment_method = 'Easypay' THEN o.id END) easypay,
	COUNT(DISTINCT CASE WHEN p.payment_method = 'Payaxis' THEN o.id END) payaxis,
	COUNT(DISTINCT CASE WHEN p.payment_method = 'customercredit' THEN o.id END) customercredit,
	COUNT(DISTINCT CASE WHEN p.payment_method = 'jazzwallet' THEN o.id END) jazzwallet
FROM order_detail o
LEFT JOIN payment_detail p ON o.payment_id=p.id
LEFT JOIN sku_detail s ON o.sku_id=s.id
WHERE is_valid = 1 AND order_date BETWEEN '2022-01-01' AND '2022-12-31'
GROUP BY 1
ORDER BY 2 DESC