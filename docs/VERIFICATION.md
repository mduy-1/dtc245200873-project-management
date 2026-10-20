# Trạng thái kiểm chứng

Tệp này phân biệt cấu hình đã chuẩn bị và kết quả đã chạy. Không coi việc có Compose/README là bằng chứng tất cả dịch vụ hoạt động.

- Có mã nguồn app, DB init, Nginx, dashboard, exporter, Loki và Promtail.
- Có smoke test kiểm tra DB, tạo dữ liệu liên kết, đổi trạng thái, đọc lại và headers.
- `docker compose config --quiet`: PASS ngày 20/10/2026, sau khi tạo .env.
- `node --check app/server.js` và `node --check app/public/app.js`: PASS.
- `git diff --check`: PASS.
- Lần chạy tiếp theo ngày 20/10/2026: Docker Engine hoạt động, build ứng dụng và khởi động Compose thành công.
- Đã cập nhật pgAdmin từ 9.2 lên 9.17 để tương thích cap_drop/no-new-privileges và tắt Postfix; cập nhật cAdvisor lên 0.55.1 để tương thích Docker containerd image store.
- App và PostgreSQL healthy; 11 service dài hạn chạy, log-init Exited (0) đúng thiết kế.
- `scripts/smoke.ps1`: PASS. Tạo dự án, thành viên, task có liên kết DB; cập nhật done; đọc lại dữ liệu; kiểm tra security headers.
- Prometheus API: đủ 5 job app, containers, nginx, postgres, prometheus UP, lastError rỗng.
- Grafana `/api/health`: database ok. Chưa kiểm tra trực quan từng panel dashboard.
- pgAdmin `/login`: HTTP 200. Chưa thao tác đăng nhập và kết nối DB qua giao diện pgAdmin.
- `scripts/verify-runtime.js`: 11 series RAM container có image; cả ba truy vấn Loki cho app, nginx và count_over_time có dữ liệu.
- Build npm báo 4 dependency vulnerabilities (2 moderate, 2 high); cần audit và nâng dependency trước khi triển khai ngoài môi trường lab. API vẫn chưa có xác thực, chỉ bind localhost theo thiết kế.
- Chưa có GitHub remote, screenshot demo và báo cáo sinh viên.
