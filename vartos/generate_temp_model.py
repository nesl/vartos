#!/bin/python

# imports
import sys
import numpy as np


def generateHeaderFile(filename, num_bins):
    # attempt to open file for writing
    fid_header = open('temp_model.h', 'w')
    print '   > file opened for write '
    # load all data into memory
    raw_temperature_data = np.fromfile(open(filename,'r'),sep='\n')
    print '   > temperature loaded into memory '
    # calculate histogram
    hist,bins = np.histogram(raw_temperature_data, bins=int(num_bins))
    print hist
    # scale to max_freq
    for f in xrange(len(hist)):
        hist[f] = (float(hist[f])/float(len(raw_temperature_data)))*255.0*2
    print '   > histogram calculated '
    print hist
    print bins
    print '     (normalized to 255 = 0.50 freq) '
    bin_width = round(bins[1]-bins[0],2);
    temp_min = round(bins[0]+(bin_width/2.0));
    # write to output header file
    fid_header.write('/* temp_model.h\n')
    fid_header.write(' *\n')
    fid_header.write(' * This contains the temperature profile / model to be loaded\n')
    fid_header.write(' * into ROM on bootup for the optimal DC calculation\n')
    fid_header.write(' *\n')
    fid_header.write(' * (file auto-generated by python script)\n')
    fid_header.write(' *\n')
    fid_header.write(' */\n')
    fid_header.write('\n')
    fid_header.write('#ifndef _TEMP_MODEL_H\n')
    fid_header.write('#define _TEMP_MODEL_H\n')
    fid_header.write('\n')
    fid_header.write('/* model dimensions */\n');
    fid_header.write('#define TEMP_MODEL_NUM_BINS ' + num_bins + '\n')
    fid_header.write('#define TEMP_MODEL_START_TEMP ' + str(temp_min) + '\n')
    fid_header.write('#define TEMP_MODEL_LEFTMOST_EDGE ' + str(round(bins[0])) + '\n')
    fid_header.write('#define TEMP_MODEL_BIN_WIDTH ' + str(bin_width) + '\n')
    fid_header.write('\n')
    fid_header.write('/* Note that a frequency of 255 corresponds to 0.50 freq */\n')
    fid_header.write('const char rom_temp_model[TEMP_MODEL_NUM_BINS] = {\n');
    for f in xrange(len(hist)-1):
        fid_header.write(str(hist[f])+',\n')
    fid_header.write(str(hist[len(hist)-1])+'\n')
    fid_header.write('};\n')
    fid_header.write('\n')
    fid_header.write('unsigned int temp_hist_numpoints = 0;\n')
    fid_header.write('unsigned int temp_hist_windowed[TEMP_MODEL_NUM_BINS] = {\n');
    for f in xrange(len(hist)-1):
        fid_header.write('0,\n')
    fid_header.write('0\n')
    fid_header.write('};\n')
    fid_header.write('\n')
    fid_header.write('#endif /* _TEMP_MODEL_H */\n')

    

if __name__ == '__main__':
    if len(sys.argv) < 3:
        print ' not enough input arguments: temp_file, num_bins'
    generateHeaderFile(sys.argv[1], sys.argv[2])