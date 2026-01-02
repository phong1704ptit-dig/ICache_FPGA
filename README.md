# ICache_FPGA
Dự án là mô tả phần cứng triển khai cache lệnh sử dụng ánh xạ tập kết hợp, phương pháp thay thế dòng cache ít được sử dụng gần đây nhất(LRU), kiến trúc cache look through. Miễn sao bộ nhớ chính hỗ trợ bus AXI4 full thì đều có thể ghép vào dự án này. 

Thông số cache là cache line 32B, 4 way, dung lượng cache 32KB, kích thước bộ nhớ chính 512MB. Đối với kích thước bộ nhớ chính có thể tùy ý miễn sao địa chỉ 32bit nếu không sẽ cần chỉnh sửa mã nguồn một chút phần độ rộng địa chỉ truy cập.

Với cache line là 32Byte vậy cần 5 bit word biểu diễn địa chỉ của từ trong line, bộ nhớ cache có dung lượng 32KB và chi là 4 way tức là mỗi way là 8KB. Kết hợp với kích thước line 32Byte ta suy ra được mỗi way có 256 line. Vậy cần 8 bit set địa chỉ dòng trong đường. Bộ nhớ chính có dung lượng 512MB tức là cần 29bit địa chỉ để biểu diễn cho bộ nhớ chính. Áp dụng kết quả tính toán trên ta có được Tag cần 16 bit để biểu diễn.

Cấu trúc cache gồm 3 phần, thứ nhất là Cache controller, thứ hai là TagRAM và cuối cùng là SRAM. Cache controller quản lý sự kiện HIT, MISS, đưa ra các yêu cầu đối với SRAM và TagRAM đồng thời nó cũng truy cập vào bộ nhớ chính DDR3 khi sự kiện MISS xảy ra. SRAM là nơi lưu dữ liệu các dòng nhớ trong cache. TagRAM lưu Tag của line chứa trong từng way của cache đỉ chỉ ra line đó thuộc page nào trong bộ nhớ chính, đồng thời nó cũng dữ các cờ valid chỉ ra dữ liệu có hợp lệ hay không và 3 bit phục vụ cho việc tìm ứng viên bị thay thế LRU.

SRAM bao gồm 4 way mỗi way 8KB và cung cấp độ rộng bus dữ liệu lên tới 256 bit tương đương 32B bằng với một dòng cache. Sử dụng 8 khối block ram mỗi khối cung cấp bus dữ liệu 32bit ghép vào để đạt được độ rộng bus dữ liệu mỗi chu kì là 256bit

TagRAM bao gồm 4 khối block ram có độ rộng dữ liệu mỗi khối là 16bit lưu set của mỗi line. Cache truy cấp nó và đọc ra set sẽ biết line đó đang ánh xạ tới page nào của bộ nhớ chính từ đó phục vụ cho việc xác định sự kiện HIT hay MISS. Bên cạch đó TagRAM còn chứa 1 bộ nhớ LUTRAM chứa 256 thanh ghi mỗi thanh 7 bit chứa 4 bit valid cho 4 way và 3 bit LRU.

## Ví dụ cache với bộ nhớ chính là DDR3 của chíp FPGA SoC XC7Z020clg400.
Đối với chính SoC FPGA đó bộ nhớ DDR3 được quản lý bằng core ARM(PS) trên board. Mọi hoạt động đọc ghi DDR3 đều phải thông qua core PS này. Trong dự án này Icache giao tiếp với PS bằng bus AXI4 full với kết nối như sau:
<p align="center">
  <img src="Image/Blockdesign.png" alt="SoC Architecture" width="800">
  <br>
  <i>Hình 1: Block Design giao tiếp DDR3 board SoC XC7Z020clg400</i>
</p>

## Mô phỏng
<p align="center">
  <img src="Image/sim.png" alt="SoC Architecture" width="800">
  <br>
  <i>Hình 2: Hình ảnh mô phỏng cacheHIT và cache MISS</i>
</p>
