function Abaqus2PhasefieldUEL3D(inputPath,MatProp)
%
% !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
% !!!!!!!!!!!!!!!!!! --------- BETA Version --------- !!!!!!!!!!!!!!!!!!!!
%  When this script is used, it is the user's responsibility to check and
%                         interpret all results.
% !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
% 
% Abaqus2PhasefieldUEL adds the UEL option to an ABAQUS created input file
%             If the input file is created in the same order as discussed
%             in the tutorials (http://www.molnar-research.com/tutorials.html)
%             present MATLAB script finds the element definition and
%             multiplies it three times for the two UEL layers and the
%             post-processing UMAT layer.
%
%     More on the theory and implementation of the UEL to model diffuse 
%     fracture with phase-field can be found in our recent paper:
%       G. Molnár, A. Gravouil, 2D and 3D Abaqus implementation of a
%        robust staggered phase-field solution for modeling brittle
%        fracture, Finite Elements in Analysis and Design, 130 pp. 27-38, 2017.
%
%     https://www.sciencedirect.com/science/article/pii/S0168874X16304954
%
%    !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
%     The script is not able to convert all types of input files, only the
%     ones created the right order discussed in these tutorials (e.g. the
%     mesh needs to be defined on the parts):
%        http://www.molnar-research.com/tutorials.html
%    !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
%               
%   Current version converts 3D tetrahedral and brick elements with
%    isotropic energy degradation function to UEL compatible input files
%
%  -----  INPUT variables are the following -------------------------------
% inputPath - is a string which point to the input file created by ABAQUS,
%				if left blank [], the script opens an inquiry
%
% MatProp - is an array of (x,12) values containing materials parameters
%           both for the stress and phase field elements, where x is the
%           number of different materials used:
%
%           MatProp(:,1) - Young's modulus
%           MatProp(:,2) - Poisson's ratio
%           MatProp(:,3) - Yield stress (von Mises)
%           MatProp(:,4) - Hardening modulus
%           MatProp(:,5) - Critical strain
%           MatProp(:,6) - Density (rho)
%           MatProp(:,7) - Anisotropic energy switch
%           MatProp(:,8) - Plasticity switch
%           MatProp(:,9) - Length scale parameter for the phase function
%           MatProp(:,10) - Fracture surface energy release rate
%           MatProp(:,11) - Elastic treshold switch
% -------------------------------------------------------------------------
%
% BASIC structure of the script:
% 0) Loading input variables
% 1) Start copying original input file into the new one
% 2) When the beginning of the element definition section is found
%    (*Element) it stops copying and starts uploading elements into ElMat
%    array.
% 3) Parallel it writes the first layer of finite elements
% 4) When ready it replicates the two additional layers
% 5) Creates element sets and assigns material properties
% 6) Continues copying the original input file until the end of the assembly
%	 part. Here the script adds an additional element set summing up all
%    the UMAT elements.
% 7) Then it finishes the with the simulation steps, adding always a field
%    output request for the SDVs
% -------------------------------------------------------------------------
%
narginLoc=nargin;

if narginLoc<2
    if narginLoc==0
% ---------------- Asking for the input file -------------------
        [FileName,PathName,FilterIndex] = uigetfile('*.inp');
        inputPath=[PathName FileName];
    else
    end
    if isa(inputPath,'char')~=1
        error('Provide a valid input file.')
    end
% ---------------- Asking for material properties ---------------
    nMatini=input('Number of materials? - ');
        for i=1:nMatini
            MatProp(i,1)=input(['Young''s modulus for material (' num2str(i) ')? - ']);
            MatProp(i,2)=input(['Poisson''s ratio for material (' num2str(i) ')? - ']);
            MatProp(i,3)=input(['Yield stress (' num2str(i) ')? - ']);
            MatProp(i,4)=input(['Hardening modulus (' num2str(i) ')? - ']);
            MatProp(i,5)=input(['Critical plastic strain (' num2str(i) ')? - ']);
            MatProp(i,6)=input(['Density (' num2str(i) ')? - ']);
            MatProp(i,7)=input(['Aniso energy degradation switch (' num2str(i) ')? - ']);
            MatProp(i,8)=input(['Plasticuty switch (' num2str(i) ')? - ']);
            MatProp(i,9)=input(['Length scale parameter (' num2str(i) ')? - ']);
            MatProp(i,10)=input(['Crack surface energy (' num2str(i) ')? - ']);
            MatProp(i,11)=input(['Elastic switch (' num2str(i) ')? - ']);
            MatProp(i,12)=input(['damage or redamage switch (' num2str(i) ')? - ']);
        end
end

if length(MatProp(1,:))<12
    error('Not enought material properties are given.')
end
if length(MatProp(1,:))>12
    error('Too much material properties are given.')
end
if isempty(inputPath)==1
    [FileName,PathName,FilterIndex] = uigetfile('*.inp');
    inputPath=[PathName FileName];
end

% ---------------- Uploaing material properties -------------------
Ymod=MatProp(:,1);
nu=MatProp(:,2);
Ystress=MatProp(:,3);
Hmod=MatProp(:,4);
epscr=MatProp(:,5);
dens=MatProp(:,6);
anisoswt=MatProp(:,7);
plswt=MatProp(:,8);
lc=MatProp(:,9);
gc=MatProp(:,10);
elswt=MatProp(:,11);
drswt=MatProp(:,12);
% ---------------- Initializing output file -------------------
inputName=inputPath;
output=[inputPath(1:end-4) '_UEL.inp'];

fid=fopen(inputName,'rt');
fout1 = fopen(output, 'wt');
a=fgets(fid);

cnt=0;

% ---------------- Sart reading input file -------------------
cntE=1;
while(ischar(a))

% ------ Repeating nodes ------
while(ischar(a))
    if strfind(a,'*Element')~=0
        break
    end
    fprintf(fout1,a);    
    a=fgets(fid);
end

a=fgets(fid);

% ------ Defintion of UEL types ------
if length(str2num(a))==5
   % triangular elements 
    fprintf(fout1,['*********************** TETRAHEDRAL ****************************\n']);
    fprintf(fout1,['** ---------------- Displacement ----------------\n']);
    fprintf(fout1,['*User element, nodes=4, type=U1, properties=11, coordinates=3, VARIABLES=52\n']);
    fprintf(fout1,['1,2,3\n']);
    fprintf(fout1,['** ---------------- Phase-field ----------------\n']);
    fprintf(fout1,['*User element, nodes=4, type=U3, properties=4, coordinates=3, VARIABLES=6\n']);
    fprintf(fout1,['4\n']);
    NnodeE(cntE)=4;
else
   % rectangular elements 
    fprintf(fout1,['************************ HEXAGONAL ***************************\n']);
    fprintf(fout1,['** ---------------- Displacement ----------------\n']);
    fprintf(fout1,['*User element, nodes=8, type=U2, properties=11, coordinates=3, VARIABLES=344\n']);
    fprintf(fout1,['1,2,3\n']);
    fprintf(fout1,['** ---------------- Phase-field ----------------\n']);
    fprintf(fout1,['*User element, nodes=8, type=U4, properties=4, coordinates=3, VARIABLES=24\n']);
    fprintf(fout1,['4\n']);
    NnodeE(cntE)=8;
end

% ------ Uploading original mesh ------
cnt=0;
while isempty(strfind(a,'*Nset,')) && isempty(strfind(a,'*Element,'))
    cnt=cnt+1;
    ElMat{cntE}(cnt,:)=str2num(a);
    a=fgets(fid);
    cnt;
end
nElem(cntE)=length(ElMat{cntE}(:,1));

fprintf(fout1,['***************************************************************\n']);

if isempty(strfind(a,'*Element,'))==0
    cntE=cntE+1;
else
    break
end
end

% ------ All elements ------
nElemAll=sum(nElem);

% ------ Replicating UELs ------
for j=1:cntE
    if NnodeE(j)==4
        ej=1;
    elseif NnodeE(j)==8
        ej=2;
    end
    fprintf(fout1,['***************************************************************\n']);
    fprintf(fout1,['*Element, type=U' num2str(ej) '\n']);
    for i=1:nElem(j)
        fprintf(fout1,[num2str(ElMat{j}(i,1)) ', ' num2str(ElMat{j}(i,2:end-1),'%d, ') ' ' num2str(ElMat{j}(i,end)) '\n']);
        i;
    end
    fprintf(fout1,['***************************************************************\n']);
    fprintf(fout1,['*Element, type=U' num2str(ej+2) '\n']);
    for i=1:nElem(j)
        fprintf(fout1,[num2str(ElMat{j}(i,1)+nElemAll) ', ' num2str(ElMat{j}(i,2:end-1),'%d, ') ' ' num2str(ElMat{j}(i,end)) '\n']);
        i;
    end
end

% ------ Sets and material properties ------
fprintf(fout1,['***************************************************************\n']);
fprintf(fout1,['********************** ASSIGNING MATERIAL PROP ****************\n']);

cnt2=1;
while isempty(strfind(a,'** Section'))
   while isempty(strfind(a,'*Elset,'))
       a=fgets(fid);
   end
   bin=strfind(a,'elset=');
   Ename=a(bin+6:end-1);
   if isempty(strfind(Ename,','))==0
      bin=strfind(Ename,',');
      Ename=Ename(1:bin-1);
   end
   ElstName{cnt2}=Ename;
   fprintf(fout1,a);
   ElSeT{1,cnt2}=a;
   a=fgets(fid);
   cnt3=2;
   while isempty(strfind(a,'** Section:')) && isempty(strfind(a,'*Nset,'))
       ElSeT{cnt3,cnt2}=a;
       fprintf(fout1,a);
       a=fgets(fid);
       cnt3=cnt3+1;
   end
   Nline(cnt2)=cnt3-1;
   cnt2=cnt2+1;
end
fprintf(fout1,['***************************************************************\n']);

nMat=length(ElstName);
if length(Ymod)<nMat
    error('Model contains more materials. Provide more material properties!')
end

for k=1:nMat
    fprintf(fout1,['*Uel property, elset=' ElstName{k} '\n']);
    fprintf(fout1,[num2str(Ymod(k)) ', ' num2str(nu(k)) ', ' num2str(Ystress(k)) ', ' num2str(Hmod(k)) ...
        ', ' num2str(epscr(k)) ', ' num2str(dens(k)) ', ' num2str(anisoswt(k)) ', ' num2str(plswt(k)) ', ' '\n']);
    fprintf(fout1,[num2str(lc(k)) ', ' num2str(gc(k)) ', ' num2str(drswt(k)) '\n']);
end
fprintf(fout1,['**E, nu, Y, H, eps_cr, rho, anisoswt, plswt,\n']);
fprintf(fout1,['**lc, gc, drswt\n']);

fprintf(fout1,['***************************************************************\n']);

for k=1:nMat
    b=ElSeT{1,k};
    c=length(ElstName{k});
    fprintf(fout1,[b(1:14) ElstName{k} '_SS' b(14+c+1:end)]);
    if isempty(strfind(b,'generate'))
        for j=2:Nline(k)-1
            b=str2num(ElSeT{j,k});
            fprintf(fout1,'%d, ',b+nElemAll);
            fprintf(fout1,'\n');
        end
        b=str2num(ElSeT{Nline(k),k});
        fprintf(fout1,'%d, ',b(1:end-1)+nElemAll);
        fprintf(fout1,'%d',b(end)+nElemAll);
        fprintf(fout1,'\n');
        
    else
        b=str2num(ElSeT{2,k});
        fprintf(fout1,[num2str(b(1)+nElemAll) ', ' num2str(b(2)+nElemAll) ', ' num2str(b(3)) '\n']);
    end
    
end

fprintf(fout1,['***************************************************************\n']);
for k=1:nMat
    fprintf(fout1,['*Uel property, elset=' ElstName{k} '_SS\n']);
    fprintf(fout1,[num2str(lc(k)) ', ' num2str(gc(k)) ', ' num2str(elswt(k)) ', ' num2str(drswt(k)) '\n']);
end
fprintf(fout1,['**lc, gc, elswt, drswt\n']);

% ------ Replicating dummy UMAT elements ------
fprintf(fout1,['***************************************************************\n']);

for j=1:cntE
    fprintf(fout1,['*Element, type=C3D' num2str(NnodeE(j)) '\n']);
    for i=1:nElem(j)
        fprintf(fout1,[num2str(ElMat{j}(i,1)+nElemAll*2) ', ' num2str(ElMat{j}(i,2:end-1),'%d, ') ' ' num2str(ElMat{j}(i,end)) '\n']);
        i;
    end
    fprintf(fout1,['***************************************************************\n']);
end

while isempty(strfind(a,'material='))
    a=fgets(fid);
end

UMATname=a(strfind(a,'material=')+9:end);

fprintf(fout1,['*Elset, elset=umatelem, generate\n']);
fprintf(fout1,[num2str(nElemAll*2+1) ', ' num2str(nElemAll*3)   ', 1\n']);

fprintf(fout1,['***************************************************************\n']);
fprintf(fout1,['*Solid Section, elset=umatelem, material=' UMATname '1.0\n']);

while isempty(strfind(a,'*End Part'))
    a=fgets(fid);
end

while(ischar(a))
    if strfind(a,'*Instance, name=')~=0
        break
    end
    fprintf(fout1,a);    
    a=fgets(fid);
end

InstanceName=a(strfind(a,'*Instance, name=')+16:strfind(a,', part=')-1);

% ------ Update elements for creating surfaces ------

while(ischar(a))
    while (strfind(a,'*Elset, elset=')~=0) & (strfind(a,'Surf')~=0)
        fprintf(fout1,a);    
        a=fgets(fid);
        while isempty(strfind(a,'*'))
            ElemSurf = textscan(a,'%s','Delimiter',',')';
            ElemSurf = str2double(ElemSurf{1,1}) + nElemAll*2;
            ElemSurf = convertStringsToChars(strjoin(string(ElemSurf),', '));
            fprintf(fout1,[ElemSurf '\n']);
            a=fgets(fid);
        end
    end    
    if strfind(a,'*End Assembly')~=0
        break
    end
    fprintf(fout1,a);    
    a=fgets(fid);
end

fprintf(fout1,['**\n']);

fprintf(fout1,['*Elset, elset=umatelem, instance=' InstanceName ', generate\n']);
fprintf(fout1,[num2str(nElemAll*2+1) ', ' num2str(nElemAll*3) ', 1\n']);
fprintf(fout1,['**\n*End Assembly\n']);
fprintf(fout1,['***************************************************************\n']);

a=fgets(fid);

while(ischar(a))

    while(ischar(a))
        if strfind(a,'*Output, history')~=0
            break
        end
        fprintf(fout1,a);    
        a=fgets(fid);
    end

    fprintf(fout1,['*element output, elset=umatelem\n']);
    fprintf(fout1,['SDV\n']);
    fprintf(fout1,['**\n']);
    a=fgets(fid);
    fprintf(fout1,a);
    a=fgets(fid);

end
fclose('all');

% --------------- Start modifying the UEL fortran file -------------------

% determining if the OS if Lunix, Windows of Mac
comp = computer;
if strfind(comp,'WIN')~=0
    comptype=1;     % windows
elseif strfind(comp,'LNX')~=0
    comptype=2;     % linux
elseif strfind(comp,'MAC')~=0
    comptype=3;     % mac
else
    comptype=input('Please provide OS type: 1 - Microsoft Windows; 2 - Linux; 3 - Apple Mac: ');     % asking user
    if comptype==1 || comptype==2 || comptype==3
    else
        comptype=input('Wrong type.\n Please provide OS type: 1 - Microsoft Windows; 2 - Linux; 3 - Apple Mac: ');     % asking user
        if comptype==1 || comptype==2 || comptype==3
        else
        error('Wrong type. Try again.')
    end
    end
end

fullp=mfilename('fullpath');
if isempty(fullp)~=1
    input2=[fullp(1:end-33) '\PhaseFieldUEL\Abaqus2PhasefieldUEL3D.for'];
else
    fullp=matlab.desktop.editor.getActiveFilename;
    input2=[fullp(1:end-35) '\PhaseFieldUEL\Abaqus2PhasefieldUEL3D.for'];
end

if comptype==1
    output=[inputName(1:end-4) '_UEL_PE.for'];
else
    output=[inputName(1:end-4) '_UEL_PE.f'];
end

fid=fopen(input2,'rt');
fout1 = fopen(output, 'wt');
a=fgets(fid);

while(ischar(a))
    if strfind(a,'N_ELEM=')~=0
        strs=strfind(a,'N_ELEM=');
        ends=strfind(a,',');
        a=[a(1:strs+6) num2str(nElemAll) a(ends(1):end)];
    end
    fprintf(fout1,a);    
    a=fgets(fid);
end

fclose('all');

return
