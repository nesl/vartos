/* temp_model.h
 *
 * This contains the temperature profile / model to be loaded
 * into ROM on bootup for the optimal DC calculation
 *
 * (file auto-generated by python script)
 *
 */

#ifndef _TEMP_MODEL_H
#define _TEMP_MODEL_H

/* model dimensions */
#define TEMP_MODEL_NUM_BINS 10
#define TEMP_MODEL_START_TEMP -30.0
#define TEMP_MODEL_LEFTMOST_EDGE -34.0
#define TEMP_MODEL_BIN_WIDTH 6.96

/* Note that a frequency of 255 corresponds to 0.50 freq */
const char rom_temp_model[TEMP_MODEL_NUM_BINS] = {
0,
10,
31,
53,
80,
78,
89,
103,
54,
7
};

unsigned int temp_hist_numpoints = 0;
unsigned int temp_hist_windowed[TEMP_MODEL_NUM_BINS] = {
0,
0,
0,
0,
0,
0,
0,
0,
0,
0
};

#endif /* _TEMP_MODEL_H */
