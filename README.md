# 🛍️ Dự Án Ứng Dụng Thương Mại Điện Tử – Ứng Dụng Di Động Đa Nền Tảng

## 🌐 Tổng Quan Dự Án

Đây là ứng dụng thương mại điện tử **đa nền tảng** được xây dựng bằng **Flutter**, chuyên bán **máy tính và linh kiện máy tính**.
Ứng dụng hỗ trợ **2 vai trò người dùng**:

* **Khách hàng** (mua sắm, theo dõi đơn hàng, tích điểm, đánh giá sản phẩm…)
* **Admin duy nhất** (quản lý sản phẩm, người dùng, đơn hàng, dashboard thống kê…)

Điểm nổi bật:

* **Triển khai đa nền tảng**: Android (APK), Windows (EXE 64-bit), Web (Firebase Hosting).
* **Hỗ trợ ngoại tuyến**: cache dữ liệu bằng Hive, hoạt động ngay cả khi mất kết nối mạng.
* **Responsive Design**: UI tương thích nhiều kích thước màn hình.
* **Real-time**: cập nhật bình luận & đánh giá sản phẩm tức thời bằng WebSocket.

---

## 👥 Thành Viên Nhóm

* **Nguyễn Vĩnh Hưng** – Trưởng nhóm
* **Nguyễn Công Quang** – Lập Trình Viên

---

## 📝 Vai Trò Và Đóng Góp

* **Nguyễn Vĩnh Hưng**:
  
  * Phát triển các tính năng quản lý người dùng (đăng ký, đăng nhập, quản lý hồ sơ, khôi phục mật khẩu) và tính năng admin (quản lý người dùng, quản lý đơn hàng)
  * Xử lý triển khai web và tích hợp các tính năng liên quan đến Firebase Authentication.
  * Chat hỗ trợ khách hàng, dashboard, và hỗ trợ ngoại tuyến với Hive. Tích hợp Firebase Functions cho các tính năng bổ sung.

* **Nguyễn Công Quang**:

  * Triển khai các tính năng liên quan đến **sản phẩm** (danh mục với phân trang, chi tiết sản phẩm/biến thể, tìm kiếm – lọc – sắp xếp).
  * Quản lý giỏ hàng, thanh toán, mã giảm giá, chương trình tích điểm.
  * Quản lý dữ liệu sản phẩm trên Firestore.
  * Xây dựng UI/UX (màn hình chính, thiết kế responsive), đánh giá/đánh giá sản phẩm với WebSockets, theo dõi/lịch sử đơn hàng
---

## 🛠 Công Nghệ Sử Dụng

### **Frontend (Flutter/Dart)**

* **Kiến trúc & Quản lý trạng thái**: GetX, Provider, flutter\_bloc (MVVM + reactive state management).
* **UI/UX nâng cao**: Carousel Slider, Flutter Swiper, Scrollable Positioned List, Shimmer (lazy loading), Readmore (mô tả dài), Flutter Rating Bar (đánh giá sao), VelocityX & Iconsax (UI tiện ích & icon hiện đại).

### **API & Xử lý dữ liệu**

* **Dio + Retrofit + Json Serializable** – gọi API, parse JSON & sinh code tự động.
* **Intl** – đa ngôn ngữ, định dạng tiền tệ.

### **Backend (Firebase)**

* Firebase Authentication – xác thực người dùng.
* Cloud Firestore – cơ sở dữ liệu trực tuyến.
* Firebase Functions – xử lý logic server-side.
* Firebase Storage – lưu trữ hình ảnh sản phẩm & avatar.
* WebSocket / Real-time Updates – cập nhật bình luận và rating tức thời.

### **Ngoại tuyến & Hiệu năng**

* Hive – cache dữ liệu offline.
* Image Picker – upload ảnh sản phẩm/chat hỗ trợ khách hàng.

### **Triển khai & Công cụ**

* Firebase Hosting – triển khai Web version.
* Git/GitHub – kiểm soát phiên bản & cộng tác nhóm.
* Đa nền tảng: APK Android (arm64), EXE Windows (64-bit), Web.

---

## 🎥 Video Demo

Xem video demo dự án tại đây: [Video Demo](https://www.canva.com/design/DAGn0FOyah8/1rFyG5i-wlsB5nr6YvlVJg/edit?utm_content=DAGn0FOyah8&utm_campaign=designshare&utm_medium=link2&utm_source=sharebutton)

---
