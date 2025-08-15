#!/bin/bash
# 安全清理 Docker 占用空间

echo "============================"
echo " Docker 安全清理脚本"
echo "============================"
echo ""
echo "注意：本操作会删除所有未使用的容器、镜像、卷和网络"
echo "运行中的容器不会受到影响"
echo ""
read -p "是否继续？(y/N): " CONFIRM

if [[ "$CONFIRM" != "y" && "$CONFIRM" != "Y" ]]; then
    echo "已取消操作。"
    exit 0
fi

echo ""
echo ">>> 删除已停止的容器..."
docker container prune -f

echo ""
echo ">>> 删除未使用的镜像..."
docker image prune -a -f

echo ""
echo ">>> 删除未使用的卷..."
docker volume prune -f

echo ""
echo ">>> 删除未使用的网络..."
docker network prune -f

echo ""
echo ">>> 一次性深度清理所有无用数据..."
docker system prune -a --volumes -f

echo ""
echo ">>> 清理完成，当前 /var/lib/docker/overlay2 占用情况："
sudo du -sh /var/lib/docker/overlay2

echo ""
echo "操作已完成 ✅"

