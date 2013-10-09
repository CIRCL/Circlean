#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <unistd.h>

/* GPIO registers address */
#define BCM2708_PERI_BASE  0x20000000
#define GPIO_BASE          (BCM2708_PERI_BASE + 0x200000) /* GPIO controller */
#define BLOCK_SIZE         (256)

/* GPIO setup macros. Always use GPIO_IN(x) before using GPIO_OUT(x) or GPIO_ALT(x,y) */
#define GPIO_IN(g)    *(gpio+((g)/10))   &= ~(7<<(((g)%10)*3))
#define GPIO_OUT(g)   *(gpio+((g)/10))   |=  (1<<(((g)%10)*3))
#define GPIO_ALT(g,a) *(gpio+(((g)/10))) |= (((a)<=3?(a)+4:(a)==4?3:2)<<(((g)%10)*3))

#define GPIO_SET(g)   *(gpio+7)  = 1<<(g)  /* sets   bit which are 1, ignores bit which are 0 */
#define GPIO_CLR(g)   *(gpio+10) = 1<<(g)  /* clears bit which are 1, ignores bit which are 0 */
#define GPIO_LEV(g)  (*(gpio+13) >> (g)) & 0x00000001



#define GPIO_4    4

int                mem_fd;
void              *gpio_map;
volatile uint32_t *gpio;

int main(int argc, char* argv[])
{
     int ret;
     int i;
     /* open /dev/mem */
     mem_fd = open("/dev/mem", O_RDWR|O_SYNC);
     if (mem_fd == -1) {
              perror("Cannot open /dev/mem");
              exit(1);
     }

     /* mmap GPIO */
     gpio_map = mmap(NULL, BLOCK_SIZE, PROT_READ|PROT_WRITE, MAP_SHARED, mem_fd, GPIO_BASE);
     if (gpio_map == MAP_FAILED) {
             perror("mmap() failed");
             exit(1);
     }
      /* Always use volatile pointer! */
        gpio = (volatile uint32_t *)gpio_map;


     GPIO_IN(GPIO_4); /* must use GPIO_IN before we can use GPIO_OUT */
     GPIO_OUT(GPIO_4);

    //Turn on led
    while (1) {
        //printf("Enable LED\n");
        GPIO_SET(GPIO_4);
        usleep(1000000);
        //printf("Disable GPIO\n"); // Does not seem to work?
        //GPIO_CLR(GPIO_4);
        //usleep(1000000);
    }
    /* Free up ressources */
        /* munmap GPIO */
        ret = munmap(gpio_map, BLOCK_SIZE);
        if (ret == -1) {
                perror("munmap() failed");
                exit(1);
        }
        /* close /dev/mem */
        ret = close(mem_fd);
        if (ret == -1) {
                perror("Cannot close /dev/mem");
                exit(1);
        }

     return EXIT_SUCCESS;
}
