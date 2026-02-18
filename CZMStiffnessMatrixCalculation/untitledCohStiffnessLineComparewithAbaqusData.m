close all;clear;clc;
%% node ID, coordinate, and material parameters
% 1-mid1-4
% |      |
% |      |
% 2-mid2-3
node=[1,2,3,4];% nodes 1 and 2 are on bottom surface; nodes 3 and 4 are on top surface
n1=[1,1];% x and y coordinates
n2=[1,0];
n3=[1,0];
n4=[1,1];
E=25000;% stiffness in normal and tangential directions
C=[E,0;0,E];% constitutive matrix
thickness=1;% thickness for 2D plain problem
%% calculate middle node and rotational matrix
mid1=(n1+n4)/2;
mid2=(n2+n3)/2;
dx=mid2(1,1)-mid1(1,1);
dy=mid2(1,2)-mid1(1,2);
l=sqrt(dx^2+dy^2);
cos_theta=dx/l;
sin_theta=dy/l;
r=[cos_theta,sin_theta;-sin_theta,cos_theta];
R=blkdiag(r,r,r,r);
%% calculate local displacement-local separation matrix
%  u1,v1,u2,v2,u3,v3,u4,v4
L=[-1, 0, 0, 0, 0, 0, 1, 0;
    0,-1, 0, 0, 0, 0, 0, 1;
    0, 0,-1, 0, 1, 0, 0, 0;
    0, 0, 0,-1, 0, 1, 0, 0];
%% Gauss integration point, weight, and numerical integration
% one point Gaussian Quadrature and Newton-Cotes Quadrature
gauss=0;
weight=2;
K=zeros(8,8);
for ii=1:length(gauss)
    a=gauss(1,ii);
    Nprim=[(1+0)/2,0,(1-0)/2,0;0,(1+a)/2,0,(1-a)/2];
    detj=l/2;
    K=K+R'*L'*Nprim'*C*Nprim*L*R*weight(1,ii)*detj*thickness;
end
K1=K

% two points Gaussian Quadrature and Newton-Cotes Quadrature
% gauss=[-1/sqrt(3),1/sqrt(3)];
% weight=[1,1];
gauss=[-1,1];
weight=[1,1];
K=zeros(8,8);
for ii=1:length(gauss)
    a=gauss(1,ii);
    Nprim=[(1+0)/2,0,(1-0)/2,0;0,(1+a)/2,0,(1-a)/2];
    detj=l/2;
    K=K+R'*L'*Nprim'*C*Nprim*L*R*weight(1,ii)*detj*thickness;
end
K2=K
figure
bar3(K2-K1)
xlabel('node ID')
ylabel('node ID')
title('difference between 1GP and 2GP')

% three points Gaussian Quadrature and Newton-Cotes Quadrature
% gauss=[-sqrt(3/5),0,sqrt(3/5)];
% weight=[5/9,8/9,5/9];
gauss=[-1,0,1];
weight=[1/3,4/3,1/3];
K=zeros(8,8);
for ii=1:length(gauss)
    a=gauss(1,ii);
    Nprim=[(1+0)/2,0,(1-0)/2,0;0,(1+a)/2,0,(1-a)/2];
    detj=l/2;
    K=K+R'*L'*Nprim'*C*Nprim*L*R*weight(1,ii)*detj*thickness;
end
K3=K
figure
bar3(K3-K2)
xlabel('node ID')
ylabel('node ID')
title('difference between 2GP and 3GP')

% four points Gaussian Quadrature and Newton-Cotes Quadrature
% gauss=[-0.8611,-0.3400,0.3400,0.8611];
% weight=[0.3479,0.6521,0.6521,0.3479];
gauss=[-1,-1/3,1/3,1];
weight=[1/4,3/4,3/4,1/4];
K=zeros(8,8);
for ii=1:length(gauss)
    a=gauss(1,ii);
    Nprim=[(1+0)/2,0,(1-0)/2,0;0,(1+a)/2,0,(1-a)/2];
    detj=l/2;
    K=K+R'*L'*Nprim'*C*Nprim*L*R*weight(1,ii)*detj*thickness;
end
K4=K
figure
bar3(K4-K3)
xlabel('node ID')
ylabel('node ID')
title('difference between 3GP and 4GP')

K2*[0;0;0;0;0.000005;0;0.000005;0]
K3*[0;0;0;0;0.000005;0;0.000005;0]
K4*[0;0;0;0;0.000005;0;0.000005;0]

