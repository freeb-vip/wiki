# Wiki Helm Chart - 快速参考卡

## 基本命令

### 安装
```bash
# 基础安装
helm install my-wiki ./wiki \
  --set postgresql.host="db.example.com" \
  --set secret.password="pwd123"

# 使用值文件
helm install my-wiki ./wiki -f values-prod.yaml

# 指定命名空间
helm install my-wiki ./wiki -n wiki --create-namespace
```

### 升级
```bash
# 升级应用
helm upgrade my-wiki ./wiki \
  --set postgresql.ssl=true

# 升级并重建 Pod
helm upgrade my-wiki ./wiki --force --recreate-pods
```

### 卸载
```bash
helm uninstall my-wiki
helm uninstall my-wiki -n wiki
```

### 查看状态
```bash
helm list
helm list -n wiki
helm status my-wiki
helm history my-wiki
```

## 关键配置参数

### PostgreSQL 连接
| 参数 | 默认值 | 说明 |
|-----|--------|------|
| `postgresql.host` | `postgres.default.svc.cluster.local` | 数据库地址 |
| `postgresql.port` | `5432` | 数据库端口 |
| `postgresql.database` | `wiki` | 数据库名 |
| `postgresql.username` | `wiki` | 数据库用户 |
| `postgresql.ssl` | `false` | 启用 SSL |
| `postgresql.ca` | `""` | CA 证书路径 |

### 密码管理
| 参数 | 默认值 | 说明 |
|-----|--------|------|
| `secret.existingSecret` | `""` | 现有 Secret 名称 |
| `secret.existingSecretKey` | `password` | Secret 中的键名 |
| `secret.password` | `changeme` | 密码（新建 Secret 时） |

### 部署配置
| 参数 | 默认值 | 说明 |
|-----|--------|------|
| `replicaCount` | `1` | 副本数 |
| `image.repository` | `requarks/wiki` | 镜像仓库 |
| `image.tag` | `latest` | 镜像标签 |
| `service.type` | `ClusterIP` | Service 类型 |
| `service.port` | `80` | 服务端口 |

## 模板文件预览

### Secret
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: {{ release }}-wiki-pg-secret
type: Opaque
data:
  password: <base64-encoded>
```

### Deployment 环境变量
```yaml
env:
- name: DB_TYPE
  value: "postgres"
- name: DB_HOST
  value: "{{ postgresql.host }}"
- name: DB_PORT
  value: "{{ postgresql.port }}"
- name: DB_NAME
  value: "{{ postgresql.database }}"
- name: DB_USER
  value: "{{ postgresql.username }}"
- name: DB_PASS
  valueFrom:
    secretKeyRef:
      name: <secret-name>
      key: <secret-key>
- name: DB_SSL
  value: "{{ postgresql.ssl }}"
```

## 常用操作

### 查看生成的 YAML
```bash
helm template my-wiki ./wiki

# 仅查看 Deployment
helm template my-wiki ./wiki | grep -A 50 "kind: Deployment"

# 仅查看 Secret
helm template my-wiki ./wiki | grep -A 10 "kind: Secret"
```

### 验证配置
```bash
helm lint ./wiki
helm template my-wiki ./wiki --validate
```

### 调试部署
```bash
# 干运行
helm install my-wiki ./wiki --dry-run --debug

# 查看完整的最终配置
helm get values my-wiki

# 查看部署的模板
helm get manifest my-wiki
```

### 管理 Secret
```bash
# 查看 Secret
kubectl get secret my-wiki-pg-secret
kubectl describe secret my-wiki-pg-secret

# 查看密码（Base64 解码）
kubectl get secret my-wiki-pg-secret -o jsonpath='{.data.password}' | base64 -d

# 更新密码
kubectl patch secret my-wiki-pg-secret -p '{"data":{"password":"'$(echo -n "newpwd" | base64)'"}}'

# 重启 Pod 应用新密码
kubectl rollout restart deployment/my-wiki-wiki
```

### 查看日志和状态
```bash
# 查看 Pod 日志
kubectl logs deployment/my-wiki-wiki

# 实时查看日志
kubectl logs -f deployment/my-wiki-wiki

# 查看 Pod 详情
kubectl describe pod <pod-name>

# 进入容器
kubectl exec -it <pod-name> -- /bin/bash
```

## 密码管理方案

### 方案 A: 直接设置（仅用于开发）
```bash
helm install my-wiki ./wiki \
  --set secret.password="my-password"
```

### 方案 B: 使用现有 Secret（推荐生产）
```bash
# 1. 创建 Secret
kubectl create secret generic postgres-creds \
  --from-literal=password='secure-password'

# 2. 部署时引用
helm install my-wiki ./wiki \
  --set secret.existingSecret="postgres-creds" \
  --set secret.existingSecretKey="password"
```

### 方案 C: 外部密钥管理（企业级）
```bash
# 集成 HashiCorp Vault、AWS Secrets Manager 等
# 在部署前获取密码
PASSWORD=$(vault kv get -field=password secret/postgres)
helm install my-wiki ./wiki \
  --set secret.password="$PASSWORD"
```

## 常见问题排查

### 连接数据库失败
```bash
# 1. 检查环境变量
kubectl set env deployment/my-wiki --list

# 2. 检查 Secret
kubectl get secret my-wiki-pg-secret -o yaml

# 3. 测试数据库连接
kubectl run -it --rm debug --image=postgres:latest --restart=Never \
  -- psql -h <host> -U <user> -d <database>

# 4. 查看 Pod 日志
kubectl logs deployment/my-wiki-wiki
```

### Pod 无法启动
```bash
# 查看事件
kubectl describe pod <pod-name>

# 查看完整日志
kubectl logs <pod-name> --previous

# 检查资源限制
kubectl top pod <pod-name>
```

### 密码不匹配
```bash
# 验证 Secret 内容
kubectl get secret <secret-name> -o jsonpath='{.data.password}' | base64 -d

# 验证环境变量
kubectl set env deployment/<deployment> --list | grep DB_

# 检查部署事件
kubectl describe deployment <deployment>
```

## 重要提示

⚠️ **生产环境检查清单**
- [ ] 使用现有 Secret 管理密码（不在 values 中存放）
- [ ] 启用 PostgreSQL SSL 连接
- [ ] 配置 resource limits 和 requests
- [ ] 设置合适的副本数量
- [ ] 启用 Ingress 和 TLS
- [ ] 配置 Pod 安全策略
- [ ] 启用监控和日志聚合
- [ ] 测试故障转移和恢复流程

## 相关文件

- `Chart.yaml` - Chart 元数据
- `values.yaml` - 默认值配置
- `values-prod.yaml` - 生产环境示例
- `README.md` - 完整文档
- `DEPLOYMENT-GUIDE.md` - 详细指南
- `SUMMARY.md` - 项目总结
