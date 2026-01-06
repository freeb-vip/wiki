#!/bin/bash
# Docker 镜像构建脚本

set -e

# 配置
REGISTRY="${REGISTRY:-docker.io}"
REPOSITORY="${REPOSITORY:-wiki}"
VERSION="${VERSION:-latest}"
BUILD_DATE=$(date -u +'%Y-%m-%dT%H:%M:%SZ')
VCS_REF=$(git rev-parse --short HEAD 2>/dev/null || echo "unknown")

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 函数
print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 显示帮助信息
show_help() {
    cat << EOF
Docker 镜像构建脚本

用法: ./build.sh [选项]

选项:
  -h, --help           显示此帮助信息
  -v, --version        指定版本号 (默认: latest)
  -r, --registry       指定镜像仓库 (默认: docker.io)
  -p, --push           构建后推送镜像
  --build-type         构建类型: standard, arm, openshift (默认: standard)
  --no-cache           不使用缓存构建

示例:
  ./build.sh                                    # 构建标准版本
  ./build.sh -v 2.5.296                        # 指定版本
  ./build.sh -r myregistry.com -v 1.0.0 -p    # 构建并推送到私有仓库
  ./build.sh --build-type arm                  # 构建 ARM 版本

EOF
}

# 解析参数
PUSH=false
BUILD_TYPE="standard"
NO_CACHE=""

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -v|--version)
            VERSION="$2"
            shift 2
            ;;
        -r|--registry)
            REGISTRY="$2"
            shift 2
            ;;
        -p|--push)
            PUSH=true
            shift
            ;;
        --build-type)
            BUILD_TYPE="$2"
            shift 2
            ;;
        --no-cache)
            NO_CACHE="--no-cache"
            shift
            ;;
        *)
            print_error "未知选项: $1"
            show_help
            exit 1
            ;;
    esac
done

# 验证构建类型
case $BUILD_TYPE in
    standard|arm|openshift)
        ;;
    *)
        print_error "未知的构建类型: $BUILD_TYPE"
        exit 1
        ;;
esac

# 确定 Dockerfile
case $BUILD_TYPE in
    standard)
        DOCKERFILE="Dockerfile"
        TAG_SUFFIX=""
        ;;
    arm)
        DOCKERFILE="Dockerfile.arm"
        TAG_SUFFIX="-arm"
        ;;
    openshift)
        DOCKERFILE="Dockerfile.openshift"
        TAG_SUFFIX="-openshift"
        ;;
esac

# 完整的镜像名称
IMAGE_NAME="${REGISTRY}/${REPOSITORY}:${VERSION}${TAG_SUFFIX}"
LATEST_NAME="${REGISTRY}/${REPOSITORY}:latest${TAG_SUFFIX}"

print_info "开始构建 Docker 镜像..."
echo ""
echo "配置信息:"
echo "  Dockerfile: $DOCKERFILE"
echo "  镜像名称: $IMAGE_NAME"
echo "  最新标签: $LATEST_NAME"
echo "  构建日期: $BUILD_DATE"
echo "  Git Ref: $VCS_REF"
echo "  推送: $([[ $PUSH == true ]] && echo '是' || echo '否')"
echo ""

# 检查 Dockerfile 存在
if [ ! -f "$DOCKERFILE" ]; then
    print_error "Dockerfile 不存在: $DOCKERFILE"
    exit 1
fi

# 执行构建
print_info "构建镜像..."
docker build \
    $NO_CACHE \
    -f "$DOCKERFILE" \
    -t "$IMAGE_NAME" \
    -t "$LATEST_NAME" \
    --label "org.opencontainers.image.created=$BUILD_DATE" \
    --label "org.opencontainers.image.version=$VERSION" \
    --label "org.opencontainers.image.revision=$VCS_REF" \
    --label "org.opencontainers.image.title=Wiki.js External PostgreSQL" \
    --label "org.opencontainers.image.description=Wiki.js with external PostgreSQL database" \
    --label "org.opencontainers.image.source=https://github.com/requarks/wiki" \
    --label "org.opencontainers.image.maintainer=requarks.io" \
    .

if [ $? -eq 0 ]; then
    print_info "镜像构建成功！"
    print_info "镜像名称: $IMAGE_NAME"
else
    print_error "镜像构建失败！"
    exit 1
fi

# 显示镜像信息
echo ""
print_info "镜像信息:"
docker inspect --format='镜像 ID: {{.ID}}' "$IMAGE_NAME"
docker inspect --format='大小: {{.Size | humanize}}' "$IMAGE_NAME"
docker images | grep "$REPOSITORY" | head -3

# 推送镜像
if [ "$PUSH" = true ]; then
    echo ""
    print_info "推送镜像到仓库..."
    
    if docker push "$IMAGE_NAME"; then
        print_info "镜像推送成功: $IMAGE_NAME"
    else
        print_error "镜像推送失败: $IMAGE_NAME"
        exit 1
    fi
    
    if docker push "$LATEST_NAME"; then
        print_info "最新标签推送成功: $LATEST_NAME"
    else
        print_warn "最新标签推送失败: $LATEST_NAME"
    fi
fi

print_info "构建完成！"
