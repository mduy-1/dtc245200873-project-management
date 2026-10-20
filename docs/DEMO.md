# Kịch bản demo và đối chiếu tiêu chí

## 1 Mã nguồn và Git

Chạy `git log --oneline`, chỉ ra ba giai đoạn triển khai, mở README và các cấu hình. Cần tạo repository GitHub theo MSSV và push bằng tài khoản của sinh viên. Không chia sẻ token hoặc mật khẩu.

## 2 Website và cơ sở dữ liệu

Mở http://localhost:8080. Tạo dự án, thành viên và task; chuyển task sang Hoàn tất. Refresh trang, mở pgAdmin để xem bản ghi thực tế trong `public.projects`, `public.members`, `public.tasks`.

Trong Query Tool dùng `SELECT t.title, p.name AS project, m.name AS member, t.status FROM tasks t JOIN projects p ON p.id=t.project_id LEFT JOIN members m ON m.id=t.member_id;`.

## 3 Reverse proxy

Website chỉ đi qua cổng 8080 của Nginx. Dùng `curl.exe -I http://localhost:8080` để xem headers. `curl.exe -i http://localhost:8080/metrics` phải trả 404. App và DB không có published port.

## 4 Giám sát

Mở http://localhost:9090/targets, kiểm tra 5 target UP. Mở Grafana http://localhost:3000, đăng nhập admin bằng GRAFANA_PASSWORD trong .env. Chọn Dashboards > Project Management. Dashboard tự nạp từ Git và có CPU/RAM container, HTTP requests, Nginx connections, trạng thái DB, số connection và transactions.

Chạy smoke test vài lần hoặc thao tác trên web, chờ ít nhất 2 phút. Nếu CPU/RAM trống, kiểm tra cAdvisor logs và series `container_memory_working_set_bytes{image!=""}`. Target UP chỉ chứng minh scrape endpoint thành công, chưa chứng minh có metric từng container. Docker Desktop có thể thay layout cgroup/storage theo phiên bản, cần điều chỉnh cAdvisor dựa trên môi trường thực tế.

PromQL:

```promql
up
sum by (status) (rate(web_requests_total[2m]))
nginx_up
pg_up
pg_stat_database_numbackends{datname="projects"}
```

## 5 Log tập trung

App và Nginx ghi log JSON lên named volume. Promtail đọc volume chỉ đọc và gửi Loki; Grafana truy vấn Loki qua mạng nội bộ. Không mount Docker socket cho Promtail. Log lỗi Nginx giữ dạng văn bản; khi dùng `json` hãy chọn riêng access.log.

Mở Grafana > Explore > Loki, chọn Last 15 minutes. Tạo traffic trước khi chạy các query:

```logql
{job="project-management", service="app"}
```

Toàn bộ log request của app.

```logql
{job="project-management", service="nginx", filename="/logs/nginx/access.log"} | json | status >= 400
```

Request HTTP lỗi. Tạo lỗi có chủ đích bằng `curl.exe http://localhost:8080/not-found-demo`, sau đó chạy query.

```logql
sum by (service) (count_over_time({job="project-management"}[5m]))
```

Số dòng log trong 5 phút theo service.

```logql
{service="app"} | json | method="POST"
```

Các thao tác tạo dữ liệu. Promtail positions đặt ở tmpfs: restart sẽ đọc lại các log còn tồn tại và có thể gửi trùng; đây là giới hạn lab, cần durable positions và log rotation trong triển khai lâu dài. Loki giữ dữ liệu tối đa 7 ngày theo chính sách retention.

Promtail đã EOL ngày 02/03/2026. Giữ thành phần này để đáp ứng đề; khi đưa vào môi trường thực tế cần thay bằng Grafana Alloy. Nguồn: https://grafana.com/docs/loki/latest/send-data/promtail/.

## 6 Hardening

Chạy `docker compose exec app id`, `docker compose exec nginx id` để chứng minh non-root. Kiểm tra `docker compose ps` và Compose để chứng minh PostgreSQL không publish port và network data là internal. Xem quyền role bằng `docker compose exec db psql -U postgres -d projects -c '\du'`.

Để chứng minh hạn chế quyền DB, kết nối pgAdmin bằng project_app, chạy `CREATE TABLE permission_probe(id integer);`: phải bị từ chối quyền schema public. SELECT/INSERT/UPDATE dữ liệu vẫn được phép. Không cấp superuser để vượt qua lỗi này.

Mở cấu hình read_only, cap_drop, no-new-privileges; giải thích ngoại lệ log-init, PostgreSQL entrypoint và cAdvisor. Không chụp toàn bộ `docker inspect`/`docker compose config` vì có thể lộ biến môi trường chứa mật khẩu.

## Minh chứng cần thu

1. GitHub source và lịch sử 3 commit.
2. Website có dữ liệu và bảng task.
3. pgAdmin cùng kết quả SQL.
4. Nginx response headers.
5. Prometheus targets UP và Grafana có dữ liệu container/web/DB.
6. Ba truy vấn Loki có kết quả.
7. UID non-root, role DB hạn chế và network isolation.

Ảnh phải lấy từ lần chạy thực tế, không dùng cấu hình hoặc sơ đồ thay cho kết quả vận hành. Báo cáo tối thiểu 10 trang và bìa theo mẫu trường được làm sau khi có thông tin sinh viên và các minh chứng này.
