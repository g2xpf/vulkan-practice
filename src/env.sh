# we assume that $VULKAN_SDK_PATH

# enable to find installed GLFW deps
export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig

# VK_LAYER_PATH might be a little bit different depending on the version of Vulkan SDK
export VK_LAYER_PATH="$VULKAN_SDK_PATH/etc/vulkan/explicit_layer.d:$VK_LAYER_PATH"
export CPLUS_INCLUDE_PATH="$VULKAN_SDK_PATH/include:$CPLUS_INCLUDE_PATH"
export LD_LIBRARY_PATH="$VULKAN_SDK_PATH/lib:$LD_LIBRARY_PATH"
