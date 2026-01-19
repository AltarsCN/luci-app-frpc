# This is free software, licensed under the Apache License, Version 2.0

include $(TOPDIR)/rules.mk

LUCI_TITLE:=LuCI Support for frp client
LUCI_DEPENDS:=+luci-base +frpc

PKG_LICENSE:=Apache-2.0

# 解决与上游 frpc 包的文件冲突
# 上游 frpc 包也包含 /etc/config/frpc 和 /etc/init.d/frpc
# 使用 preinst 脚本在安装前删除这些冲突文件
define Package/luci-app-frpc/preinst
#!/bin/sh
[ -n "$${IPKG_INSTROOT}" ] || {
	# 运行时安装：删除可能由 frpc 包安装的冲突文件
	rm -f /etc/config/frpc 2>/dev/null
	rm -f /etc/init.d/frpc 2>/dev/null
}
exit 0
endef

define Package/luci-app-frpc/postrm
#!/bin/sh
[ -n "$${IPKG_INSTROOT}" ] || {
	# 卸载后重新安装 frpc 默认配置（如果 frpc 仍然存在）
	[ -x /etc/init.d/frpc ] || [ -f /usr/bin/frpc ] && {
		# frpc 二进制存在但配置丢失，创建空配置
		[ -f /etc/config/frpc ] || touch /etc/config/frpc
	}
}
exit 0
endef

include $(TOPDIR)/feeds/luci/luci.mk

# call BuildPackage - OpenWrt buildroot signature
