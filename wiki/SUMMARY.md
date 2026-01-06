# Wiki Helm Chart 部署总结

## 📋 项目概述

已成功创建 **wiki** Helm Chart，用于部署 Wiki.js 应用并连接到外部 PostgreSQL 数据库。该 Chart 基于原始 wiki Chart 的最佳实践进行设计。

## 🏗️ Chart 结构

```
wiki/
├── Chart.yaml                 # Chart 元数据
├── values.yaml               # 默认配置值
├── values-prod.yaml          # 生产环境配置示例
├── README.md                 # 完整使用文档
├── DEPLOYMENT-GUIDE.md       # 详细部署指南
├── .helmignore               # 打包时忽略的文件
└── templates/
    ├── _helpers.tpl          # 模板辅助函数
    ├── deployment.yaml       # Wiki.js 部署定义
    ├── service.yaml          # Kubernetes Service
    ├── serviceaccount.yaml    # Service Account
    ├── secret.yaml           # PostgreSQL 密码 Secret
    ├── ingress.yaml          # Ingress 配置
    └── NOTES.txt             # 部署后的使用说明
```

## 🔐 安全特性

### 1. 密码保护
- ✅ 数据库密码存储在 Kubernetes Secret 中
- ✅ 支持两种密码管理方式：
  - 直接在 values.yaml 中设置（开发环境）
  - 引用现有 Secret（生产环境推荐）

### 2. 安全的环境变量注入
```yaml
- name: DB_PASS
  valueFrom:
    secretKeyRef:
      name: <secret-name>
      key: <secret-key>
```

## ⚙️ 可配置项

### PostgreSQL 连接配置
```yaml
postgresql:
  host: "postgres.example.com"      # 数据库服务器地址
  port: 5432                        # 端口号
  database: "wiki"                  # 数据库名
  username: "wiki_user"             # 数据库用户名
  ssl: false                        # 是否启用 SSL
  ca: ""                           # CA 证书路径
```

### Secret 配置
```yaml
secret:
  existingSecret: ""               # 现有 Secret 名称
  existingSecretKey: "password"    # Secret 中密码的键
  password: "changeme"             # 密码（如果不使用现有 Secret）
```

## 🚀 快速开始

### 最小化部署
```bash
helm install my-wiki ./wiki \
  --set postgresql.host="postgres.example.com" \
  --set postgresql.database="wiki" \
  --set postgresql.username="wiki" \
  --set secret.password="secure-password-123"
```

### 使用现有 Secret（推荐）
```bash
# 1. 创建 Secret
kubectl create secret generic postgres-creds \
  --from-literal=password='my-secure-password'

# 2. 部署 Chart
helm install my-wiki ./wiki \
  --set postgresql.host="postgres.example.com" \
  --set postgresql.database="wiki" \
  --set postgresql.username="wiki" \
  --set secret.existingSecret="postgres-creds" \
  --set secret.existingSecretKey="password"
```

### 使用生产配置
```bash
helm install my-wiki ./wiki \
  -f values-prod.yaml \
  --set postgresql.host="prod-postgres.example.com"
```

## 📊 生成的 Kubernetes 资源

部署会创建以下资源：

1. **ServiceAccount** - 应用运行的身份
2. **Secret** - 存储数据库密码
3. **Service** - 暴露应用端口
4. **Deployment** - Wiki.js 应用部署
5. **Ingress**（可选）- 外部访问配置

## 🔍 环境变量映射

Chart 自动配置以下环境变量：

| 环境变量 | 来源 | 值 |
|---------|------|-----|
| DB_TYPE | 固定值 | postgres |
| DB_HOST | postgresql.host | 配置值 |
| DB_PORT | postgresql.port | 配置值 |
| DB_NAME | postgresql.database | 配置值 |
| DB_USER | postgresql.username | 配置值 |
| DB_PASS | Secret | 来自密钥管理 |
| DB_SSL | postgresql.ssl | 配置值 |
| DB_SSL_CA | postgresql.ca | 配置值（如果设置） |
| HA_ACTIVE | 动态计算 | 副本数 <= 2 |

## 📋 验证清单

- ✅ Helm lint 检查通过（0 errors）
- ✅ 支持自动生成 Secret
- ✅ 支持使用现有 Secret
- ✅ 完整的模板帮助函数
- ✅ 生产级别的配置示例
- ✅ 详细的部署文档
- ✅ 故障排查指南
- ✅ 最佳实践建议

## 🎯 与原始 Chart 的主要差异

| 特性 | 原始 wiki | wiki |
|------|---------|------------------|
| PostgreSQL 依赖 | 包含 | 不包含 |
| 数据库部署 | 自动部署 PostgreSQL | 使用外部数据库 |
| 初始化方式 | 自动化 | 需预创建数据库 |
| 配置复杂度 | 中等 | 简化 |
| 适用场景 | 开发/测试 | 生产环境 |
| 密码管理 | 自动生成 | 灵活管理 |

## 📚 文档文件

1. **README.md** - 基础使用文档
2. **DEPLOYMENT-GUIDE.md** - 详细部署指南
3. **values-prod.yaml** - 生产环境配置示例
4. **NOTES.txt** - 部署后自动输出的说明

## 🧪 测试命令

```bash
# 验证 Chart 语法
helm lint ./wiki

# 预览生成的 YAML
helm template my-wiki ./wiki \
  --set postgresql.host="postgres.example.com" \
  --set secret.password="test123"

# 验证 Secret 生成
helm template my-wiki ./wiki \
  --set secret.password="test" | grep -A5 "kind: Secret"

# 干运行（不实际部署）
helm install my-wiki ./wiki --dry-run --debug
```

## 🔒 安全建议

1. **生产环境必须**
   - 使用 `secret.existingSecret` 而不是在 values.yaml 中存放密码
   - 启用 PostgreSQL SSL 连接
   - 配置 Pod 安全策略
   - 使用 NetworkPolicy 限制网络访问

2. **密钥管理**
   - 集成 HashiCorp Vault 或 AWS Secrets Manager
   - 启用审计日志
   - 定期轮换密钥

3. **网络安全**
   - 启用 Ingress TLS
   - 配置证书管理器（cert-manager）
   - 限制 Pod 间通信

## 📞 使用示例

### 在 Kubernetes 中部署
```bash
cd /home/hong/code/wiki/wiki
kubectl create namespace wiki
helm install wiki-app ./wiki \
  -n wiki \
  --set postgresql.host="postgres.example.com" \
  --set postgresql.database="wiki" \
  --set postgresql.username="wiki_user" \
  --set secret.password="your-secure-password"
```

### 检查部署状态
```bash
helm status wiki-app -n wiki
kubectl get all -n wiki
kubectl logs -n wiki deployment/wiki-app-wiki
```

### 更新配置
```bash
helm upgrade wiki-app ./wiki \
  -n wiki \
  --set postgresql.ssl=true
```

## 🎓 下一步

1. 查看 `DEPLOYMENT-GUIDE.md` 了解更多部署场景
2. 查看 `values-prod.yaml` 获取生产环境配置示例
3. 根据实际需求调整 resources、nodeSelector 等配置
4. 集成 CI/CD 流程自动化部署

---

**创建日期**: 2026-01-06  
**Chart 版本**: 1.0.0  
**Wiki.js 版本**: latest  
**Kubernetes 最小版本**: 1.16+  
**Helm 最小版本**: 3.0+
