include $(TOPDIR)/rules.mk

PKG_NAME:=faito
PKG_REV:=1
PKG_VERSION:=r$(PKG_REV)
PKG_RELEASE:=1
#PKG_BRANCH=test

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/faito/Default
  URL:=http://www.blogin.it/
  MAINTAINER:=Nam Pham <nampt282@gmail.com>
endef

define Package/faito
	SECTION:=net
	CATEGORY:=Network
	TITLE:=FAITO Network
endef

define Package/faito/description
       SDK for AP controller
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) ./src/* $(PKG_BUILD_DIR)/
endef

define Build/Configure
endef

define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR) \
	CC="$(TARGET_CC)" \
	CFLAGS="$(TARGET_CFLAGS) -Wall" \
	LDFLAGS="$(TARGET_LDFLAGS)"
endef

define Package/faito/install
	$(INSTALL_DIR) $(1)
	$(CP) ./files/* $(1)/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/bin/lib/faito/* $(1)/lib/faito
endef

#define Package/robin/postinst
#	rm -f $${IPKG_INSTROOT}/etc/init.d/ntpdate
#endef

$(eval $(call BuildPackage,faito))
