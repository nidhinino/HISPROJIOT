#include <stdio.h>
#include <stdlib.h>
#include <time.h>
//#include "xtimer.h"
void generate_random_Temperature(int l, int r)
{
      int rand_num = (rand() % (r - l + 1)) + l;

      printf("Temperature = ");
      printf("%d ", rand_num);
}

void generate_random_Humidity(int l, int r)
{
      int rand_num = (rand() % (r - l + 1)) + l;

      printf("Humidity = ");
      printf("%d ", rand_num);
}

void delay(int number_of_seconds)
{  
    int milli_seconds = 1000 * number_of_seconds;
 
    clock_t start_time = clock();
 
    while (clock() < start_time + milli_seconds)
        ;
}
int main()
{
       srand(time(0));
       generate_random_Temperature(20, 30);
       delay(1000);  
       printf("\n");

       generate_random_Humidity(50, 99);
       delay(1000);  
       printf("\n");
  
return 0;
}


