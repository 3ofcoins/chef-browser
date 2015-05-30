#
# This makefile is inspired by the fpm_with_system_ruby from:
# https://github.com/jordansissel/fpm
#
# Usage:
# VERSION variable is expected by this configuration
# > VERSION=1.1.1 make package
#

# where to get the source
GIT_URL=https://github.com/3ofcoins/chef-browser.git
TAG_SPEC=refs/tags/$(VERSION)

CHECKOUT_DIR=chef-browser-checkout
BUILD_DIR=build
LIB_DIR=$(BUILD_DIR)/opt/chef-browser
BIN_DIR=$(BUILD_DIR)/opt/bin
GEM_PATH:=$(shell readlink -f .)/build/gem
CHEF_BROWSER_BIN=$(BIN_DIR)/chef-browser
RUBY_CMD=/usr/bin/ruby
BUNDLE_BIN=$(GEM_PATH)/bin/bundle
BUNDLE_CMD=$(RUBY_CMD) $(BUNDLE_BIN)
FPM_CMD=/opt/bin/fpm
GEM_CMD=$(RUBY_CMD) -S gem

.PHONY: clean
clean:
	rm -rf $(CHECKOUT_DIR)
	rm -rf $(BUILD_DIR)
	rm -f chef-browser*.rpm

$(CHECKOUT_DIR):
	rm -rf $(CHECKOUT_DIR)
	git clone $(GIT_URL) $(CHECKOUT_DIR) --depth 1
	cd $(CHECKOUT_DIR) && git fetch && git checkout $(TAG_SPEC)

$(BUNDLE_BIN):
	$(GEM_CMD) install bundler --install-dir=$(GEM_PATH) --no-ri --no-rdoc

$(CHEF_BROWSER_BIN):
	mkdir --parents $(BIN_DIR)
# 	Couldn't think of a nice way to do this, so here is this code turd
	cp bin/chef-browser $(CHEF_BROWSER_BIN)
	chmod +x $(CHEF_BROWSER_BIN)

.PHONY: install
install: $(CHECKOUT_DIR) $(BUNDLE_BIN) $(CHEF_BROWSER_BIN)
	mkdir --parents $(LIB_DIR)
	cd $(CHECKOUT_DIR) && GEM_PATH=$(GEM_PATH) $(BUNDLE_CMD) install --without=development --standalone
	cp -r $(CHECKOUT_DIR)/bundle $(LIB_DIR)/bundle
	cp -r $(CHECKOUT_DIR)/lib $(LIB_DIR)/lib
	cp -r $(CHECKOUT_DIR)/public $(LIB_DIR)/public
	cp -r $(CHECKOUT_DIR)/views $(LIB_DIR)/views
	cp $(CHECKOUT_DIR)/CHANGELOG.md $(LIB_DIR)/CHANGELOG.md
	cp $(CHECKOUT_DIR)/LICENSE $(LIB_DIR)/LICENSE
	cp $(CHECKOUT_DIR)/README.md $(LIB_DIR)/README.md
	cp $(CHECKOUT_DIR)/settings.rb.example $(LIB_DIR)/settings.rb.example
	cp config/config.ru $(LIB_DIR)/config.ru

.PHONY: package
package: install
	$(FPM_CMD) -s dir -t rpm -n chef-browser -d ruby -d libicu -d zlib -d openssl -v $(VERSION) -C $(BUILD_DIR) opt

