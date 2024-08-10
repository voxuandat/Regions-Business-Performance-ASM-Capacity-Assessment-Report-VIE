CREATE OR REPLACE PROCEDURE fact_funding_summary(
			    -- Tham số truyền vào là biến ngày
			    month_key_input int default NULL
				)
LANGUAGE plpgsql
AS $$
DECLARE 
		-- Bổ sung các biến 
		v_month_key int := month_key_input;
	    vstart_time timestamp;
       	vProcess_dt date;
BEGIN 
	    -- ---------------------
	    -- THÔNG TIN NGƯỜI TẠO
	    -- ---------------------
	    -- Tên người tạo: Võ Xuân Đạt
	    -- Ngày tạo: 
	    -- Mục đích : Tổng hợp các tiêu chí nguồn vốn và sử dụng vốn theo ngày
	
	    -- ---------------------
	    -- THÔNG TIN NGƯỜI CẬP NHẬT
	    -- ---------------------
	    -- Tên người cập nhật: 
	    -- Ngày cập nhật: 
	    -- Mục đích cập nhật: 
	
	    -- ---------------------
	    -- SUMMARY LUỒNG XỬ LÝ
	    -- ---------------------
	    -- Bước 1: xoá dữ liệu fact_summary_funding_daily tại ngày vProcess_dt
	    -- Bước 2: insert dữ liệu vào bảng "fact_funding_summary"
		-- Bước 3: insert vào bảng "BÁO CÁO TỔNG HỢP"
		-- Bước 4: insert vào bảng "BÁO CÁO XẾP HẠNG"
	    -- Bước 5: ghi log và xử lý ngoại lệ 
	    -- ---------------------
	    -- CHI TIẾT CÁC BƯỚC
	    -- ---------------------
vstart_time := now();
vProcess_dt := current_date;
-- Bước 1: xoá dữ liệu "fact_summary_funding_daily" và "BÁO CÁO TỔNG HỢP" tại  v_month_key
DELETE FROM fact_funding_summary WHERE month_key = v_month_key;
DELETE FROM "BÁO CÁO TỔNG HỢP" WHERE "Tháng báo cáo" = v_month_key;
-- Bước 2: insert dữ liệu vào bảng "fact_funding_summary"
	--1. Lãi trong hạn - funding_level: 3	
	--2. Lãi quá hạn - funding_level: 3
	--3. Phí Bảo hiểm - funding_level: 3
	--4. Phí tăng hạn mức - funding_level: 3
	--5. Phí thanh toán chậm, thu từ ngoại bảng, khác ... - funding_level: 3	
	--8. CP vốn TT 2 - funding_level: 3
	--9. CP vốn TT 1 - funding_level: 3
	--10. CP vốn CCTG - funding_level: 3
	--11. Chi phí thuần KDV  - funding_level: 2
	--12. DT Fintech - funding_level: 3
	--13. DT tiểu thương, cá nhân - funding_level: 3
	--14. DT Kinh doanh - funding_level: 3
	--15. CP hoa hồng - funding_level: 3
	--16. CP thuần KD khác - funding_level: 3
	--17. CP hợp tác kd tàu (net) - funding_level: 3
	--18. Chi phí thuần hoạt động khác - funding_level: 2	
	--19. Tổng thu nhập hoạt động - funding_level: 2
	--20. CP thuế, phí - funding_level: 3		
	--21. CP nhân viên - funding_level: 3
	--22. CP quản lý - funding_level: 3	
	--23. CP tài sản - funding_level: 3		
	--24. Tổng chi phí hoạt động - funding_level: 2
	--25. CP dự phòng - funding_level: 2
	--26. Lợi nhuận trước thuế - funding_level: 1
	--27. Số lượng nhân sự (Sales Manager) - funding_level: 1	
	--28. Chỉ số tài chính - funding_level: 1
	--29. CIR (%) - funding_level: 3
	--30. Margin (%) - funding_level: 3
	--31. Hiệu suất trên/vốn (%) - funding_level: 3
	--32. Hiệu suất BQ/ Nhân sự	- funding_level: 3
INSERT INTO fact_funding_summary(funding_id, month_key, area_code, total_amount)
--1. Lãi trong hạn - funding_level: 3			
SELECT 	
		10 AS funding_id,
		t1.month_key,
		t1.area_code,
		--amount_dvml,
		--amount_head,
		--avg_dnck_sau_wo,
		--avg_dnck_sau_wo_all,
		amount_dvml + (amount_head*avg_dnck_sau_wo/avg_dnck_sau_wo_all) total_amount
FROM
		--Lấy theo đầu kế toán với account_code thuộc : 702000030002, 702000030001,702000030102
		(
		SELECT 	
				--202302 AS month_key,
				v_month_key AS month_key,
				area_code,
				sum(amount) amount_dvml
		FROM fact_txn_month_raw_data ftmrd 
		LEFT JOIN dim_analysis_code dac ON ftmrd.analysis_code = dac.analysis_code 
		WHERE 	--to_char(transaction_date,'YYYYMM')::int <= 202302
				to_char(transaction_date,'YYYYMM')::int <= v_month_key
				AND account_code IN (702000030002, 702000030001,702000030102)
				AND dvml_head = 'DVML'
		GROUP BY area_code 	
		) t1
LEFT JOIN 
		--Tính avg_dnck_sau_wo từng area - nhóm 1
		(
		SELECT 	--202302 AS month_key,
				v_month_key AS month_key,
				area_code,
				avg(dnck_sau_wo) avg_dnck_sau_wo
		FROM
				(
				SELECT 	kpi_month,
						area_code,
						sum(outstanding_principal) dnck_sau_wo
				FROM fact_kpi_month_raw_data fkmrd 
				LEFT JOIN dim_analysis_code dac ON fkmrd.pos_cde = dac.pos_cde 
				WHERE 	--kpi_month <= 202302
						kpi_month <= v_month_key
						AND max_bucket = 1 
				GROUP BY 
						kpi_month,
						area_code 
				)
		GROUP BY area_code
		) t2 ON t1.month_key = t2.month_key AND t1.area_code = t2.area_code
LEFT JOIN 
		--Tính avg_dnck_sau_wo tất cả - nhóm 1
		(
		SELECT 	--202302 AS month_key,
				v_month_key AS month_key,
				avg(dnck_sau_wo) avg_dnck_sau_wo_all
		FROM
				(
				SELECT 	kpi_month,
						sum(outstanding_principal) dnck_sau_wo
				FROM fact_kpi_month_raw_data fkmrd 
				WHERE 	--kpi_month <= 202302
						kpi_month <= v_month_key
						AND max_bucket = 1 
				GROUP BY 
						kpi_month
				)
		) t3 ON t1.month_key = t3.month_key
LEFT JOIN
		--Tính sum amount đầu 'HEAD'
		(
		SELECT 
			--202302 AS month_key,
			v_month_key AS month_key,
			sum(amount) amount_head
		FROM fact_txn_month_raw_data ftmrd 
		WHERE account_code IN (702000030002, 702000030001,702000030102) 
			--AND to_char(transaction_date,'YYYYMM')::int <= 202302 
			AND to_char(transaction_date,'YYYYMM')::int <= v_month_key
			AND	analysis_code LIKE 'HEAD%'
		) t4 ON t1.month_key = t4.month_key
UNION ALL 
SELECT 
	10 AS funding_id,
	--202302 AS month_key,
	v_month_key AS month_key,
	'A' AS area_code,
	sum(amount) amount_head
FROM fact_txn_month_raw_data ftmrd 
WHERE account_code IN (702000030002, 702000030001,702000030102) 
	--AND to_char(transaction_date,'YYYYMM')::int <= 202302 
	AND to_char(transaction_date,'YYYYMM')::int <= v_month_key
	AND	analysis_code LIKE 'HEAD%'
UNION ALL 
--2. Lãi quá hạn - funding_level: 3	
SELECT 	
		11 AS funding_id,
		t1.month_key,
		t1.area_code,
		--amount_dvml,
		--amount_head,
		--avg_dnck_sau_wo,
		--avg_dnck_sau_wo_all,
		amount_dvml + (amount_head*avg_dnck_sau_wo/avg_dnck_sau_wo_all) total_amount
FROM
		--Lấy theo đầu kế toán với account_code thuộc : 702000030012, 702000030112
		(
		SELECT 	
				--202302 AS month_key,
				v_month_key AS month_key,
				area_code,
				sum(amount) amount_dvml
		FROM fact_txn_month_raw_data ftmrd 
		LEFT JOIN dim_analysis_code dac ON ftmrd.analysis_code = dac.analysis_code 
		WHERE 	--to_char(transaction_date,'YYYYMM')::int <= 202302
				to_char(transaction_date,'YYYYMM')::int <= v_month_key
				AND account_code IN (702000030012, 702000030112)
				AND dvml_head = 'DVML'
		GROUP BY area_code 	
		) t1
LEFT JOIN 
		--Tính avg_dnck_sau_wo từng area - nhóm 2
		(
		SELECT 	--202302 AS month_key,
				v_month_key AS month_key,
				area_code,
				avg(dnck_sau_wo) avg_dnck_sau_wo
		FROM
				(
				SELECT 	kpi_month,
						area_code,
						sum(outstanding_principal) dnck_sau_wo
				FROM fact_kpi_month_raw_data fkmrd 
				LEFT JOIN dim_analysis_code dac ON fkmrd.pos_cde = dac.pos_cde 
				WHERE 	--kpi_month <= 202302
						kpi_month <= v_month_key
						AND max_bucket = 2 
				GROUP BY 
						kpi_month,
						area_code 
				)
		GROUP BY area_code
		) t2 ON t1.month_key = t2.month_key AND t1.area_code = t2.area_code
LEFT JOIN 
		--Tính avg_dnck_sau_wo tất cả - nhóm 2
		(
		SELECT 	--202302 AS month_key,
				v_month_key AS month_key,
				avg(dnck_sau_wo) avg_dnck_sau_wo_all
		FROM
				(
				SELECT 	kpi_month,
						sum(outstanding_principal) dnck_sau_wo
				FROM fact_kpi_month_raw_data fkmrd 
				WHERE 	--kpi_month <= 202302
						kpi_month <= v_month_key
						AND max_bucket = 2 
				GROUP BY 
						kpi_month
				)
		) t3 ON t1.month_key = t3.month_key
LEFT JOIN
		--Tính sum amount đầu 'HEAD'
		(
		SELECT 
		--202302 AS month_key,
		v_month_key AS month_key,
		sum(amount) amount_head
		FROM fact_txn_month_raw_data ftmrd 
		WHERE account_code IN (702000030012, 702000030112)
			--AND to_char(transaction_date,'YYYYMM')::int <= 202302
			AND to_char(transaction_date,'YYYYMM')::int <= v_month_key
			AND analysis_code LIKE 'HEAD%'
		) t4 ON t1.month_key = t4.month_key
UNION ALL
SELECT 
	11 AS funding_id,
	--202302 AS month_key,
	v_month_key AS month_key,
	'A' AS area_code,
	sum(amount) amount_head
FROM fact_txn_month_raw_data ftmrd 
WHERE account_code IN (702000030012, 702000030112) 
	--AND to_char(transaction_date,'YYYYMM')::int <= 202302 
	AND to_char(transaction_date,'YYYYMM')::int <= v_month_key
	AND	analysis_code LIKE 'HEAD%'
UNION ALL 
--3.  Phí Bảo hiểm - funding_level: 3
SELECT 	
		12 AS funding_id,
		t1.month_key,
		t1.area_code,
		--amount_dvml,
		--psdn,
		amount_dvml + (amount_head*psdn/total_psdn) total_amount
FROM
		--Lấy theo đầu kế toán với account_code thuộc : 716000000001
		(
		SELECT 	
				--202302 AS month_key,
				v_month_key AS month_key,
				area_code,
				sum(amount) amount_dvml
		FROM fact_txn_month_raw_data ftmrd 
		LEFT JOIN dim_analysis_code dac ON ftmrd.analysis_code = dac.analysis_code 
		WHERE 	--to_char(transaction_date,'YYYYMM')::int <= 202302
				to_char(transaction_date,'YYYYMM')::int <= v_month_key
				AND account_code = '716000000001'
				AND dvml_head = 'DVML'
		GROUP BY area_code 	
		) t1
LEFT JOIN 	
		--Tính sum psdn theo từng khu vực
		(
		SELECT 
				--202302 AS month_key,
				v_month_key AS month_key,
				area_code,
				sum(psdn) psdn
		FROM fact_kpi_month_raw_data fkmrd 
		LEFT JOIN dim_analysis_code dac ON fkmrd.pos_cde = dac.pos_cde
		WHERE 
				--kpi_month <= 202302
				kpi_month <= v_month_key
		GROUP BY area_code	
		) t2 ON t1.month_key = t2.month_key AND t1.area_code = t2.area_code
LEFT JOIN 	
		(
		SELECT 
				--202302 AS month_key,
				v_month_key AS month_key,
				sum(psdn) total_psdn
		FROM fact_kpi_month_raw_data fkmrd 
		WHERE 
				--kpi_month <= 202302
				kpi_month <= v_month_key
		) t3 ON t1.month_key = t3.month_key 
LEFT JOIN
		(
		SELECT 
				--202302 AS month_key,
				v_month_key AS month_key,
				sum(amount) amount_head
		FROM fact_txn_month_raw_data ftmrd 
		WHERE account_code = 716000000001
				--AND to_char(transaction_date,'YYYYMM')::int <= 202302
				AND to_char(transaction_date,'YYYYMM')::int <= v_month_key
				AND analysis_code LIKE 'HEAD%'
		) t4 ON t1.month_key = t4.month_key
UNION ALL 
SELECT 
	12 AS funding_id,
	--202302 AS month_key,
	v_month_key AS month_key,
	'A' AS area_code,
	sum(amount) amount_head
FROM fact_txn_month_raw_data ftmrd 
WHERE account_code = 716000000001 
	--AND to_char(transaction_date,'YYYYMM')::int <= 202302 
	AND to_char(transaction_date,'YYYYMM')::int <= v_month_key
	AND	analysis_code LIKE 'HEAD%'
UNION ALL 
--4. Phí tăng hạn mức - funding_level: 3				
SELECT 	
		13 AS funding_id,
		t1.month_key,
		t1.area_code,
		--amount_dvml,
		--amount_head,
		--avg_dnck_sau_wo,
		--avg_dnck_sau_wo_all,
		amount_dvml + (amount_head*avg_dnck_sau_wo/avg_dnck_sau_wo_all) total_amount
FROM
		--Lấy theo đầu kế toán với account_code thuộc : 719000030002
		(
		SELECT 	
				--202302 AS month_key,
				v_month_key AS month_key,
				area_code,
				sum(amount) amount_dvml
		FROM fact_txn_month_raw_data ftmrd 
		LEFT JOIN dim_analysis_code dac ON ftmrd.analysis_code = dac.analysis_code 
		WHERE 	--to_char(transaction_date,'YYYYMM')::int <= 202302
				to_char(transaction_date,'YYYYMM')::int <= v_month_key
				AND account_code = 719000030002
				AND dvml_head = 'DVML'
		GROUP BY area_code 	
		) t1
LEFT JOIN 
		--Tính avg_dnck_sau_wo từng area - nhóm 1
		(
		SELECT 	--202302 AS month_key,
				v_month_key AS month_key,
				area_code,
				avg(dnck_sau_wo) avg_dnck_sau_wo
		FROM
				(
				SELECT 	kpi_month,
						area_code,
						sum(outstanding_principal) dnck_sau_wo
				FROM fact_kpi_month_raw_data fkmrd 
				LEFT JOIN dim_analysis_code dac ON fkmrd.pos_cde = dac.pos_cde 
				WHERE 	--kpi_month <= 202302
						kpi_month <= v_month_key
						AND max_bucket = 1 
				GROUP BY 
						kpi_month,
						area_code 
				)
		GROUP BY area_code
		) t2 ON t1.month_key = t2.month_key AND t1.area_code = t2.area_code
LEFT JOIN 
		--Tính avg_dnck_sau_wo tất cả - nhóm 1
		(
		SELECT 	--202302 AS month_key,
				v_month_key AS month_key,
				avg(dnck_sau_wo) avg_dnck_sau_wo_all
		FROM
				(
				SELECT 	kpi_month,
						sum(outstanding_principal) dnck_sau_wo
				FROM fact_kpi_month_raw_data fkmrd 
				WHERE 	--kpi_month <= 202302
						kpi_month <= v_month_key
						AND max_bucket = 1 
				GROUP BY 
						kpi_month
				)
		) t3 ON t1.month_key = t3.month_key
LEFT JOIN
		--Tính sum amount đầu 'HEAD'
		(
		SELECT 
		--202302 AS month_key,
		v_month_key AS month_key,
		sum(amount) amount_head
		FROM fact_txn_month_raw_data ftmrd 
		WHERE account_code = 719000030002 AND
			--to_char(transaction_date,'YYYYMM')::int <= 202302 AND
			to_char(transaction_date,'YYYYMM')::int <= v_month_key AND
			analysis_code LIKE 'HEAD%'
		) t4 ON t1.month_key = t4.month_key
UNION ALL 
SELECT 
	13 AS funding_id,
	--202302 AS month_key,
	v_month_key AS month_key,
	'A' AS area_code,
	sum(amount) amount_head
FROM fact_txn_month_raw_data ftmrd 
WHERE account_code = 719000030002
	--AND to_char(transaction_date,'YYYYMM')::int <= 202302 
	AND to_char(transaction_date,'YYYYMM')::int <= v_month_key
	AND	analysis_code LIKE 'HEAD%'
UNION ALL 
--5. Phí thanh toán chậm, thu từ ngoại bảng, khác ... - funding_level: 3				
SELECT 	
		14 AS funding_id,
		t1.month_key,
		t1.area_code,
		--amount_dvml,
		--amount_head,
		--avg_dnck_sau_wo,
		--avg_dnck_sau_wo_all,
		amount_dvml + (amount_head*avg_dnck_sau_wo/avg_dnck_sau_wo_all) total_amount
FROM
		--Lấy theo đầu kế toán với account_code thuộc : 719000030003,719000030103,790000030003,790000030103,790000030004,790000030104
		(
		SELECT 	
				--202302 AS month_key,
				v_month_key AS month_key,
				area_code,
				sum(amount) amount_dvml
		FROM fact_txn_month_raw_data ftmrd 
		LEFT JOIN dim_analysis_code dac ON ftmrd.analysis_code = dac.analysis_code 
		WHERE 	--to_char(transaction_date,'YYYYMM')::int <= 202302
				to_char(transaction_date,'YYYYMM')::int <= v_month_key
				AND account_code IN (719000030003,719000030103,790000030003,790000030103,790000030004,790000030104)
				AND dvml_head = 'DVML'
		GROUP BY area_code 	
		) t1
LEFT JOIN 
		--Tính avg_dnck_sau_wo từng area - nhóm 2-5
		(
		SELECT 	--202302 AS month_key,
				v_month_key AS month_key,
				area_code,
				avg(dnck_sau_wo) avg_dnck_sau_wo
		FROM
				(
				SELECT 	kpi_month,
						area_code,
						sum(outstanding_principal) dnck_sau_wo
				FROM fact_kpi_month_raw_data fkmrd 
				LEFT JOIN dim_analysis_code dac ON fkmrd.pos_cde = dac.pos_cde 
				WHERE 	--kpi_month <= 202302
						kpi_month <= v_month_key
						AND max_bucket BETWEEN 2 AND 5
				GROUP BY 
						kpi_month,
						area_code 
				)
		GROUP BY area_code
		) t2 ON t1.month_key = t2.month_key AND t1.area_code = t2.area_code
LEFT JOIN 
		--Tính avg_dnck_sau_wo tất cả - nhóm 2-5
		(
		SELECT 	--202302 AS month_key,
				v_month_key AS month_key,
				avg(dnck_sau_wo) avg_dnck_sau_wo_all
		FROM
				(
				SELECT 	kpi_month,
						sum(outstanding_principal) dnck_sau_wo
				FROM fact_kpi_month_raw_data fkmrd 
				WHERE 	--kpi_month <= 202302
						kpi_month <= v_month_key
						AND max_bucket BETWEEN 2 AND 5
				GROUP BY 
						kpi_month
				)
		) t3 ON t1.month_key = t3.month_key
LEFT JOIN
		--Tính sum amount đầu 'HEAD'
		(
		SELECT 
		--202302 AS month_key,
		v_month_key AS month_key,
		sum(amount) amount_head
		FROM fact_txn_month_raw_data ftmrd 
		WHERE account_code IN (719000030003,719000030103,790000030003,790000030103,790000030004,790000030104) AND
			--to_char(transaction_date,'YYYYMM')::int <= 202302 AND 
			to_char(transaction_date,'YYYYMM')::int <= v_month_key AND
			analysis_code LIKE 'HEAD%'
		) t4 ON t1.month_key = t4.month_key
UNION ALL 
SELECT 
		14 AS funding_id,
		--202302 AS month_key,
		v_month_key AS month_key,
		'A' AS area_code,
		sum(amount) amount_head
FROM fact_txn_month_raw_data ftmrd 
WHERE account_code IN (719000030003,719000030103,790000030003,790000030103,790000030004,790000030104)
	--AND to_char(transaction_date,'YYYYMM')::int <= 202302 
	AND to_char(transaction_date,'YYYYMM')::int <= v_month_key
	AND	analysis_code LIKE 'HEAD%';	
INSERT INTO fact_funding_summary(funding_id, month_key, area_code, total_amount)	
--6. Thu nhập từ hoạt động thẻ - funding_level: 2
SELECT 
		4 AS funding_id,
		month_key,
		area_code,
		sum(total_amount) total_amount
FROM fact_funding_summary ffs 
WHERE 	--month_key = 202302
		month_key = v_month_key 
		AND funding_id BETWEEN 10 AND 14
GROUP BY 	area_code,
			month_key;
INSERT INTO fact_funding_summary(funding_id, month_key, area_code, total_amount)
--7. DT Nguồn vốn - funding_level: 3	
SELECT 
		15 AS funding_id,
		v_month_key AS month_key,
		--202302 AS month_key,
		area_code,
		0 AS total_amount
FROM 	dim_area_code dac 	
UNION ALL 
--8. CP vốn TT 2 - funding_level: 3
SELECT 	
		16 AS funding_id,
		t1.month_key,
		t1.area_code,
		amount_head*t1.total_amount/t3.total_amount total_amount
FROM
		(
		SELECT *
		FROM 
			fact_funding_summary ffs
		WHERE funding_id = 4 AND month_key = v_month_key
		) t1
LEFT JOIN 		
		--Lấy theo đầu kế toán với account_code thuộc : 801000000001, 802000000001
		(
		SELECT 	
				--202302 AS month_key,
				v_month_key AS month_key,
				sum(amount) amount_head
		FROM fact_txn_month_raw_data ftmrd 
		WHERE 	--to_char(transaction_date,'YYYYMM')::int <= 202302
				to_char(transaction_date,'YYYYMM')::int <= v_month_key
				AND account_code IN (801000000001, 802000000001)
		) t2 ON t1.month_key = t2.month_key 
LEFT JOIN  
		(
		SELECT 	
				--202302 AS month_key,
				v_month_key AS month_key,
				sum(total_amount) total_amount
		FROM fact_funding_summary ffs 
		WHERE funding_id = 4 AND month_key = v_month_key
		) t3 ON t1.month_key = t3.month_key
UNION ALL 
--9. CP vốn TT 1 - funding_level: 3
SELECT 
		17 AS funding_id,
		v_month_key AS month_key,
		--202302 AS month_key,
		area_code,
		0 AS total_amount
FROM 	dim_area_code dac 
UNION ALL
--10. CP vốn CCTG - funding_level: 3
SELECT 	
		18 AS funding_id,
		t1.month_key,
		t1.area_code,
		amount_head*t1.total_amount/t3.total_amount total_amount
FROM
		(
		SELECT *
		FROM 
			fact_funding_summary ffs
		WHERE funding_id = 4 AND month_key = v_month_key
		) t1
LEFT JOIN 		
		--Lấy theo đầu kế toán với account_code thuộc : 803000000001
		(
		SELECT 	
				--202302 AS month_key,
				v_month_key AS month_key,
				sum(amount) amount_head
		FROM fact_txn_month_raw_data ftmrd 
		WHERE 	--to_char(transaction_date,'YYYYMM')::int <= 202302
				to_char(transaction_date,'YYYYMM')::int <= v_month_key
				AND account_code = 803000000001
		) t2 ON t1.month_key = t2.month_key 
LEFT JOIN  
		(
		SELECT 	
				--202302 AS month_key,
				v_month_key AS month_key,
				sum(total_amount) total_amount
		FROM fact_funding_summary ffs 
		WHERE funding_id = 4 AND month_key = v_month_key
		) t3 ON t1.month_key = t3.month_key;
INSERT INTO fact_funding_summary(funding_id, month_key, area_code, total_amount)	
--11.  Chi phí thuần KDV  - funding_level: 2
SELECT 
		5 AS funding_id,
		month_key,
		area_code,
		sum(total_amount) total_amount
FROM fact_funding_summary ffs 
WHERE 	--month_key = 202302
		month_key = v_month_key 
		AND funding_id IN (15,16,17,18)
GROUP BY 	area_code,
			month_key;
INSERT INTO fact_funding_summary(funding_id, month_key, area_code, total_amount)
--12.  DT Fintech - funding_level: 3			
SELECT 
		19 AS funding_id,
		v_month_key AS month_key,
		--202302 AS month_key,
		area_code,
		0 AS total_amount
FROM 	dim_area_code dac 
UNION ALL
--13.   DT tiểu thương, cá nhân - funding_level: 3
SELECT 
		20 AS funding_id,
		v_month_key AS month_key,
		--202302 AS month_key,
		area_code,
		0 AS total_amount
FROM 	dim_area_code dac 
UNION ALL 
--14.    DT Kinh doanh - funding_level: 3
SELECT 	
		21 AS funding_id,
		t1.month_key,
		t1.area_code,
		--amount_dvml,
		--amount_head,
		--avg_dnck_sau_wo,
		--avg_dnck_sau_wo_all,
		amount_dvml + (amount_head*avg_dnck_sau_wo/avg_dnck_sau_wo_all) total_amount
FROM
		--Lấy theo đầu kế toán với account_code thuộc : 702000010001,702000010002,704000000001,705000000001,709000000001,714000000002,714000000003,714037000001,714000000004,714014000001,715000000001,715037000001,719000000001,709000000101,719000000101
		(
		SELECT 	
				--202302 AS month_key,
				v_month_key AS month_key,
				area_code,
				sum(amount) amount_dvml
		FROM fact_txn_month_raw_data ftmrd 
		LEFT JOIN dim_analysis_code dac ON ftmrd.analysis_code = dac.analysis_code 
		WHERE 	--to_char(transaction_date,'YYYYMM')::int <= 202302
				to_char(transaction_date,'YYYYMM')::int <= v_month_key
				AND account_code IN (702000010001,702000010002,704000000001,705000000001,709000000001,714000000002,714000000003,714037000001,714000000004,714014000001,715000000001,715037000001,719000000001,709000000101,719000000101)
				AND dvml_head = 'DVML'
		GROUP BY area_code 	
		) t1
LEFT JOIN 
		--Tính avg_dnck_sau_wo từng area 
		(
		SELECT 	--202302 AS month_key,
				v_month_key AS month_key,
				area_code,
				avg(dnck_sau_wo) avg_dnck_sau_wo
		FROM
				(
				SELECT 	kpi_month,
						area_code,
						sum(outstanding_principal) dnck_sau_wo
				FROM fact_kpi_month_raw_data fkmrd 
				LEFT JOIN dim_analysis_code dac ON fkmrd.pos_cde = dac.pos_cde 
				WHERE 	--kpi_month <= 202302
						kpi_month <= v_month_key
				GROUP BY 
						kpi_month,
						area_code 
				)
		GROUP BY area_code
		) t2 ON t1.month_key = t2.month_key AND t1.area_code = t2.area_code
LEFT JOIN 
		--Tính avg_dnck_sau_wo tất cả 
		(
		SELECT 	--202302 AS month_key,
				v_month_key AS month_key,
				avg(dnck_sau_wo) avg_dnck_sau_wo_all
		FROM
				(
				SELECT 	kpi_month,
						sum(outstanding_principal) dnck_sau_wo
				FROM fact_kpi_month_raw_data fkmrd 
				WHERE 	--kpi_month <= 202302
						kpi_month <= v_month_key
				GROUP BY 
						kpi_month
				)
		) t3 ON t1.month_key = t3.month_key
LEFT JOIN
		--Tính sum amount đầu 'HEAD'
		(
		SELECT 
		--202302 AS month_key,
		v_month_key AS month_key,
		sum(amount) amount_head
		FROM fact_txn_month_raw_data ftmrd 
		WHERE account_code IN (702000010001,702000010002,704000000001,705000000001,709000000001,714000000002,714000000003,714037000001,714000000004,714014000001,715000000001,715037000001,719000000001,709000000101,719000000101)
			--AND to_char(transaction_date,'YYYYMM')::int <= 202302 
			AND to_char(transaction_date,'YYYYMM')::int <= v_month_key
			AND	analysis_code LIKE 'HEAD%'
		) t4 ON t1.month_key = t4.month_key
UNION ALL
SELECT 
	21 AS funding_id,
	--202302 AS month_key,
	v_month_key AS month_key,
	'A' AS area_code,
	sum(amount) amount_head
FROM fact_txn_month_raw_data ftmrd 
WHERE account_code IN (702000010001,702000010002,704000000001,705000000001,709000000001,714000000002,714000000003,714037000001,714000000004,714014000001,715000000001,715037000001,719000000001,709000000101,719000000101) 
	--AND to_char(transaction_date,'YYYYMM')::int <= 202302 
	AND to_char(transaction_date,'YYYYMM')::int <= v_month_key
	AND	analysis_code LIKE 'HEAD%'
UNION ALL
--15.     CP hoa hồng - funding_level: 3
SELECT 	
		22 AS funding_id,
		t1.month_key,
		t1.area_code,
		--amount_dvml,
		--amount_head,
		--avg_dnck_sau_wo,
		--avg_dnck_sau_wo_all,
		amount_dvml + (amount_head*avg_dnck_sau_wo/avg_dnck_sau_wo_all) total_amount
FROM
		--Lấy theo đầu kế toán với account_code thuộc : 816000000001,816000000002,816000000003
		(
		SELECT 	
				--202302 AS month_key,
				v_month_key AS month_key,
				area_code,
				sum(amount) amount_dvml
		FROM fact_txn_month_raw_data ftmrd 
		LEFT JOIN dim_analysis_code dac ON ftmrd.analysis_code = dac.analysis_code 
		WHERE 	--to_char(transaction_date,'YYYYMM')::int <= 202302
				to_char(transaction_date,'YYYYMM')::int <= v_month_key
				AND account_code IN (816000000001,816000000002,816000000003)
				AND dvml_head = 'DVML'
		GROUP BY area_code 	
		) t1
LEFT JOIN 
		--Tính avg_dnck_sau_wo từng area 
		(
		SELECT 	--202302 AS month_key,
				v_month_key AS month_key,
				area_code,
				avg(dnck_sau_wo) avg_dnck_sau_wo
		FROM
				(
				SELECT 	kpi_month,
						area_code,
						sum(outstanding_principal) dnck_sau_wo
				FROM fact_kpi_month_raw_data fkmrd 
				LEFT JOIN dim_analysis_code dac ON fkmrd.pos_cde = dac.pos_cde 
				WHERE 	--kpi_month <= 202302
						kpi_month <= v_month_key
				GROUP BY 
						kpi_month,
						area_code 
				)
		GROUP BY area_code
		) t2 ON t1.month_key = t2.month_key AND t1.area_code = t2.area_code
LEFT JOIN 
		--Tính avg_dnck_sau_wo tất cả 
		(
		SELECT 	--202302 AS month_key,
				v_month_key AS month_key,
				avg(dnck_sau_wo) avg_dnck_sau_wo_all
		FROM
				(
				SELECT 	kpi_month,
						sum(outstanding_principal) dnck_sau_wo
				FROM fact_kpi_month_raw_data fkmrd 
				WHERE 	--kpi_month <= 202302
						kpi_month <= v_month_key
				GROUP BY 
						kpi_month
				)
		) t3 ON t1.month_key = t3.month_key
LEFT JOIN
		--Tính sum amount đầu 'HEAD'
		(
		SELECT 
		--202302 AS month_key,
		v_month_key AS month_key,
		sum(amount) amount_head
		FROM fact_txn_month_raw_data ftmrd 
		WHERE account_code IN (816000000001,816000000002,816000000003)
			--AND to_char(transaction_date,'YYYYMM')::int <= 202302 
			AND to_char(transaction_date,'YYYYMM')::int <= v_month_key
			AND	analysis_code LIKE 'HEAD%'
		) t4 ON t1.month_key = t4.month_key
UNION ALL
SELECT 
	22 AS funding_id,
	--202302 AS month_key,
	v_month_key AS month_key,
	'A' AS area_code,
	sum(amount) amount_head
FROM fact_txn_month_raw_data ftmrd 
WHERE account_code IN (816000000001,816000000002,816000000003) 
	--AND to_char(transaction_date,'YYYYMM')::int <= 202302 
	AND to_char(transaction_date,'YYYYMM')::int <= v_month_key
	AND	analysis_code LIKE 'HEAD%'
UNION ALL 	
--16.     CP thuần KD khác - funding_level: 3
SELECT 	
		23 AS funding_id,
		t1.month_key,
		t1.area_code,
		--amount_dvml,
		--amount_head,
		--avg_dnck_sau_wo,
		--avg_dnck_sau_wo_all,
		amount_dvml + (amount_head*avg_dnck_sau_wo/avg_dnck_sau_wo_all) total_amount
FROM
		--Lấy theo đầu kế toán với account_code thuộc : 809000000002,809000000001,811000000001,811000000102,811000000002,811014000001,
		--811037000001,811039000001,811041000001,815000000001,819000000002,819000000003,819000000001,790000000003,790000050101,
		--790000000101,790037000001,849000000001,899000000003,899000000002,811000000101,819000060001
		(
		SELECT 	
				--202302 AS month_key,
				v_month_key AS month_key,
				area_code,
				sum(amount) amount_dvml
		FROM fact_txn_month_raw_data ftmrd 
		LEFT JOIN dim_analysis_code dac ON ftmrd.analysis_code = dac.analysis_code 
		WHERE 	--to_char(transaction_date,'YYYYMM')::int <= 202302
				to_char(transaction_date,'YYYYMM')::int <= v_month_key
				AND account_code IN (809000000002,809000000001,811000000001,811000000102,811000000002,811014000001,811037000001,
									811039000001,811041000001,815000000001,819000000002,819000000003,819000000001,790000000003,
									790000050101,790000000101,790037000001,849000000001,899000000003,899000000002,811000000101,
									819000060001)
				AND dvml_head = 'DVML'
		GROUP BY area_code 	
		) t1
LEFT JOIN 
		--Tính avg_dnck_sau_wo từng area 
		(
		SELECT 	--202302 AS month_key,
				v_month_key AS month_key,
				area_code,
				avg(dnck_sau_wo) avg_dnck_sau_wo
		FROM
				(
				SELECT 	kpi_month,
						area_code,
						sum(outstanding_principal) dnck_sau_wo
				FROM fact_kpi_month_raw_data fkmrd 
				LEFT JOIN dim_analysis_code dac ON fkmrd.pos_cde = dac.pos_cde 
				WHERE 	--kpi_month <= 202302
						kpi_month <= v_month_key
				GROUP BY 
						kpi_month,
						area_code 
				)
		GROUP BY area_code
		) t2 ON t1.month_key = t2.month_key AND t1.area_code = t2.area_code
LEFT JOIN 
		--Tính avg_dnck_sau_wo tất cả 
		(
		SELECT 	--202302 AS month_key,
				v_month_key AS month_key,
				avg(dnck_sau_wo) avg_dnck_sau_wo_all
		FROM
				(
				SELECT 	kpi_month,
						sum(outstanding_principal) dnck_sau_wo
				FROM fact_kpi_month_raw_data fkmrd 
				WHERE 	--kpi_month <= 202302
						kpi_month <= v_month_key
				GROUP BY 
						kpi_month
				)
		) t3 ON t1.month_key = t3.month_key
LEFT JOIN
		--Tính sum amount đầu 'HEAD'
		(
		SELECT 
		--202302 AS month_key,
		v_month_key AS month_key,
		sum(amount) amount_head
		FROM fact_txn_month_raw_data ftmrd 
		WHERE account_code IN (809000000002,809000000001,811000000001,811000000102,811000000002,811014000001,811037000001,811039000001,
								811041000001,815000000001,819000000002,819000000003,819000000001,790000000003,790000050101,790000000101,
								790037000001,849000000001,899000000003,899000000002,811000000101,819000060001)
			--AND to_char(transaction_date,'YYYYMM')::int <= 202302 
			AND to_char(transaction_date,'YYYYMM')::int <= v_month_key
			AND	analysis_code LIKE 'HEAD%'
		) t4 ON t1.month_key = t4.month_key
UNION ALL
SELECT 
	23 AS funding_id,
	--202302 AS month_key,
	v_month_key AS month_key,
	'A' AS area_code,
	sum(amount) amount_head
FROM fact_txn_month_raw_data ftmrd 
WHERE account_code IN (809000000002,809000000001,811000000001,811000000102,811000000002,811014000001,811037000001,811039000001,
								811041000001,815000000001,819000000002,819000000003,819000000001,790000000003,790000050101,790000000101,
								790037000001,849000000001,899000000003,899000000002,811000000101,819000060001) 
	--AND to_char(transaction_date,'YYYYMM')::int <= 202302 
	AND to_char(transaction_date,'YYYYMM')::int <= v_month_key
	AND	analysis_code LIKE 'HEAD%'
UNION ALL
--17. CP hợp tác kd tàu (net) - funding_level: 3
SELECT 
		24 AS funding_id,
		v_month_key AS month_key,
		--202302 AS month_key,
		area_code,
		0 AS total_amount
FROM 	dim_area_code dac 
;
INSERT INTO fact_funding_summary(funding_id, month_key, area_code, total_amount)
--18.  Chi phí thuần hoạt động khác - funding_level: 2		
SELECT 
		6 AS funding_id,
		month_key,
		area_code,
		sum(total_amount) total_amount
FROM fact_funding_summary ffs 
WHERE 	--month_key = 202302
		month_key = v_month_key 
		AND funding_id BETWEEN 19 AND 24
GROUP BY 	area_code,
			month_key;
INSERT INTO fact_funding_summary(funding_id, month_key, area_code, total_amount)		
--19. Tổng thu nhập hoạt động - funding_level: 2
SELECT 
		7 AS funding_id,
		month_key,
		area_code,
		sum(total_amount) total_amount
FROM fact_funding_summary ffs 
WHERE 	--month_key = 202302
		month_key = v_month_key 
		AND funding_id BETWEEN 4 AND 6
GROUP BY 	area_code,
			month_key;
INSERT INTO fact_funding_summary(funding_id, month_key, area_code, total_amount)	
--20. CP thuế, phí - funding_level: 3	
SELECT 
		25 AS funding_id,
		v_month_key AS month_key,
		--202302 AS month_key,
		area_code,
		0 AS total_amount
FROM 	dim_area_code dac;
INSERT INTO fact_funding_summary(funding_id, month_key, area_code, total_amount)
--21. CP nhân viên - funding_level: 3	
SELECT 	
		26 AS funding_id,
		t1.month_key,
		t1.area_code,
		--amount_dvml,
		--area_sm_number,
		--total_sm_number,
		amount_dvml + (amount_head*area_sm_number/total_sm_number) total_amount
FROM
		--Lấy theo đầu kế toán với account_code thuộc : 85x
		(
		SELECT 	
				--202302 AS month_key,
				v_month_key AS month_key,
				area_code,
				sum(amount) amount_dvml
		FROM fact_txn_month_raw_data ftmrd
		LEFT JOIN dim_analysis_code dac ON ftmrd.analysis_code = dac.analysis_code 
		WHERE 	--to_char(transaction_date,'YYYYMM')::int <= 202302
				to_char(transaction_date,'YYYYMM')::int <= v_month_key
				AND account_code::varchar LIKE '85%'
				AND dvml_head = 'DVML'
		GROUP BY area_code 	
		) t1
LEFT JOIN 
		--Tính sm_number từng area 
		(
		SELECT 	--202302 AS month_key,
				v_month_key AS month_key,
				area_code,
				count(*) area_sm_number
		FROM
				kpi_asm_data kad
		LEFT JOIN dim_area_code dac ON kad.area_name = dac.area_name
		GROUP BY area_code
		) t2 ON t1.month_key = t2.month_key AND t1.area_code = t2.area_code
LEFT JOIN 
		--Tính sm_number tất cả 
		(
		SELECT 	--202302 AS month_key,
				v_month_key AS month_key,
				count(*) total_sm_number
		FROM
				kpi_asm_data kad
		LEFT JOIN dim_area_code dac ON kad.area_name = dac.area_name
		) t3 ON t1.month_key = t3.month_key
LEFT JOIN
		--Tính sum amount đầu 'HEAD'
		(
		SELECT 
		--202302 AS month_key,
		v_month_key AS month_key,
		sum(amount) amount_head
		FROM fact_txn_month_raw_data ftmrd 
		WHERE account_code::varchar LIKE '85%'
			--AND to_char(transaction_date,'YYYYMM')::int <= 202302 
			AND to_char(transaction_date,'YYYYMM')::int <= v_month_key
			AND	analysis_code LIKE 'HEAD%'
		) t4 ON t1.month_key = t4.month_key
UNION ALL
SELECT 
	26 AS funding_id,
	--202302 AS month_key,
	v_month_key AS month_key,
	'A' AS area_code,
	sum(amount) amount_head
FROM fact_txn_month_raw_data ftmrd 
WHERE account_code::varchar LIKE '85%' 
	--AND to_char(transaction_date,'YYYYMM')::int <= 202302 
	AND to_char(transaction_date,'YYYYMM')::int <= v_month_key
	AND	analysis_code LIKE 'HEAD%'
UNION ALL
--22. CP quản lý - funding_level: 3	
SELECT 	
		27 AS funding_id,
		t1.month_key,
		t1.area_code,
		--amount_dvml,
		--area_sm_number,
		--total_sm_number,
		amount_dvml + (amount_head*area_sm_number/total_sm_number) total_amount
FROM
		--Lấy theo đầu kế toán với account_code thuộc : 86x
		(
		SELECT 	
				--202302 AS month_key,
				v_month_key AS month_key,
				area_code,
				sum(amount) amount_dvml
		FROM fact_txn_month_raw_data ftmrd
		LEFT JOIN dim_analysis_code dac ON ftmrd.analysis_code = dac.analysis_code 
		WHERE 	--to_char(transaction_date,'YYYYMM')::int <= 202302
				to_char(transaction_date,'YYYYMM')::int <= v_month_key
				AND account_code::varchar LIKE '86%'
				AND dvml_head = 'DVML'
		GROUP BY area_code 	
		) t1
LEFT JOIN 
		--Tính sm_number từng area 
		(
		SELECT 	--202302 AS month_key,
				v_month_key AS month_key,
				area_code,
				count(*) area_sm_number
		FROM
				kpi_asm_data kad
		LEFT JOIN dim_area_code dac ON kad.area_name = dac.area_name
		GROUP BY area_code
		) t2 ON t1.month_key = t2.month_key AND t1.area_code = t2.area_code
LEFT JOIN 
		--Tính sm_number tất cả 
		(
		SELECT 	--202302 AS month_key,
				v_month_key AS month_key,
				count(*) total_sm_number
		FROM
				kpi_asm_data kad
		LEFT JOIN dim_area_code dac ON kad.area_name = dac.area_name
		) t3 ON t1.month_key = t3.month_key
LEFT JOIN
		--Tính sum amount đầu 'HEAD'
		(
		SELECT 
		--202302 AS month_key,
		v_month_key AS month_key,
		sum(amount) amount_head
		FROM fact_txn_month_raw_data ftmrd 
		WHERE account_code::varchar LIKE '86%'
			--AND to_char(transaction_date,'YYYYMM')::int <= 202302 
			AND to_char(transaction_date,'YYYYMM')::int <= v_month_key
			AND	analysis_code LIKE 'HEAD%'
		) t4 ON t1.month_key = t4.month_key
UNION ALL
SELECT 
	27 AS funding_id,
	--202302 AS month_key,
	v_month_key AS month_key,
	'A' AS area_code,
	sum(amount) amount_head
FROM fact_txn_month_raw_data ftmrd 
WHERE account_code::varchar LIKE '86%' 
	--AND to_char(transaction_date,'YYYYMM')::int <= 202302 
	AND to_char(transaction_date,'YYYYMM')::int <= v_month_key
	AND	analysis_code LIKE 'HEAD%'
UNION ALL
--23. CP tài sản - funding_level: 3		
SELECT 	
		28 AS funding_id,
		t1.month_key,
		t1.area_code,
		--amount_dvml,
		--area_sm_number,
		--total_sm_number,
		amount_dvml + (amount_head*area_sm_number/total_sm_number) total_amount
FROM
		--Lấy theo đầu kế toán với account_code thuộc : 87x
		(
		SELECT 	
				--202302 AS month_key,
				v_month_key AS month_key,
				area_code,
				sum(amount) amount_dvml
		FROM fact_txn_month_raw_data ftmrd
		LEFT JOIN dim_analysis_code dac ON ftmrd.analysis_code = dac.analysis_code 
		WHERE 	--to_char(transaction_date,'YYYYMM')::int <= 202302
				to_char(transaction_date,'YYYYMM')::int <= v_month_key
				AND account_code::varchar LIKE '87%'
				AND dvml_head = 'DVML'
		GROUP BY area_code 	
		) t1
LEFT JOIN 
		--Tính sm_number từng area 
		(
		SELECT 	--202302 AS month_key,
				v_month_key AS month_key,
				area_code,
				count(*) area_sm_number
		FROM
				kpi_asm_data kad
		LEFT JOIN dim_area_code dac ON kad.area_name = dac.area_name
		GROUP BY area_code
		) t2 ON t1.month_key = t2.month_key AND t1.area_code = t2.area_code
LEFT JOIN 
		--Tính sm_number tất cả 
		(
		SELECT 	--202302 AS month_key,
				v_month_key AS month_key,
				count(*) total_sm_number
		FROM
				kpi_asm_data kad
		LEFT JOIN dim_area_code dac ON kad.area_name = dac.area_name
		) t3 ON t1.month_key = t3.month_key
LEFT JOIN
		--Tính sum amount đầu 'HEAD'
		(
		SELECT 
		--202302 AS month_key,
		v_month_key AS month_key,
		sum(amount) amount_head
		FROM fact_txn_month_raw_data ftmrd 
		WHERE account_code::varchar LIKE '87%'
			--AND to_char(transaction_date,'YYYYMM')::int <= 202302 
			AND to_char(transaction_date,'YYYYMM')::int <= v_month_key
			AND	analysis_code LIKE 'HEAD%'
		) t4 ON t1.month_key = t4.month_key
UNION ALL
SELECT 
	28 AS funding_id,
	--202302 AS month_key,
	v_month_key AS month_key,
	'A' AS area_code,
	sum(amount) amount_head
FROM fact_txn_month_raw_data ftmrd 
WHERE account_code::varchar LIKE '87%' 
	--AND to_char(transaction_date,'YYYYMM')::int <= 202302 
	AND to_char(transaction_date,'YYYYMM')::int <= v_month_key
	AND	analysis_code LIKE 'HEAD%';
INSERT INTO fact_funding_summary(funding_id, month_key, area_code, total_amount)
--24. Tổng chi phí hoạt động - funding_level: 2
SELECT 
		8 AS funding_id,
		month_key,
		area_code,
		sum(total_amount) total_amount
FROM fact_funding_summary ffs 
WHERE 	--month_key = 202302
		month_key = v_month_key 
		AND funding_id BETWEEN 25 AND 28
GROUP BY 	area_code,
			month_key;
INSERT INTO fact_funding_summary(funding_id, month_key, area_code, total_amount)
--25. CP dự phòng - funding_level: 2	
SELECT 	
		9 AS funding_id,
		t1.month_key,
		t1.area_code,
		--amount_dvml,
		--area_sm_number,
		--total_sm_number,
		amount_dvml + (amount_head*area_sm_number/total_sm_number) total_amount
FROM
		--Lấy theo đầu kế toán với account_code thuộc : 790000050001, 882200050001, 790000030001, 882200030001, 790000000001, 790000020101, 
							--882200000001, 882200050101, 882200020101, 882200060001,790000050101, 882200030101
		(
		SELECT 	
				--202302 AS month_key,
				v_month_key AS month_key,
				area_code,
				sum(amount) amount_dvml
		FROM fact_txn_month_raw_data ftmrd
		LEFT JOIN dim_analysis_code dac ON ftmrd.analysis_code = dac.analysis_code 
		WHERE 	--to_char(transaction_date,'YYYYMM')::int <= 202302
				to_char(transaction_date,'YYYYMM')::int <= v_month_key
				AND account_code IN (790000050001, 882200050001, 790000030001, 882200030001, 790000000001, 790000020101, 882200000001, 
							882200050101, 882200020101, 882200060001,790000050101, 882200030101)
				AND dvml_head = 'DVML'
		GROUP BY area_code 	
		) t1
LEFT JOIN 
		--Tính sm_number từng area 
		(
		SELECT 	--202302 AS month_key,
				v_month_key AS month_key,
				area_code,
				count(*) area_sm_number
		FROM
				kpi_asm_data kad
		LEFT JOIN dim_area_code dac ON kad.area_name = dac.area_name
		GROUP BY area_code
		) t2 ON t1.month_key = t2.month_key AND t1.area_code = t2.area_code
LEFT JOIN 
		--Tính sm_number tất cả 
		(
		SELECT 	--202302 AS month_key,
				v_month_key AS month_key,
				count(*) total_sm_number
		FROM
				kpi_asm_data kad
		LEFT JOIN dim_area_code dac ON kad.area_name = dac.area_name
		) t3 ON t1.month_key = t3.month_key
LEFT JOIN
		--Tính sum amount đầu 'HEAD'
		(
		SELECT 
		--202302 AS month_key,
		v_month_key AS month_key,
		sum(amount) amount_head
		FROM fact_txn_month_raw_data ftmrd 
		WHERE account_code IN (790000050001, 882200050001, 790000030001, 882200030001, 790000000001, 790000020101, 882200000001, 
					882200050101, 882200020101, 882200060001,790000050101, 882200030101)
			--AND to_char(transaction_date,'YYYYMM')::int <= 202302 
			AND to_char(transaction_date,'YYYYMM')::int <= v_month_key
			AND	analysis_code LIKE 'HEAD%'
		) t4 ON t1.month_key = t4.month_key
UNION ALL
SELECT 
	9 AS funding_id,
	--202302 AS month_key,
	v_month_key AS month_key,
	'A' AS area_code,
	sum(amount) amount_head
FROM fact_txn_month_raw_data ftmrd 
WHERE account_code IN (790000050001, 882200050001, 790000030001, 882200030001, 790000000001, 790000020101, 882200000001, 
					882200050101, 882200020101, 882200060001,790000050101, 882200030101) 
	--AND to_char(transaction_date,'YYYYMM')::int <= 202302 
	AND to_char(transaction_date,'YYYYMM')::int <= v_month_key
	AND	analysis_code LIKE 'HEAD%';
INSERT INTO fact_funding_summary(funding_id, month_key, area_code, total_amount)
--26. Lợi nhuận trước thuế - funding_level: 1
SELECT 
		1 AS funding_id,
		--202302 AS month_key,
		v_month_key AS month_key,
		area_code,
		sum(total_amount) total_amount
FROM fact_funding_summary
WHERE funding_id BETWEEN 7 AND 9
GROUP BY area_code;
INSERT INTO fact_funding_summary(funding_id, month_key, area_code, total_amount)
--27. Số lượng nhân sự (Sales Manager) - funding_level: 1	
SELECT 	
		2 AS funding_id,
		--202302 AS month_key,
		v_month_key AS month_key,
		area_code,
		count(*) total_amount
FROM
		kpi_asm_data kad
LEFT JOIN dim_area_code dac ON kad.area_name = dac.area_name
GROUP BY area_code
UNION ALL
SELECT 	
		2 AS funding_id,
		--202302 AS month_key,
		v_month_key AS month_key,
		'A' AS area_code,
		count(*) total_amount
FROM
		kpi_asm_data kad;
--28. Chỉ số tài chính - funding_level: 1
INSERT INTO fact_funding_summary(funding_id, month_key, area_code, total_amount)	
SELECT 
		3 AS funding_id,
		v_month_key AS month_key,
		--202302 AS month_key,
		area_code,
		0 AS total_amount
FROM 	dim_area_code dac
--29. CIR (%) - funding_level: 3
UNION ALL 
SELECT
		29 AS funding_id,
		v_month_key AS month_key,
		--202302 AS month_key,
		t1.area_code,
		--total_cost,
		--total_income,
		-total_cost*100/total_income total_amount
FROM 
		(
		SELECT
				area_code,
				total_amount AS total_cost
		FROM fact_funding_summary
		WHERE funding_id = 8
				AND month_key = v_month_key
				--AND month_key = 202302
		) t1
LEFT JOIN 
		(
		SELECT
				area_code,
				total_amount AS total_income
		FROM fact_funding_summary
		WHERE funding_id = 7
				AND month_key = v_month_key
				--AND month_key = 202302
		) t2 ON t1.area_code = t2.area_code
--30. Margin (%) - funding_level: 3
UNION ALL 
SELECT
		30 AS funding_id,
		v_month_key AS month_key,
		--202302 AS month_key,
		t1.area_code,
		--loinhuan_truoc_thue,
		--thunhap_the,
		--dt_nguonvon,
		--dt_kinhdoanh,
		loinhuan_truoc_thue*100/(thunhap_the + dt_nguonvon + dt_kinhdoanh) total_amount
FROM 
		(
		SELECT
				area_code,
				total_amount AS loinhuan_truoc_thue
		FROM fact_funding_summary
		WHERE funding_id = 1
				AND month_key = v_month_key
				--AND month_key = 202302
		) t1
LEFT JOIN 
		(
		SELECT
				area_code,
				total_amount AS thunhap_the
		FROM fact_funding_summary
		WHERE funding_id = 4
				AND month_key = v_month_key
				--AND month_key = 202302
		) t2 ON t1.area_code = t2.area_code
LEFT JOIN 
		(
		SELECT
				area_code,
				total_amount AS dt_nguonvon
		FROM fact_funding_summary
		WHERE funding_id = 15
				AND month_key = v_month_key
				--AND month_key = 202302
		) t3 ON t1.area_code = t3.area_code
LEFT JOIN 
		(
		SELECT
				area_code,
				total_amount AS dt_kinhdoanh
		FROM fact_funding_summary
		WHERE funding_id = 21
				AND month_key = v_month_key
				--AND month_key = 202302
		) t4 ON t1.area_code = t4.area_code
--31. Hiệu suất trên/vốn (%) - funding_level: 3
UNION ALL 
SELECT
		31 AS funding_id,
		v_month_key AS month_key,
		--202302 AS month_key,
		t1.area_code,
		--chiphi_kdv,
		--loinhuan_truoc_thue,
		-chiphi_thuan_kdv*100/loinhuan_truoc_thue total_amount
FROM 
		(
		SELECT
				area_code,
				total_amount AS chiphi_thuan_kdv
		FROM fact_funding_summary
		WHERE funding_id = 5
				AND month_key = v_month_key
				--AND month_key = 202302
		) t1
LEFT JOIN 
		(
		SELECT
				area_code,
				total_amount AS loinhuan_truoc_thue
		FROM fact_funding_summary
		WHERE funding_id = 1
				AND month_key = v_month_key
				--AND month_key = 202302
		) t2 ON t1.area_code = t2.area_code
--32. Hiệu suất BQ/ Nhân sự	- funding_level: 3
UNION ALL 
SELECT
		32 AS funding_id,
		v_month_key AS month_key,
		--202302 AS month_key,
		t1.area_code,
		--so_luong_sm,
		--loinhuan_truoc_thue,
		loinhuan_truoc_thue/so_luong_sm total_amount
FROM 
		(
		SELECT
				area_code,
				total_amount AS so_luong_sm
		FROM fact_funding_summary
		WHERE funding_id = 2
				AND month_key = v_month_key
				--AND month_key = 202302
		) t1
LEFT JOIN 
		(
		SELECT
				area_code,
				total_amount AS loinhuan_truoc_thue
		FROM fact_funding_summary
		WHERE funding_id = 1
				AND month_key = v_month_key
				--AND month_key = 202302
		) t2 ON t1.area_code = t2.area_code;
-- Bước 3: insert vào bảng "BÁO CÁO TỔNG HỢP"
DROP EXTENSION IF EXISTS tablefunc CASCADE;
CREATE extension tablefunc;
INSERT INTO "BÁO CÁO TỔNG HỢP"("TIÊU CHÍ", "HỘI SỞ", "Đông Bắc Bộ", "Tây Bắc Bộ", "Đồng Bằng Sông Hồng", "Bắc Trung Bộ", 
		"Nam Trung Bộ", "Tây Nam Bộ", "Đông Nam Bộ", "Tháng báo cáo")
SELECT 	*,
		v_month_key AS month_key_report
FROM crosstab(
		'SELECT 	
				funding_name,
				area_name,
				total_amount
		FROM dim_funding_id dfi 
		LEFT JOIN fact_funding_summary ffs ON dfi.funding_id  = ffs.funding_id 
												AND ffs.month_key = ' || v_month_key || '
		LEFT JOIN dim_area_code dac ON ffs.area_code = dac.area_code 
		ORDER BY sortorder, dac.area_code',
		'SELECT 
				area_name
		FROM dim_area_code
		ORDER BY area_code')
AS final_result(
		"TIÊU CHÍ" varchar(50), 
		"HỘI SỞ" float8, 
		"Đông Bắc Bộ" float8, 
		"Tây Bắc Bộ" float8, 
		"Đồng Bằng Sông Hồng" float8, 
		"Bắc Trung Bộ" float8, 
		"Nam Trung Bộ" float8, 
		"Tây Nam Bộ" float8, 
		"Đông Nam Bộ" float8 
		);
-- Bước 4: insert vào bảng "BÁO CÁO XẾP HẠNG"
INSERT INTO "BÁO CÁO XẾP HẠNG"
SELECT 
		--202302 AS month_key,
		v_month_key AS month_key,
		area_code,
		area_name,
		email,
		"Điểm Quy Mô" + (rank_cir + rank_margin + rank_hs_von + rank_hsbq_nhan_su) "Tổng điểm",
		RANK() OVER (ORDER BY "Điểm Quy Mô" + (rank_cir + rank_margin + rank_hs_von + rank_hsbq_nhan_su)) rank_final,
		ltn_avg,
		rank_ltn_avg,
		psdn_avg,
		rank_psdn_avg,
		approval_rate_avg,
		rank_approval_rate_avg,
		npl_bef_wo,
		rank_npl_bef_wo,
		"Điểm Quy Mô",
		rank_ptkd,
		cir,
		rank_cir,
		margin,
		rank_margin,
		hs_von,
		rank_hs_von,
		hsbq_nhan_su,
		rank_hsbq_nhan_su,
		(rank_cir + rank_margin + rank_hs_von + rank_hsbq_nhan_su) "Điểm FIN",
		RANK() OVER (ORDER BY (rank_cir + rank_margin + rank_hs_von + rank_hsbq_nhan_su)) rank_fin
FROM 
		(
		SELECT 
				quy_mo.area_code,
				area_name,
				email,
				ltn_avg,
				rank_ltn_avg,
				psdn_avg,
				rank_psdn_avg,
				approval_rate_avg,
				rank_approval_rate_avg,
				npl_bef_wo,
				rank_npl_bef_wo,
				(rank_ltn_avg + rank_psdn_avg + rank_approval_rate_avg + rank_npl_bef_wo) "Điểm Quy Mô",
				RANK() OVER (ORDER BY (rank_ltn_avg + rank_psdn_avg + rank_approval_rate_avg + rank_npl_bef_wo)) rank_ptkd,
				cir.total_amount cir,
				DENSE_RANK() OVER (ORDER BY cir.total_amount) rank_cir,
				margin.total_amount margin,
				DENSE_RANK() OVER (ORDER BY margin.total_amount DESC) rank_margin,
				hs_von.total_amount hs_von,
				DENSE_RANK() OVER (ORDER BY hs_von.total_amount DESC) rank_hs_von,
				hsbq_nhan_su.total_amount hsbq_nhan_su,
				DENSE_RANK() OVER (ORDER BY hsbq_nhan_su.total_amount DESC) rank_hsbq_nhan_su
		FROM 
				(
				SELECT 
						fkad.area_code,
						area_name,
						email,
						avg(ltn) ltn_avg,
						rank() OVER (ORDER BY avg(ltn) DESC) rank_ltn_avg,
						avg(psdn) psdn_avg,
						rank() OVER (ORDER BY avg(psdn) DESC) rank_psdn_avg,
						avg(app_rate) approval_rate_avg,
						rank() OVER (ORDER BY avg(app_rate) DESC) rank_approval_rate_avg,
						npl_bef_wo,
						rank() OVER (ORDER BY npl_bef_wo) rank_npl_bef_wo
				FROM fact_kpi_asm_data fkad
				LEFT JOIN 
						(
						SELECT 
						t1.tieuchuan,
						t1.area_code,
						--tong_no_xau,
						--tong_du_no,
						tong_no_xau*1.0/tong_du_no NPL_bef_WO
						FROM 
								(
								SELECT 
										'NPL' AS tieuchuan,
										area_code,
										sum(outstanding_principal) tong_no_xau
								FROM fact_kpi_month_raw_data fkmrd 
								LEFT JOIN dim_analysis_code dac ON fkmrd.pos_cde = dac.pos_cde
								WHERE 	max_bucket BETWEEN 3 AND 5 
										--AND kpi_month <= 202302
										AND kpi_month <= v_month_key
								GROUP BY area_code
								) t1
						LEFT JOIN 
								(
								SELECT 
										'NPL' AS tieuchuan,
										area_code,
										sum(outstanding_principal) tong_du_no
								FROM fact_kpi_month_raw_data fkmrd 
								LEFT JOIN dim_analysis_code dac ON fkmrd.pos_cde = dac.pos_cde
								WHERE 	--kpi_month <= 202302
										kpi_month <= v_month_key
								GROUP BY area_code
								) t2 ON t1.tieuchuan = t2.tieuchuan AND t1.area_code = t2.area_code
						) npl ON fkad.area_code = npl.area_code
				WHERE 	
						(ltn IS NOT NULL OR psdn IS NOT NULL OR app_approved IS NOT NULL OR app_in IS NOT NULL OR app_rate IS NOT NULL)
						--AND kpi_asm_month <= 202302
						AND kpi_asm_month <= v_month_key
				GROUP BY fkad.area_code, area_name, email, npl_bef_wo
				) quy_mo
		LEFT JOIN fact_funding_summary cir ON quy_mo.area_code = cir.area_code AND cir.funding_id = 29 AND cir.month_key = v_month_key
		LEFT JOIN fact_funding_summary margin ON quy_mo.area_code = margin.area_code AND margin.funding_id = 30 AND margin.month_key = v_month_key
		LEFT JOIN fact_funding_summary hs_von ON quy_mo.area_code = hs_von.area_code AND hs_von.funding_id = 31 AND hs_von.month_key = v_month_key
		LEFT JOIN fact_funding_summary hsbq_nhan_su ON quy_mo.area_code = hsbq_nhan_su.area_code AND hsbq_nhan_su.funding_id = 32 AND hsbq_nhan_su.month_key = v_month_key
		);
-- Bước 5: ghi log và xử lý ngoại lệ 
-- Ghi log   
INSERT INTO log_tracking (procedure_name, start_time , end_time, is_successful, rec_created_dt)
VALUES ('fact_funding_summary', vstart_time , CURRENT_TIMESTAMP, TRUE, vProcess_dt);
-- Ghi nhận lỗi vào bảng log
EXCEPTION
WHEN others THEN
    INSERT INTO log_tracking (procedure_name, start_time, end_time, is_successful, error_log, rec_created_dt)
    VALUES ('fact_funding_summary', vstart_time, CURRENT_TIMESTAMP, FALSE, SQLERRM, CURRENT_TIMESTAMP);
	RAISE EXCEPTION 'Error';
END;
$$;

--Kiểm tra dữ liệu bằng cách execute để test các trường hợp xảy ra
CALL fact_funding_summary(202301);
SELECT * FROM fact_funding_summary;	
SELECT * FROM log_tracking;
SELECT * FROM "BÁO CÁO TỔNG HỢP"; 
SELECT * FROM "BÁO CÁO XẾP HẠNG"; 
--TRUNCATE TABLE fact_funding_summary;
--TRUNCATE TABLE log_tracking;
--TRUNCATE TABLE "BÁO CÁO TỔNG HỢP";
--TRUNCATE TABLE "BÁO CÁO XẾP HẠNG";