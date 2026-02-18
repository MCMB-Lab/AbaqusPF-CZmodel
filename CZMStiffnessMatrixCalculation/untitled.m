close all;clear;clc;
%% basic information about the model
nelement=3;% number of total elements
nnode=8;% number of total nodes
nodedof=2;% number of dofs for each node
ndof=nnode*nodedof;% number of total dofs
% tangent stiffness matrix from time step 300
element1=readVariableMatrix('element1.txt');
element2=readVariableMatrix('element2.txt');
element5=readVariableMatrix('element5.txt');
element6=readVariableMatrix('element6.txt');
element7=readVariableMatrix('element7.txt');
element1node=[1,2,3,4];
element2node=[7,8,5,6];
element5node=[1,2,3,4];
element6node=[7,8,5,6];
element7node=[8,7,2,1];
% Abaqus results from two time steps: 300 and 301
abaqusRF=readmatrix('abaqusRF.txt');
abaqusU=readmatrix('abaqusU.txt');
%% obtain tangent stiffness matrix for each element 1, 2, 3
element1stiffness=zeros(8,8);
element2stiffness=zeros(8,8);
element5stiffness=zeros(8,8);
element6stiffness=zeros(8,8);
element7stiffness=zeros(8,8);
k=zeros(ndof,ndof);
element1stiffness(1,1:1)=element1(1,1:1);
element1stiffness(2,1:2)=element1(2,1:2);
element1stiffness(3,1:3)=element1(3,1:3);
element1stiffness(4,1:4)=element1(4,1:4);
element1stiffness(5,1:5)=[element1(5,1:4),element1(6,1:1)];
element1stiffness(6,1:6)=[element1(7,1:4),element1(8,1:2)];
element1stiffness(7,1:7)=[element1(9,1:4),element1(10,1:3)];
element1stiffness(8,1:8)=[element1(11,1:4),element1(12,1:4)];
element2stiffness(1,1:1)=element2(1,1:1);
element2stiffness(2,1:2)=element2(2,1:2);
element2stiffness(3,1:3)=element2(3,1:3);
element2stiffness(4,1:4)=element2(4,1:4);
element2stiffness(5,1:5)=[element2(5,1:4),element2(6,1:1)];
element2stiffness(6,1:6)=[element2(7,1:4),element2(8,1:2)];
element2stiffness(7,1:7)=[element2(9,1:4),element2(10,1:3)];
element2stiffness(8,1:8)=[element2(11,1:4),element2(12,1:4)];
element5stiffness(1,1:1)=element5(1,1:1);
element5stiffness(2,1:2)=element5(2,1:2);
element5stiffness(3,1:3)=element5(3,1:3);
element5stiffness(4,1:4)=element5(4,1:4);
element5stiffness(5,1:5)=[element5(5,1:4),element5(6,1:1)];
element5stiffness(6,1:6)=[element5(7,1:4),element5(8,1:2)];
element5stiffness(7,1:7)=[element5(9,1:4),element5(10,1:3)];
element5stiffness(8,1:8)=[element5(11,1:4),element5(12,1:4)];
element6stiffness(1,1:1)=element6(1,1:1);
element6stiffness(2,1:2)=element6(2,1:2);
element6stiffness(3,1:3)=element6(3,1:3);
element6stiffness(4,1:4)=element6(4,1:4);
element6stiffness(5,1:5)=[element6(5,1:4),element6(6,1:1)];
element6stiffness(6,1:6)=[element6(7,1:4),element6(8,1:2)];
element6stiffness(7,1:7)=[element6(9,1:4),element6(10,1:3)];
element6stiffness(8,1:8)=[element6(11,1:4),element6(12,1:4)];
element7stiffness(1,1:1)=element7(1,1:1);
element7stiffness(2,1:2)=element7(2,1:2);
element7stiffness(3,1:3)=element7(3,1:3);
element7stiffness(4,1:4)=element7(4,1:4);
element7stiffness(5,1:5)=[element7(5,1:4),element7(6,1:1)];
element7stiffness(6,1:6)=[element7(7,1:4),element7(8,1:2)];
element7stiffness(7,1:7)=[element7(9,1:4),element7(10,1:3)];
element7stiffness(8,1:8)=[element7(11,1:4),element7(12,1:4)];
element1stiffness=(element1stiffness+element1stiffness')-diag(diag(element1stiffness));
element2stiffness=(element2stiffness+element2stiffness')-diag(diag(element2stiffness));
element5stiffness=(element5stiffness+element5stiffness')-diag(diag(element5stiffness));
element6stiffness=(element6stiffness+element6stiffness')-diag(diag(element6stiffness));
element7stiffness=(element7stiffness+element7stiffness')-diag(diag(element7stiffness));
%% obtain global tangent stiffness matrix
for ii=1:4
    for jj=1:4
        k(2*element1node(ii)-1,2*element1node(jj)-1)=k(2*element1node(ii)-1,2*element1node(jj)-1)+element1stiffness(2*ii-1,2*jj-1);
        k(2*element1node(ii)-1,2*element1node(jj))=k(2*element1node(ii)-1,2*element1node(jj))+element1stiffness(2*ii-1,2*jj);
        k(2*element1node(ii),2*element1node(jj)-1)=k(2*element1node(ii),2*element1node(jj)-1)+element1stiffness(2*ii,2*jj-1);
        k(2*element1node(ii),2*element1node(jj))=k(2*element1node(ii),2*element1node(jj))+element1stiffness(2*ii,2*jj);
        k(2*element2node(ii)-1,2*element2node(jj)-1)=k(2*element2node(ii)-1,2*element2node(jj)-1)+element2stiffness(2*ii-1,2*jj-1);
        k(2*element2node(ii)-1,2*element2node(jj))=k(2*element2node(ii)-1,2*element2node(jj))+element2stiffness(2*ii-1,2*jj);
        k(2*element2node(ii),2*element2node(jj)-1)=k(2*element2node(ii),2*element2node(jj)-1)+element2stiffness(2*ii,2*jj-1);
        k(2*element2node(ii),2*element2node(jj))=k(2*element2node(ii),2*element2node(jj))+element2stiffness(2*ii,2*jj);
        k(2*element5node(ii)-1,2*element5node(jj)-1)=k(2*element5node(ii)-1,2*element5node(jj)-1)+element5stiffness(2*ii-1,2*jj-1);
        k(2*element5node(ii)-1,2*element5node(jj))=k(2*element5node(ii)-1,2*element5node(jj))+element5stiffness(2*ii-1,2*jj);
        k(2*element5node(ii),2*element5node(jj)-1)=k(2*element5node(ii),2*element5node(jj)-1)+element5stiffness(2*ii,2*jj-1);
        k(2*element5node(ii),2*element5node(jj))=k(2*element5node(ii),2*element5node(jj))+element5stiffness(2*ii,2*jj);
        k(2*element6node(ii)-1,2*element6node(jj)-1)=k(2*element6node(ii)-1,2*element6node(jj)-1)+element6stiffness(2*ii-1,2*jj-1);
        k(2*element6node(ii)-1,2*element6node(jj))=k(2*element6node(ii)-1,2*element6node(jj))+element6stiffness(2*ii-1,2*jj);
        k(2*element6node(ii),2*element6node(jj)-1)=k(2*element6node(ii),2*element6node(jj)-1)+element6stiffness(2*ii,2*jj-1);
        k(2*element6node(ii),2*element6node(jj))=k(2*element6node(ii),2*element6node(jj))+element6stiffness(2*ii,2*jj);
        k(2*element7node(ii)-1,2*element7node(jj)-1)=k(2*element7node(ii)-1,2*element7node(jj)-1)+element7stiffness(2*ii-1,2*jj-1);
        k(2*element7node(ii)-1,2*element7node(jj))=k(2*element7node(ii)-1,2*element7node(jj))+element7stiffness(2*ii-1,2*jj);
        k(2*element7node(ii),2*element7node(jj)-1)=k(2*element7node(ii),2*element7node(jj)-1)+element7stiffness(2*ii,2*jj-1);
        k(2*element7node(ii),2*element7node(jj))=k(2*element7node(ii),2*element7node(jj))+element7stiffness(2*ii,2*jj);
    end
end
subk=k([1,3,5,7,13,15],[1,3,5,7,13,15]);
invsubk=inv(subk);
% obtain force increment at nodes with prescribed displacement
subinvsubk=invsubk(3:4,3:4);
dfx3fx4=inv(subinvsubk)*[0.000005;0.000005]
% obtain displacement increment at nodes with displacement unknowns
du123478=invsubk*[0;0;dfx3fx4;0;0]
% obtain force increment at all nodes
du=[du123478(1);0;du123478(2);0;du123478(3);0;du123478(4);0;0;0;0;0;du123478(5);0;du123478(6);0];
df=k*du;
df
du

%% check with Abaqus results
RFxy=zeros(ndof,2);
RFxy(1:2:end,1)=abaqusRF(1:8,3);
RFxy(2:2:end,1)=abaqusRF(1:8,4);
RFxy(1:2:end,2)=abaqusRF(25:32,3);
RFxy(2:2:end,2)=abaqusRF(25:32,4);
Uxy=zeros(ndof,1);
Uxy(1:2:end,1)=abaqusU(1:8,3);
Uxy(2:2:end,1)=abaqusU(1:8,4);
Uxy(1:2:end,2)=abaqusU(25:32,3);
Uxy(2:2:end,2)=abaqusU(25:32,4);
dfabaqus=RFxy(:,2)-RFxy(:,1)
duabaqus=Uxy(:,2)-Uxy(:,1)
dferror=abs(100*(df-dfabaqus)./dfabaqus);
dferror([1,3,13,15])=0;
duerror=abs(100*(du-duabaqus)./duabaqus);
duerror([2,4,6,8,9,10,11,12,14,16])=0;
figure
plot(df,'^')
hold on
plot(dfabaqus,'s')
xticks(1:16);
xticklabels({'node 1 fx','node 1 fy','node 2 fx','node 2 fy',...
             'node 3 fx','node 3 fy','node 4 fx','node 4 fy',...
             'node 5 fx','node 5 fy','node 6 fx','node 6 fy',...
             'node 7 fx','node 7 fy','node 8 fx','node 8 fy'})
h=get(gca,'XTickLabel');
set(gca,'XTickLabel',h,'FontSize',20,'FontWeight','bold','FontName','Times New Roman')
xtickangle(90)
ylabel('force increment [N]','FontSize',30,'FontWeight','bold')
legend('from author''s calculation','from Abaqus','location','best','FontSize',25)
xlim([0,17])

figure
bar(dferror)
hold on
% plot(dferror)
xticks(1:16);
xticklabels({'node 1 fx','node 1 fy','node 2 fx','node 2 fy',...
             'node 3 fx','node 3 fy','node 4 fx','node 4 fy',...
             'node 5 fx','node 5 fy','node 6 fx','node 6 fy',...
             'node 7 fx','node 7 fy','node 8 fx','node 8 fy'})
h=get(gca,'XTickLabel');
set(gca,'XTickLabel',h,'FontSize',20,'FontWeight','bold','FontName','Times New Roman')
xtickangle(90)
ylabel('force increment percent error [\%]','FontSize',30,'FontWeight','bold')

figure
plot(du,'^')
hold on
plot(duabaqus,'s')
xticks(1:16);
xticklabels({'node 1 fx','node 1 fy','node 2 fx','node 2 fy',...
             'node 3 fx','node 3 fy','node 4 fx','node 4 fy',...
             'node 5 fx','node 5 fy','node 6 fx','node 6 fy',...
             'node 7 fx','node 7 fy','node 8 fx','node 8 fy'})
h=get(gca,'XTickLabel');
set(gca,'XTickLabel',h,'FontSize',20,'FontWeight','bold','FontName','Times New Roman')
xtickangle(90)
ylabel('displacement increment [mm]','FontSize',30,'FontWeight','bold')
legend('from author''s calculation','from Abaqus','location','best','FontSize',25)
xlim([0,17])

figure
bar(duerror)
hold on
% plot(duerror)
xticks(1:16);
xticklabels({'node 1 u','node 1 v','node 2 u','node 2 v',...
             'node 3 u','node 3 v','node 4 u','node 4 v',...
             'node 5 u','node 5 v','node 6 u','node 6 v',...
             'node 7 u','node 7 v','node 8 u','node 8 v'})
h=get(gca,'XTickLabel');
set(gca,'XTickLabel',h,'FontSize',20,'FontWeight','bold','FontName','Times New Roman')
xtickangle(90)
ylabel('displacement increment percent error [\%]','FontSize',28,'FontWeight','bold')

