# Triển khai trên Ubuntu trong VMware

Đích triển khai là Ubuntu VM trong VMware. Docker Engine và Docker Compose plugin phải cài trực tiếp trong Ubuntu. Không cần cài Ubuntu WSL để dùng máy ảo này.

## Chuẩn bị

Kiểm tra trên Ubuntu:

```bash
cat /etc/os-release
hostname -I
docker version
docker compose version
```

Nếu chưa có Docker Engine, cài theo kho apt chính thức: https://docs.docker.com/engine/install/ubuntu/. Không gỡ hoặc thay Docker hiện có trước khi kiểm tra các workload của máy ảo.

## Chạy mã nguồn

```bash
git clone https://github.com/mduy-1/dtc245200873-project-management.git
cd dtc245200873-project-management
bash scripts/start.sh
```

Nếu user Ubuntu chưa có quyền Docker, dùng `sudo docker ...` cho các lệnh Docker hoặc nhờ quản trị viên cấp quyền phù hợp. Không chỉnh socket Docker thành world-writable.

Compose bind các giao diện vào 127.0.0.1. Trình duyệt trong Ubuntu truy cập localhost bình thường. Để mở từ Windows mà vẫn giữ bind localhost, chạy SSH tunnel trong PowerShell và giữ cửa sổ đó mở:

```powershell
ssh -N -L 8080:127.0.0.1:8080 -L 3000:127.0.0.1:3000 -L 5050:127.0.0.1:5050 -L 9090:127.0.0.1:9090 ubuntu@<IP_UBUNTU>
```

Sau đó truy cập các URL localhost trên Windows. Tắt stack Docker Desktop cũ trước khi mở tunnel nếu stack cũ đang chiếm các cổng này. Không cần mở thêm cổng web trong UFW khi dùng SSH tunnel; cổng SSH 22 cần được phép từ máy Windows.

## Dữ liệu khi chuyển môi trường

Named volumes thuộc từng Docker Engine và không tự chuyển giữa Docker Desktop và Ubuntu VM. Nếu có dữ liệu cần giữ, phải sao lưu/khôi phục PostgreSQL và các volume Grafana, pgAdmin, Prometheus, Loki trước khi đổi môi trường chính. Giữ `.env` hiện tại khi phục hồi dữ liệu cũ. Không dùng `docker compose down -v` trên bản cũ.

## Kiểm chứng

```bash
docker compose ps
curl -fsS http://127.0.0.1:8080/health
curl -I http://127.0.0.1:8080
docker compose exec -T app node < scripts/verify-runtime.js
docker compose exec app id
docker compose exec nginx id
```

Chụp ảnh thực tế và cập nhật kết quả kiểm chứng sau khi chạy trên Ubuntu; kết quả kiểm tra Docker Desktop trước đây không phải bằng chứng đã chạy trên máy ảo.
