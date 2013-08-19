#ifndef _SENSOR_MEASUREMENT_H
#define _SENSOR_MEASUREMENT_H

// function declarations
// returned value = meters*100 (2 decimal precision). sensorID is [1,8], speed is 100*(kmph) (2 decimal precision)
int getSensorValue(char sensorID, unsigned long speed, unsigned long long time_usec);
float randnormal( void );


#endif // _SENSOR_MEASUREMENT_H
