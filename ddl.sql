--1. DỰNG CÁC BẢNG DIM
--2. DỰNG CÁC BẢNG FACT
--3. DỰNG BẢNG `log_tracking`
--4. DỰNG CÁC BẢNG ĐÍCH "BÁO CÁO TỔNG HỢP" và "BÁO CÁO XẾP HẠNG"

-----------------------------------------
--1. DỰNG CÁC BẢNG DIM
--Tạo bảng "dim_analysis_code"
CREATE TABLE dim_analysis_code as
		SELECT 	
				DISTINCT analysis_code,
				LEFT(analysis_code,4) dvml_head,
				RIGHT(LEFT(analysis_code,7),2) region_code,
				RIGHT(LEFT(analysis_code,9),1) area_code,
				RIGHT(LEFT(analysis_code,12),2) city_code,
				RIGHT(analysis_code,(length(analysis_code) - 13)) pos_cde
		FROM 
				fact_txn_month_raw_data

--Tạo bảng "dim_area_code"
CREATE TABLE dim_area_code (
	area_code varchar(50) NULL,
	area_name_funding text NULL,
	area_name text NULL
);				
		
--Tạo bảng "dim_city_code"
CREATE TABLE dim_city_code (
	city_code varchar NULL,
	city_name text NULL
);

--Tạo bảng "dim_funding_id"
CREATE TABLE dim_funding_id (
	funding_id int4 NULL,
	funding_code varchar(50) NULL,
	funding_name varchar(50) NULL,
	funding_parent_id int4 NULL,
	funding_level int4 NULL,
	sortorder int4 NULL
);

-----------------------------------------
--2. DỰNG CÁC BẢNG FACT
--Tạo bảng "fact_funding_summary"
CREATE TABLE fact_funding_summary (
	funding_id int4 NULL,
	area_code varchar NULL,
	total_amount float8 NULL,
	month_key int4 NULL
);

--Tạo bảng "fact_kpi_asm_data"
CREATE TABLE fact_kpi_asm_data AS 
SELECT 
		'202301' AS kpi_asm_month,
		area_code,
		kad.area_name,
		sale_name,
		email,
		jan_ltn AS ltn,
		jan_psdn AS psdn,
		jan_app_approved AS app_approved,
		jan_app_in AS app_in,
		CASE
			WHEN jan_app_in = 0 THEN 0
			ELSE jan_app_approved*1.0/jan_app_in 
		END AS app_rate
FROM kpi_asm_data kad
LEFT JOIN dim_area_code dac ON kad.area_name = dac.area_name
UNION ALL
SELECT 
		'202302' AS kpi_asm_month,
		area_code,
		kad.area_name,
		sale_name,
		email,
		feb_ltn AS ltn,
		feb_psdn AS psdn,
		feb_app_approved AS app_approved,
		feb_app_in AS app_in,
		CASE
			WHEN feb_app_in = 0 THEN 0
			ELSE feb_app_approved*1.0/feb_app_in 
		END AS app_rate
FROM kpi_asm_data kad
LEFT JOIN dim_area_code dac ON kad.area_name = dac.area_name
UNION ALL
SELECT 
		'202303' AS kpi_asm_month,
		area_code,
		kad.area_name,
		sale_name,
		email,
		mar_ltn AS ltn,
		mar_psdn AS psdn,
		mar_app_approved AS app_approved,
		mar_app_in AS app_in,
		CASE
			WHEN mar_app_in = 0 THEN 0
			ELSE mar_app_approved*1.0/mar_app_in 
		END AS app_rate
FROM kpi_asm_data kad
LEFT JOIN dim_area_code dac ON kad.area_name = dac.area_name
UNION ALL
SELECT 
		'202304' AS kpi_asm_month,
		area_code,
		kad.area_name,
		sale_name,
		email,
		apr_ltn AS ltn,
		apr_psdn AS psdn,
		apr_app_approved AS app_approved,
		apr_app_in AS app_in,
		CASE
			WHEN apr_app_in = 0 THEN 0
			ELSE apr_app_approved*1.0/apr_app_in 
		END AS app_rate
FROM kpi_asm_data kad
LEFT JOIN dim_area_code dac ON kad.area_name = dac.area_name
UNION ALL
SELECT 
		'202305' AS kpi_asm_month,
		area_code,
		kad.area_name,
		sale_name,
		email,
		may_ltn AS ltn,
		may_psdn AS psdn,
		may_app_approved AS app_approved,
		may_app_in AS app_in,
		CASE
			WHEN may_app_in = 0 THEN 0
			ELSE may_app_approved*1.0/may_app_in 
		END AS app_rate
FROM kpi_asm_data kad
LEFT JOIN dim_area_code dac ON kad.area_name = dac.area_name;

-----------------------------------------
--3. DỰNG BẢNG `log_tracking` 
CREATE TABLE IF NOT EXISTS log_tracking (
	log_id SERIAL PRIMARY KEY,
	procedure_name VARCHAR(255) NOT NULL,
	start_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	end_time TIMESTAMP,
	is_successful BOOLEAN,
	error_log TEXT,
	rec_created_dt TIMESTAMP DEFAULT CURRENT_DATE
	); 
	

-----------------------------------------
--4. DỰNG CÁC BẢNG ĐÍCH "BÁO CÁO TỔNG HỢP" và "BÁO CÁO XẾP HẠNG"
CREATE TABLE "BÁO CÁO TỔNG HỢP" (
		"TIÊU CHÍ" varchar(50), 
		"HỘI SỞ" float8, 
		"Đông Bắc Bộ" float8, 
		"Tây Bắc Bộ" float8, 
		"Đồng Bằng Sông Hồng" float8, 
		"Bắc Trung Bộ" float8, 
		"Nam Trung Bộ" float8, 
		"Tây Nam Bộ" float8, 
		"Đông Nam Bộ" float8,
		"Tháng báo cáo" int
		);
	
CREATE TABLE "BÁO CÁO XẾP HẠNG" (
		month_key int4 NULL,
		area_code varchar(50) NULL,
		area_name varchar(50) NULL,
		email varchar(50) NULL,
		"Tổng điểm" int8 NULL,
		rank_final int8 NULL,
		ltn_avg numeric NULL,
		rank_ltn_avg int8 NULL,
		psdn_avg numeric NULL,
		rank_psdn_avg int8 NULL,
		approval_rate_avg numeric NULL,
		rank_approval_rate_avg int8 NULL,
		npl_bef_wo numeric NULL,
		rank_npl_bef_wo int8 NULL,
		"Điểm Quy Mô" int8 NULL,
		rank_ptkd int8 NULL,
		cir float8 NULL,
		rank_cir int8 NULL,
		margin float8 NULL,
		rank_margin int8 NULL,
		hs_von float8 NULL,
		rank_hs_von int8 NULL,
		hsbq_nhan_su float8 NULL,
		rank_hsbq_nhan_su int8 NULL,
		"Điểm FIN" int8 NULL,
		rank_fin int8 NULL
		);