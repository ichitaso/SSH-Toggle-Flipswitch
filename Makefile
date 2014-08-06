ARCHS = armv6 armv7 armv7s arm64
THEOS_DEVICE_IP = 192.168.0.14

BUNDLE_NAME = SSHToggle
SSHToggle_FILES = Switch.x
SSHToggle_FRAMEWORKS = UIKit
SSHToggle_LIBRARIES = flipswitch
SSHToggle_INSTALL_PATH = /Library/Switches

TOOL_NAME = sshtogglesw
sshtogglesw_FILES = main.mm
sshtogglesw_INSTALL_PATH = /Library/Switches/SSHToggle.bundle

include theos/makefiles/common.mk
include $(THEOS_MAKE_PATH)/bundle.mk
include $(THEOS_MAKE_PATH)/tool.mk

before-package::
	sudo chown -R root:wheel $(THEOS_STAGING_DIR)
	sudo chmod -R 755 $(THEOS_STAGING_DIR)
	sudo chmod 666 $(THEOS_STAGING_DIR)/Library/Switches/SSHToggle.bundle/*.pdf
	sudo chmod 4755 $(THEOS_STAGING_DIR)/Library/Switches/SSHToggle.bundle/sshtogglesw

after-install::
	install.exec "killall -9 backboardd"
	sudo rm -rf _
	rm -rf .obj
	rm -rf obj
	rm -rf .theos
	rm -rf *.deb
