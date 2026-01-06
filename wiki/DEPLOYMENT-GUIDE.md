# Wiki.js 外部PostgreSQL部署指南

## Chart 结构

```
wiki/
├── Chart.yaml                 # Chart 元数据
├── values.yaml               # 默认配置值
├── values-prod.yaml          # 生产环境配置示例
├── README.md                 # 完整文档
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

## 核心特性

### 1. 密码安全保护
- 数据库密码存储在 Kubernetes Secret 中
- 支持引用现有的 Secret，不需要在 values.yaml 中暴露密码
- 使用 Base64 编码存储

### 2. 可配置的数据库连接
在 `values.yaml` 中配置：
```yaml
postgresql:
  host: "postgres.example.com"      # PostgreSQL 服务器地址
  port: 5432                         # 端口号
  database: "wiki"                   # 数据库名
  username: "wiki_user"              # 数据库用户
  ssl: false                         # SSL 连接
  ca: ""                            # CA 证书路径
```

### 3. 灵活的密码管理

**方式1：在 values.yaml 中指定密码**（开发环境）
```bash
helm install my-wiki ./wiki \
  --set secret.password="my-secret-password"
```

**方式2：使用现有 Secret**（生产环境推荐）
```bash
# 先创建 Secret
kubectl create secret generic postgres-creds \
  --from-literal=password='my-secure-password'

# 部署时引用
helm install my-wiki ./wiki \
  --set secret.existingSecret="postgres-creds" \
  --set secret.existingSecretKey="password"
```

## 快速开始

### 最小化配置
```bash
helm install my-wiki ./wiki \
  --set postgresql.host="postgres.example.com" \
  --set postgresql.database="wiki" \
  --set postgresql.username="wiki" \
  --set secret.password="changeme"
```

### 完整配置示例
```bash
helm install my-wiki ./wiki \
  -f values-prod.yaml \
  --set postgresql.host="postgres.example.com" \
  --set postgresql.port=5432 \
  --set postgresql.database="wiki_prod" \
  --set postgresql.username="wiki_user" \
  --set postgresql.ssl=true \
  --set secret.existingSecret="postgres-credentials" \
  --set secret.existingSecretKey="password"
```

### 启用 Ingress
```bash
helm install my-wiki ./wiki \
  --set ingress.enabled=true \
  --set ingress.className="nginx" \
  --set ingress.hosts[0].host="wiki.example.com" \
  --set ingress.hosts[0].paths[0].path="/" \
  --set ingress.hosts[0].paths[0].pathType="Prefix"
```

## 常见配置场景

### 场景1：连接云数据库（AWS RDS）
```yaml
postgresql:
  host: "mydb.xxxxx.rds.amazonaws.com"
  port: 5432
  database: "wiki"
  username: "admin"
  ssl: true
  ca: "/etc/ssl/certs/rds-ca-bundle.pem"

secret:
  existingSecret: "rds-password"
  existingSecretKey: "password"
```

### 场景2：连接内部 PostgreSQL 集群
```yaml
postgresql:
  host: "postgres.database.svc.cluster.local"
  port: 5432
  database: "wiki"
  username: "wiki"
  ssl: false

secret:
  password: "local-password"
```

### 场景3：多副本高可用部署
```yaml
replicaCount: 3

resources:
  requests:
    cpu: 250m
    memory: 256Mi
  limits:
    cpu: 500m
    memory: 512Mi

affinity:
  podAntiAffinity:
    preferredDuringSchedulingIgnoredDuringExecution:
      - weight: 100
        podAffinityTerm:
          labelSelector:
            matchExpressions:
              - key: app.kubernetes.io/name
                operator: In
                values:
                  - wiki
          topologyKey: kubernetes.io/hostname
```

## 故障排查

### 检查部署状态
```bash
kubectl get deployment -n default my-wiki
kubectl describe deployment my-wiki
kubectl logs deployment/my-wiki
```

### 验证数据库连接
```bash
# 查看 Pod 环境变量
kubectl set env deployment/my-wiki --list

# 检查 Secret
kubectl get secret my-wiki-pg-secret -o yaml
kubectl get secret my-wiki-pg-secret -o jsonpath='{.data.password}' | base64 -d
```

### 测试数据库连接
```bash
kubectl run -it --rm psql-client --image=postgres:latest --restart=Never \
  -- psql -h postgres.example.com -U wiki -d wiki -c "SELECT 1"
```

## 更新部署

### 更新数据库密码
```bash
# 更新 Secret
kubectl patch secret my-wiki-pg-secret -p '{"data":{"password":"'$(echo -n "newpassword" | base64)'"}}'

# 重启 Pod 以应用新密码
kubectl rollout restart deployment/my-wiki
```

### 更新其他配置
```bash
helm upgrade my-wiki ./wiki \
  --set postgresql.host="new-host.com" \
  --set postgresql.ssl=true
```

### 回滚部署
```bash
helm rollback my-wiki
```

## 卸载

```bash
helm uninstall my-wiki
```

## 与原始 wiki Chart 的区别

| 特性 | wiki | wiki |
|------|------|------------------|
| 依赖管理 | 包含 PostgreSQL 依赖 | 仅使用外部数据库 |
| 数据库部署 | 自动部署 PostgreSQL | 连接现有 PostgreSQL |
| 初始化 | 自动化 | 需要预创建数据库 |
| 配置复杂度 | 较高 | 简化 |
| 生产就绪 | 开发导向 | 生产导向 |

## 最佳实践

1. **密码管理**
   - 生产环境始终使用 `existingSecret`
   - 使用专业的密钥管理服务（如 HashiCorp Vault）

2. **网络安全**
   - 启用 SSL 连接到数据库
   - 使用 NetworkPolicy 限制流量
   - 启用 Ingress TLS

3. **资源管理**
   - 设置合适的 CPU 和内存请求/限制
   - 根据负载设置副本数量
   - 使用 Pod 反亲和性分散部署

4. **监控和日志**
   - 配置日志聚合
   - 设置 liveness/readiness probes
   - 监控数据库连接

## 许可证

此 Chart 遵循与 Wiki.js 相同的许可证。更多信息见 [Wiki.js 项目](https://github.com/Requarks/wiki)
