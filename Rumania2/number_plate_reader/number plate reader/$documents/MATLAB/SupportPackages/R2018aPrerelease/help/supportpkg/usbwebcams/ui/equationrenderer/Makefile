# Copyright 2014-2017 The MathWorks, Inc.
COMPONENT := equationrenderer
include $(MAKE_INCLUDE_DIR)/build_component.mk

UI_NAME := $(COMPONENT)
PROFILE_FILE := $(UI_NAME).profile.js

GENERATE_JS_SUPPORTING_FILES = 1
include $(JAVASCRIPT_BUILD_HARNESS)/makefiles/build_javascript.mk

define POST_DOJO_BUILD
cp $(DERIVED_DIR)/$(UI_NAME)/MathRenderer.js $(RELEASE_DIR)/
mkdir -p $(RELEASE_DIR)/css
cp -R $(DERIVED_DIR)/css-$(UI_NAME)/main.css $(RELEASE_DIR)/css/
mkdir -p $(RELEASE_DIR)/fonts
cp -R -f $(DERIVED_DIR)/fonts/STIX* $(RELEASE_DIR)/fonts/
cp -R -f $(DERIVED_DIR)/fonts/MWMath* $(RELEASE_DIR)/fonts/
endef

define CLEAN_FILES

endef
