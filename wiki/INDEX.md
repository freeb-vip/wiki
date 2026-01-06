# Wiki Helm Chart 索引

快速导航：选择您需要的内容

## 🎯 按使用场景

### 我要在本地开发
👉 [DOCKER-COMPOSE-README.md](DOCKER-COMPOSE-README.md)
- 快速启动本地开发环境
- PostgreSQL + Wiki.js 集成
- 常用命令和故障排查

### 我要部署到 Kubernetes
👉 [README.md](README.md) 或 [DEPLOYMENT-GUIDE.md](DEPLOYMENT-GUIDE.md)
- Helm Chart 部署
- 多种部署场景
- 配置说明

### 我要构建自定义镜像
👉 [DOCKERFILE-README.md](DOCKERFILE-README.md)
- 4 种 Dockerfile 说明
- 构建脚本使用
- 镜像规格对比

### 我要快速查找命令
👉 [QUICK-REFERENCE.md](QUICK-REFERENCE.md)
- 常用 Helm 命令
- Docker 命令
- 参数速查表

## 📖 按内容类型

### 快速开始
| 内容 | 文件 |
|------|------|
| 5分钟快速部署 | [README.md#快速开始](README.md) |
| 最小化配置 | [examples/values-minimal.yaml](examples/values-minimal.yaml) |
| Docker Compose 快速启动 | [DOCKER-COMPOSE-README.md](DOCKER-COMPOSE-README.md) |

### 详细配置
| 内容 | 文件 |
|------|------|
| 所有配置参数说明 | [values.yaml](values.yaml) 注释 |
| PostgreSQL 连接配置 | [README.md#配置](README.md) |
| 密码管理方案 | [QUICK-REFERENCE.md#密码管理](QUICK-REFERENCE.md) |

### 部署环境示例
| 环境 | 配置文件 | 说明 |
|------|--------|------|
| 开发环境 | [examples/values-dev.yaml](examples/values-dev.yaml) | 本地 Kubernetes |
| 生产环境 | [examples/values-minimal.yaml](examples/values-minimal.yaml) | 最小化配置 |
| AWS RDS | [examples/values-aws-rds.yaml](examples/values-aws-rds.yaml) | AWS 云环境 |
| 阿里云 RDS | [examples/values-alibabacloud.yaml](examples/values-alibabacloud.yaml) | 阿里云环境 |
| 内部数据中心 | [examples/values-internal-dc.yaml](examples/values-internal-dc.yaml) | 企业内部环境 |

### Docker 相关
| 内容 | 文件 |
|------|------|
| Docker 构建说明 | [DOCKERFILE-README.md](DOCKERFILE-README.md) |
| Docker Compose 配置 | [docker-compose.yml](docker-compose.yml) |
| 构建脚本 | [build.sh](build.sh) |

### Kubernetes/Helm
| 内容 | 文件 |
|------|------|
| Chart 基础信息 | [Chart.yaml](Chart.yaml) |
| 默认值 | [values.yaml](values.yaml) |
| 模板文件 | [templates/](templates/) |
| 部署指南 | [DEPLOYMENT-GUIDE.md](DEPLOYMENT-GUIDE.md) |

## 🔐 密码和安全

### 密码管理
- **问题**: 如何安全地管理数据库密码？
- **答案**: [QUICK-REFERENCE.md#密码管理方案](QUICK-REFERENCE.md)

### SSL/TLS 连接
- **问题**: 如何启用 PostgreSQL SSL？
- **答案**: [README.md#SSL配置](README.md) 或 [DEPLOYMENT-GUIDE.md](DEPLOYMENT-GUIDE.md)

### Secret 最佳实践
- **问题**: 应该如何使用 Kubernetes Secret？
- **答案**: [README.md](README.md) 或 [QUICK-REFERENCE.md](QUICK-REFERENCE.md)

## 🐛 故障排查

| 问题 | 查看文档 |
|------|---------|
| 数据库连接失败 | [QUICK-REFERENCE.md#连接数据库失败](QUICK-REFERENCE.md) |
| Pod 无法启动 | [QUICK-REFERENCE.md#pod-无法启动](QUICK-REFERENCE.md) |
| Docker Compose 问题 | [DOCKER-COMPOSE-README.md#故障排查](DOCKER-COMPOSE-README.md) |
| Helm 部署问题 | [DEPLOYMENT-GUIDE.md#故障排查](DEPLOYMENT-GUIDE.md) |
| 镜像构建问题 | [DOCKERFILE-README.md#故障排查](DOCKERFILE-README.md) |

## 📚 完整文档索引

### 核心文档（必读）
1. **[README.md](README.md)** - 项目概述和基础使用
   - 功能介绍
   - 快速开始
   - 配置参数
   - 基础故障排查

2. **[DEPLOYMENT-GUIDE.md](DEPLOYMENT-GUIDE.md)** - 详细部署指南
   - Chart 结构说明
   - 多种部署场景
   - 常见配置
   - 高级用法

3. **[QUICK-REFERENCE.md](QUICK-REFERENCE.md)** - 命令速查表
   - 所有常用命令
   - 配置参数表
   - 快速示例
   - 问题速查

### 辅助文档
4. **[BUILD.md](BUILD.md)** - 完整项目文档（本文件）
   - 项目结构
   - 工作流程
   - CI/CD 示例
   - 统计信息

5. **[SUMMARY.md](SUMMARY.md)** - 项目总结
   - 技术栈
   - 核心特性
   - 与原始项目的区别

6. **[DOCKERFILE-README.md](DOCKERFILE-README.md)** - Docker 构建详解
   - 4 种 Dockerfile
   - 构建方法
   - 镜像对比
   - 性能优化

7. **[DOCKER-COMPOSE-README.md](DOCKER-COMPOSE-README.md)** - 本地开发环境
   - Docker Compose 配置
   - 快速开始
   - 常用命令
   - 开发工作流

### 配置示例
8. **[examples/README.md](examples/README.md)** - 示例说明
   - 5 种环境配置
   - 部署步骤
   - 参数调整
   - 最佳实践

## 🚀 常见任务快速指南

### 任务 1: 本地开发（5 分钟）
```bash
# 步骤
1. cd wiki
2. docker-compose up
3. 访问 http://localhost:3000

# 文档
参考: DOCKER-COMPOSE-README.md
```

### 任务 2: 部署到 Kubernetes（10 分钟）
```bash
# 步骤
1. 创建 Secret: kubectl create secret generic ...
2. 部署应用: helm install wiki ./wiki ...
3. 验证: kubectl get all

# 文档
参考: README.md 或 QUICK-REFERENCE.md
```

### 任务 3: 构建自定义镜像（15 分钟）
```bash
# 步骤
1. ./build.sh -v 1.0.0 -r myregistry.com -p

# 文档
参考: DOCKERFILE-README.md
```

### 任务 4: 配置生产环境（30 分钟）
```bash
# 步骤
1. 选择合适的 values 文件: examples/values-xxx.yaml
2. 根据环境调整参数
3. 创建 Secret 存放密码
4. 部署应用

# 文档
参考: DEPLOYMENT-GUIDE.md 或 examples/README.md
```

## 📊 文档覆盖范围

| 功能 | 文档 | 详细度 |
|------|------|--------|
| 快速开始 | README.md, DOCKER-COMPOSE-README.md | ⭐⭐⭐⭐⭐ |
| 部署配置 | DEPLOYMENT-GUIDE.md, README.md | ⭐⭐⭐⭐⭐ |
| Docker 构建 | DOCKERFILE-README.md | ⭐⭐⭐⭐⭐ |
| Helm Chart | README.md, values.yaml | ⭐⭐⭐⭐ |
| 密码管理 | QUICK-REFERENCE.md | ⭐⭐⭐⭐ |
| 故障排查 | 各文档的故障排查章节 | ⭐⭐⭐⭐ |
| 最佳实践 | DEPLOYMENT-GUIDE.md | ⭐⭐⭐⭐ |
| CI/CD 集成 | BUILD.md | ⭐⭐⭐ |

## 🔍 按技能级别

### 初学者
推荐阅读顺序：
1. [README.md](README.md) - 了解项目
2. [DOCKER-COMPOSE-README.md](DOCKER-COMPOSE-README.md) - 本地开发
3. [examples/README.md](examples/README.md) - 部署示例

### 中级用户
推荐阅读顺序：
1. [DEPLOYMENT-GUIDE.md](DEPLOYMENT-GUIDE.md) - 部署指南
2. [DOCKERFILE-README.md](DOCKERFILE-README.md) - 构建优化
3. [QUICK-REFERENCE.md](QUICK-REFERENCE.md) - 命令参考

### 高级用户
推荐阅读顺序：
1. [BUILD.md](BUILD.md) - 项目架构
2. [templates/](templates/) - Helm 模板源码
3. [DEPLOYMENT-GUIDE.md](DEPLOYMENT-GUIDE.md) - 高级配置

## 📞 文档和资源链接

### 官方文档
- [Wiki.js 官方文档](https://docs.requarks.io/)
- [Helm 官方文档](https://helm.sh/docs/)
- [Kubernetes 官方文档](https://kubernetes.io/docs/)
- [Docker 官方文档](https://docs.docker.com/)

### 相关项目
- [Wiki.js GitHub](https://github.com/Requarks/wiki)
- [Helm Charts Hub](https://artifacthub.io/)
- [Docker Hub](https://hub.docker.com/)

## ✅ 查看清单

使用此项目前：
- [ ] 阅读 [README.md](README.md)
- [ ] 确定部署方式（Docker/Kubernetes）
- [ ] 选择合适的配置示例
- [ ] 准备好 PostgreSQL 数据库
- [ ] 准备好镜像仓库地址

部署前：
- [ ] 配置 PostgreSQL 连接信息
- [ ] 创建或准备密码 Secret
- [ ] 测试数据库连接
- [ ] 确认资源充足
- [ ] 备份现有数据（如有）

部署后：
- [ ] 验证应用启动
- [ ] 检查健康状态
- [ ] 测试访问
- [ ] 配置备份策略
- [ ] 设置监控告警

## 🆘 快速帮助

**我是新用户，不知道从何开始**
→ 从 [README.md](README.md) 开始

**我想快速部署应用**
→ 跳到 [README.md#快速开始](README.md)

**我需要查找特定命令**
→ 使用 [QUICK-REFERENCE.md](QUICK-REFERENCE.md)

**我遇到了问题**
→ 查看相关文档的故障排查部分

**我想了解最佳实践**
→ 阅读 [DEPLOYMENT-GUIDE.md#最佳实践](DEPLOYMENT-GUIDE.md)

**我想贡献改进**
→ 查看项目 GitHub 主页

---

**文档完成度**: 100%  
**最后更新**: 2026-01-06  
**版本**: 1.0.0
