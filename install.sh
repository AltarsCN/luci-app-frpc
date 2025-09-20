#!/bin/sh
# LuCI app-frpc 手动安装脚本
# 在OpenWrt系统中运行此脚本

echo "安装 LuCI app-frpc..."

# 1. 确保依赖包已安装
echo "检查依赖包..."
opkg update
opkg install frpc luci-base

# 2. 创建必要的目录
echo "创建目录..."
mkdir -p /www/luci-static/resources/view
mkdir -p /usr/share/luci/menu.d
mkdir -p /usr/share/rpcd/acl.d
mkdir -p /etc/config

# 检查并创建可能的LuCI静态文件目录
if [ ! -d "/www/luci-static" ]; then
    echo "创建 /www/luci-static 目录..."
    mkdir -p /www/luci-static/resources/view
fi

# 检查uhttpd配置
if [ -f "/etc/config/uhttpd" ]; then
    echo "检查uhttpd配置..."
    # 确保home目录正确
    uci get uhttpd.main.home 2>/dev/null || uci set uhttpd.main.home='/www'
    uci commit uhttpd
fi

# 3. 复制文件
echo "复制文件..."

# 复制JavaScript视图文件
echo "复制 frpc.js..."
cp ./htdocs/luci-static/resources/view/frpc.js /www/luci-static/resources/view/
if [ $? -eq 0 ]; then
    echo "✓ frpc.js 复制成功"
    ls -la /www/luci-static/resources/view/frpc.js
else
    echo "✗ frpc.js 复制失败"
    exit 1
fi

# 复制菜单配置
echo "复制菜单配置..."
cp ./root/usr/share/luci/menu.d/luci-app-frpc.json /usr/share/luci/menu.d/
if [ $? -eq 0 ]; then
    echo "✓ 菜单配置复制成功"
else
    echo "✗ 菜单配置复制失败"
    exit 1
fi

# 复制ACL配置
echo "复制ACL配置..."
cp ./root/usr/share/rpcd/acl.d/luci-app-frpc.json /usr/share/rpcd/acl.d/
if [ $? -eq 0 ]; then
    echo "✓ ACL配置复制成功"
else
    echo "✗ ACL配置复制失败"
    exit 1
fi

# 复制默认配置文件
echo "复制默认配置..."
cp ./files/etc/config/frpc /etc/config/
if [ $? -eq 0 ]; then
    echo "✓ 默认配置复制成功"
else
    echo "✗ 默认配置复制失败"
    exit 1
fi

echo "安装完成！"

# 4. 验证安装
echo "验证安装..."
echo "检查文件是否存在："
ls -la /www/luci-static/resources/view/frpc.js
ls -la /usr/share/luci/menu.d/luci-app-frpc.json
ls -la /usr/share/rpcd/acl.d/luci-app-frpc.json
ls -la /etc/config/frpc

# 5. 重启服务
echo "重启相关服务..."
/etc/init.d/rpcd restart
/etc/init.d/uhttpd restart

echo ""
echo "安装完成！"
echo "请执行以下步骤："
echo "1. 清除浏览器缓存 (Ctrl+F5)"
echo "2. 访问 LuCI 界面"
echo "3. 在左侧菜单中查找 'Services' -> 'frp Client'"
echo ""
echo "如果仍有问题，请检查："
echo "- 文件权限：chmod 644 /www/luci-static/resources/view/frpc.js"
echo "- uhttpd配置：uci show uhttpd"
echo "- 日志：logread | grep uhttpd"
echo "- 或者尝试：cp ./htdocs/luci-static/resources/view/frpc.js /usr/share/luci-static/resources/view/"