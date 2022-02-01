# Makefile del proyecto								\
	Correr "make help" para obtener ayuda			\


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



# Paths stuff ~~~~~~~~~~~~~~~~~~~~~~~~~

# Directorio root
MAKE_DIR			= .

# Subdirectorios
BIN_DIR    			= $(MAKE_DIR)/bin
DOC_DIR	    		= $(MAKE_DIR)/doc
LIB_DIR 			= $(MAKE_DIR)/lib
OBJ_DIR   			= $(MAKE_DIR)/obj
SRC_DIR   			= $(MAKE_DIR)/src
SRC_PC_DIR			= $(SRC_DIR)/platform/pc
SRC_RPI_DIR			= $(SRC_DIR)/platform/rpi

# Paths stuff ~~~~~~~~~~~~~~~~~~~~~~~~~



# Objects stuff ~~~~~~~~~~~~~~~~~~~~~~~~~

# Objetos principales
_OBJS_MAIN 		= main.o queue.o fsm.o ranking.o
OBJS_MAIN 		= $(patsubst %, $(OBJ_DIR)/%, $(_OBJS_MAIN))

# Objetos genericos de plataforma
_OBJS_GENERIC = display.o game.o input.o menu.o nombre.o sound.o

# Objetos especificos PC
_OBJS_PC 		= allegro_stuff.o entities.o game_data.o geometry.o
_OBJS_PC		+= $(_OBJS_GENERIC)
OBJS_PC			= $(patsubst %.o,$(OBJ_DIR)/%_PC.o,$(_OBJS_PC))
_OBJS_PC_ALGIF 	= algif.o bitmap.o gif.o lzw.o
ALGIF_OBJS		= $(patsubst %.o,$(OBJ_DIR)/%_PC_ALGIF.o,$(_OBJS_PC_ALGIF))

# Objetos especificos RPI
_OBJS_RPI	= bitmap.o mensajes.o
_OBJS_RPI	+= $(_OBJS_GENERIC)
OBJS_RPI	= $(patsubst %.o,$(OBJ_DIR)/%_RPI.o,$(_OBJS_RPI))

# Objetos a usar. Se preinicializa con los principales.
OBJS 		= $(OBJS_MAIN)

# Objects stuff ~~~~~~~~~~~~~~~~~~~~~~~~~



# Libraries stuff ~~~~~~~~~~~~~~~~~~~~~~~~~

# Generics
LIBS		= -lpthread

# PC
LIBS_PC		= `pkg-config allegro-5 allegro_font-5 allegro_ttf-5 allegro_primitives-5 allegro_image-5 allegro_audio-5 allegro_acodec-5 --libs --cflags`
LIBS_PC 	+= -L$(LIB_DIR) -lalgif

# RPI
LIBS_RPI	=  -L$(LIB_DIR) -lrpiutils -lSDL2

# Libraries stuff ~~~~~~~~~~~~~~~~~~~~~~~~~



# Compilator stuff ~~~~~~~~~~~~~~~~~~~~~~~~~

# Compilador
CC 			= gcc

# Debugger
DEBUGGER	= gdb

# Flags de compilacion
CFLAGS 		= -Wall -Wno-unknown-pragmas -O2
ifdef DEBUG
CFLAGS		+= -g
endif

# Compilator stuff ~~~~~~~~~~~~~~~~~~~~~~~~~



# Deteccion de plataforma ~~~~~~~~~~~~~~~~~~~~~~~~~
# https://westermarck.com/thoughts/raspberry-pi-linux-32-64/

arch		= $(shell uname -m)
ifeq ($(arch), armv7l)
PLATFORM	= RPI
EXTRA_DEPS	=
else
PLATFORM 	= PC
EXTRA_DEPS	= $(LIB_DIR)/libalgif.a
endif

# Nombre del ejecutable
EXEC		= frogger_$(PLATFORM)
# Ejecutable con el path
TARGET 		= $(BIN_DIR)/$(EXEC)
# Objetos a usar
OBJS		+= $(OBJS_$(PLATFORM))
# Bibliotecas a usar
LIBS		+= $(LIBS_$(PLATFORM))

# Deteccion de plataforma ~~~~~~~~~~~~~~~~~~~~~~~~~



# Other stuff ~~~~~~~~~~~~~~~~~~~~~~~~~

# Crea directorio de objetos y ejecutable si no estan creados
dummy_obj_folder = $(shell mkdir -p $(OBJ_DIR))
dummy_bin_folder = $(shell mkdir -p $(BIN_DIR))

# Comando para borrar
RM	= rm -f

# Other stuff ~~~~~~~~~~~~~~~~~~~~~~~~~



#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



# Reglas principales ~~~~~~~~~~~~~~~~~~~~~~~~~

## -- Reglas Principales --

## Compila y linkea todo el proyecto.
.PHONY: all
all: $(TARGET)

## Compila, linkea y ejecuta el proyecto.
.PHONY: run
run: all
	cd $(BIN_DIR);./$(EXEC)

## Borra todos los objetos.
.PHONY: clean
clean:
	$(RM) $(OBJ_DIR)/*.o
	$(RM) $(EXTRA_DEPS)

## Borra todos los objetos y el ejecutable.
.PHONY: cleaner
cleaner: clean
	$(RM) $(TARGET)

# Reglas principales ~~~~~~~~~~~~~~~~~~~~~~~~~



# Linkeo de objetos y creacion del ejecutable ~~~~~~~~~~~~~~~~~~~~~~~~~

$(TARGET): $(OBJS) $(EXTRA_DEPS)
	$(CC) $(CFLAGS) $(OBJS) $(LIBS) -o $@ -lm

# Linkeo de objetos y creacion del ejecutable ~~~~~~~~~~~~~~~~~~~~~~~~~



# Compilacion generica ~~~~~~~~~~~~~~~~~~~~~~~~~

$(OBJ_DIR)/main.o: $(patsubst %,$(SRC_DIR)/%,main.c fsm.h queue.h)
	$(CC) $(CFLAGS) -c $< -o $@

$(OBJ_DIR)/queue.o: $(patsubst %,$(SRC_DIR)/%,queue.c queue.h)
	$(CC) $(CFLAGS) -c $< -o $@

$(OBJ_DIR)/fsm.o: $(patsubst %,$(SRC_DIR)/%,fsm.c fsm.h queue.h) $(patsubst %.o,$(SRC_DIR)/%.h,$(_OBJS_GENERIC))
	$(CC) $(CFLAGS) -c $< -o $@

$(OBJ_DIR)/ranking.o: $(patsubst %,$(SRC_DIR)/%,ranking.c ranking.h)
	$(CC) $(CFLAGS) -c $< -o $@

# Compilacion generica ~~~~~~~~~~~~~~~~~~~~~~~~~



# Compilacion de PC ~~~~~~~~~~~~~~~~~~~~~~~~~

$(OBJ_DIR)/display_PC.o: $(patsubst %,$(SRC_PC_DIR)/%,display.c allegro_stuff.h game_data.h) $(patsubst %,$(SRC_DIR)/%,display.h queue.h ranking.h)
	$(CC) $(CFLAGS) -c $< -o $@

$(OBJ_DIR)/game_PC.o: $(patsubst %,$(SRC_PC_DIR)/%,game.c allegro_stuff.h entities.h game_data.h) $(patsubst %,$(SRC_DIR)/%,game.h menu.h queue.h)
	$(CC) $(CFLAGS) -c $< -o $@

$(OBJ_DIR)/input_PC.o: $(patsubst %,$(SRC_PC_DIR)/%,input.c allegro_stuff.h entities.h game_data.h) $(patsubst %,$(SRC_DIR)/%,input.h queue.h)
	$(CC) $(CFLAGS) -c $< -o $@

$(OBJ_DIR)/menu_PC.o: $(patsubst %,$(SRC_PC_DIR)/%,menu.c allegro_stuff.h geometry.h game_data.h) $(patsubst %,$(SRC_DIR)/%,menu.h sound.h queue.h)
	$(CC) $(CFLAGS) -c $< -o $@

$(OBJ_DIR)/nombre_PC.o: $(patsubst %,$(SRC_PC_DIR)/%,nombre.c allegro_stuff.h game_data.h) $(patsubst %,$(SRC_DIR)/%,nombre.h)
	$(CC) $(CFLAGS) -c $< -o $@

$(OBJ_DIR)/sound_PC.o: $(patsubst %,$(SRC_PC_DIR)/%,sound.c allegro_stuff.h) $(patsubst %,$(SRC_DIR)/%,sound.h)
	$(CC) $(CFLAGS) -c $< -o $@


$(OBJ_DIR)/allegro_stuff_PC.o: $(patsubst %,$(SRC_PC_DIR)/%,allegro_stuff.c allegro_stuff.h entities.h geometry.h algif5/algif.h)
	$(CC) $(CFLAGS) -c $< -o $@

$(OBJ_DIR)/entities_PC.o: $(patsubst %,$(SRC_PC_DIR)/%,entities.c entities.h allegro_stuff.h geometry.h game_data.h)
	$(CC) $(CFLAGS) -c $< -o $@

$(OBJ_DIR)/game_data_PC.o: $(patsubst %,$(SRC_PC_DIR)/%,game_data.c game_data.h allegro_stuff.h geometry.h)
	$(CC) $(CFLAGS) -c $< -o $@

$(OBJ_DIR)/geometry_PC.o: $(patsubst %,$(SRC_PC_DIR)/%,geometry.c geometry.h)
	$(CC) $(CFLAGS) -c $< -o $@


$(LIB_DIR)/libalgif.a: $(ALGIF_OBJS)
	ar -rc $@ $(ALGIF_OBJS)
	ranlib $@

$(OBJ_DIR)/algif_PC_ALGIF.o: $(patsubst %,$(SRC_PC_DIR)/%,algif5/algif.c)
	$(CC) $(CFLAGS) -c $< -o $@

$(OBJ_DIR)/bitmap_PC_ALGIF.o: $(patsubst %,$(SRC_PC_DIR)/%,algif5/bitmap.c)
	$(CC) $(CFLAGS) -c $< -o $@

$(OBJ_DIR)/gif_PC_ALGIF.o: $(patsubst %,$(SRC_PC_DIR)/%,algif5/gif.c)
	$(CC) $(CFLAGS) -c $< -o $@

$(OBJ_DIR)/lzw_PC_ALGIF.o: $(patsubst %,$(SRC_PC_DIR)/%,algif5/lzw.c)
	$(CC) $(CFLAGS) -c $< -o $@

# Compilacion de PC ~~~~~~~~~~~~~~~~~~~~~~~~~



# Compilacion de RPI ~~~~~~~~~~~~~~~~~~~~~~~~~

$(OBJ_DIR)/display_RPI.o: $(patsubst %,$(SRC_RPI_DIR)/%,display.c) $(patsubst %,$(SRC_DIR)/%,display.h ranking.h)
	$(CC) $(CFLAGS) -c $< -o $@

$(OBJ_DIR)/game_RPI.o: $(patsubst %,$(SRC_RPI_DIR)/%,game.c) $(patsubst %,$(SRC_DIR)/%,game.h)
	$(CC) $(CFLAGS) -c $< -o $@

$(OBJ_DIR)/input_RPI.o: $(patsubst %,$(SRC_RPI_DIR)/%,input.c) $(patsubst %,$(SRC_DIR)/%,input.h)
	$(CC) $(CFLAGS) -c $< -o $@

$(OBJ_DIR)/menu_RPI.o: $(patsubst %,$(SRC_RPI_DIR)/%,menu.c) $(patsubst %,$(SRC_DIR)/%,menu.h)
	$(CC) $(CFLAGS) -c $< -o $@

$(OBJ_DIR)/nombre_RPI.o: $(patsubst %,$(SRC_RPI_DIR)/%,nombre.c) $(patsubst %,$(SRC_DIR)/%,nombre.h)
	$(CC) $(CFLAGS) -c $< -o $@

$(OBJ_DIR)/sound_RPI.o: $(patsubst %,$(SRC_RPI_DIR)/%,sound.c audio.h) $(patsubst %,$(SRC_DIR)/%,sound.h)
	$(CC) $(CFLAGS) -c $< -o $@


$(OBJ_DIR)/bitmap_RPI.o: $(patsubst %,$(SRC_RPI_DIR)/%,bitmap.c bitmap.h)
	$(CC) $(CFLAGS) -c $< -o $@

$(OBJ_DIR)/mensajes_RPI.o: $(patsubst %,$(SRC_RPI_DIR)/%,mensajes.c mensajes.h)
	$(CC) $(CFLAGS) -c $< -o $@

# Compilacion de RPI ~~~~~~~~~~~~~~~~~~~~~~~~~



# Otras reglas ~~~~~~~~~~~~~~~~~~~~~~~~~

## -- Otras Reglas --

## Compila (sin linkear) todos los objetos de PC
.PHONY: compile-pc
compile-pc: $(OBJS_PC) $(ALGIF_OBJS)

## Compila (sin linkear) todos los objetos de RPI
.PHONY: compile-rpi
compile-rpi: $(OBJS_RPI)

## Corre el ejecutable con el debugger.
## Previamente, hacer: "make cleaner" y "make all DEBUG=1"
.PHONY: debug
debug: all
	cd $(BIN_DIR);$(DEBUGGER) $(EXEC)


# Otras reglas ~~~~~~~~~~~~~~~~~~~~~~~~~



#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



# https://gist.github.com/prwhite/8168133

#.DEFAULT_GOAL = help

## This help message
.PHONY: help
help:
	@printf "Usage\n";

	@awk '{ \
			if ($$0 ~ /^.PHONY: [-a-zA-Z0-9_/9]+$$/) { \
				helpCommand = substr($$0, index($$0, ":") + 2); \
				if (helpMessage) { \
					printf "\033[36m%-20s\033[0m %s\n", \
						helpCommand, helpMessage; \
					helpMessage = ""; \
				} \
			} else if ($$0 ~ /^[-a-zA-Z0-9_/.]+:/) { \
				helpCommand = substr($$0, 0, index($$0, ":")); \
				if (helpMessage) { \
					printf "\033[36m%-20s\033[0m %s\n", \
						helpCommand, helpMessage; \
					helpMessage = ""; \
				} \
			} else if ($$0 ~ /^##/) { \
				if (helpMessage) { \
					helpMessage = helpMessage"\n                     "substr($$0, 3); \
				} else { \
					helpMessage = substr($$0, 3); \
				} \
			} else { \
				if (helpMessage) { \
					print "\n                     "helpMessage"\n" \
				} \
				helpMessage = ""; \
			} \
		}' \
		$(MAKEFILE_LIST)
