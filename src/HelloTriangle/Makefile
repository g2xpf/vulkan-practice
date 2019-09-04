VULKAN_VERSION=1.1.114.0
VULKAN_SDK_PATH=../../include/$(VULKAN_VERSION)/x86_64

CXXFLAGS  =-std=c++17 -I$(VULKAN_SDK_PATH)/include
LDFLAGS =-L$(VULKAN_SDK_PATH)/lib `pkg-config --static --libs glfw3` -lvulkan

HelloTriangle: main.cpp
	g++ $(CXXFLAGS) -o $@ $< $(LDFLAGS) 

.PHONY: test clean

test: HelloTriangle
	./$<

clean:
	rm -f HelloTriangle
