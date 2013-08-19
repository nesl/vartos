// includes
#include <math.h>
#include <stdio.h>
#include "sensor_measurement.h"

// node coordinates and other parameters
#define PI ( 3.14159265359f )
#define NOISE_VARIANCE ( 50.0f )

// returned value = meters*100 (2 decimal precision). sensorID is [1,8], speed is 100*(kmph) (2 decimal precision)
int getSensorValue(char sensorID, unsigned long speed_mph, unsigned long long time_usec){
    // position
    float pos;
    // noise to be added
    float additive_noise;
    // convert arguments to usable units
    float time_sec = (float)(time_usec/1000000.0);
    // additional time division for ratio to be correct
    time_sec /= 3600.0;
    
    // get noise
    additive_noise = 50*randnormal();
    // get pos
    pos = 555*sin(0.1*time_sec) + additive_noise;
   
    return( (int)(pos) );

}

float randnormal( void ){
    float urand_1 = (float)( rand() % 1000 )/1000.0f;
    float urand_2 = (float)( rand() % 1000 )/1000.0f;

    // make sure values don't achieve 0
    if(urand_1 < 0.001)
        urand_1 = 0.001;
    if(urand_2 < 0.001)
        urand_2 = 0.001;

    float nrand = sqrt( -2*log(urand_1) )*cos( 2*PI*urand_2 );

    return(nrand);
}


/*

int main( void ){
    int unsigned long long t;
    int val;
    for(t=0; t<3600*100e6; t+=3600*1e6){
        val = getSensorValue(1,1,t);
        printf("\n%llu,%d",t,val);
    }

}


*/
