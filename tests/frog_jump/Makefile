all: frog.c
	gcc frog.c `pkg-config allegro-5 allegro_font-5 allegro_dialog-5 allegro_ttf-5 allegro_primitives-5 allegro_image-5 allegro_audio-5 allegro_acodec-5 --libs --cflags` -o frog -O2 -Wall

clean:
	rm -f frog