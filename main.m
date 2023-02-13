%% Clear workspace
close all; clearvars; format compact;

%% C-scan .csv file names
panelType = ["BL","CONT","RPR"];
impactEnergy = ["10","15","20"];
n = length(impactEnergy);
m = length(panelType);
fileNames = strings([n*m*2,1]);
count = 0;
for i = 1:n
    for j = 1:m
        count = count + 1;
        fileNames(count) = strcat(panelType(j),"-S-",...
            impactEnergy(i),"J-2");
        fileNames(count+n*m) = strcat(panelType(j),"-S-",...
            impactEnergy(i),"J-2-back");
    end
end
fileNames = ["BL-H-15J-1";
                 "CONT-H-10J-2";"CONT-H-10J-3";
                 "CONT-H-20J-1";"CONT-H-20J-2";"CONT-H-20J-3";
                  "RPR-H-20J-2";"RPR-H-20J-3"; fileNames];
numFiles = length(fileNames);

%% Function inputs

% READCSCAN options =======================================================
runReadCscan   = false;      % Run readcscan?
filesReadCscan = 1:numFiles; % Indices of files to read
% READCSCAN inputs --------------------------------------------------------
delim      = "   ";      % Field delimiter characters (i.e. "," or " ")
inFolder   = "Input";    % Folder location of .csv C-scan input file
outFolder  = "Output";   % Folder to write .mat C-scan output file
dRow       = 1;          % # rows to down sample
dCol       = 5;          % # col to down sample
% END READCSCAN____________________________________________________________
% #########################################################################

% PROCESSCSCAN options ====================================================
runProcessCscan   = false;      % Run processascan?
filesProcessCscan = 1:numFiles; % Indices of files to read
% PROCESSCSCAN inputs -----------------------------------------------------
figFolder   = "Figures";% Folder path to .fig and .png files
dt          = 1/50;     % Sampling period in microseconds
bounds      = [30 217 30 350]; % Indices of search area for bounding box
                               % in format: [startX endX startY endY]
incr        = 10;      % Increment for bounding box search in indices
baseRow     = 50:5:60; % Vector of row indices to calculate baseline TOF
baseCol     = 10:5:20; % Vector of cols indices to calculate baseline TOF
cropThresh  = 0.2;     % If abs(basetof-tof(i)) > cropthresh, pt is damaged
pad         = 1;       % (1+pad)*incr added to calculated bounding box
minProm1    = 0.03;    % Min prominence for a peak to be identified
noiseThresh = 0.01;    % If average signal lower, then pt is not processed
maxWidth    = 0.75;    % Max width for a peak to be marked as wide
res         = 300;     % Image resolution setting in dpi
% END PROCESSCSCAN ________________________________________________________
% #########################################################################

% SEGCSCAN options ========================================================
runSegCscan   = false;      % Run processtof?
filesSegCscan = 1:numFiles; % Indices of files to read
% PROCESSTOF inputs -------------------------------------------------------
minProm2   = 0.013;%Min prominence in findpeaks for a peak to be identified
peakThresh = 0.04; %Threshold of dt for peak to be labeled as unique
% MODETHRESH:       Threshold for TOF to be set to mode TOF
hig = 0.25;
med = 0.14;
low = 0.06;
modeThresh = [hig; hig; hig; hig; hig;       %  1- 5 
              med; hig; hig; med; hig;       %  6-10
              hig; med; low; low; low;       % 11-15
              med; med; hig; hig; hig;       % 16-20
              hig; hig; hig; med; med; hig]; % 21-26
% END SEGCSCAN ____________________________________________________________
% #########################################################################

% PLOTFIG options =========================================================
runPlotFig   = false;      % Run plottof?
filesPlotFig = 1:numFiles; % Indices of files to read
% PLOTFIG inputs ----------------------------------------------------------
plateThick  = 3.3;% Plate thickness in millimeters
nLayers = 25;     % Number of layers in plate
% END PLOTFIG _____________________________________________________________
% #########################################################################

% MERGETOF options ========================================================
runMergeTOF   = true;   % Run mergetof?
filesMergeTOF = 9;%:17; % Indices of files to read
% MERGETOF inputs ---------------------------------------------------------
di = 8;                 % File index offset if necessary
dx = [ 8;-2;            % 9-10
      -4; 7; 4;-27;-45; % 11-15
       6; 9];           % 16-17
dyMergeTOF = [2; 0;            % 9-10
       2;-1;-5; -2;  0; % 11-15
       1; 0];           % 16-17
testMergeTOF = false;
% END MERGETOF ____________________________________________________________
% #########################################################################

% PLOTCUSTOM options ======================================================
runPlotCustom   = false;      % Run customplot?
filesPlotCustom = 1:numFiles; % Indices of files to read
% PLOTCUSTOM inputs -------------------------------------------------------
startRowUT = 22;
endRowUT = 617;
startColUT = 98;
endColUT = 477;
utwinCrop = [startRowUT endRowUT startColUT endColUT];
dyPlotCustom = [26; 12; -5; 70; 73;      %  1- 5 
                25; 25; 72;-18; -5;      %  6-10
                10; -5; 28; 58; 40;      % 11-15
                -2; -2; -5; -2; 10;      % 16-20
                -7; -5; 55; 43; -5; 10]; % 21-26
testPlotCustom = false;
% END PLOTCUSTOM __________________________________________________________
% #########################################################################

%% Read C-scans from .csv file(s)
% Note: parfor results in file processing to complete out of order

if runReadCscan == true
tic
fprintf("READCSCAN======================================\n\n")
fprintf("Converting C-scans from .csv to .mat files for:\n\n");
parfor i = filesReadCscan
    disp(strcat(num2str(i),'.',fileNames(i)));
    readcscan(fileNames(i),delim,inFolder,outFolder,dRow,dCol);
end
sec = toc;
fprintf('\nElapsed time is:')
disp(duration(0,0,sec))
fprintf("Finished converting all C-scan .csv files!\n\n")
end
%% Process C-scans

if runProcessCscan == true
tic
fprintf("PROCESSCSCAN====================================\n\n")
fprintf("Processing C-scans for:\n\n");
for i = filesProcessCscan
    disp(strcat(num2str(i),'.',fileNames(i)));
    processcscan(fileNames(i),outFolder,figFolder,dt,bounds,incr, ...
        baseRow,baseCol,cropThresh,pad,minProm1,noiseThresh,maxWidth,res)
end
sec = toc;
fprintf('\nElapsed time is:')
disp(duration(0,0,sec))
fprintf("Finished processing all C-scan .mat files!\n\n")
end

%% Segment C-Scan
% Note: parfor results in file processing to complete out of order

if runSegCscan == true
tic
fprintf("SEGCSCAN======================================\n\n")
fprintf("Segmented C-scan for:\n\n");
parfor i = filesSegCscan
    disp(strcat(num2str(i),'.',fileNames(i)));
    segcscan(fileNames(i),outFolder,figFolder,minProm2,peakThresh, ...
        modeThresh(i),res);
end
sec = toc;
fprintf('\nElapsed time is:')
disp(duration(0,0,sec))
fprintf("Finished segmenting all C-scans!\n\n")
end

%% Plot figures
% Note: parfor results in file processing to complete out of order

if runPlotFig == true
tic
fprintf("PLOTFIG======================================\n\n")
fprintf("Plotting figures for:\n\n");
parfor i = filesPlotFig
    disp(strcat(num2str(i),'.',fileNames(i)));
    plotfig(fileNames(i),outFolder,figFolder,plateThick,nLayers,res);
end
sec = toc;
fprintf('\nElapsed time is:')
disp(duration(0,0,sec))
fprintf("Finished plotting!\n\n")
end

%% Merge for hybrid C-scan

if runMergeTOF == true
tic
fprintf("MERGETOF======================================\n\n")
fprintf("Merging TOF for:\n\n");
for i = filesMergeTOF
    disp(strcat(num2str(i),'.',fileNames(i)));
    mergetof(fileNames(i),outFolder,figFolder,dx(i-di),dyMergeTOF(i-di),testMergeTOF, ...
        res);
end
sec = toc;
fprintf('\nElapsed time is:')
disp(duration(0,0,sec))
fprintf("Finished merging!\n\n")
end

%% Make custom plots

if runPlotCustom == true
tic
fprintf("PLOTCUSTOM======================================\n\n")
fprintf("Plotting custom plots for:\n\n");
parfor i = filesPlotCustom
    disp(strcat(num2str(i),'.',fileNames(i)));
    plotcustom(fileNames(i),inFolder,outFolder,figFolder,utwinCrop, ...
        dyPlotCustom(i),res,testPlotCustom);
end
sec = toc;
fprintf('\nElapsed time is:')
disp(duration(0,0,sec))
fprintf("Finished plotting!\n\n")
end
