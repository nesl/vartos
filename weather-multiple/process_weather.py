import glob
import numpy as np
from itertools import *
from math import exp
import sys
#import scipy.stats

def slpPower(t) :
    Vdd = 1.04
    Nl = 0.02
    Al = -9210
    Bl = 890    
    Vpl = 0.232
    Vnl = .2
    delta_vtp = 0
    t = t + 273;
    v = Vdd;
    power = Nl * v * t*t * ( exp(Al*Vnl/t) + exp(Al*(Vpl+delta_vtp)/t) ) * exp(Bl*v/t);
    return power/1000000;

def actPower(t) :
    return t*2

def avgPower(temps, fun, w=None) :
    p = [fun(t) for t in temps]
    return np.average(p, weights=w)

def loadfile(filename) :
    return [float(line) for line in open(filename)]

def normhist(data, nbins) :
    hist, bins = np.histogram(data, nbins)
    hist = hist/float(np.sum(hist))
    center = (bins[:-1]+bins[1:])/2
    return [hist, center]
 	
def powerset(iterable):
    s = list(iterable)
    return chain.from_iterable(combinations(s, r) for r in range(len(s)+1))
     
path = 'data/'

listing = glob.glob(path+"*")
locations = []

temp_dict = {}
sp_dict_100 = {}
sp_dict_10 = {}
sp_dict_5 = {}
sp_dict_3 = {}


for infile in listing:
    #print infile, 
    fdata = loadfile(infile)
    #print np.max(fdata)
    #temp_dict[infile] = fdata
    [weights, bins] = normhist(fdata, 100)
    sp = avgPower(bins, slpPower, weights)
    #sp = avgPower(fdata, slpPower)
    sp_dict_100[infile] = sp
    [weights, bins] = normhist(fdata, 10)
    sp = avgPower(bins, slpPower, weights)
    sp_dict_10[infile] = sp
    [weights, bins] = normhist(fdata, 5)
    sp = avgPower(bins, slpPower, weights)
    sp_dict_5[infile] = sp
    [weights, bins] = normhist(fdata, 3)
    sp = avgPower(bins, slpPower, weights)
    sp_dict_3[infile] = sp
    loc = infile[:-4]
    if loc not in locations :
        locations.append(loc)
        
#exit()        

psetcnt = 0


for loc in locations :
    files = glob.iglob(loc+"*")
    pset = powerset(files)
    for s in pset :
        if (len(s) < 2) : continue
        combos = combinations(s,len(s)-1)
        for trainset in combos :
            testf = list(set(s) - set(trainset))[0]
            testavg = sp_dict_100[testf]         
            print len(trainset), testavg, 
            esterrors = []
            for d in [sp_dict_3, sp_dict_5, sp_dict_10, sp_dict_100] :
				traindata = []
				for f in trainset :
					traindata.append(d[f])
				trainavg = np.mean(traindata)
				esterror = (testavg - trainavg)
				print esterror,
            print ""
            psetcnt = psetcnt + 1

#print psetcnt




