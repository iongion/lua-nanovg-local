LUAVER?=5.3
L_EXT?=so
UNAME=$(shell uname)
SYS=$(if $(filter Linux%,$(UNAME)),linux,\
	$(if $(filter MINGW%,$(UNAME)),mingw,\
	$(if $(filter Darwin%,$(UNAME)),macosx,\
	undefined\
)))
PROJECT_HOME:=$(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
PATH+="$(HOME)/.lua:$(HOME)/.luarocks/bin"

ifdef MINGW_PREFIX
	MINGW=1
	L_EXT=dll
else
	UNAME_S:=$(shell uname -s)
	ifeq ($(UNAME_S),Linux)
		LINUX=1
	endif
	ifeq ($(UNAME_S),Darwin)
		OSX=1
	endif
endif

INCDIR+=-Iglfw/include

# CI
PREFIX?=$(PROJECT_HOME)/build/$(SYS)/install/lua
INCDIR+=-I$(PROJECT_HOME)/build/$(SYS)/install/lua/include
LDFLAGS?=-L$(PROJECT_HOME)/build/$(SYS)/install/lua/lib -llua

# Directory where to install Lua modules
L_DIR=$(PREFIX)/share/lua/$(LUAVER)
# Directory where to install Lua C modules
C_DIR=$(PREFIX)/lib/lua/$(LUAVER)
# Directory where to install C headers
H_DIR=$(PREFIX)/include
# Directory where to install C libraries
S_DIR=$(PREFIX)/lib

default : all

.PHONY: all clean moonglfw install test mingw linux macosx undefined doc

all: clean moonglfw $(SYS) doc

doc:
	@echo "Building documentation: [$(PROJECT_HOME)]"
	@cd doc && make

undefined :
	@echo "I can't guess your platform, please do 'make PLATFORM' where PLATFORM is one of these:"
	@echo "      linux mingw macosx"

clean :
	@rm -fr *.so
	@rm -fr *.dll
	@rm -fr *.a
	@rm -fr *.o
	@echo "Cleaned build files"
	@cd moonglfw && $(MAKE) clean

moonglfw :
	@echo "Building moonglfw dependency in $(PREFIX) $(INCDIR)"
	@cd moonglfw && INCDIR="$(INCDIR)" $(MAKE) clean && cd .
	@cd moonglfw && INCDIR="$(INCDIR)" $(MAKE) && cd .
	@cp moonglfw/src/moonglfw.$(L_EXT) moonglfw.$(L_EXT)

install : moonglfw $(SYS)
	@echo "Installing moonglfw dependency in $(PREFIX)"
	@cd moonglfw && PREFIX="$(PREFIX)" $(MAKE) -f Makefile install && cd .
	@echo "Installing nvg dependency in $(C_DIR)"
	@cp -f nvg.$(L_EXT) $(C_DIR)

test :
	@bash ./scripts/run-tests.sh

mingw : OS := MINGW
mingw : CFLAGS += -DLUAVER=$(LUAVER) -D_GLFW_USE_OPENGL -D_GLFW_WIN32 -D_GLFW_WGL -D_GLFW_BUILD_ALL -fPIC
mingw : LDFLAGS += -lm -lopengl32 -lgdi32
mingw :
	# NanoVG
	gcc -c -O3 $(CFLAGS) $(INCDIR) nanovg/src/nanovg.c
	ar rcs libnanovg.a *.o
	gcc -shared -O3 $(CFLAGS) $(INCDIR) -o nvg.$(L_EXT) lua-nanovg.c libnanovg.a $(LDFLAGS)

linux : OS := LINUX
linux : CFLAGS += -DLUAVER=$(LUAVER) -D_GLFW_USE_OPENGL -D_GLFW_X11 -D_GLFW_BUILD_ALL -fPIC
linux :
	# NanoVG
	gcc -c -O3 $(CFLAGS) $(INCDIR) nanovg/src/nanovg.c
	ar rcs libnanovg.a *.o
	gcc -shared -O3 $(CFLAGS) $(INCDIR) -o nvg.$(L_EXT) lua-nanovg.c libnanovg.a $(LDFLAGS)

macosx : OS := MACOSX
macosx : CFLAGS += -DLUAVER=$(LUAVER) -D_GLFW_USE_OPENGL -D_GLFW_COCOA -D_GLFW_BUILD_ALL -D_GLFW_NSGL
macosx :
	# NanoVG
	gcc -c -O3 $(CFLAGS) $(INCDIR) nanovg/src/nanovg.c
	ar rcs libnanovg.a *.o
	gcc  -O3 -bundle -undefined dynamic_lookup -o nvg.$(L_EXT) lua-nanovg.c libnanovg.a
