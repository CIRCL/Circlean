/***************************************************************************************/
/*                                                                                     */
/*  file : ledBtn.c                                                                    */
/*                                                                                     */
/*  synopsis :                                                                         */
/*  the compiled code should be ran with root privileges to allow for access to        */
/*  the GPIO pins through direct GPIO register manipulation in C-code.                 */
/*  After initialization, the code update the LEDs status according to the commands    */
/*  passed on std input (using a pipe).                                                */
/*  It also monitors the push-button and triggers a reboot sequence                    */
/*  when it is depressed.                                                              */
/*                                                                                     */
/*                                                                                     */
/*  This code is based on examples from                                                */
/*      http://elinux.org/RPi_Low-level_peripherals#C                                  */
/*      How to access GPIO registers from C-code on the Raspberry-Pi, Example program  */
/*      Dom and Gert, 15-January-2012, Revised: 15-Feb-2013                            */
/*                                                                                     */
/*  and from Raphael Vinot (CIRCL.lu)                                                  */
/*                                                                                     */
/*  v 1.00 - 22/02/2015 - initial release (Marc Durvaux)                               */
/*  v 1.10 - 27/02/2015 - added 'z' command for debugging, improved handling of        */
/*			  concateneted command sequences                               */
/*                                                                                     */
/*                                                                                     */
/*                                                                                     */
/***************************************************************************************/

// Includes
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <unistd.h>
#include <errno.h>

// Constant for low-level access to GPIO
#define BCM2708_PERI_BASE        0x20000000
#define GPIO_BASE                (BCM2708_PERI_BASE + 0x200000) /* GPIO controller */
#define BLOCK_SIZE (4*1024)

// global variables related to GPIO
int  mem_fd ;
void *gpio_map ;
volatile unsigned *gpio ;   // I/O access

// GPIO setup macros. Always use INP_GPIO(x) before using OUT_GPIO(x) or SET_GPIO_ALT(x,y)
#define INP_GPIO(g) *(gpio+((g)/10)) &= ~(7<<(((g)%10)*3))
#define OUT_GPIO(g) *(gpio+((g)/10)) |=  (1<<(((g)%10)*3))
#define SET_GPIO_ALT(g,a) *(gpio+(((g)/10))) |= (((a)<=3?(a)+4:(a)==4?3:2)<<(((g)%10)*3))

#define GPIO_SET *(gpio+7)  // sets   bits which are 1 ignores bits which are 0
#define GPIO_CLR *(gpio+10) // clears bits which are 1 ignores bits which are 0

#define GET_GPIO(g) (*(gpio+13)&(1<<g)) // 0 if LOW, (1<<g) if HIGH

#define GPIO_PULL *(gpio+37) // Pull up/pull down
#define GPIO_PULLCLK0 *(gpio+38) // Pull up/pull down clock

// LED and push-button GPIO pin mapping (from schematic)
#define GREEN_LED   17
#define YELLOW_LED  18
#define RED_LED     22
#define PUSHBUTTON  23

// Time tic (in nsec) for loops : 10 ms
#define TIME_TIC  10000000L
// Blink half-period in tics
#define MAX_COUNT 30
// Button long pression threshold
#define LONG_PUSH 300


// forward declaration of functions
void setup_io() ;
void do_reboot() ;

/***************************************************************************************/
//
// main
//      input : path and name of the FIFO must be passed as 1st argument
//
int main(int argc, char **argv) {
    int fd, nbytes ;
    int state, count, repeat_count ;
    int Btn_state, Btn_prev_state, Btn_press_count ;
    char code ;

    state = 0 ;             // initialize state variable
    count = 0 ;             // initialize loop counter
    repeat_count = 0 ;
    code = 0 ;

    setup_io() ;    // initialize GPIO pointer and GPIO pins
    Btn_state = GET_GPIO( PUSHBUTTON) ; // get push-button initial state
    Btn_prev_state = Btn_state ;
    Btn_press_count = 0 ;

    fd = open(argv[1], O_RDONLY) ;
    if (fd < 0) {
        perror("open") ;
        exit (2) ;
    }

    while(1) {
        Btn_state = GET_GPIO( PUSHBUTTON) ;
        if (Btn_state != 0) {   // button released
            Btn_press_count = 0 ;   // reset counter
        } else {    // button pressed
            Btn_press_count++ ;
            if (Btn_state != Btn_prev_state) {
                //printf("Button pressed!\n");
                if (state >= 4) { // final state, immediate reboot
                    close(fd) ;
                    do_reboot() ;
                }
            }
            if (Btn_press_count == LONG_PUSH) { // trigger forced reboot
                state = 10 ;    // LED animation before reboot
                repeat_count = 0 ;
            }
        }
        Btn_prev_state = Btn_state ;

        nbytes = read(fd, &code, 1) ;
        if (nbytes < 0) {
            perror("read") ;
            exit (2) ;
        }

        if (nbytes > 0) {
            switch (code) {    // codes evaluated at every tic
                case 'z' :  // clear without restart (for debugging)
                            GPIO_CLR = 1<<GREEN_LED ;
                            GPIO_CLR = 1<<YELLOW_LED ;
                            GPIO_CLR = 1<<RED_LED ;
                            state = 0 ;
                            break ;
                case 'r' :  // Ready
                            GPIO_SET = 1<<GREEN_LED ;
                            state = 1 ;
                            break ;
                case 'p' :  // Processing
                            GPIO_CLR = 1<<GREEN_LED ;
                            GPIO_SET = 1<<YELLOW_LED ;
                            state = 2 ;
                            break ;
                case 'e' :  // Error (process aborted)
                            GPIO_CLR = 1<<GREEN_LED ;
                            GPIO_CLR = 1<<YELLOW_LED ;
                            GPIO_SET = 1<<RED_LED ;
                            state = 6 ;
                            break ;
                case 'c' :  // task successfully completed
                            GPIO_CLR = 1<<YELLOW_LED ;
                            GPIO_SET = 1<<GREEN_LED ;
                            state = 4 ;
                            count = 0 ;
                            break ;
                case 'f' :  // file processing successfully completed
                            GPIO_SET = 1<<GREEN_LED ;
                            state = 3 ;
                            count = 0 ;
                            break ;
            } // end switch
        }

        count++ ;
        if (count >= MAX_COUNT) {
            count = 0 ;

            switch (state) {    // states evaluated after MAX_COUNT tics
                case  3 :   // green LED flash OFF
                            GPIO_CLR = 1<<GREEN_LED ;
                            state = 2 ;
                            break ;
                case  4 :   // green LED blinks OFF
                            GPIO_CLR = 1<<GREEN_LED ;
                            state = 5 ;
                            break ;
                case  5 :   // green LED blinks ON
                            GPIO_SET = 1<<GREEN_LED ;
                            state = 4 ;
                            break ;
                case 10 :   // start LED animation before reboot
                            GPIO_SET = 1<<GREEN_LED ;
                            GPIO_SET = 1<<YELLOW_LED ;
                            GPIO_SET = 1<<RED_LED ;
                            state = 11 ;
                            break ;
                case 11 :   // LED animation before reboot
                            GPIO_CLR = 1<<GREEN_LED ;
                            GPIO_CLR = 1<<YELLOW_LED ;
                            GPIO_CLR = 1<<RED_LED ;
                            repeat_count++ ;
                            if (repeat_count > 5) {
                                state = 12 ;
                            } else {
                                state = 10 ;
                            }
                            break ;
                case 12 :   // proceed with reboot
                            close(fd) ;
                            do_reboot() ;
                            break ;
            }   // end switch
        }   // end if

        // loop delay
        nanosleep((struct timespec[]){{0, TIME_TIC}}, NULL) ;
    }

    return 0 ;    // we should never come here!
} // main

/***************************************************************************************/
//
// Set up a memory region to access GPIO
//
void setup_io() {
    /* open /dev/mem */
    if ((mem_fd = open("/dev/mem", O_RDWR|O_SYNC) ) < 0) {
        printf("can't open /dev/mem \n");
        exit(-1);
    }

    /* mmap GPIO */
    gpio_map = mmap(
        NULL,             //Any adddress in our space will do
        BLOCK_SIZE,       //Map length
        PROT_READ|PROT_WRITE,// Enable reading & writting to mapped memory
        MAP_SHARED,       //Shared with other processes
        mem_fd,           //File to map
        GPIO_BASE         //Offset to GPIO peripheral
    );

    close(mem_fd); //No need to keep mem_fd open after mmap

    if (gpio_map == MAP_FAILED) {
        printf("mmap error %d\n", (int)gpio_map);//errno also set!
        exit(-1);
    }

    // Always use volatile pointer!
    gpio = (volatile unsigned *)gpio_map ;

    // initializes the LED and push-button pins
    INP_GPIO( GREEN_LED) ;   // must use INP_GPIO before we can use OUT_GPIO
    OUT_GPIO( GREEN_LED) ;
    INP_GPIO( YELLOW_LED) ;
    OUT_GPIO( YELLOW_LED) ;
    INP_GPIO( RED_LED) ;
    OUT_GPIO( RED_LED) ;
    INP_GPIO( PUSHBUTTON) ;

    // initializes LEDs to OFF state
    GPIO_CLR = 1<<GREEN_LED ;
    GPIO_CLR = 1<<YELLOW_LED ;
    GPIO_CLR = 1<<RED_LED ;

} // setup_io

/***************************************************************************************/
//
// Call system reboot
//
void do_reboot() {
    static char *execArgv[5] ;     /* define arguments for shutdown exec */

    execArgv[0] = "shutdown" ;
    execArgv[1] = "-r" ;
    execArgv[2] = "now" ;
    execArgv[3] = NULL ;

    //printf("going to reboot!\n") ;
    execv("/sbin/shutdown", execArgv) ;
} // do_reboot



/*** END OF FILE ***********************************************************************/
