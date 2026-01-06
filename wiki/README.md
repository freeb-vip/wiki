# Wiki.js with External PostgreSQL

This Helm chart deploys Wiki.js with an external PostgreSQL database. The database password is securely stored in a Kubernetes Secret.

## Features

- **External PostgreSQL Support**: Connect to an existing PostgreSQL database
- **Secure Password Management**: Database password stored in Kubernetes Secrets
- **Configurable Database Settings**: Host, port, database name, and username can be configured
- **SSL/TLS Support**: Optional SSL connection to PostgreSQL
- **Service Account**: Dedicated service account for the deployment
- **Ingress Support**: Optional Ingress configuration for external access

## Prerequisites

- Kubernetes 1.16+
- Helm 3+
- A running PostgreSQL database (external)

## Installation

### Basic Installation

```bash
helm install my-wiki ./wiki \
  --set postgresql.host="postgres.example.com" \
  --set postgresql.database="wiki" \
  --set postgresql.username="wiki_user" \
  --set secret.password="your_secure_password"
```

### With Existing Secret

If you already have a secret containing the database password:

```bash
helm install my-wiki ./wiki \
  --set postgresql.host="postgres.example.com" \
  --set postgresql.database="wiki" \
  --set postgresql.username="wiki_user" \
  --set secret.existingSecret="my-existing-secret" \
  --set secret.existingSecretKey="db-password"
```

### With SSL Connection

```bash
helm install my-wiki ./wiki \
  --set postgresql.host="postgres.example.com" \
  --set postgresql.ssl=true \
  --set postgresql.ca="/path/to/ca.crt" \
  --set secret.password="your_secure_password"
```

## Configuration

The following table lists the configurable parameters and their default values.

| Parameter | Description | Default |
|-----------|-------------|---------|
| `replicaCount` | Number of replicas | `1` |
| `image.repository` | Image repository | `requarks/wiki` |
| `image.tag` | Image tag | `latest` |
| `image.imagePullPolicy` | Image pull policy | `IfNotPresent` |
| `postgresql.host` | PostgreSQL host address | `postgres.default.svc.cluster.local` |
| `postgresql.port` | PostgreSQL port | `5432` |
| `postgresql.database` | PostgreSQL database name | `wiki` |
| `postgresql.username` | PostgreSQL username | `wiki` |
| `postgresql.ssl` | Enable SSL connection | `false` |
| `postgresql.ca` | PostgreSQL CA certificate path | `""` |
| `secret.existingSecret` | Name of existing secret | `""` |
| `secret.existingSecretKey` | Key in existing secret | `password` |
| `secret.password` | Database password | `changeme` |
| `service.type` | Service type | `ClusterIP` |
| `service.port` | Service port | `80` |
| `ingress.enabled` | Enable Ingress | `false` |
| `resources` | CPU/Memory resources | `{}` |
| `nodeSelector` | Node selector | `{}` |
| `tolerations` | Tolerations | `[]` |
| `affinity` | Affinity rules | `{}` |

## Usage

### Port Forwarding

To access Wiki.js locally without Ingress:

```bash
kubectl port-forward svc/my-wiki 8080:80
```

Then visit http://localhost:8080

### Check Logs

```bash
kubectl logs deployment/my-wiki
```

### Update Values

```bash
helm upgrade my-wiki ./wiki \
  --set secret.password="new_password"
```

## Database Migration

If you're migrating from the internal PostgreSQL to an external one:

1. Export data from the old database
2. Import to the new database
3. Deploy this chart pointing to the new database

## Troubleshooting

### Database Connection Errors

Check the deployment logs:
```bash
kubectl logs deployment/my-wiki
```

Verify database credentials:
```bash
kubectl get secret my-wiki-pg-secret -o jsonpath='{.data.password}' | base64 -d
```

### Pod Not Starting

Check pod events:
```bash
kubectl describe pod <pod-name>
```

Verify PostgreSQL connectivity:
```bash
kubectl run -it --rm debug --image=postgres:latest --restart=Never -- \
  psql -h <host> -U <username> -d <database>
```

## License

This chart is provided as-is. Refer to the Wiki.js project for licensing information.
