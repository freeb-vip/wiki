# Docker Compose 使用指南

## 概述

本 `docker-compose.yml` 用于本地开发环境，包含 Wiki.js 应用和 PostgreSQL 数据库。

## 快速开始

### 1. 启动服务
```bash
# 启动全部服务
docker-compose up

# 后台启动
docker-compose up -d

# 显示日志
docker-compose logs -f
```

### 2. 访问应用
```
http://localhost:3000
```

### 3. 数据库信息
```
Host: localhost
Port: 5432
Database: wiki
User: wiki
Password: wiki123
```

### 4. 停止服务
```bash
# 停止服务
docker-compose down

# 停止并删除卷（清除数据）
docker-compose down -v
```

## 服务配置

### PostgreSQL
- **镜像**: postgres:15-alpine
- **端口**: 5432
- **数据库**: wiki
- **用户**: wiki
- **密码**: wiki123
- **数据持久化**: postgres_data 卷

### Wiki.js
- **构建**: 从源代码构建
- **Dockerfile**: Dockerfile
- **端口**: 3000
- **依赖**: postgres（需要健康检查通过）
- **数据持久化**: wiki_data 卷

## 常用命令

### 查看日志
```bash
# 查看所有服务日志
docker-compose logs

# 查看特定服务日志
docker-compose logs -f postgres
docker-compose logs -f wiki

# 显示最后 100 行日志
docker-compose logs --tail 100
```

### 管理服务
```bash
# 启动特定服务
docker-compose up -d postgres

# 重启服务
docker-compose restart wiki

# 强制重建镜像
docker-compose up -d --build

# 清理未使用的资源
docker-compose down --remove-orphans
```

### 进入容器
```bash
# 进入 Wiki.js 容器
docker-compose exec wiki /bin/sh

# 进入 PostgreSQL 容器
docker-compose exec postgres psql -U wiki -d wiki

# 查看容器状态
docker-compose ps
```

## 环境变量配置

### 修改数据库密码
编辑 `docker-compose.yml`，修改以下部分：

```yaml
postgres:
  environment:
    POSTGRES_PASSWORD: your-new-password

wiki:
  environment:
    DB_PASS: your-new-password
```

### 修改应用配置
```yaml
wiki:
  environment:
    NODE_ENV: development
    LOG_LEVEL: debug
    HA_ACTIVE: "false"
```

## 数据库初始化

### 手动创建 Wiki 模式
```bash
# 连接到数据库
docker-compose exec postgres psql -U wiki -d wiki

# 查看已存在的表
\dt

# 退出
\q
```

### 备份数据库
```bash
docker-compose exec postgres pg_dump -U wiki wiki > wiki_backup.sql
```

### 恢复数据库
```bash
docker-compose exec -T postgres psql -U wiki wiki < wiki_backup.sql
```

## 故障排查

### 应用无法连接数据库
```bash
# 检查 PostgreSQL 是否运行
docker-compose ps

# 查看 PostgreSQL 日志
docker-compose logs postgres

# 测试数据库连接
docker-compose exec postgres pg_isready
```

### 健康检查失败
```bash
# 检查容器状态
docker-compose ps

# 查看健康检查详情
docker-compose exec wiki curl -v http://localhost:3000/healthz

# 查看应用日志
docker-compose logs wiki
```

### 端口已被占用
```bash
# 修改端口映射
# 编辑 docker-compose.yml，修改：
# ports:
#   - "3001:3000"  # 使用 3001 访问

docker-compose up -d
```

## 开发工作流

### 1. 初始设置
```bash
# 启动所有服务
docker-compose up -d

# 等待应用启动（约 30-60 秒）
docker-compose logs -f wiki

# 访问 http://localhost:3000
```

### 2. 代码修改
```bash
# 修改源代码后，重建镜像
docker-compose up -d --build

# 或重启应用
docker-compose restart wiki
```

### 3. 数据库变更
```bash
# 查看现有表
docker-compose exec postgres psql -U wiki -d wiki -c '\dt'

# 执行 SQL 脚本
docker-compose exec -T postgres psql -U wiki -d wiki < script.sql
```

### 4. 清理和重置
```bash
# 保留数据停止
docker-compose stop

# 删除所有数据并重新开始
docker-compose down -v
docker-compose up -d
```

## 性能优化

### 1. 使用 bind mount 加速开发
编辑 `docker-compose.yml`：
```yaml
wiki:
  volumes:
    - ../server:/wiki/server
    - ../assets:/wiki/assets
    - /wiki/node_modules
```

### 2. 增加内存限制
```yaml
services:
  postgres:
    mem_limit: 1g
    
  wiki:
    mem_limit: 2g
```

### 3. 调整资源请求
```yaml
services:
  wiki:
    deploy:
      resources:
        limits:
          cpus: '1'
          memory: 2G
        reservations:
          cpus: '0.5'
          memory: 1G
```

## 生产部署

对于生产环境，不建议使用 docker-compose，改用 Kubernetes Helm chart：

```bash
# 使用 Helm chart 部署
helm install wiki ./wiki \
  --set postgresql.host="prod-postgres.example.com" \
  --set secret.password="secure-password"
```

详见 [README.md](README.md) 和 [DEPLOYMENT-GUIDE.md](DEPLOYMENT-GUIDE.md)。

## 网络配置

### 外部访问
如需从其他机器访问，修改端口映射：

```yaml
services:
  wiki:
    ports:
      - "0.0.0.0:3000:3000"  # 监听所有网卡
```

### 自定义网络
所有服务都在 `wiki-network` 网络中：

```bash
# 查看网络
docker network ls | grep wiki

# 查看网络详情
docker network inspect wiki_wiki-network
```

## 日志管理

### 设置日志驱动
```yaml
services:
  wiki:
    logging:
      driver: json-file
      options:
        max-size: "100m"
        max-file: "10"
```

### 导出日志
```bash
# 导出所有日志
docker-compose logs > app.log

# 导出特定服务日志
docker-compose logs wiki > wiki.log
```

## 相关文档

- [Dockerfile 说明](DOCKERFILE-README.md)
- [Helm Chart 部署](README.md)
- [快速参考](QUICK-REFERENCE.md)
