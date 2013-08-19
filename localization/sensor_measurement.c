// includes
#include <math.h>
#include <stdio.h>
#include "sensor_measurement.h"

// node coordinates and other parameters
#define TRACK_CIRCUMFERENCE ( 300.0f ) // meters
#define NUM_SENSOR_NODES ( 8 )
#define PI ( 3.14159265359f )
#define NOISE_VARIANCE ( 40.0f )
#define OBSERVATION_RADIUS ( 80.0f )

static float track_radius, r_x, alpha;
static float node_x, node_y;
static float car_x, car_y;


// returned value = meters*100 (2 decimal precision). sensorID is [1,8], speed is 100*(kmph) (2 decimal precision)
int getSensorValue(char sensorID, unsigned long speed_mph, unsigned long long time_usec){
    // distance
    float distance;
    float additive_noise;
    // convert arguments to usable units
    float time_sec = (float)(time_usec/1000000.0);
    // additional time division for ratio to be correct
    time_sec /= 3600.0;
    //printf("\ntime called: %f",time_sec);
    float speed_kmph = ((float)speed_mph)/1000.0;
    float inst_velocity_mps = (speed_kmph*1000.0)/60.0;
    float rad_per_sec = (2.0*PI*inst_velocity_mps/TRACK_CIRCUMFERENCE);
    float omega = rad_per_sec; // pointless, I know. shut up.
    
    // initialize parameters
    track_radius = TRACK_CIRCUMFERENCE/(2.0*PI);
    r_x = track_radius*1.3;
    alpha = r_x*sqrt(2.0)/2.0;
    
    // find node (x,y)
    switch( sensorID ){
        case 0:
            node_x = -alpha;
            node_y = alpha;
            break;
        case 1:
            node_x = 0.0;
            node_y = r_x;
            break;
        case 2:
            node_x = alpha;
            node_y = alpha;
            break;
        case 3:
            node_x = -r_x;
            node_y = 0.0;
            break;
        case 4:
            node_x = r_x;
            node_y = 0.0;
            break;
        case 5:
            node_x = -alpha;
            node_y = -alpha;
            break;
        case 6:
            node_x = 0.0;
            node_y = -r_x;
            break;
        case 7:
            node_x = alpha;
            node_y = -alpha;
            break;
        default:
            break;
    }


    // find car (x,y)
    car_x = track_radius*cos(omega*time_sec);
    car_y = track_radius*sin(omega*time_sec);

    // find distance
    distance = sqrt( pow(node_x-car_x,2) + pow(node_y-car_y,2) );

    // can we even see it?
    if( distance > OBSERVATION_RADIUS ){
        // -1 means we didn't observe anything (sensor can't read negative)
        return(-1);
    }

    // add noise
    additive_noise = NOISE_VARIANCE*randnormal();
    distance += additive_noise;
    
    // bound the result
    if( distance < 0.01 ){
        distance = 0.01;
    }


    return( (int)(distance*100) );

}

float randnormal( void ){
    float urand_1 = (float)( rand() % 1000 )/1000.0f;
    float urand_2 = (float)( rand() % 1000 )/1000.0f;

    // make sure values don't achieve 0
    if(urand_1 < 0.001)
        urand_1 = 0.001;
    if(urand_2 < 0.001)
        urand_2 = 0.001;

    /*
    printf("\nr1: %f",urand_1);
    printf("\nr2: %f",urand_2);
    printf("\nsqrt: %f", sqrt( -2*log(urand_1) ));
    printf("\ncos: %f", cos( 2*PI*urand_2) );
    */

    float nrand = sqrt( -2*log(urand_1) )*cos( 2*PI*urand_2 );

    return(nrand);
}


/*
int main( void ){
    int i;
    for(i=0; i<100000; i++){
        printf("\n%f",randnormal());
    }

}
*/

