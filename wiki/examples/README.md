# Example 部署说明

本目录包含各种常见场景的 Helm values 配置示例。

## 文件说明

### values-dev.yaml
本地开发环境配置
- 单副本部署
- 最小资源限制
- 无 SSL 连接
- 直接设置密码（开发使用）

使用方法：
```bash
helm install wiki ./wiki -f examples/values-dev.yaml
```

### values-minimal.yaml
最小化生产配置
- 单副本部署
- 基础资源限制
- 使用现有 Secret
- 生产级别的设置

使用方法：
```bash
kubectl create secret generic pg-credentials --from-literal=password='your-password'
helm install wiki ./wiki -f examples/values-minimal.yaml
```

### values-aws-rds.yaml
AWS RDS PostgreSQL 配置
- 3 副本高可用
- AWS RDS SSL 连接
- AWS ALB Ingress
- Pod 反亲和性配置

使用方法：
```bash
kubectl create secret generic aws-rds-credentials --from-literal=password='your-rds-password'
helm install wiki ./wiki -f examples/values-aws-rds.yaml
```

### values-alibabacloud.yaml
阿里云 RDS PostgreSQL 配置
- 2 副本部署
- RDS SSL 连接
- NGINX Ingress
- 中等资源配置

使用方法：
```bash
kubectl create secret generic alibabacloud-rds-secret --from-literal=password='your-rds-password'
helm install wiki ./wiki -f examples/values-alibabacloud.yaml
```

### values-internal-dc.yaml
企业内部数据中心配置
- 2 副本部署
- 内部网络连接
- CA 证书支持
- Pod 反亲和性
- 内部 Ingress

使用方法：
```bash
kubectl create secret generic internal-db-credentials --from-literal=db_password='your-password'
kubectl create configmap internal-ca-certs --from-file=ca.pem=/path/to/ca.pem
helm install wiki ./wiki -f examples/values-internal-dc.yaml
```

## 通用部署流程

### 第一步：准备 Secret
```bash
# 方法 1：从命令行创建
kubectl create secret generic <secret-name> \
  --from-literal=password='your-secure-password'

# 方法 2：从文件创建
kubectl create secret generic <secret-name> \
  --from-file=password=/path/to/password-file
```

### 第二步：选择合适的 values 文件
根据您的部署环境选择对应的 values 文件。

### 第三步：部署
```bash
# 使用 values 文件部署
helm install <release-name> ./wiki \
  -f examples/values-xxx.yaml

# 或者使用命令行覆盖
helm install <release-name> ./wiki \
  -f examples/values-xxx.yaml \
  --set postgresql.host="your-database-host"
```

### 第四步：验证部署
```bash
helm status <release-name>
kubectl get all
kubectl logs deployment/<deployment-name>
```

## 自定义配置

如果现有的示例都不完全符合您的需求，可以：

1. 复制最接近的 values 文件
2. 根据您的环境调整参数
3. 保存为新文件，如 `values-custom.yaml`
4. 使用新文件部署

## 常见参数调整

### 修改副本数
```bash
helm install wiki ./wiki -f examples/values-xxx.yaml \
  --set replicaCount=3
```

### 修改镜像标签
```bash
helm install wiki ./wiki -f examples/values-xxx.yaml \
  --set image.tag="2.5.296"
```

### 修改数据库配置
```bash
helm install wiki ./wiki -f examples/values-xxx.yaml \
  --set postgresql.host="new-host.com" \
  --set postgresql.ssl=true
```

## 最佳实践

1. **版本控制**
   - 将 values 文件提交到版本控制系统
   - 追踪配置变更历史

2. **环境隔离**
   - 为开发、测试、生产环境创建不同的 values 文件
   - 使用命名空间隔离环境

3. **密钥管理**
   - 生产环境不要在 values 文件中存放密码
   - 使用 Secret 或密钥管理系统
   - 定期轮换密钥

4. **文档记录**
   - 记录每个环境的配置
   - 说明特殊配置的原因
   - 维护故障排查指南

## 需要帮助？

详见：
- [README.md](../README.md) - 基础使用文档
- [DEPLOYMENT-GUIDE.md](../DEPLOYMENT-GUIDE.md) - 详细部署指南
- [QUICK-REFERENCE.md](../QUICK-REFERENCE.md) - 快速参考卡
