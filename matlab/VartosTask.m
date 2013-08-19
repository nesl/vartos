classdef VartosTask
    %VARTOSTASK Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        name;
        kmin;
        kmax;
        pi;
        offset;
        slope;
        dc;
        utilc;
        dmin;
        dmax;
        clock_freq;
    end
    
    methods
        % constructor
        function obj = VartosTask(name, kmin, kmax, pi, offset, slope, freq)
            obj.name = name;
            obj.kmin = kmin;
            obj.kmax = kmax;
            obj.pi = pi;
            obj.offset = offset;
            obj.slope = slope;
            obj.clock_freq = freq*1e6;
            obj.dc = 0.0;
            
            % find dmax and dmin
            obj.dmin = obj.knobToDC(obj.kmin);
            obj.dmax = obj.knobToDC(obj.kmax);
            
            % create utility curve
            obj.utilc = -log( (2/(0.99+1)) - 1)/(obj.dmax-obj.dmin);
            
        end
        
        function d = knobToDC(obj, k)
            d = (obj.offset/obj.clock_freq) +  (obj.slope/obj.clock_freq)*k;
        end
        
        function k = DCtoKnob(obj, d)
            k = (d - (obj.offset/obj.clock_freq))*(1/(obj.slope/obj.clock_freq));
            k = round(k);
            if k < obj.kmin
                k = obj.kmin;
            end
            if k > obj.kmax
                k = obj.kmax;
            end
        end
        
        function u = dcToUtil(obj, dc)
            d = dc;
            if d > obj.dmax
                d = obj.dmax;
            end
            if d < obj.dmin
                u = 0;
                return;
            end
            u = obj.pi*(2./(1 + exp(-obj.utilc*(d-obj.dmin))) - 1);
        end
        
        function m = getMarginalUtil(obj, delta)
            util_start = obj.dcToUtil(obj.dc);
            util_finish = obj.dcToUtil(obj.dc+delta);
            m = (util_finish-util_start)/delta;
        end
       
        
    end
    
end
