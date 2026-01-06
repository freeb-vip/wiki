# Wiki-External-PG 完整项目文档

## 📦 项目概览

**wiki** 是一个完整的 Helm Chart 和 Docker 构建项目，用于部署 Wiki.js 应用并连接到外部 PostgreSQL 数据库。本项目基于 [requarks/wiki](https://github.com/Requarks/wiki) 的最佳实践构建。

**项目位置**: `/home/hong/code/wiki/wiki/`

## 📂 项目结构

```
wiki/
├── 📄 核心配置
│   ├── Chart.yaml                 # Helm Chart 元数据
│   ├── values.yaml                # 默认配置值
│   ├── values-prod.yaml           # 生产环境配置示例
│   └── .helmignore                # Helm 打包规则
│
├── 🐳 Docker 构建
│   ├── Dockerfile                 # 标准版（Node.js 24）
│   ├── Dockerfile.build           # 完整构建版
│   ├── Dockerfile.arm             # ARM 架构版（Node.js 20）
│   ├── Dockerfile.openshift       # OpenShift 兼容版
│   ├── .dockerignore              # Docker 构建忽略规则
│   └── build.sh                   # 构建脚本
│
├── 🐳 本地开发
│   ├── docker-compose.yml         # Docker Compose 配置
│   └── DOCKER-COMPOSE-README.md   # Docker Compose 使用指南
│
├── 📚 Helm 模板
│   ├── templates/
│   │   ├── _helpers.tpl           # 模板辅助函数
│   │   ├── deployment.yaml        # Wiki.js 部署
│   │   ├── service.yaml           # Kubernetes Service
│   │   ├── secret.yaml            # PostgreSQL 密码 Secret
│   │   ├── serviceaccount.yaml    # Service Account
│   │   ├── ingress.yaml           # Ingress 配置
│   │   └── NOTES.txt              # 部署说明
│
├── 📖 文档
│   ├── README.md                  # 基础使用文档
│   ├── SUMMARY.md                 # 项目总结
│   ├── DEPLOYMENT-GUIDE.md        # 详细部署指南
│   ├── QUICK-REFERENCE.md         # 快速参考卡
│   ├── DOCKERFILE-README.md       # Docker 说明
│   ├── DOCKER-COMPOSE-README.md   # Docker Compose 说明
│   └── BUILD.md                   # 本文件
│
├── 📋 部署示例
│   └── examples/
│       ├── README.md              # 示例说明
│       ├── values-dev.yaml        # 开发环境
│       ├── values-minimal.yaml    # 最小化生产
│       ├── values-aws-rds.yaml    # AWS RDS 配置
│       ├── values-alibabacloud.yaml # 阿里云 RDS
│       └── values-internal-dc.yaml  # 企业内部数据中心
│
└── 🔧 配置文件
    └── (以上配置见各目录)
```

## 🚀 快速开始

### 本地开发（Docker Compose）

```bash
# 启动开发环境
cd /home/hong/code/wiki/wiki
docker-compose up

# 访问应用
http://localhost:3000
```

### Kubernetes 部署（Helm）

```bash
# 创建命名空间
kubectl create namespace wiki

# 部署应用
helm install wiki-app ./wiki \
  -n wiki \
  --set postgresql.host="postgres.example.com" \
  --set postgresql.database="wiki" \
  --set postgresql.username="wiki_user" \
  --set secret.password="secure-password"

# 查看部署
kubectl get all -n wiki
```

### 构建自定义镜像

```bash
# 标准版
./build.sh -v 1.0.0

# ARM 架构
./build.sh --build-type arm -v 1.0.0

# 构建并推送
./build.sh -r myregistry.com -v 1.0.0 -p
```

## 🐳 Docker 镜像

### 可用的 Dockerfile

| Dockerfile | 用途 | Node 版本 | 大小 | 构建时间 |
|-----------|------|---------|------|---------|
| `Dockerfile` | 标准生产 | 24-alpine | ~400MB | 5-10min |
| `Dockerfile.arm` | ARM 架构 | 20-alpine | ~380MB | 5-10min |
| `Dockerfile.openshift` | OpenShift | 基于 wiki:2 | ~450MB | ~1min |

### 构建镜像

```bash
# 标准构建
docker build -t wiki:latest -f Dockerfile .

# ARM 构建
docker build -t wiki:latest-arm -f Dockerfile.arm .

# 使用脚本构建
./build.sh -v 1.0.0 -r myregistry.com -p
```

## ☸️ Kubernetes Helm Chart

### Chart 信息
- **Chart Name**: wiki
- **Chart Version**: 1.0.0
- **App Version**: latest
- **Kubernetes**: 1.16+
- **Helm**: 3.0+

### 密钥管理（关键特性）

#### 方式 1：自动创建 Secret
```bash
helm install wiki ./wiki \
  --set secret.password="my-password"
```

#### 方式 2：使用现有 Secret（推荐生产）
```bash
# 创建 Secret
kubectl create secret generic pg-credentials \
  --from-literal=password='secure-password'

# 部署时引用
helm install wiki ./wiki \
  --set secret.existingSecret="pg-credentials" \
  --set secret.existingSecretKey="password"
```

### 配置示例

#### 开发环境
```bash
helm install wiki ./wiki \
  -f examples/values-dev.yaml
```

#### AWS RDS
```bash
helm install wiki ./wiki \
  -f examples/values-aws-rds.yaml \
  --set postgresql.host="mydb.xxxxx.rds.amazonaws.com"
```

#### 阿里云 RDS
```bash
helm install wiki ./wiki \
  -f examples/values-alibabacloud.yaml \
  --set postgresql.host="mydb.postgres.rds.aliyuncs.com"
```

#### 企业内部数据中心
```bash
helm install wiki ./wiki \
  -f examples/values-internal-dc.yaml \
  --set postgresql.host="postgres.internal.company.com"
```

## 🔐 密码管理（核心特性）

### 自动 Secret 创建
Chart 会自动创建包含数据库密码的 Secret：

```yaml
# secret.yaml 模板
apiVersion: v1
kind: Secret
metadata:
  name: {{ release }}-wiki-pg-secret
type: Opaque
data:
  password: <base64-encoded>
```

### 环境变量注入
密码通过 Secret 安全注入到 Pod：

```yaml
- name: DB_PASS
  valueFrom:
    secretKeyRef:
      name: <secret-name>
      key: <secret-key>
```

### 最佳实践
1. **开发环境**：可直接在 values 中设置密码
2. **生产环境**：使用现有 Secret，不在 values 中暴露密码
3. **企业环境**：集成 Vault、AWS Secrets Manager 等

## 📊 环境变量配置

### 数据库连接
```yaml
postgresql:
  host: "postgres.example.com"
  port: 5432
  database: "wiki"
  username: "wiki_user"
  ssl: true                        # 启用 SSL
  ca: "/etc/ssl/certs/ca.crt"      # CA 证书路径
```

### Secret 配置
```yaml
secret:
  existingSecret: ""                # 现有 Secret 名称
  existingSecretKey: "password"    # Secret 中的键名
  password: "changeme"             # 密码（新建 Secret 时）
```

### 应用配置
```yaml
replicaCount: 1
image:
  repository: requarks/wiki
  tag: latest
service:
  type: ClusterIP
  port: 80
```

## 📚 文档导航

| 文档 | 说明 |
|------|------|
| [README.md](README.md) | 基础使用和功能概述 |
| [SUMMARY.md](SUMMARY.md) | 项目总结和技术栈 |
| [DEPLOYMENT-GUIDE.md](DEPLOYMENT-GUIDE.md) | 详细部署步骤和场景 |
| [QUICK-REFERENCE.md](QUICK-REFERENCE.md) | 常用命令速查表 |
| [DOCKERFILE-README.md](DOCKERFILE-README.md) | Docker 镜像构建详解 |
| [DOCKER-COMPOSE-README.md](DOCKER-COMPOSE-README.md) | 本地开发环境配置 |
| [examples/README.md](examples/README.md) | 各环境配置示例 |

## 🔄 工作流程

### 本地开发流程
```bash
1. git clone <repo>
2. cd wiki
3. docker-compose up          # 启动开发环境
4. 访问 http://localhost:3000
5. 修改代码
6. docker-compose restart wiki # 重启应用
```

### 生产部署流程
```bash
1. 构建镜像: ./build.sh -v 1.0.0 -r registry.com -p
2. 创建 Secret: kubectl create secret generic pg-creds ...
3. 部署: helm install wiki ./wiki -f values-prod.yaml
4. 验证: kubectl get all -n wiki
5. 访问: kubectl port-forward svc/wiki 8080:80
```

### CI/CD 集成示例

#### GitHub Actions
```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Build and push Docker image
        run: |
          ./build.sh -v ${{ github.ref_name }} \
            -r ${{ secrets.REGISTRY }} -p
      - name: Deploy to Kubernetes
        run: |
          helm upgrade --install wiki ./wiki \
            --kubeconfig=${{ secrets.KUBECONFIG }}
```

## 🛠️ 常见操作

### 查看 Helm Chart
```bash
# 验证 Chart
helm lint ./wiki

# 预览生成的 YAML
helm template wiki ./wiki

# 查看 Chart 信息
helm show chart ./wiki
helm show values ./wiki
```

### 管理部署
```bash
# 列出部署
helm list -n wiki

# 查看部署历史
helm history wiki -n wiki

# 升级配置
helm upgrade wiki ./wiki --set ...

# 回滚部署
helm rollback wiki 1

# 卸载
helm uninstall wiki -n wiki
```

### Docker 操作
```bash
# 构建镜像
docker build -t wiki:latest .

# 运行容器
docker run -it -p 3000:3000 \
  -e DB_HOST=postgres \
  wiki:latest

# 推送镜像
docker push myregistry.com/wiki:latest

# 查看日志
docker logs -f <container-id>
```

## 🔍 故障排查

### 常见问题

#### 1. 数据库连接失败
```bash
# 检查环境变量
kubectl set env deployment/wiki --list | grep DB_

# 测试连接
kubectl run -it --rm debug --image=postgres:latest \
  -- psql -h <host> -U <user> -d <db>

# 查看 Secret
kubectl get secret wiki-pg-secret -o yaml
```

#### 2. Pod 无法启动
```bash
# 查看事件
kubectl describe pod <pod-name>

# 查看日志
kubectl logs <pod-name> --previous

# 检查资源
kubectl top pod <pod-name>
```

#### 3. Docker Compose 连接问题
```bash
# 检查服务状态
docker-compose ps

# 查看日志
docker-compose logs postgres

# 重启服务
docker-compose restart
```

## 📈 性能优化

### Kubernetes
- 配置合适的 resource limits/requests
- 启用 Pod 反亲和性
- 使用 HPA 自动扩展
- 配置 Ingress 和 TLS

### Docker
- 使用 Alpine 基础镜像
- 多阶段构建优化镜像大小
- 使用 .dockerignore 加快构建
- 启用镜像缓存

### 应用
- 调整 Node.js 内存选项
- 配置数据库连接池
- 启用应用缓存
- 监控和优化日志级别

## 🔒 安全最佳实践

✅ **实现的安全特性**
- [x] 密码存储在 Secret 中
- [x] 支持 SSL/TLS 数据库连接
- [x] 非 root 用户运行应用
- [x] Pod 安全策略支持
- [x] 资源限制控制
- [x] 网络策略支持

⚠️ **推荐的安全措施**
- 启用 RBAC
- 配置网络策略
- 使用 Pod 安全策略
- 定期扫描镜像漏洞
- 启用审计日志
- 使用密钥管理系统（Vault）

## 📊 项目统计

```
文件总数: 28
├── 配置文件: 5 (Chart.yaml, values*.yaml, docker-compose.yml)
├── Dockerfile: 4 (标准版、完整版、ARM版、OpenShift版)
├── 文档: 7 (README、Guide、Reference 等)
├── 模板: 7 (Helm 模板)
├── 示例: 5 (各环境配置)
└── 脚本: 1 (build.sh)

代码行数:
├── YAML 配置: ~1500 行
├── Dockerfile: ~200 行
├── 文档: ~3000 行
└── 脚本: ~300 行
```

## 📝 版本信息

- **Chart 版本**: 1.0.0
- **Wiki.js 版本**: latest (可自定义)
- **Node.js**: 24-alpine (标准), 20-alpine (ARM)
- **PostgreSQL**: 外部部署（15+ 推荐）
- **Kubernetes**: 1.16+
- **Helm**: 3.0+

## 🎓 学习资源

- [Wiki.js 官方文档](https://docs.requarks.io/)
- [Helm 官方文档](https://helm.sh/docs/)
- [Kubernetes 官方文档](https://kubernetes.io/docs/)
- [Docker 官方文档](https://docs.docker.com/)

## 📞 支持和反馈

### 相关项目
- [Wiki.js 项目](https://github.com/Requarks/wiki)
- [Helm 社区](https://helm.sh/)
- [Docker 社区](https://www.docker.com/)

### 问题排查
详见各文档的故障排查部分：
- Docker Compose 问题 → [DOCKER-COMPOSE-README.md](DOCKER-COMPOSE-README.md)
- Helm 部署问题 → [DEPLOYMENT-GUIDE.md](DEPLOYMENT-GUIDE.md)
- 构建问题 → [DOCKERFILE-README.md](DOCKERFILE-README.md)

---

**创建日期**: 2026-01-06  
**最后更新**: 2026-01-06  
**作者**: GitHub Copilot
