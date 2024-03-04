--testing
CREATE TABLE kimia_farma.kf_analisa1 AS
SELECT ft.transaction_id, ft.date, ft.branch_id, kc.branch_name
FROM kimia_farma.kf_final_transaction as ft
LEFT JOIN kimia_farma.kf_kantor_cabang as kc
  on ft.branch_id = kc.branch_id
;


--nett sales
CREATE TABLE kimia_farma.kf_nett_sales AS
SELECT
  ft.customer_name,
  pr.product_name,
  ft.product_id,
  pr.price,
  ft.discount_percentage,
  pr.price - (pr.price * ft.discount_percentage / 100) AS nett_sales
FROM
  kimia_farma.kf_final_transaction AS ft
LEFT JOIN
  kimia_farma.kf_product AS pr
ON
  ft.product_id = pr.product_id
;



--persentase
CREATE TABLE kimia_farma.kf_persentase AS
SELECT
  nett_sales,
  CASE
    WHEN nett_sales <= 50000 THEN 0.1  -- Laba 10% untuk harga <= Rp 50.000
    WHEN nett_sales > 50000 AND nett_sales <= 100000 THEN 0.15  -- Laba 15% untuk harga > Rp 50.000 - 100.000
    WHEN nett_sales > 100000 AND nett_sales <= 300000 THEN 0.2  -- Laba 20% untuk harga > Rp 100.000 - 300.000
    WHEN nett_sales > 300000 AND nett_sales <= 500000 THEN 0.25  -- Laba 25% untuk harga > Rp 300.000 - 500.000
    ELSE 0.3  -- Laba 30% untuk harga > Rp 500.000
  END AS persentase_gross_laba
FROM
  kimia_farma.kf_nett_sales;




--nett_profit
CREATE TABLE kimia_farma.kf_nett_profit AS
SELECT
  SUM(nett_sales) AS nett_profit
FROM
  kimia_farma.kf_nett_sales
;


--perbandingan pendapatan pertahun
CREATE TABLE kimia_farma.kf_perbandingan_pendapatan_pertahun AS
SELECT
  EXTRACT(YEAR FROM date) AS tahun,
  SUM(price) AS total_pendapatan
FROM
  kimia_farma.kf_final_transaction
GROUP BY
  tahun
ORDER BY
  tahun
;


--Top 5 Cabang Dengan Rating Tertinggi, namun Rating Transaksi Terendah
SELECT ft.branch_id, avg(ft.rating) as avg_rating_transaction, kc.rating as rating_cabang
FROM kimia_farma.kf_final_transaction as ft
left join kimia_farma.kf_kantor_cabang as kc
  on ft. branch_id = kc.branch_id
group by ft.branch_id, kc.rating
order by kc.rating desc, avg(ft. rating) asc



-- Top 10 Total transaksi per cabang provinsi
CREATE TABLE kimia_farma.kf_top_10_total_transaksi AS
SELECT
  kc.provinsi,
  COUNT(*) AS total_transaksi_cabang
FROM
  kimia_farma.kf_final_transaction as ft
LEFT JOIN
  kimia_farma.kf_kantor_cabang as kc
ON
  ft.branch_id = kc.branch_id
GROUP BY
  kc.provinsi
ORDER BY
  total_transaksi_cabang DESC
LIMIT
  10;



-- Top 10 Nett sales per cabang provinsi
CREATE TABLE kimia_farma.kf_top_10_nett_sales AS
SELECT
  kc.cabang_provinsi,
  SUM(ns.nett_sales) AS total_nett_sales_cabang
FROM
  kimia_farma.kf_final_transaction as ft
LEFT JOIN
  kimia_farma.kf_kantor_cabang as kc
ON
  ft.branch_id = kc.branch_id
LEFT JOIN
  kimia_farma.kf_nett_sales as ns
ON
  ft.transaction_id = ns.transaction_id
GROUP BY
  kc.cabang_provinsi
ORDER BY
  total_nett_sales_cabang DESC
LIMIT
  10;


