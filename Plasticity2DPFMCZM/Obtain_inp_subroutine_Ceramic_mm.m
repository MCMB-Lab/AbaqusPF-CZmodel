close all;clear;clc;
%% material parameters
EE1=87000;% Young's modulus, [MPa]
miu1=0.3;% Poisson's ratio, [1]
EY1=87000;% Yield stress, [MPa]
EH1=87000;% Hardening modulus, [MPa]
crieps1=0;% crieps=1: according to critical plastic strain; crieps=0: according to critical energy release rate
thick1=1;% thickness for 2D prolem, [mm]
rho1=7.85E-3;% density, [g/(mm)^3]
ANISOSWT1=1;% ANISOSWT=1: all strain energy is decomposed; ANISOSWT=0: only hydrostatic strain energy is decomposed
PLASWT1=0;% PLASWT=1: von misses criterion is used; PLASWT=0, von misses criterion is not used
Lc1=0.012;% length scale, [mm]
Gc1=0.0091;% critical release rate, [N/mm]
ELSSWT1=1;% ELSSWT=1: has a linear elastic range; ELSSWT=0: no linear elastic range
DRSWT1=0;% DRSWT=0: normal damage simulation; DRSWT=1: simulation consider initial damage

EE2=489000;% Young's modulus, [MPa]
miu2=0.3;% Poisson's ratio, [1]
EY2=489000;% Yield stress, [MPa]
EH2=489000;% Hardening modulus, [MPa]
crieps2=0;% crieps=1: according to critical plastic strain; crieps=0: according to critical energy release rate
thick2=1;% thickness for 2D prolem, [mm]
rho2=7.85E-3;% density, [g/(mm)^3]
ANISOSWT2=1;% ANISOSWT=1: all strain energy is decomposed; ANISOSWT=0: only hydrostatic strain energy is decomposed
PLASWT2=0;% PLASWT=1: von misses criterion is used; PLASWT=0, von misses criterion is not used
Lc2=0.0042;% length scale, [mm]
Gc2=0.0265;% critical release rate, [N/mm]
ELSSWT2=1;% ELSSWT=1: has a linear elastic range; ELSSWT=0: no linear elastic range
DRSWT2=0;% DRSWT=0: normal damage simulation; DRSWT=1: simulation consider initial damage

mat=[EE1,miu1,EY1,EH1,crieps1,thick1,rho1,ANISOSWT1,PLASWT1,Lc1,Gc1,ELSSWT1,DRSWT1;
     EE1,miu1,EY1,EH1,crieps1,thick1,rho1,ANISOSWT1,PLASWT1,Lc1,Gc1,ELSSWT1,DRSWT1;
     EE2,miu2,EY2,EH2,crieps2,thick2,rho2,ANISOSWT2,PLASWT2,Lc2,Gc2,ELSSWT2,DRSWT2;];% with interface, with damage
%% generate inp file and subroutine
Abaqus2PhasefieldUEL2DPlasticity('Job-2Model-2V1.inp',mat)

