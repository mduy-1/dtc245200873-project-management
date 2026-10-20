#!/bin/sh
set -eu
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" --set=app_password="$APP_DB_PASSWORD" --set=monitor_password="$MONITOR_DB_PASSWORD" <<'SQL'
CREATE ROLE project_app LOGIN PASSWORD :'app_password';
CREATE ROLE project_monitor LOGIN PASSWORD :'monitor_password';
GRANT pg_monitor TO project_monitor;
REVOKE CREATE ON SCHEMA public FROM PUBLIC;
CREATE TABLE projects(id SERIAL PRIMARY KEY,name VARCHAR(200) NOT NULL,description TEXT NOT NULL DEFAULT '');
CREATE TABLE members(id SERIAL PRIMARY KEY,name VARCHAR(200) NOT NULL,email VARCHAR(200) UNIQUE NOT NULL);
CREATE TABLE tasks(id SERIAL PRIMARY KEY,title VARCHAR(200) NOT NULL,project_id INTEGER NOT NULL REFERENCES projects(id),member_id INTEGER REFERENCES members(id),status VARCHAR(10) NOT NULL DEFAULT 'todo' CHECK(status IN ('todo','doing','done')));
GRANT CONNECT ON DATABASE projects TO project_app;
GRANT USAGE ON SCHEMA public TO project_app;
GRANT SELECT,INSERT,UPDATE,DELETE ON ALL TABLES IN SCHEMA public TO project_app;
GRANT USAGE,SELECT ON ALL SEQUENCES IN SCHEMA public TO project_app;
INSERT INTO projects(name,description) VALUES('Triển khai Đề 14','Docker Compose, giám sát và log tập trung');
INSERT INTO members(name,email) VALUES('Sinh viên demo','demo@example.com');
INSERT INTO tasks(title,project_id,member_id,status) VALUES('Cấu hình Nginx',1,1,'done'),('Kiểm tra dashboard',1,1,'doing'),('Demo LogQL',1,1,'todo');
SQL
