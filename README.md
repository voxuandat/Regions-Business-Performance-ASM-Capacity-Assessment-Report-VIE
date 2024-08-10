## I. Tổng quan
#### 1.	Mục tiêu
Ban điều hành (BOD) muốn biết được hiệu quả kinh doanh của doanh nghiệp (công ty tài chính) và các khu vực mạng lưới trên toàn quốc cũng như đánh giá năng lực của các nhân sự (ASM).
#### 2.	Dữ liệu đầu vào
-	File `fact_kpi_month_raw_data` : nguồn sao kê dư nợ thẻ theo khách hàng tại thời điểm cuối mỗi tháng.
-	File `fact_txn_month_raw_data` : nguồn dữ liệu các khoản phát sinh được hạch toán vào sổ cái kế toán (General Ledger).
-	File `kpi_asm_data` : nguồn số liệu về doanh số kinh doanh theo từng tháng của các ASM (Area Sales Manager).
#### 3.	Kết quả đầu ra
-	Báo cáo tổng hợp (báo cáo chính): ghi nhận tình hình kinh doanh của các khu vực mạng lưới trên toàn quốc.
-	Báo cáo xếp hạng (báo cáo chính): đánh giá nhân sự (ASM) theo các chỉ số tài chính và các chỉ số kinh doanh.
-	Báo cáo kinh doanh: thống kê, phân tích tình hình kinh doanh của các khu vực mạng lưới trên toàn quốc.
-	Doanh thu lũy kế năm: thống kê, phân tích tình hình các nguồn thu nhập, lợi nhuận các khu vực mạng lưới trên toàn quốc và đưa ra đánh giá về mức độ hiệu quả.
-	Chi phí lũy kế năm: thống kê, phân tích tình hình các nguồn chi phí, phân bổ chi phí của các khu vực mạng lưới trên toàn quốc và đưa ra đánh giá về mức độ hiệu quả.
-	Đánh giá ASM: thống kê, phân tích và đánh giá mức độ hiệu quả của các nhân sự (ASM) theo các chỉ số tài chính và các chỉ số kinh doanh
#### 4. Flowchart
![image]([https://1drv.ms/i/c/7bf0fb35dcf828c6/EV8zcu2sxIZJrWMxPTwfMDQBeneYHlfG5cPRq26LiFfKJw?e=p8Tenm](https://photos.onedrive.com/share/7BF0FB35DCF828C6!sed72335fc4ac4986ad63313d3c1f3034?cid=7BF0FB35DCF828C6&resId=7BF0FB35DCF828C6!sed72335fc4ac4986ad63313d3c1f3034&ithint=photo&e=p8Tenm&migratedtospo=true&redeem=aHR0cHM6Ly8xZHJ2Lm1zL2kvYy83YmYwZmIzNWRjZjgyOGM2L0VWOHpjdTJzeElaSnJXTXhQVHdmTURRQmVuZVlIbGZHNWNQUnEyNkxpRmZLSnc_ZT1wOFRlbm0))
