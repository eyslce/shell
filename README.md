# Shell 脚本工具集

这是一个包含实用shell脚本的集合，主要用于系统维护和清理工作。

## 📁 项目内容

### 🐳 Docker 清理脚本
- **文件**: `docker_cleanup.sh`
- **功能**: 安全清理Docker占用空间
- **特性**: 
  - 删除未使用的容器、镜像、卷和网络
  - 运行中的容器不受影响
  - 交互式确认操作
  - 显示清理后的存储使用情况

### 🖥️ Ubuntu 系统清理脚本
- **文件**: `ubuntu_cleanup.sh`
- **功能**: 全面清理Ubuntu系统无用文件
- **特性**:
  - APT缓存和软件包清理
  - 系统日志文件清理
  - 临时文件和用户缓存清理
  - 缩略图缓存清理
  - Snap和Flatpak缓存清理
  - 旧内核清理（可选）
  - Docker缓存清理（集成docker_cleanup.sh）
  - 彩色输出和进度提示

## 🚀 快速开始

### 克隆仓库
```bash
git clone git@github.com:eyslce/shell.git
cd shell
```

### 设置执行权限
```bash
chmod +x *.sh
```

### 运行脚本

#### Docker清理
```bash
./docker_cleanup.sh
```

#### Ubuntu系统清理
```bash
./ubuntu_cleanup.sh
```

## 📋 系统要求

- **操作系统**: Ubuntu 18.04+ 或其他基于Debian的Linux发行版
- **权限**: 需要sudo权限执行某些清理操作
- **依赖**: 
  - bash shell
  - docker (可选，用于Docker清理)
  - snap (可选，用于snap清理)
  - flatpak (可选，用于flatpak清理)

## ⚠️ 注意事项

1. **备份重要数据**: 运行清理脚本前请确保重要数据已备份
2. **运行中的服务**: 脚本不会影响正在运行的服务和容器
3. **权限要求**: 某些清理操作需要sudo权限
4. **交互式确认**: 重要操作会要求用户确认

## 🔧 自定义配置

### 修改清理策略
- 编辑脚本文件中的相关参数
- 调整日志保留时间
- 修改缓存清理策略

### 添加新的清理功能
- 在相应脚本中添加新的函数
- 在主函数中调用新功能
- 更新README文档

## 📊 清理效果

运行清理脚本后，通常可以释放：
- **APT缓存**: 100MB - 1GB
- **系统日志**: 50MB - 500MB
- **临时文件**: 100MB - 2GB
- **Snap缓存**: 200MB - 1GB
- **Docker缓存**: 500MB - 5GB+

## 🤝 贡献

欢迎提交Issue和Pull Request来改进这些脚本！

### 贡献指南
1. Fork 本仓库
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 开启 Pull Request

## 📄 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情。

## 📞 联系方式

如有问题或建议，请通过以下方式联系：
- 提交 GitHub Issue
- 发送邮件至项目维护者

---

**免责声明**: 这些脚本仅供学习和个人使用。在生产环境中使用前，请充分测试并确保符合您的系统要求。 