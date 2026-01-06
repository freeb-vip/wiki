# Dockerfile 说明文档

## 概述

wiki 提供多个 Dockerfile，与原始 requarks/wiki 项目保持一致。

## Dockerfile 选项

### 1. Dockerfile（标准版 - Node.js 24）
**用途**：标准的生产环境构建

**特点**：
- 使用 Node.js 24-alpine 作为基础镜像
- 包含完整的构建流程（客户端资源和服务器代码）
- 多阶段构建优化镜像大小
- 使用 node 用户运行应用

**构建命令**：
```bash
docker build -t wiki:latest -f Dockerfile .
```

**Dockerfile 流程**：
1. 构建阶段（assets）：编译客户端资源
2. 发布阶段：创建最小运行镜像

### 2. Dockerfile.build（完整构建版 - Node.js 24）
**用途**：完整的本地开发和构建

**特点**：
- 与 Dockerfile 完全相同
- 用于源代码完整构建

**构建命令**：
```bash
docker build -t wiki:latest-full -f Dockerfile.build .
```

### 3. Dockerfile.arm（ARM 架构版 - Node.js 20）
**用途**：ARM 架构支持（树莓派、ARM 服务器等）

**特点**：
- 使用 Node.js 20-alpine（ARM 更稳定）
- 优化的依赖安装
- 适合资源受限的环境

**构建命令**：
```bash
docker build -t wiki:latest-arm -f Dockerfile.arm .
```

### 4. Dockerfile.openshift（OpenShift 兼容版）
**用途**：在 OpenShift 上运行

**特点**：
- 基于 requarks/wiki:2 官方镜像
- 配置 OpenShift 权限和用户
- 支持任意用户 ID 运行（1001）

**构建命令**：
```bash
docker build -t wiki:latest-openshift -f Dockerfile.openshift .
```

## 镜像规格对比

| 特性 | Dockerfile | Dockerfile.arm | Dockerfile.openshift |
|------|-----------|-----------------|----------------------|
| Node.js | 24-alpine | 20-alpine | 基于 requarks/wiki:2 |
| 构建方式 | 完整构建 | 完整构建 | 基础镜像扩展 |
| 镜像大小 | ~400MB | ~380MB | ~450MB |
| 构建时间 | ~5-10分钟 | ~5-10分钟 | ~1分钟 |
| 推荐用途 | 生产环境 | ARM 架构 | OpenShift |
| 编译工具 | 包含 | 包含 | 不包含 |

## 完整构建流程

### 标准构建
```bash
# 1. 克隆或准备源代码
cd /path/to/wiki

# 2. 构建镜像
docker build -t myregistry/wiki:latest -f Dockerfile .

# 3. 测试运行
docker run --rm \
  -e DB_TYPE=postgres \
  -e DB_HOST=postgres.example.com \
  -e DB_PORT=5432 \
  -e DB_NAME=wiki \
  -e DB_USER=wiki \
  -e DB_PASS=password \
  -p 3000:3000 \
  myregistry/wiki:latest
```

### 多架构构建（使用 buildx）
```bash
# 启用 buildx
docker buildx create --name multiarch --use

# 构建多架构镜像
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  -t myregistry/wiki:latest \
  -f Dockerfile \
  --push \
  .
```

## 环境变量

### 数据库连接
```bash
DB_TYPE=postgres          # 数据库类型
DB_HOST=localhost         # 数据库地址
DB_PORT=5432             # 数据库端口
DB_NAME=wiki             # 数据库名
DB_USER=wiki             # 数据库用户
DB_PASS=password         # 数据库密码
DB_SSL=false             # 启用 SSL
DB_SSL_CA=               # CA 证书路径
```

### 应用配置
```bash
NODE_ENV=production      # Node 环境
LOG_LEVEL=info          # 日志级别
HA_ACTIVE=true          # 高可用模式
```

## 基础镜像更新

为保持与 requarks/wiki 一致，建议定期检查和更新基础镜像：

```bash
# 检查最新的 Node 版本
docker pull node:latest-alpine

# 更新 Dockerfile 中的 Node 版本
# FROM node:24-alpine -> FROM node:25-alpine
```

## 性能优化建议

1. **多阶段构建**
   - 减少最终镜像大小
   - 分离构建工具和运行时

2. **Alpine 基础镜像**
   - 更小的镜像大小（~50MB vs ~900MB）
   - 更快的拉取和启动

3. **非 root 用户运行**
   - 提高安全性
   - 限制容器权限

4. **明确指定依赖版本**
   - 保证构建一致性
   - 方便版本追踪

## 镜像推送

### 推送到 Docker Hub
```bash
docker build -t myusername/wiki:1.0.0 -f Dockerfile .
docker push myusername/wiki:1.0.0

# 添加 latest 标签
docker tag myusername/wiki:1.0.0 myusername/wiki:latest
docker push myusername/wiki:latest
```

### 推送到私有仓库
```bash
docker build -t myregistry.com/wiki:1.0.0 -f Dockerfile .
docker push myregistry.com/wiki:1.0.0
```

## 故障排查

### 构建失败
```bash
# 添加构建进度输出
docker build --progress=plain -f Dockerfile .

# 检查 npm 依赖问题
docker build --no-cache -f Dockerfile .
```

### 运行时问题
```bash
# 查看镜像信息
docker inspect wiki:latest

# 进入容器调试
docker run -it --entrypoint /bin/sh wiki:latest

# 查看完整日志
docker logs <container-id>
```

## 与原始项目的一致性

✅ 使用相同的 Node 版本（24-alpine）  
✅ 相同的多阶段构建过程  
✅ 相同的运行用户（node）  
✅ 相同的端口配置（3000, 3443）  
✅ 相同的应用启动命令  
✅ 相同的依赖管理方式  
✅ 相同的配置文件位置  

## 最佳实践

1. **版本控制**
   - 使用具体的版本标签而不是 `latest`
   - 追踪 Node 版本变更

2. **安全性**
   - 定期扫描镜像漏洞
   - 使用私有镜像仓库
   - 启用镜像签名验证

3. **监控**
   - 记录构建日志
   - 监控镜像大小
   - 追踪构建时间

## 相关文件

- `Dockerfile` - 标准版生产构建
- `Dockerfile.build` - 完整构建版
- `Dockerfile.arm` - ARM 架构版
- `Dockerfile.openshift` - OpenShift 兼容版
- `docker-compose.yml` - 本地开发用
- `.helmignore` - Helm 打包忽略规则
