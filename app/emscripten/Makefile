


#
# Makefile for building with emscripten
# This is intended to be run from the root dir:
#  make -f app/emscripten/Makefile
#

CC         = emcc

S3_BUCKET_URL = s3://m1lkdr0p.com/

CONFIG     ?= release
BUILD_DIR   = build/emscripten/$(CONFIG)
OUTPUT_DIR  = $(BUILD_DIR)/bin
OUTPUT_HTML = $(OUTPUT_DIR)/index.html
OUTPUT_WASM = $(OUTPUT_DIR)/index.wasm
OUTPUT_DATA = $(OUTPUT_DIR)/index.data
OUTPUT_FAVICON = $(OUTPUT_DIR)/favicon.ico

EMRUN       = emrun
BROWSER    ?= chrome


INCLUDE_DIRS += src
INCLUDE_DIRS += src/script
INCLUDE_DIRS += src/script/mdp-eel2

SOURCES := $(shell find src -name '*.cpp')
SOURCES += $(shell find src -name '*.c' )
SOURCES += $(shell find app/emscripten -name '*.cpp')
WEBROOT_SOURCES += $(shell find app/emscripten/www)

# include ImGui
IMGUI_ROOT := external/imgui
SOURCES += $(IMGUI_ROOT)/imgui.cpp
SOURCES += $(IMGUI_ROOT)/imgui_widgets.cpp
SOURCES += $(IMGUI_ROOT)/imgui_draw.cpp
SOURCES += $(IMGUI_ROOT)/imgui_demo.cpp
SOURCES += $(IMGUI_ROOT)/imgui_tables.cpp
INCLUDE_DIRS += $(IMGUI_ROOT)


# HLSL2GLSL

HLSL2GLSL_ROOT := external/hlsl2glslfork/hlslang
SOURCES += $(shell find $(HLSL2GLSL_ROOT)/GLSLCodeGen -name '*.cpp')
SOURCES += $(shell find $(HLSL2GLSL_ROOT)/MachineIndependent -name '*.cpp')
SOURCES += $(shell find $(HLSL2GLSL_ROOT)/OSDependent/Emscripten -name '*.cpp')
INCLUDE_DIRS += $(HLSL2GLSL_ROOT)
INCLUDE_DIRS += $(HLSL2GLSL_ROOT)/hlslang
INCLUDE_DIRS += $(HLSL2GLSL_ROOT)/Include
INCLUDE_DIRS += $(HLSL2GLSL_ROOT)/MachineIndependent
INCLUDE_DIRS += $(HLSL2GLSL_ROOT)/GLSLCodeGen
INCLUDE_DIRS += $(HLSL2GLSL_ROOT)/OSDependent/Emscripten


# MINIZIP
MINIZIP_ROOT := external/minizip
SOURCES += $(MINIZIP_ROOT)/ioapi.c
SOURCES += $(MINIZIP_ROOT)/ioapi_buf.c
SOURCES += $(MINIZIP_ROOT)/ioapi_mem.c
SOURCES += $(MINIZIP_ROOT)/unzip.c
SOURCES += $(MINIZIP_ROOT)/zip.c

# LZMA

LZMA_SOURCE_DIR = external/lzma1801/C
LZMA_SOURCE += ${LZMA_SOURCE_DIR}/Lzma2Dec.c ${LZMA_SOURCE_DIR}/Ppmd7Dec.c ${LZMA_SOURCE_DIR}/Aes.c
LZMA_SOURCE += ${LZMA_SOURCE_DIR}/Bcj2.c ${LZMA_SOURCE_DIR}/LzFind.c ${LZMA_SOURCE_DIR}/DllSecur.c
LZMA_SOURCE += ${LZMA_SOURCE_DIR}/Sort.c ${LZMA_SOURCE_DIR}/Ppmd7.c
LZMA_SOURCE += ${LZMA_SOURCE_DIR}/Bra.c ${LZMA_SOURCE_DIR}/Bra86.c ${LZMA_SOURCE_DIR}/7zArcIn.c
LZMA_SOURCE += ${LZMA_SOURCE_DIR}/7zAlloc.c ${LZMA_SOURCE_DIR}/Alloc.c ${LZMA_SOURCE_DIR}/LzmaDec.c
LZMA_SOURCE += ${LZMA_SOURCE_DIR}/Ppmd7Enc.c ${LZMA_SOURCE_DIR}/7zDec.c ${LZMA_SOURCE_DIR}/7zBuf2.c
LZMA_SOURCE += ${LZMA_SOURCE_DIR}/BraIA64.c ${LZMA_SOURCE_DIR}/Lzma86Dec.c ${LZMA_SOURCE_DIR}/7zStream.c
LZMA_SOURCE += ${LZMA_SOURCE_DIR}/Sha256.c ${LZMA_SOURCE_DIR}/Delta.c ${LZMA_SOURCE_DIR}/7zFile.c
LZMA_SOURCE += ${LZMA_SOURCE_DIR}/7zCrc.c ${LZMA_SOURCE_DIR}/AesOpt.c ${LZMA_SOURCE_DIR}/CpuArch.c
LZMA_SOURCE += ${LZMA_SOURCE_DIR}/7zCrcOpt.c ${LZMA_SOURCE_DIR}/7zBuf.c
SOURCES += ${LZMA_SOURCE}



SOURCES_JS = $(shell find src -name '*.js')




OBJS       := $(SOURCES:%=$(BUILD_DIR)/%.o)
DEPS       := $(SOURCES:%=$(BUILD_DIR)/%.d)
#DATA_FILES := $(shell find assets)
#SHELL_HTML ?= app/emscripten/emscripten_shell.html
SHELL_HTML ?= app/emscripten/shell_minimal.html


#
# compile flags
#

CC_FLAGS += -Wno-register

ifeq ($(CONFIG),debug)
CC_FLAGS += -g
CC_FLAGS += -O1
CC_FLAGS += -DDEBUG=1
else ifeq ($(CONFIG),profile)
CC_FLAGS += -O2
CC_FLAGS += --profiling 
CC_FLAGS += --tracing
CC_FLAGS += --cpuprofiler
CC_FLAGS += -DPROFILE=1
else ifeq ($(CONFIG),release)
CC_FLAGS += -O2
CC_FLAGS += -DRELEASE=1
else
error invalid configuration $(CONFIG) (must be debug,profile,release)
endif

CC_FLAGS += -DBUILD_CONFIG=$(CONFIG)
CC_FLAGS += -Wno-deprecated-register
CC_FLAGS += -Wreorder-init-list
CC_FLAGS += -s USE_ZLIB


#
# linker flags
#

LD_FLAGS += --preload-file assets 
# LD_FLAGS += --use-preload-plugins 
LD_FLAGS += --emrun 
LD_FLAGS += -s TOTAL_MEMORY=536870912
LD_FLAGS += -s DEMANGLE_SUPPORT=1

ifneq ($(CONFIG),profile)
LD_FLAGS += --shell-file $(SHELL_HTML)
endif
LD_FLAGS += -s WASM=1
LD_FLAGS += -s ASSERTIONS=1
LD_FLAGS += -s USE_WEBGL2=1
LD_FLAGS += -s USE_SDL=2
#LD_FLAGS += -s "BINARYEN_TRAP_MODE='clamp'"
LD_FLAGS += -mnontrapping-fptoint

LD_FLAGS += -s MIN_WEBGL_VERSION=2
LD_FLAGS += -s MAX_WEBGL_VERSION=2

# LD_FLAGS += -s FULL_ES3=1
LD_FLAGS +=  -lopenal
LD_FLAGS += -s DISABLE_DEPRECATED_FIND_EVENT_TARGET_BEHAVIOR=1

LD_FLAGS += $(addprefix --post-js , $(SOURCES_JS) )

#
#

.PHONY: default
default: build

.PHONY: run
run: build
	$(EMRUN) --serve_after_close --browser $(BROWSER) $(OUTPUT_HTML)

.PHONY: build
build: $(OUTPUT_HTML)

.PHONY: serve
serve: $(OUTPUT_HTML)
	open http://localhost:6931/ & 
	$(EMRUN) --no_browser $(OUTPUT_HTML)

test:
	echo $(addprefix --post-js , $(SOURCES_JS) )

.PHONY: clean
clean:
	rm -Rf $(BUILD_DIR)


$(OUTPUT_HTML) $(OUTPUT_WASM) $(OUTPUT_DATA): $(OBJS) $(SHELL_HTML) $(SOURCES_JS) $(MAKEFILE_LIST) 
	@mkdir -p $(@D)
	@echo Linking $@
	@$(CC) $(OBJS) -o $@ $(CC_FLAGS) $(LD_FLAGS)


$(BUILD_DIR)/%.c.o: %.c
	@mkdir -p $(@D)
	@echo Compiling $<
	@$(CC) -c $< -o $@ -MMD $(CC_FLAGS) $(INCLUDE_DIRS:%=-I%) 

$(BUILD_DIR)/%.cpp.o: %.cpp
	@mkdir -p $(@D)
	@echo Compiling $<
	@$(CC) -c $< -o $@ -MMD $(CC_FLAGS) -std=c++17 $(INCLUDE_DIRS:%=-I%)

$(OUTPUT_DIR): $(OUTPUT_HTML) $(OUTPUT_WASM) $(OUTPUT_DATA) $(WEBROOT_SOURCES)
	@mkdir -p $@
	cp -av $(WEBROOT_SOURCES) $@
	touch $@


.PHONY: deploy
deploy: build
	aws s3 cp $(OUTPUT_DIR)  $(S3_BUCKET_URL) --recursive



-include $(DEPS)
