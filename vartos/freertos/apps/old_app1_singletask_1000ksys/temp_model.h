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
#define TEMP_MODEL_START_TEMP 4.0
#define TEMP_MODEL_BIN_WIDTH 4.9

/* Note that a frequency of 255 corresponds to 0.50 freq */
const char rom_temp_model[TEMP_MODEL_NUM_BINS] = {
7,
41,
72,
75,
64,
60,
70,
63,
42,
11
};

#endif /* _TEMP_MODEL_H */
