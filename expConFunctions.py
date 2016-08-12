from math import exp

#----------------------------------------------------------------------------------
#These are rebuilds of the functions implemented by Experiment Control.
#This file contains a linear ramp, an exponential ramp and a s-shaped ramp.
#The if-condition offered by Experiment Control is evaluated in the "allInAll.py" part.
#----------------------------------------------------------------------------------

#Realize a linear ramp from value v_start to value v_end starting at t_start and ending at t_end.
#The course of this ramp is completly determined by the values given.
def ramplin(v_start, v_end, t_start, t_end, t):
    value = ((v_end-v_start)/(t_end-t_start))*(t-t_start) + v_start
    return value

#Realize an exponential ramp from value v_start to value v_end starting at t_start and ending at t_end.
#tau is the time constant.
#The course of this ramp is completly determined by the values given.
def rampexp(v_start, v_end, t_start, t_end, tau, t):
    A = (v_end-v_start)/(exp((t_end-t_start)/tau)-1)
    value = A*(exp((t-t_start)/tau)-1) + v_start
    return value

#Realize a S-shaped ramp from value v_start to value v_end starting at t_start and ending at t_end.
#Modelled by a polyomial of third order.
#The course of this ramp is completly determined by the values given, when you model it with a polynomial function of third order and assume vanishing derivatives at start and end.
def ramps(v_start, v_end, t_start, t_end, t):
    value = (v_start - 2*((v_end - v_start)/((t_end - t_start)**3))*((t - t_start)**3) + 3*((v_end - v_start)/((t_end - t_start)**2))*((t - t_start)**2))
    return value
