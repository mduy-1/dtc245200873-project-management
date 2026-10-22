# Ubuntu WSL2 và Docker Engine

Ubuntu WSL2 là môi trường Linux riêng trên Windows. Docker Engine được cài trực tiếp trong Ubuntu qua kho apt chính thức của Docker; không dùng daemon Docker Desktop để chạy bản triển khai này.

## Môi trường đã cài trên máy làm bài

- Distribution: `Ubuntu-24.04`, Ubuntu 24.04.5 LTS, WSL version 2.
- User Linux mặc định: `dtc245200873`.
- Thư mục bài: `/home/dtc245200873/project-management`.
- Docker Engine Community 29.9.2; Docker Compose plugin 5.6.1.
- User `dtc245200873` đã được thêm vào nhóm docker theo yêu cầu người dùng ngày 22/10/2026 và kiểm tra chạy Docker thành công không cần sudo. Nhóm docker có quyền tương đương root; mật khẩu sudo chưa được thiết lập. Để quản trị stack từ Windows:

```powershell
wsl -d Ubuntu-24.04 -u dtc245200873 --cd /home/dtc245200873/project-management
```

Trong terminal Ubuntu đó dùng `docker compose ps`, `docker compose up -d` hoặc `docker compose logs`. Docker daemon được enable bằng systemd, tự chạy khi distro khởi động; Ubuntu WSL không tự khởi động cùng Windows nếu chưa có tác vụ khởi động.

Trên máy này, sau khi đóng hết phiên WSL, distro tự tắt và kéo theo Docker. Đã dùng một phiên `sleep infinity` nền để giữ distro hoạt động trong lúc demo. Sau khi khởi động lại Windows, chạy từ thư mục bài:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/start-wsl.ps1
```

Script chỉ khởi chạy stack đã cài, giữ một phiên WSL ẩn và không tạo tác vụ tự khởi động Windows. Để dừng, vào terminal quản trị Ubuntu, chạy `docker compose stop`, thoát terminal rồi dùng `wsl --terminate Ubuntu-24.04` từ Windows. Chỉ terminate sau khi dừng sạch các dịch vụ của distro.

`.env` hiện tại và sáu volume từ Docker Desktop đã được sao lưu/phục hồi. Không cần sinh lại mật khẩu khi dùng dữ liệu đã chuyển. Bản sao lưu ở `.local/desktop-volumes-20261022/` trên Windows, nằm ngoài Git.

## Cài Ubuntu

Chạy trên Windows:

```powershell
wsl --install -d Ubuntu-24.04
```

Hoàn thành tạo user Linux khi được hỏi. Kiểm tra `wsl --list --verbose`: dòng Ubuntu phải có VERSION 2. Nếu cách tải tự động không hoạt động, có thể tải file `.wsl` từ URL chính thức trong danh mục Microsoft WSL, kiểm tra SHA256 rồi dùng chức năng cài từ file của WSL.

## Cài Docker bên trong Ubuntu

```bash
git clone https://github.com/mduy-1/dtc245200873-project-management.git
cd dtc245200873-project-management
sudo bash scripts/install-docker-ubuntu.sh
sudo bash scripts/start.sh
```

Trước khi cài, kiểm tra các workload Docker đang có trong Ubuntu. Script dành cho bản Ubuntu mới, dùng apt repository chính thức https://docs.docker.com/engine/install/ubuntu/.

Mã nguồn nên đặt trong thư mục nhà Linux, thay vì chạy trực tiếp trên `/mnt/c`, để giữ đúng quyền và tránh lỗi xuống dòng script.

Nếu muốn chạy Docker không qua sudo, quản trị viên có thể cấp user quyền nhóm docker; nhóm này có quyền quản trị host. Không dùng `chmod 666 /var/run/docker.sock`.

## Truy cập từ Windows

Sau khi stack chạy trong WSL2:

- Website: http://localhost:8080
- pgAdmin: http://localhost:5050
- Grafana: http://localhost:3000
- Prometheus: http://localhost:9090

Docker Desktop cũ phải dừng stack chiếm cùng các cổng. Giữ volumes cũ để dự phòng. Dữ liệu không tự chuyển giữa Docker Desktop và Docker Engine Ubuntu; sao lưu và phục hồi trước khi coi Ubuntu là bản chính nếu cần giữ dữ liệu.

## Kiểm tra đúng Engine

Chạy bên trong Ubuntu:

```bash
cat /etc/os-release
uname -r
sudo docker info --format '{{.OperatingSystem}} | {{.Name}} | {{.DockerRootDir}}'
sudo docker compose ps
curl -fsS http://localhost:8080/health
sudo docker compose exec -T app node < scripts/verify-runtime.js
```

`docker info` phải chỉ tới daemon trên Ubuntu, không phải Docker Desktop. Chụp minh chứng từ lần chạy thật trong WSL2 và ghi đúng môi trường trong báo cáo.
