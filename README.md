
## Mục Lục
- [I. TỔNG QUAN](#i-tổng-quan)
- [II. CÁC BƯỚC THỰC HIỆN](#ii-các-bước-thực-hiện)
- [III. TRỰC QUAN HOÁ VÀ PHÂN TÍCH DỮ LIỆU](#iii-trực-quan-hoá-và-phân-tích-dữ-liệu)
- [IV. KẾT QUẢ CÁ NHÂN ĐẠT ĐƯỢC SAU PROJECT](#iv-kết-quả-cá-nhân-đạt-được-sau-project)



## I. TỔNG QUAN
#### 1.	Mục tiêu
Ban điều hành (BOD) muốn biết được hiệu quả kinh doanh của doanh nghiệp (công ty tài chính) và các khu vực mạng lưới trên toàn quốc cũng như đánh giá năng lực của các nhân sự (ASM).
#### 2.	Dữ liệu đầu vào
-	File `fact_kpi_month_raw_data` : nguồn sao kê dư nợ thẻ theo khách hàng tại thời điểm cuối mỗi tháng.
-	File `fact_txn_month_raw_data` : nguồn dữ liệu các khoản phát sinh được hạch toán vào sổ cái kế toán (General Ledger).
-	File `kpi_asm_data` : nguồn số liệu về doanh số kinh doanh theo từng tháng của các ASM (Area Sales Manager).
#### 3.	Kết quả đầu ra
-	`Báo cáo tổng hợp` (báo cáo chính): ghi nhận tình hình kinh doanh của các khu vực mạng lưới trên toàn quốc.
-	`Báo cáo xếp hạng` (báo cáo chính): đánh giá nhân sự (ASM) theo các chỉ số tài chính và các chỉ số kinh doanh.
-	`Báo cáo kinh doanh`: thống kê, phân tích tình hình kinh doanh của các khu vực mạng lưới trên toàn quốc.
-	`Doanh thu lũy kế năm`: thống kê, phân tích tình hình các nguồn thu nhập, lợi nhuận các khu vực mạng lưới trên toàn quốc và đưa ra đánh giá về mức độ hiệu quả.
-	`Chi phí lũy kế năm`: thống kê, phân tích tình hình các nguồn chi phí, phân bổ chi phí của các khu vực mạng lưới trên toàn quốc và đưa ra đánh giá về mức độ hiệu quả.
-	`Đánh giá ASM`: thống kê, phân tích và đánh giá mức độ hiệu quả của các nhân sự (ASM) theo các chỉ số tài chính và các chỉ số kinh doanh
#### 4. Flowchart
![image](https://github.com/voxuandat/Regions-Business-Performance-ASM-Capacity-Assessment-Report-vietnamese/blob/main/Assets/flowchart.png?raw=true)

## II.	CÁC BƯỚC THỰC HIỆN
#### 1.	Xây dựng bảng mô nghiệp vụ 
Xem chi tiết tại file *Nghiệp vụ.xlsx* trên

#### 2.	Sử dụng Dbeaver nhập dữ liệu đầu vào vào Cơ sở dữ liệu ta có các bảng fact tương ứng
- Bảng `fact_kpi_month_raw_data`
  
![image](https://github.com/voxuandat/Regions-Business-Performance-ASM-Capacity-Assessment-Report-vietnamese/blob/main/Assets/fact_kpi_month_raw_data.JPG?raw=true)
- Bảng `fact_txn_month_raw_data`
  
![image](https://github.com/voxuandat/Regions-Business-Performance-ASM-Capacity-Assessment-Report-vietnamese/blob/main/Assets/fact_txn_month_raw_data.JPG?raw=true)
- Bảng `kpi_asm_data`
  
![image](https://github.com/voxuandat/Regions-Business-Performance-ASM-Capacity-Assessment-Report-vietnamese/blob/main/Assets/kpi_asm_data.JPG?raw=true)

#### 3. Sử dụng PostgreSQL Data Definition Language (DDL) xây dựng các bảng dim, fact, log_tracking
#### a.	Xây dựng các bảng dim:
-	Bảng `dim_funding_id` chứa thông tin theo các tiêu chí để tiện truy vấn và sắp xếp
  
![image](https://github.com/voxuandat/Regions-Business-Performance-ASM-Capacity-Assessment-Report-vietnamese/blob/main/Assets/dim_funding_id.jpg?raw=true)
-	Bảng `dim_analysis_code` chứa thông tin về đơn vị, vùng, khu vực, tỉnh/thành phố, thứ tự đơn vị mạng lưới của mã code
  
![image](https://github.com/voxuandat/Regions-Business-Performance-ASM-Capacity-Assessment-Report-vietnamese/blob/main/Assets/dim_analysis_code.jpg?raw=true)
-	Bảng `dim_area_code` chứa thông tin về mã code của khu vực
  
![image](https://github.com/voxuandat/Regions-Business-Performance-ASM-Capacity-Assessment-Report-vietnamese/blob/main/Assets/dim_area_code.jpg?raw=true)
- Bảng `dim_city_code` chứa thông tin về mã code của tỉnh/thành phố

![image](https://github.com/voxuandat/Regions-Business-Performance-ASM-Capacity-Assessment-Report-vietnamese/blob/main/Assets/dim_city_code.jpg?raw=true)
#### b.	Xây dựng các bảng fact:
- Bảng `bao_cao_kinh_doanh`
  
![image](https://github.com/voxuandat/Regions-Business-Performance-ASM-Capacity-Assessment-Report-vietnamese/blob/main/Assets/ket_qua_kinh_doanh.jpg?raw=true)
- Bảng `danh_gia_kpi_asm`

![image](https://github.com/voxuandat/Regions-Business-Performance-ASM-Capacity-Assessment-Report-vietnamese/blob/main/Assets/danh_gia_kpi_asm.jpg?raw=true)
#### c.	Xây dựng bảng log-tracking:
- Bảng `log_tracking` để ghi nhận và xử lý ngoại lệ
  
![image](https://github.com/voxuandat/Regions-Business-Performance-ASM-Capacity-Assessment-Report-vietnamese/blob/main/Assets/log_tracking.jpg?raw=true)

#### 4. Viết Stored Procedure
-	Viết procedure với tham số truyền vào là tháng báo cáo dạng ‘YYYYMM’ để đổ dữ liệu từ 3 nguồn dữ liệu đầu vào kết hợp các bảng dim, log_tracking được tạo vào bảng `bao_cao_kinh_doanh` và `danh_gia_kpi_asm`
- Ghi nhận lỗi từ bảng log và kiểm tra dữ liệu bằng cách execute để test các trường hợp xảy ra
- Xem chi tiết tại file *procedure* trên

## III.	TRỰC QUAN HOÁ VÀ PHÂN TÍCH DỮ LIỆU
Chi tiết tại Demo Online bằng PowerBI [link](https://app.powerbi.com/view?r=eyJrIjoiMDljNmJkMzEtZjk4NS00ZDljLThjM2EtNTEyNWEzOTllMzI2IiwidCI6IjZhYzJhZDA2LTY5MmMtNDY2My1iN2FmLWE5ZmYyYTg2NmQwYyIsImMiOjEwfQ%3D%3D)

## IV. KẾT QUẢ CÁ NHÂN ĐẠT ĐƯỢC SAU PROJECT
- Sử dụng thành thạo hơn các tools như Dbeaver, PowerBI và các kỹ năng như SQL Programming,...
- Có khả năng xử lý lượng dữ liệu lớn từ hàng triệu đến chục triệu records.
- Tối ưu Cơ sở dữ liệu (Database) bằng cách đánh index, partition vào các bảng.
- Học được các mô hình dữ liệu Dim-Fact, quản lý dữ liệu trong Data Warehouse.
- Năm được kiến thức nghiệp vụ về Thẻ, Tài chính trong các công ty tài chính,...
