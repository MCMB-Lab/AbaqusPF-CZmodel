close all;clear;clc;
%% material parameters
Ymod=25000;% Young's modulus, [MPa]
nu=0.2;% Poisson's ratio, [1]
Ystress=25000;% Yield stress, [MPa]
Hmod=25000;% Hardening modulus, [MPa]
epscr=0;% crieps=0: according to critical energy release rate; crieps=1: according to critical plastic strain
density=7.85E-3;% density, [g/(mm)^3]
anisoswt=1;% ANISOSWT=0: only hydrostatic strain energy is decomposed; ANISOSWT=1: all strain energy is decomposed
plswt=0;% PLASWT=0, von misses criterion is not used; PLASWT=1: von misses criterion is used
lc=4;% length scale, [mm]
gc=0.05;% critical energy release rate, [N/mm]
elswt=1;% ELSSWT=0: without linear elastic range; ELSSWT=1: with linear elastic range
drswt=0;% DRSWT=0: normal damage simulation; DRSWT=1: simulation consider initial damage
mat=[Ymod,nu,Ystress,Hmod,epscr,density,anisoswt,plswt,lc,gc,elswt,drswt;
     Ymod,nu,Ystress,Hmod,epscr,density,anisoswt,plswt,lc,gc,elswt,drswt;];
% mat=[Ymod,nu,Ystress,Hmod,epscr,density,anisoswt,plswt,lc,gc,elswt,drswt;
%      Ymod,nu,Ystress,Hmod,epscr,density,anisoswt,plswt,lc,gc,elswt,drswt;
%      Ymod,nu,Ystress,Hmod,epscr,density,anisoswt,plswt,lc,gc,elswt,drswt;
%      Ymod,nu,Ystress,Hmod,epscr,density,anisoswt,plswt,lc,gc,elswt,drswt;];
%% generate inp file and subroutine
Abaqus2PhasefieldUEL3DPlasticity('Job-1.inp',mat)
% Abaqus2PhasefieldUEL3DPlasticityBackups0('Job-1.inp',mat)

