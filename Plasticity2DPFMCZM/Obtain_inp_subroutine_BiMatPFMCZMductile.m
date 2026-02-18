close all;clear;clc;
%% material parameters
EE=210000;% Young's modulus, [MPa]
nu=0.3;% Poisson's ratio, [1]
EY=250;% Yield stress, [MPa]
EH=21000;% Hardening modulus, [MPa]
crieps=0;% crieps=1: according to critical plastic strain; crieps=0: according to critical energy release rate
thick=1;% thickness for 2D prolem, [mm]
rho=7.85E-3;% density, [g/(mm)^3]
ANISOSWT=1;% ANISOSWT=1: all strain energy is decomposed; ANISOSWT=0: only hydrostatic strain energy is decomposed
PLASWT=1;% PLASWT=1: von misses criterion is used; PLASWT=0, von misses criterion is not used
Lc=0.01;% length scale, [mm]
Gc=2.7;% critical release rate, [N/mm]
ELSSWT=1;% ELSSWT=1: has a linear elastic range; ELSSWT=0: no linear elastic range
DRSWT=0;% DRSWT=0: normal damage simulation; DRSWT=1: simulation consider initial damage
mlm=0.01;
mat=[EE,nu,EY,EH,crieps,thick,rho,ANISOSWT,PLASWT,Lc,Gc,ELSSWT,DRSWT;
     EE*mlm,nu,EY,EH,crieps,thick,rho,ANISOSWT,PLASWT,Lc,Gc/mlm,ELSSWT,DRSWT];
sig=9*sqrt(EE*Gc/6/Lc)/16
%% generate inp file and subroutine
Abaqus2PhasefieldUEL2DPlasticity('Job-1.inp',mat)



