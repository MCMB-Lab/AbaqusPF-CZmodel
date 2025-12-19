function Abaqus2PhasefieldUEL3DPlasticity(InputPath,MatProp)
% This code is used for creating unified PFM-CZM (phase field model and
% cohesive zone model). Since there are many different cases when using PFM
% and CZM, this code cannot convert all situations, and it is user's
% responsibility to make sure the generated inp file correct. Some notices
% for this Matlab code are as follows
%
% 1. assume there is only one part in the Abaqus CAE model;
% 2. assume that there are only two types of element, PFM and CZM; in the
% Abasuqs CAE's part, the name of set for PFM should include "Uel", and the
% name of set for CZM should include "Coh"; the name of section for PFM and
% CZM should include "Uel" and "Coh", respectively; there is only one
% material for PFM in the Abasuqs CAE, which includes density, 34 SDV,
% Young's modulus, and Poisson's ratio.
% 3. assume in the original inp file, element ID for PFM starts first, and
% then the element ID for CZM later. Or create normal elements first, and
% then create CZM later.
% 4. assume that load and boundary conditions are only apllied on the PFM
% elements, not on the cohesive element, which can greatly simplify this
% Matlab code.
% 5. the PFM is based on the work of Molnár, G., Gravouil, A., Seghir, R.,
% & Réthoré, J. (2020). An open-source Abaqus implementation of the
% phase-field method to study the effect of plasticity on the instantaneous
% fracture toughness in dynamic crack propagation. Computer Methods in
% Applied Mechanics and Engineering, 365, 113004. Interested readear are
% referred to the original code.
% 6. it is still necessary to check material parameters are put under the
% right set name. If not, modify material parameters manually in the
% generated inp file.

% check if the input file is readed. If not, read it manually
narginLoc=nargin;
if narginLoc~=2
    % input inp file manually
    [FileName,PathName,FilterIndex]=uigetfile('*.inp');
    InputPath=[PathName,FileName];
    if isa(InputPath,'char')~=1
        error('The input path provided is not correct.')
    end
    % input material parameters manually
    nMatIni=input('Number of materials? - ');
    for i=1:nMatIni
        MatProp(i,1)=input(['Young''s modulus for material (' num2str(i) ')? - ']);
        MatProp(i,2)=input(['Poisson''s ratio for material (' num2str(i) ')? - ']);
        MatProp(i,3)=input(['Yield stress for material (' num2str(i) ')? - ']);
        MatProp(i,4)=input(['Hardening modulus for material (' num2str(i) ')? - ']);
        MatProp(i,5)=input(['Failure based on critical energy release rate (0) or critical plastic strain (1) for material (' num2str(i) ')? - ']);
        MatProp(i,6)=input(['Density for material (' num2str(i) ')? - ']);
        MatProp(i,7)=input(['Split based on hydrostatic strain energy (0) or all strain energy (1) for material (' num2str(i) ')? - ']);
        MatProp(i,8)=input(['Von misses criterion is not used (0) or used (1) for material (' num2str(i) ')? - ']);
        MatProp(i,9)=input(['Length scale for material (' num2str(i) ')? - ']);
        MatProp(i,10)=input(['Critical energy release rate for material (' num2str(i) ')? - ']);
        MatProp(i,11)=input(['Linear elastic range is not used (0) or used (1) for material (' num2str(i) ')? - ']);
        MatProp(i,12)=input(['Damage (0) or redamage (1) switch for material (' num2str(i) ')? - ']);
    end
end

% check again if the inp file is readed
if isempty(InputPath)==1
    [FileName,PathName,FilterIndex]=uigetfile('*.inp');
    InputPath=[PathName,FileName];
end

% check if the number of material parameters is correct
if length(MatProp(1,:))<12
    error('Not enought material parameters are given.')
end
if length(MatProp(1,:))>12
    error('Too many material parameters are given.')
end

% read material parameters
Ymod=MatProp(:,1);% Young's modulus for material
nu=MatProp(:,2);% Poisson's ratio for material
Ystress=MatProp(:,3);% Yield stress for material
Hmod=MatProp(:,4);% Hardening modulus for material
epscr=MatProp(:,5);% Failure based on critical energy release rate (0) or critical plastic strain (1) for material
density=MatProp(:,6);% Density for material
anisoswt=MatProp(:,7);% Split based on hydrostatic strain energy (0) or all strain energy (1) for material
plswt=MatProp(:,8);% Von misses criterion is not used (0) or used (1) for material
lc=MatProp(:,9);% Length scale for material
gc=MatProp(:,10);% Critical energy release rate for material
elswt=MatProp(:,11);% Linear elastic range is not used (0) or used (1) for material
drswt=MatProp(:,12);% Damage (0) or redamage (1) switch for material

% initialize output file
InputName=InputPath;
OutputName=[InputPath(1:end-4),'_UEL.inp'];
fid=fopen(InputName,'rt');
fout1=fopen(OutputName,'wt');
currentread=fgets(fid);

% sart reading input file and copy nodes
while(ischar(currentread))
    if contains(currentread,'*Element')
        break
    end
    fprintf(fout1,currentread);
    currentread=fgets(fid);
end

% assign UEL element
CntEleTyp=1;
while(ischar(currentread))
    if contains(currentread,'*Element, type=') && ~contains(currentread,'COH')
        SetNameEle{1,CntEleTyp}=currentread;
        currentread=fgets(fid);
        % defintion of UEL types
        if length(str2num(currentread))==5
            % tetrahedron elements
            fprintf(fout1,['*********************** TETRAHEDRAL ***************************\n']);
            fprintf(fout1,['** -------------------- Displacement --------------------------\n']);
            fprintf(fout1,['*User element, nodes=4, type=U1, properties=11, coordinates=3, VARIABLES=52\n']);
            fprintf(fout1,['1,2,3\n']);
            fprintf(fout1,['** -------------------- Phase  field --------------------------\n']);
            fprintf(fout1,['*User element, nodes=4, type=U3, properties=4, coordinates=3, VARIABLES=6\n']);
            fprintf(fout1,['4\n']);
            nNodeEle(1,CntEleTyp)=4;
        else
            % hexagonal elements
            fprintf(fout1,['***********************  HEXAGONAL  ***************************\n']);
            fprintf(fout1,['** -------------------- Displacement --------------------------\n']);
            fprintf(fout1,['*User element, nodes=8, type=U2, properties=11, coordinates=3, VARIABLES=344\n']);
            fprintf(fout1,['1,2,3\n']);
            fprintf(fout1,['** -------------------- Phase  field --------------------------\n']);
            fprintf(fout1,['*User element, nodes=8, type=U4, properties=4, coordinates=3, VARIABLES=24\n']);
            fprintf(fout1,['4\n']);
            nNodeEle(1,CntEleTyp)=8;
        end
    elseif contains(currentread,'*Element, type=') && contains(currentread,'COH')
        SetNameEle{1,CntEleTyp}=currentread;
        currentread=fgets(fid);
        % defintion of cohesive element types
        if length(str2num(currentread))==7
            % COH3D6
            nNodeEle(1,CntEleTyp)=6;
        else
            % COH3D8
            nNodeEle(1,CntEleTyp)=8;
        end
    end
    
    % record original mesh
    count=0;
    while ~contains(currentread,'*Element,') && ~contains(currentread,'*Nset,')
        count=count+1;
        SetNameEle{2,CntEleTyp}(count,:)=str2num(currentread);
        currentread=fgets(fid);
    end
    % number of meshes for each type of element
    SetNameEle{3,CntEleTyp}=num2str(length(SetNameEle{2,CntEleTyp}(:,1)));
    
    % update element type counter
    if contains(currentread,'*Element,')
        CntEleTyp=CntEleTyp+1;
    else
        break
    end
end
fprintf(fout1,['***************************************************************\n']);

% number of all elements except cohesive elements
nElemAll=0;
for ii=1:CntEleTyp
    if contains(SetNameEle{1,ii},'type=C3D4') || contains(SetNameEle{1,ii},'type=C3D8')
        nElemAll=nElemAll+str2double(SetNameEle(3,ii));
    end
end

% replicate UELs
for ii=1:CntEleTyp
    if ~contains(SetNameEle{1,ii},'type=COH')
        if nNodeEle(1,ii)==4
            ej=1;
        elseif nNodeEle(1,ii)==8
            ej=2;
        end
        fprintf(fout1,['***************************************************************\n']);
        fprintf(fout1,['*Element, type=U' num2str(ej) '\n']);
        for jj=1:str2double(SetNameEle(3,ii))
            fprintf(fout1,[num2str(SetNameEle{2,ii}(jj,1)) ', ' num2str(SetNameEle{2,ii}(jj,2:end-1),'%d, ') ' ' num2str(SetNameEle{2,ii}(jj,end)) '\n']);
        end
        fprintf(fout1,['***************************************************************\n']);
        fprintf(fout1,['*Element, type=U' num2str(ej+2) '\n']);
        for jj=1:str2double(SetNameEle(3,ii))
            fprintf(fout1,[num2str(SetNameEle{2,ii}(jj,1)+nElemAll) ', ' num2str(SetNameEle{2,ii}(jj,2:end-1),'%d, ') ' ' num2str(SetNameEle{2,ii}(jj,end)) '\n']);
        end
        fprintf(fout1,['***************************************************************\n']);
        if nNodeEle(1,ii)==4
            fprintf(fout1,['*Element, type=C3D4' '\n']);
        else
            fprintf(fout1,['*Element, type=C3D8' '\n']);
        end
        for jj=1:str2double(SetNameEle(3,ii))
            fprintf(fout1,[num2str(SetNameEle{2,ii}(jj,1)+2*nElemAll) ', ' num2str(SetNameEle{2,ii}(jj,2:end-1),'%d, ') ' ' num2str(SetNameEle{2,ii}(jj,end)) '\n']);
        end
    else
        if nNodeEle(1,ii)==6
            fprintf(fout1,['***************************************************************\n']);
            fprintf(fout1,['*Element, type=COH3D6' '\n']);
            for jj=1:str2double(SetNameEle(3,ii))
                fprintf(fout1,[num2str(SetNameEle{2,ii}(jj,1)+2*nElemAll) ', ' num2str(SetNameEle{2,ii}(jj,2:end-1),'%d, ') ' ' num2str(SetNameEle{2,ii}(jj,end)) '\n']);
            end
        elseif nNodeEle(1,ii)==8
            fprintf(fout1,['***************************************************************\n']);
            fprintf(fout1,['*Element, type=COH3D8' '\n']);
            for jj=1:str2double(SetNameEle(3,ii))
                fprintf(fout1,[num2str(SetNameEle{2,ii}(jj,1)+2*nElemAll) ', ' num2str(SetNameEle{2,ii}(jj,2:end-1),'%d, ') ' ' num2str(SetNameEle{2,ii}(jj,end)) '\n']);
            end
        end
    end
end

% sets and material properties
fprintf(fout1,['***************************************************************\n']);
fprintf(fout1,['********************** ASSIGNING MATERIAL PROP ****************\n']);

CntElset=0;
while ~contains(currentread,'** Section')
    while ~contains(currentread,'*Elset,')
        fprintf(fout1,currentread);
        currentread=fgets(fid);
        if contains(currentread,'** Section')
            break
        end
    end
    if contains(currentread,'** Section')
        break
    end
    bin=strfind(currentread,'elset=');
    EName=currentread(bin+6:end-1);
    if contains(EName,',')
        bin=strfind(EName,',');
        EName=EName(1:bin-1);
    end
    if contains(EName,'Uel')
        CntElset=CntElset+1;
        ElstName{CntElset}=EName;
        ElSeT{2,CntElset}=currentread;
        ElSeT{3,CntElset}=ElstName{CntElset};
        fprintf(fout1,currentread);
        currentread=fgets(fid);
        cnt=4;
        while ~contains(currentread,'*')
            ElSeT{cnt,CntElset}=currentread;
            fprintf(fout1,currentread);
            currentread=fgets(fid);
            cnt=cnt+1;
        end
        ElSeT{1,CntElset}=cnt-4;% how many lines of element for each element set
    else
        CntElset=CntElset+1;
        ElstName{CntElset}=EName;
        ElSeT{2,CntElset}=currentread;
        ElSeT{3,CntElset}=ElstName{CntElset};
        fprintf(fout1,currentread);
        currentread=fgets(fid);
        cnt=4;
        while ~contains(currentread,'*')
            if ~contains(ElSeT{2,CntElset},'generate')
                ElSeT{cnt,CntElset}=currentread;
                b=str2num(currentread);
                fprintf(fout1,'%d, ',b+2*nElemAll);
                fprintf(fout1,'\n');
                currentread=fgets(fid);
                cnt=cnt+1;
            else
                ElSeT{cnt,CntElset}=currentread;
                b=str2num(currentread);
                fprintf(fout1,'%d, ',[b(1:(end-1))+2*nElemAll,b(end)]);
                fprintf(fout1,'\n');
                currentread=fgets(fid);
                cnt=cnt+1;
            end
        end
        ElSeT{1,CntElset}=cnt-4;
    end
end
fprintf(fout1,['***************************************************************\n']);

% check if the number of uel sets and the number of materials agree with each other
nMat=0;
nMatMatrix=[];
for ii=1:CntElset
    if contains(ElSeT{2,ii},'Uel')
        nMat=nMat+1;
        nMatMatrix=[nMatMatrix,ii];
    end
end
if length(Ymod)~=nMat
    error('The number of uel sets does not agree with the number of materials.')
end

% displacement field uel properties
for k=1:nMat
    fprintf(fout1,['*Uel property, elset=' ElstName{k} '\n']);
    fprintf(fout1,[num2str(Ymod(nMatMatrix(k))) ', ' num2str(nu(nMatMatrix(k))) ', ' num2str(Ystress(nMatMatrix(k))) ', ' num2str(Hmod(nMatMatrix(k))) ...
        ', ' num2str(epscr(nMatMatrix(k))) ', ' num2str(density(nMatMatrix(k))) ', ' num2str(anisoswt(nMatMatrix(k))) ', ' num2str(plswt(nMatMatrix(k))) ', ' '\n']);
    fprintf(fout1,[num2str(lc(nMatMatrix(k))) ', ' num2str(gc(nMatMatrix(k))) ', ' num2str(drswt(nMatMatrix(k))) '\n']);
end
fprintf(fout1,['**E, nu, Y, H, eps_cr, rho, anisoswt, plswt,\n']);
fprintf(fout1,['**lc, gc, drswt\n']);
fprintf(fout1,['***************************************************************\n']);

% create element set for phase field
for ii=nMatMatrix
    setname=ElSeT{2,ii};
    setnamelength=length(ElstName{ii});
    fprintf(fout1,[setname(1:14) ElstName{ii} '_PH' setname(14+setnamelength+1:end)]);
    if ~contains(setname,'generate')
        for jj=4:(4+ElSeT{1,ii}-1)
            setname=str2num(ElSeT{jj,ii});
            fprintf(fout1,'%d, ',setname+nElemAll);
            fprintf(fout1,'\n');
        end
%         b=str2num(ElSeT{Nline(k),k});
%         fprintf(fout1,'%d, ',b(1:end-1)+nElemAll);
%         fprintf(fout1,'%d',b(end)+nElemAll);
%         fprintf(fout1,'\n');
    else
        setname=str2num(ElSeT{4,ii});
        fprintf(fout1,[num2str(setname(1)+nElemAll) ', ' num2str(setname(2)+nElemAll) ', ' num2str(setname(3)) '\n']);
    end
end

% phase field uel properties
fprintf(fout1,['***************************************************************\n']);
for ii=1:nMat
    fprintf(fout1,['*Uel property, elset=' ElstName{ii} '_PH\n']);
    fprintf(fout1,[num2str(lc(ii)) ', ' num2str(gc(ii)) ', ' num2str(elswt(ii)) ', ' num2str(drswt(ii)) '\n']);
end
fprintf(fout1,['**lc, gc, elswt, drswt\n']);

% ------ Replicating dummy UMAT elements ------
fprintf(fout1,['***************************************************************\n']);

% UMAT element set and its elements
fprintf(fout1,['*Elset, elset=umatelem, generate\n']);
fprintf(fout1,[num2str(nElemAll*2+1) ', ' num2str(nElemAll*3) ', 1\n']);
fprintf(fout1,['***************************************************************\n']);
while ~contains(currentread,'material=')
    fprintf(fout1,currentread);
    currentread=fgets(fid);
end
UMATname=currentread(strfind(currentread,'material=')+9:end);
fprintf(fout1,['*Solid Section, elset=umatelem, material=' UMATname ',\n']);
% other section information and end of part
while ~contains(currentread,'Coh')
    currentread=fgets(fid);
end
while ~contains(currentread,'*End Part')
    fprintf(fout1,currentread);
    currentread=fgets(fid);
end

% instance
while(ischar(currentread))
    if contains(currentread,'*Instance, name=')
        break
    end
    fprintf(fout1,currentread);
    currentread=fgets(fid);
end
InstanceName=currentread(strfind(currentread,'*Instance, name=')+16:strfind(currentread,', part=')-1);

% update elements for creating surfaces
while(ischar(currentread))
    while contains(currentread,'*Elset, elset=')
        if ~contains(currentread,'generate')
            fprintf(fout1,currentread);
            currentread=fgets(fid);
            while ~contains(currentread,'*')
                ElemSurf = textscan(currentread,'%s','Delimiter',',')';
                ElemSurf = str2double(ElemSurf{1,1})+nElemAll*2;
                ElemSurf = convertStringsToChars(strjoin(string(ElemSurf),', '));
                fprintf(fout1,[ElemSurf '\n']);
                currentread=fgets(fid);
            end
        else
            fprintf(fout1,currentread);
            currentread=fgets(fid);
            while ~contains(currentread,'*')
                ElemSurf = textscan(currentread,'%s','Delimiter',',')';
                ElemSurf = str2double(ElemSurf{1,1})+nElemAll*2;
                ElemSurf(end)=ElemSurf(end)-nElemAll*2;
                ElemSurf = convertStringsToChars(strjoin(string(ElemSurf),', '));
                fprintf(fout1,[ElemSurf '\n']);
                currentread=fgets(fid);
            end
        end
    end
    if strfind(currentread,'*End Assembly')~=0
        break
    end
    fprintf(fout1,currentread);
    currentread=fgets(fid);
end

while(ischar(currentread))
    if strfind(currentread,'*End Assembly')~=0
        break
    end
    fprintf(fout1,currentread);
    currentread=fgets(fid);
end
fprintf(fout1,['**\n']);

fprintf(fout1,['*Elset, elset=umatelem, instance=' InstanceName ', generate\n']);
fprintf(fout1,[num2str(nElemAll*2+1) ', ' num2str(nElemAll*3) ', 1\n']);
fprintf(fout1,['**\n*End Assembly\n']);
fprintf(fout1,['***************************************************************\n']);

currentread=fgets(fid);
while(ischar(currentread))
    while(ischar(currentread))
        if strfind(currentread,'*Output, history')~=0
            break
        end
        fprintf(fout1,currentread);    
        currentread=fgets(fid);
    end
    fprintf(fout1,['*element output, elset=umatelem\n']);
    fprintf(fout1,['SDV\n']);
    fprintf(fout1,['**\n']);
    currentread=fgets(fid);
    fprintf(fout1,currentread);
    currentread=fgets(fid);
end
fclose('all');

% start modifying the UEL fortran file
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
    OutputName=[InputName(1:end-4) '_UEL_PE.for'];
else
    OutputName=[InputName(1:end-4) '_UEL_PE.f'];
end

fid=fopen(input2,'rt');
fout1 = fopen(OutputName, 'wt');
currentread=fgets(fid);

while(ischar(currentread))
    if strfind(currentread,'N_ELEM=')~=0
        strs=strfind(currentread,'N_ELEM=');
        ends=strfind(currentread,',');
        currentread=[currentread(1:strs+6) num2str(nElemAll) currentread(ends(1):end)];
    end
    fprintf(fout1,currentread);    
    currentread=fgets(fid);
end

fclose('all');

fprintf('completed \n');
return
