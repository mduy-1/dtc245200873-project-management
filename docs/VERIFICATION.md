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
- Đã push lên repository công khai https://github.com/mduy-1/dtc245200873-project-management, branch main. Tên repository theo MSSV dtc245200873; tài khoản hiện có là mduy-1.
- Chưa có screenshot demo và báo cáo sinh viên.

## Chuyển sang Ubuntu WSL2 ngày 22/10/2026

- Cài Ubuntu-24.04 từ file Ubuntu chính thức, kiểm tra SHA256 theo danh mục Microsoft WSL trước khi cài; `cat /etc/os-release` xác nhận Ubuntu 24.04.5 LTS, kernel `6.18.54.1-microsoft-standard-WSL2`.
- Docker Engine Community 29.9.2 và Compose plugin 5.6.1 được cài bằng apt repository chính thức của Docker. `docker info` xác nhận OperatingSystem Ubuntu 24.04.5 LTS, DockerRootDir `/var/lib/docker`.
- Mã nguồn nằm tại `/home/dtc245200873/project-management`; `.env` permission 600, thuộc user dtc245200873. Không cấp user vào nhóm docker; quản trị qua `wsl -u root`.
- Stack Docker Desktop cũ đã dừng. Sao lưu và phục hồi 6 volume: PostgreSQL, pgAdmin, Grafana, Prometheus, Loki và logs. Các image được chuyển cục bộ từ Docker Desktop sang Docker Ubuntu rồi chạy bằng Compose.
- PostgreSQL sau phục hồi: 4 projects, 3 members, 6 tasks. `/health` trả status ok, database connected.
- 11 service dài hạn chạy trong Ubuntu; app và DB healthy. log-init là tác vụ một lần và Exited (0) đúng thiết kế.
- Windows kiểm tra website `/health`, pgAdmin `/login`, Grafana `/api/health`, Prometheus `/-/ready`: tất cả HTTP 200.
- Prometheus: 5 target UP, không lastError. Grafana đăng nhập API bằng mật khẩu cũ thành công, dashboard UID project-lab có 9 panel.
- `scripts/verify-runtime.js`: 11 series bộ nhớ container có image; ba query LogQL cho app, nginx và count_over_time đều có kết quả.
- App UID 1000 và Nginx UID 101 được kiểm tra trong container Ubuntu.
- Khi không giữ phiên WSL, distro tự dừng làm các container ngừng theo. Đã khắc phục bằng phiên nền `sleep infinity`; `scripts/start-wsl.ps1` giữ phiên này trong các lần khởi động sau. Không tạo scheduled task hay tự chạy cùng Windows.
- Compose có cảnh báo volume đã tồn tại do phục hồi tạo volume trước; dữ liệu được mount và hoạt động, không xóa/recreate volume để loại bỏ cảnh báo.
- Chưa có screenshot riêng của Ubuntu WSL2 hoặc báo cáo hoàn chỉnh. Các giới hạn xác thực app/dependency audit trước đó vẫn cần xử lý trước khi triển khai Internet.
