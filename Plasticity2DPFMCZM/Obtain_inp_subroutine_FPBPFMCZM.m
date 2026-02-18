close all;clear;clc;
%% material parameters
EE=25000;% Young's modulus, [1E6MPa]
nu=0.2;% Poisson's ratio, [1]
EY=25000;% Yield stress, [1E6MPa]
EH=25000;% Hardening modulus, [1E6MPa]
crieps=0;% crieps=1: according to critical plastic strain; crieps=0: according to critical energy release rate
thick=1;% thickness for 2D prolem, [mm]
rho=7.85E-3;% density, [g/(um)^3]
ANISOSWT=1;% ANISOSWT=1: all strain energy is decomposed; ANISOSWT=0: only hydrostatic strain energy is decomposed
PLASWT=0;% PLASWT=1: von misses criterion is used; PLASWT=0, von misses criterion is not used
Lc=4;% length scale, [um]
Gc=0.05;% critical release rate, [N/um]
ELSSWT=0;% ELSSWT=1: has a linear elastic range; ELSSWT=0: no linear elastic range
DRSWT=0;% DRSWT=0: normal damage simulation; DRSWT=1: simulation consider initial damage
mat=[EE,nu,EY,EH,crieps,thick,rho,ANISOSWT,PLASWT,Lc,Gc,ELSSWT,DRSWT;
     EE,nu,EY,EH,crieps,thick,rho,ANISOSWT,PLASWT,Lc,Gc,ELSSWT,DRSWT;
     EE,nu,EY,EH,crieps,thick,rho,ANISOSWT,PLASWT,Lc,Gc,ELSSWT,DRSWT;
     EE,nu,EY,EH,crieps,thick,rho,ANISOSWT,PLASWT,Lc,Gc,ELSSWT,DRSWT;];
%% generate inp file and subroutine
Abaqus2PhasefieldUEL2DPlasticity('Job-1.inp',mat)

