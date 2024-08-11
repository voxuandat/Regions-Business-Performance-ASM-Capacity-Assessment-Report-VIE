# BÁO CÁO: ĐÁNH GIÁ HIỆU QUẢ KINH DOANH CÁC KHU VỰC & NĂNG LỰC NHÂN SỰ (ASM)

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

## II. CÁC BƯỚC THỰC HIỆN
#### 1.	Xây dựng bảng mô nghiệp vụ 
Xem chi tiết tại file ***[Nghiệp vụ.xlsx](https://1drv.ms/x/c/7bf0fb35dcf828c6/EfKnKg8WNytOhlrzT7ybsfkBmjY3tAB3SZaDXGOyI9YdfQ?e=GmiqcJ)*** trên

#### 2.	Sử dụng Dbeaver nhập dữ liệu đầu vào vào Cơ sở dữ liệu ta có các bảng fact tương ứng
- Bảng `fact_kpi_month_raw_data`
  
![image](https://github.com/voxuandat/Regions-Business-Performance-ASM-Capacity-Assessment-Report-vietnamese/blob/main/Assets/fact_kpi_month_raw_data.JPG?raw=true)
- Bảng `fact_txn_month_raw_data`
  
![image](https://github.com/voxuandat/Regions-Business-Performance-ASM-Capacity-Assessment-Report-vietnamese/blob/main/Assets/fact_txn_month_raw_data.JPG?raw=true)
- Bảng `kpi_asm_data`
  
![image](https://github.com/voxuandat/Regions-Business-Performance-ASM-Capacity-Assessment-Report-vietnamese/blob/main/Assets/kpi_asm_data.png?raw=true)

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

#### 4. Viết Stored Procedure  (Xem chi tiết tại file *[procedure.sql](https://github.com/voxuandat/Regions-Business-Performance-ASM-Capacity-Assessment-Report-vietnamese/blob/main/procedure.sql)* trên)
-	Viết procedure với tham số truyền vào là tháng báo cáo dạng ‘YYYYMM’ để đổ dữ liệu từ 3 nguồn dữ liệu đầu vào kết hợp các bảng dim, log_tracking được tạo vào bảng `bao_cao_kinh_doanh` và `danh_gia_kpi_asm`
- Ghi nhận lỗi từ bảng log và kiểm tra dữ liệu bằng cách execute để test các trường hợp xảy ra

## III. TRỰC QUAN HOÁ VÀ PHÂN TÍCH DỮ LIỆU
Xem chi tiết tại Demo Online bằng PowerBI: [link](https://app.powerbi.com/view?r=eyJrIjoiMDljNmJkMzEtZjk4NS00ZDljLThjM2EtNTEyNWEzOTllMzI2IiwidCI6IjZhYzJhZDA2LTY5MmMtNDY2My1iN2FmLWE5ZmYyYTg2NmQwYyIsImMiOjEwfQ%3D%3D)
#### 1.	Sử dụng Power BI kết nối với Cơ sở dữ liệu bằng cách sử dụng Direct Query
#### 2.	Trực quan hoá & Phân tích hiệu quả hoạt động kinh doanh của các khu vực & đánh giá năng lực nhân sự (ASM) tại thời điểm tháng 3/ 2023
- `BÁO CÁO TỔNG HỢP & BÁO CÁO XẾP HẠNG`: *(xem tại link Demo Online bằng PowerBI trên)*
- `BÁO CÁO KINH DOANH`:

![image](https://github.com/voxuandat/Regions-Business-Performance-ASM-Capacity-Assessment-Report-vietnamese/blob/main/Assets/bao_cao_kinh_doanh_1.jpg?raw=true)

Nhìn chung trong khoảng thời gian này Ngân hàng đạt được các chỉ số mong muốn, tuy nhiên sự **phân bổ thu/chi giữa các khu vực không đồng đều**

![image](https://github.com/voxuandat/Regions-Business-Performance-ASM-Capacity-Assessment-Report-vietnamese/blob/main/Assets/bao_cao_kinh_doanh_2.jpg?raw=true)
![image](https://github.com/voxuandat/Regions-Business-Performance-ASM-Capacity-Assessment-Report-vietnamese/blob/main/Assets/bao_cao_kinh_doanh_3.jpg?raw=true)

Nhìn chung các khu vực trong khoảng thời gian này đều có **mức độ tăng trưởng ổn định**, đặc biệt là khu vực Tây Nam Bộ

![image](https://github.com/voxuandat/Regions-Business-Performance-ASM-Capacity-Assessment-Report-vietnamese/blob/main/Assets/bao_cao_kinh_doanh_4.jpg?raw=true)
![image](https://github.com/voxuandat/Regions-Business-Performance-ASM-Capacity-Assessment-Report-vietnamese/blob/main/Assets/bao_cao_kinh_doanh_5.jpg?raw=true)

Tây Nam Bộ là khu vực **hoạt động hiệu quả nhất quý I** này với lợi nhuận, tổng thu nhập cao nhất tuy số lượng nhân sự (ASM) chỉ đứng thứ 3 (chiếm ~20%)
-	`DOANH THU LŨY KẾ NĂM`:
Lợi nhuận trước thuế trong 3 tháng đầu năm **tăng trưởng ấn tượng** ~ 50%, Doanh thu tăng trưởng đều đặn ~ 60%. Đồng nghĩa với việc **chi phí hoạt động cũng đang tăng**

![image](https://github.com/voxuandat/Regions-Business-Performance-ASM-Capacity-Assessment-Report-vietnamese/blob/main/Assets/doanh_thu_luy_ke_nam_1.jpg?raw=true)

Nguồn thu nhập từ **hoạt động thẻ chiếm phần lớn** (~90%) so với các doanh thu khác

![image](https://github.com/voxuandat/Regions-Business-Performance-ASM-Capacity-Assessment-Report-vietnamese/blob/main/Assets/doanh_thu_luy_ke_nam_2.jpg?raw=true)

Tây Nam Bộ tuy có số lượng nhân sự xếp sau Đồng bằng sông Hồng và Đông Nam Bộ tuy nhiên đem về nhiều doanh thu nhất, biên lợi nhuận cũng cao, đạt 27.2% -> **Khu vực Tây Nam Bộ hoạt động hiệu quả nhất trong quý I này**

![image](https://github.com/voxuandat/Regions-Business-Performance-ASM-Capacity-Assessment-Report-vietnamese/blob/main/Assets/doanh_thu_luy_ke_nam_3.jpg?raw=true)

Ngoài ra biên lợi nhuận của 2 khu vực Nam Trung Bộ và Bắc Trung Bộ cũng sao với lần lượt 31.88% và 28.29%
- `CHI PHÍ LŨY KẾ NĂM`:
Như đã phân tích trên ta có thể thấy **chi phí hoạt động trong quý I này tăng**, cụ thể tăng ~50% mỗi tháng

![image](https://github.com/voxuandat/Regions-Business-Performance-ASM-Capacity-Assessment-Report-vietnamese/blob/main/Assets/chi_phi_luy_ke_nam_1.jpg?raw=true)

**Chi phí dự phòng** chiếm tỉ lệ cao nhất với 54%. Theo sau là **chi phí hoạt động** chiếm 25%, trong đó **phân bổ cho chi phí nhân viên nhiều nhất**

![image](https://github.com/voxuandat/Regions-Business-Performance-ASM-Capacity-Assessment-Report-vietnamese/blob/main/Assets/chi_phi_luy_ke_nam_2.jpg?raw=true)

Ta có thể thấy **Đông Nam Bộ là khu vực hoạt động kém hiệu quả nhất** khi mà chiếm nhiều chi phí nhất (chỉ sau Tây Nam Bộ) nhưng lợi nhuận trước thuế lại âm

![image](https://github.com/voxuandat/Regions-Business-Performance-ASM-Capacity-Assessment-Report-vietnamese/blob/main/Assets/chi_phi_luy_ke_nam_3.jpg?raw=true)

Khu vực Nam Trung Bộ đem lại **thu nhập không quá cao nhưng chi phí lại thấp** dẫn đến CIR = 10.7%, thấp nhất (xếp dưới Tây Nam Bộ với 11.45%) trong khi Bắc Trung Bộ có mức thu nhập ngang bằng nhưng CIR lại cao nhất, 18.5%

![image](https://github.com/voxuandat/Regions-Business-Performance-ASM-Capacity-Assessment-Report-vietnamese/blob/main/Assets/chi_phi_luy_ke_nam_4.jpg?raw=true)

-	`ĐÁNH GIÁ NHÂN SỰ (ASM)`:
Đồng Bằng Sông Hồng có số lượng ASM nhiều nhất, cũng như số ASM thuộc top 10, tuy nhiên **chưa hiệu quả trong hoạt động kinh doanh** khi doanh thu chỉ xếp thứ 2

![image](https://github.com/voxuandat/Regions-Business-Performance-ASM-Capacity-Assessment-Report-vietnamese/blob/main/Assets/danh_gia_nhan_su_asm_1.jpg?raw=true)

Bắc Trung Bộ, Nam Trung Bộ có lượng ASM không nhiều nhưng có tỉ lệ ASM thuộc top 10 đều đặn -> các ASM **quản lý tốt mạng lưới khu vực của họ, xem xét mở rộng đơn vị chi nhánh, mô hình kinh doanh khu vực này**

![image](https://github.com/voxuandat/Regions-Business-Performance-ASM-Capacity-Assessment-Report-vietnamese/blob/main/Assets/danh_gia_nhan_su_asm_2.png?raw=true)

Trong top 10 ASM theo xếp hạng tổng, tuy Tỉ lệ trung bình lượng KH được duyệt không cao nhưng **Tỉ lệ Phát sinh dư nợ luôn top đầu**

![image](https://github.com/voxuandat/Regions-Business-Performance-ASM-Capacity-Assessment-Report-vietnamese/blob/main/Assets/danh_gia_nhan_su_asm_3.jpg?raw=true)

#### 3.	Đề xuất
-	Cần có kế hoạch cắt giảm chi phí dự phòng, chi phí hoạt động khác để tối ưu hoá doanh thu, đặc biệt là khu vực Tây Nam Bộ tuy có doanh thu và biên lợi nhuận cao nhất nhưng chi phí cũng chiếm tỉ lệ nhiều nhất và khu vực Bắc Trung Bộ mang lại doanh thu cao như Nam Trung Bộ nhưng chi phí lại cao.
-	Các ASM khu vực Bắc Trung Bộ, Nam Trung Bộ quản lý tốt mạng lưới khu vực của họ, xem xét mở rộng đơn vị chi nhánh, mô hình kinh doanh các khu vực này.

## IV. KẾT QUẢ CÁ NHÂN ĐẠT ĐƯỢC SAU PROJECT
- Sử dụng thành thạo hơn các tools như Dbeaver, PowerBI và các kỹ năng như SQL Programming,...
- Có khả năng xử lý lượng dữ liệu lớn từ hàng triệu đến chục triệu records.
- Tối ưu Cơ sở dữ liệu (Database) bằng cách đánh index, partition vào các bảng.
- Học được các mô hình dữ liệu Dim-Fact, quản lý dữ liệu trong Data Warehouse.
- Năm được kiến thức nghiệp vụ về Thẻ, Tài chính trong các công ty tài chính,...
