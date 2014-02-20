#include "orsocdef.h"
#include <stdlib.h>
#include "system.h"


void delay(unsigned int);


int main()
{
	
	while(1)
	{
		gpio_o_wr(0,1);
		delay(5000000);
		gpio_o_wr(0,0);
		delay(5000000);
	}//while
	 return 0;
}




void delay ( unsigned int num ){
	
	while (num>0){ 
		num--;
		asm volatile ("nop");
	}
	return;

}

