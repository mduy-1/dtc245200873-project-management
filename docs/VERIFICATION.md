# Trạng thái kiểm chứng

Tệp này phân biệt cấu hình đã chuẩn bị và kết quả đã chạy. Không coi việc có Compose/README là bằng chứng tất cả dịch vụ hoạt động.

- Có mã nguồn app, DB init, Nginx, dashboard, exporter, Loki và Promtail.
- Có smoke test kiểm tra DB, tạo dữ liệu liên kết, đổi trạng thái, đọc lại và headers.
- `docker compose config --quiet`: PASS ngày 20/10/2026, sau khi tạo .env.
- `node --check app/server.js` và `node --check app/public/app.js`: PASS.
- `git diff --check`: PASS.
- `docker compose up -d --build`: chưa chạy được; Docker Engine trả `500 Internal Server Error` tại `/_ping`. `docker version` cũng trả 500 ở endpoint `/version`. Docker Desktop CLI báo ứng dụng đã chạy nhưng không lấy được trạng thái Engine.
- Chưa xác minh build image, health container, SQL runtime, smoke test HTTP, dữ liệu dashboard hoặc LogQL. Cần sửa/khởi động lại Docker Desktop Linux Engine rồi chạy lại lệnh triển khai và checklist DEMO.md.
- Chưa có GitHub remote, screenshot demo và báo cáo sinh viên.
