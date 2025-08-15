#!/bin/bash
# Ubuntu 系统清理脚本
# 功能：清理系统缓存、日志、临时文件等无用文件

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 检查是否为root用户
check_root() {
    if [[ $EUID -eq 0 ]]; then
        echo -e "${RED}警告：不建议以root用户身份运行此脚本${NC}"
        read -p "是否继续？(y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
}

# 显示清理前系统信息
show_system_info() {
    echo -e "${BLUE}==============================${NC}"
    echo -e "${BLUE}    Ubuntu 系统清理脚本${NC}"
    echo -e "${BLUE}==============================${NC}"
    echo ""
    
    echo -e "${YELLOW}当前系统信息：${NC}"
    echo "系统版本: $(lsb_release -d | cut -f2)"
    echo "内核版本: $(uname -r)"
    echo "当前用户: $(whoami)"
    echo ""
    
    echo -e "${YELLOW}清理前磁盘使用情况：${NC}"
    df -h /
    echo ""
    
    echo -e "${YELLOW}清理前 /var 目录大小：${NC}"
    sudo du -sh /var 2>/dev/null || echo "无法获取 /var 目录大小"
    echo ""
}

# 清理APT缓存
clean_apt_cache() {
    echo -e "${GREEN}>>> 清理APT缓存...${NC}"
    sudo apt-get clean
    sudo apt-get autoclean
    sudo apt-get autoremove --purge -y
    echo -e "${GREEN}APT缓存清理完成${NC}"
}

# 清理日志文件
clean_logs() {
    echo -e "${GREEN}>>> 清理系统日志...${NC}"
    
    # 清理journalctl日志
    if command -v journalctl &> /dev/null; then
        echo "清理journalctl日志..."
        sudo journalctl --vacuum-time=7d
        sudo journalctl --vacuum-size=100M
    fi
    
    # 清理旧日志文件
    echo "清理旧日志文件..."
    sudo find /var/log -name "*.log" -type f -mtime +30 -delete 2>/dev/null
    sudo find /var/log -name "*.gz" -type f -mtime +30 -delete 2>/dev/null
    
    # 清理特定服务的日志
    sudo truncate -s 0 /var/log/syslog 2>/dev/null
    sudo truncate -s 0 /var/log/kern.log 2>/dev/null
    
    echo -e "${GREEN}日志清理完成${NC}"
}

# 清理临时文件
clean_temp_files() {
    echo -e "${GREEN}>>> 清理临时文件...${NC}"
    
    # 清理系统临时目录
    sudo rm -rf /tmp/*
    sudo rm -rf /var/tmp/*
    
    # 清理用户临时目录
    rm -rf ~/.cache/*
    rm -rf ~/.local/share/Trash/*
    
    # 清理浏览器缓存（如果存在）
    if [ -d ~/.mozilla ]; then
        rm -rf ~/.mozilla/firefox/*/Cache/*
        rm -rf ~/.mozilla/firefox/*/cache2/*
    fi
    
    if [ -d ~/.config/google-chrome ]; then
        rm -rf ~/.config/google-chrome/Default/Cache/*
        rm -rf ~/.config/google-chrome/Default/Code\ Cache/*
    fi
    
    echo -e "${GREEN}临时文件清理完成${NC}"
}

# 清理旧内核
clean_old_kernels() {
    echo -e "${GREEN}>>> 清理旧内核...${NC}"
    
    # 显示当前安装的内核
    echo "当前安装的内核："
    dpkg --list | grep linux-image
    
    # 询问是否清理旧内核
    read -p "是否清理旧内核？(y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        sudo apt-get autoremove --purge -y
        echo -e "${GREEN}旧内核清理完成${NC}"
    else
        echo "跳过内核清理"
    fi
}

# 清理缩略图缓存
clean_thumbnail_cache() {
    echo -e "${GREEN}>>> 清理缩略图缓存...${NC}"
    
    if [ -d ~/.cache/thumbnails ]; then
        rm -rf ~/.cache/thumbnails/*
        echo -e "${GREEN}缩略图缓存清理完成${NC}"
    else
        echo "未找到缩略图缓存目录"
    fi
}

# 清理软件包下载缓存
clean_package_cache() {
    echo -e "${GREEN}>>> 清理软件包下载缓存...${NC}"
    
    # 清理snap缓存
    if command -v snap &> /dev/null; then
        echo -e "${YELLOW}清理snap缓存...${NC}"
        
        # 显示清理前的snap信息
        echo "清理前snap包数量: $(snap list | wc -l)"
        echo "清理前snap存储使用: $(snap list --all | grep -c disabled) 个已禁用版本"
        
        # 清理已禁用的旧版本
        echo "清理已禁用的旧版本..."
        sudo snap list --all | awk '/disabled/{print $1, $3}' | while read snapname revision; do
            echo "  移除: $snapname (版本: $revision)"
            sudo snap remove "$snapname" --revision="$revision" 2>/dev/null
        done
        
        # 设置保留版本数量
        echo "设置snap版本保留策略..."
        sudo snap set system refresh.retain=2
        
        # 清理snap下载缓存
        echo "清理snap下载缓存..."
        sudo rm -rf /var/lib/snapd/cache/*
        
        # 清理snap挂载点（如果有孤立的）
        echo "清理孤立的snap挂载点..."
        sudo umount /var/lib/snapd/snaps/*.snap 2>/dev/null || true
        
        # 清理snap临时文件
        echo "清理snap临时文件..."
        sudo rm -rf /var/lib/snapd/tmp/*
        
        # 显示清理后的信息
        echo "清理后snap包数量: $(snap list | wc -l)"
        echo -e "${GREEN}snap缓存清理完成${NC}"
    else
        echo "系统未安装snap"
    fi
    
    # 清理flatpak缓存
    if command -v flatpak &> /dev/null; then
        echo -e "${YELLOW}清理flatpak缓存...${NC}"
        echo "清理前flatpak包数量: $(flatpak list | wc -l)"
        flatpak uninstall --unused -y
        echo "清理后flatpak包数量: $(flatpak list | wc -l)"
        echo -e "${GREEN}flatpak缓存清理完成${NC}"
    else
        echo "系统未安装flatpak"
    fi
    
    echo -e "${GREEN}软件包缓存清理完成${NC}"
}

# 深度清理snap（可选）
clean_snap_deep() {
    if command -v snap &> /dev/null; then
        echo -e "${GREEN}>>> 深度清理snap...${NC}"
        
        read -p "是否进行snap深度清理？这将清理更多snap相关文件 (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo -e "${YELLOW}执行snap深度清理...${NC}"
            
            # 清理snap数据目录中的旧数据
            echo "清理snap数据目录..."
            sudo find /var/lib/snapd/snaps -name "*.snap" -mtime +30 -delete 2>/dev/null || true
            
            # 清理snap用户数据
            echo "清理snap用户数据..."
            sudo find /home/*/snap -name "common" -type d -mtime +90 -exec rm -rf {} + 2>/dev/null || true
            
            # 清理snap挂载的旧版本
            echo "清理snap挂载的旧版本..."
            sudo find /var/lib/snapd/snaps -name "*.snap" -exec basename {} \; | \
                sort | uniq -d | while read snapname; do
                    echo "  清理重复的snap: $snapname"
                    sudo snap remove "$snapname" --revision=oldest 2>/dev/null || true
                done
            
            # 清理snap日志
            echo "清理snap日志..."
            sudo journalctl --vacuum-time=7d | grep -i snap || true
            
            echo -e "${GREEN}snap深度清理完成${NC}"
        else
            echo "跳过snap深度清理"
        fi
    fi
}

# 清理Docker（如果安装）
clean_docker() {
    if command -v docker &> /dev/null; then
        echo -e "${GREEN}>>> 清理Docker...${NC}"
        
        read -p "是否清理Docker？(y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            # 检查docker_cleanup.sh是否存在
            if [ -f "./docker_cleanup.sh" ]; then
                echo "调用 docker_cleanup.sh 脚本..."
                bash ./docker_cleanup.sh
            else
                echo "未找到 docker_cleanup.sh，使用默认Docker清理命令..."
                docker system prune -a --volumes -f
            fi
            echo -e "${GREEN}Docker清理完成${NC}"
        else
            echo "跳过Docker清理"
        fi
    fi
}

# 显示清理后结果
show_cleanup_results() {
    echo ""
    echo -e "${BLUE}==============================${NC}"
    echo -e "${BLUE}        清理完成${NC}"
    echo -e "${BLUE}==============================${NC}"
    echo ""
    
    echo -e "${YELLOW}清理后磁盘使用情况：${NC}"
    df -h /
    echo ""
    
    echo -e "${YELLOW}清理后 /var 目录大小：${NC}"
    sudo du -sh /var 2>/dev/null || echo "无法获取 /var 目录大小"
    echo ""
    
    echo -e "${GREEN}系统清理完成！✅${NC}"
}

# 主函数
main() {
    check_root
    show_system_info
    
    echo -e "${YELLOW}本脚本将清理以下内容：${NC}"
    echo "• APT缓存和软件包"
    echo "• 系统日志文件"
    echo "• 临时文件"
    echo "• 缩略图缓存"
    echo "• 软件包下载缓存（包括snap和flatpak）"
    echo "• 旧内核（可选）"
    echo "• snap深度清理（可选）"
    echo "• Docker缓存（可选）"
    echo ""
    
    read -p "是否继续清理？(y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "已取消操作。"
        exit 0
    fi
    
    echo ""
    
    # 执行清理操作
    clean_apt_cache
    clean_logs
    clean_temp_files
    clean_thumbnail_cache
    clean_package_cache
    clean_old_kernels
    clean_snap_deep
    clean_docker
    
    show_cleanup_results
}

# 运行主函数
main "$@" 