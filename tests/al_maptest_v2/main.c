/**
 * @file main.c
 * @author your name (you@domain.com)
 * @brief 
 * @version 0.1
 * @date 2022-01-10
 * 
 * @copyright Copyright (c) 2022
 * 
 */

/*******************************************************************************
 * INCLUDE HEADER FILES
 ******************************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <time.h>
#include <stdbool.h>

#include "allegro_stuff.h"
#include "entities.h"
#include "geometry.h"
#include "game_data.h"
#include "menu.h"

#include "algif.h"

#include <pthread.h>


/*******************************************************************************
 * CONSTANT AND MACRO DEFINITIONS USING #DEFINE
 ******************************************************************************/

#define CHECK_KEY(key) (keyboard_check_key(key) == KEY_JUST_PRESSED)


/*******************************************************************************
 * ENUMERATIONS AND STRUCTURES AND TYPEDEFS
 ******************************************************************************/



/*******************************************************************************
 * VARIABLES WITH GLOBAL SCOPE
 ******************************************************************************/

// +ej: unsigned int anio_actual;+


/*******************************************************************************
 * FUNCTION PROTOTYPES FOR PRIVATE FUNCTIONS WITH FILE LEVEL SCOPE
 ******************************************************************************/

static void *thread0(void *ptr);


/*******************************************************************************
 * ROM CONST VARIABLES WITH FILE LEVEL SCOPE
 ******************************************************************************/

// +ej: static const int temperaturas_medias[4] = {23, 26, 24, 29};+


/*******************************************************************************
 * STATIC VARIABLES AND CONST VARIABLES WITH FILE LEVEL SCOPE
 ******************************************************************************/

static ALLEGRO_EVENT_TYPE event;

static pthread_t th0;

bool flag_init = true;

/*******************************************************************************
 *******************************************************************************
                                    MAIN 
 *******************************************************************************
 ******************************************************************************/

int main(void)
{
    srand(time(NULL));
 
    /*
    while(1)
    {
        printf("%d~", lanes_logs[get_rand_between(0, LANES_LOG_TOTAL-1)]);
        for(int i = 0; i < 10000000; i++);
    }
    */
    
	allegro_inits();
	game_data_init();
	entities_init();
	
    //menu_init();

	pthread_create(&th0, NULL, thread0, NULL);
	
	while(!allegro_get_var_done())
	{
		if(!(game_data_get_frames() % 300))
		{
			printf("\ntesda");
			flag_init = false;
		}
			
	}

    pthread_join(th0, NULL);

    //se destruyen reservas de memoria de allegro
    allegro_deinits();

    return 0;
}

/*******************************************************************************
 *******************************************************************************
                        LOCAL FUNCTION DEFINITIONS
 *******************************************************************************
 ******************************************************************************/

static void *thread0(void *ptr)
{
	allegro_reinit_display();


	while(1)    
    {	
        event = allegro_wait_for_event();

		
        
        switch(event)
        {
            case ALLEGRO_EVENT_TIMER:
                
                game_data_update();
                entities_update();
                //menu_update();
                
                //si es 'escape', avisa para cerrar la ventana
                if(CHECK_KEY(ALLEGRO_KEY_ESCAPE))
                    allegro_set_var_done(true);     
                /*
                if(CHECK_KEY(ALLEGRO_KEY_T))
					game_data_subtract_live();

				if(CHECK_KEY(ALLEGRO_KEY_Y))
					game_data_add_score(100);

                */
				
                //avisa que hay que renderizar
                allegro_set_var_redraw(true);

                break;

            //se apretó la "x" de la ventana
            case ALLEGRO_EVENT_DISPLAY_CLOSE:

                allegro_set_var_done(true);
                
                break;

            default:

                break;

        }

        //si hay que cerrar el programa
        if(allegro_get_var_done())
        {
            printf("\n~~cerrado~~\n\n");

            //sale del while
			break;  
        }

        //actualiza teclado
        keyboard_update();

		//al_lock_mutex(allegro_mutex);
		//pthread_mutex_lock(&allegro_lock);
		if(allegro_get_var_redraw() && allegro_is_event_queue_empty())
		{
			allegro_clear_display();

			allegro_draw_background();
            //entidades
            entities_draw();
            //data
            game_data_draw();
	

			al_flip_display();

			
            //avisa que ya se renderizó
			allegro_set_var_redraw(false);

		}
		//pthread_mutex_unlock(&allegro_lock);
		//al_unlock_mutex(allegro_mutex);

    }

	return NULL;
}
