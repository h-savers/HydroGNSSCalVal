%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% HydroGNSS Extraction Script - 6-Hour Block Processing & Aggregation %%%
%%% Updated to include all required observables and detailed explanations %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all
close all

%%% Add function path
% This path should contain the extract_HydroGNSS function and utilities
% addpath('C:\Users\syedw\Desktop\HydroGNSS validation\src\HydroGNSS_Extraction\functions\')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Define Input/Output/Log/Figure Directories %%%
% - HydInPath: where raw HydroGNSS NetCDF files are stored, organized by DoY folders
% - HydOutPath: where output .mat files will be saved
% - HydFigurePath: (optional) location to store verification plots
% - LogPath: path to log warnings/errors from extraction
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

HydInPath     = 'C:\Users\syedw\Desktop\sapienza\datasets\PDGS_nas\HydroGNSS-1\DataRelease\L1A_L1B\2018-08';
HydOutPath    = 'C:\Users\syedw\Desktop\HydroGNSS-validation\test_data\extracted\';
HydFigurePath = 'C:\Users\syedw\Desktop\HydroGNSS-validation\test_data\extracted\figures\';
LogPath       = 'C:\Users\syedw\Desktop\HydroGNSS-validation\test_data\extracted\logs\';

verifydir(HydOutPath);
verifydir(HydFigurePath);
verifydir(LogPath);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Define Processing Date Range %%%
% Set the start and end date of the extraction in dd/mm/yyyy format
% Dates are converted to MATLAB serial date numbers
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

initdate     = '02/10/2021';
enddate      = '03/10/2021';
initdatenum  = datenum(initdate, 'dd/mm/yyyy');
enddatenum   = datenum(enddate, 'dd/mm/yyyy');
datelist     = initdatenum:enddatenum;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Define Time Blocks (6-Hour Intervals) %%%
% Data will be processed separately for each block in UTC time
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

time_blocks = [0 6; 6 12; 12 18; 18 24];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Initialize Aggregated Output Variables %%%
% These will collect data across all days and time blocks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

agg_TimeUTC       = [];   % Time tag
agg_Lat           = [];   % Latitude of specular point
agg_Lon           = [];   % Longitude of specular point
agg_SM            = [];   % Soil Moisture (if available)
agg_LST           = [];   % Land Surface Temperature (optional)
agg_TB            = [];   % Brightness Temperature (optional)
agg_QC            = [];   % Quality control flags
agg_DDM           = [];   % Calibrated Delay-Doppler Map (power units)
agg_Noise         = [];   % Estimated noise power
agg_SNR           = [];   % Estimated Signal-to-Noise Ratio
agg_IncAngle      = [];   % Incidence angle at SP
agg_Coherence     = [];   % Degree of coherence
agg_PRN           = [];   % Transmitter PRN ID
agg_ModulationID  = [];   % Signal modulation or frequency band
agg_Reflectivity  = [];   % Peak reflectivity
agg_NBRCS         = [];   % Normalized Bistatic Radar Cross Section
agg_RxPos         = [];   % Receiver position (ECEF)
agg_TxPos         = [];   % Transmitter position (ECEF)
agg_RxVel         = [];   % Receiver velocity (ECEF)
agg_TxVel         = [];   % Transmitter velocity (ECEF)
agg_ProcParams    = [];   % Processing parameters (e.g. integration time)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Main Loop Over Dates and 6-Hour Time Blocks %%%
% For each day and block, extract and aggregate HydroGNSS data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

tic
for ii = 1:length(datelist)
    datechar = datestr(datelist(ii), 'yyyymmdd');
    Year     = datechar(1:4);
    d        = datetime(datechar, 'InputFormat', 'yyyyMMdd');
    doy      = day(d, 'dayofyear');
    
    disp(['Processing date ' datechar ' (DoY ' num2str(doy) ') ...']);

    % Path to that day's folder
    DoYfolder = [HydInPath, num2str(doy), '\'];
    files = dir([DoYfolder 'hydrognss*.nc']);

    if isempty(files)
        disp(['No HydroGNSS files found for DoY ', num2str(doy)]);
        continue
    end

    % Loop through 6-hour blocks
    for b = 1:size(time_blocks, 1)
        start_hour = time_blocks(b,1);
        end_hour   = time_blocks(b,2);
        disp(['  Block: ', num2str(start_hour), '–', num2str(end_hour), ' UTC']);

        for f = 1:length(files)
            filename = fullfile(DoYfolder, files(f).name);
            
            try
                % Call extraction function (must support all required outputs)
                [TimeUTC, Lat, Lon, SM, LST, TB, QC, DDM, Noise, SNR, IncAngle, ...
                 Coherence, PRN, ModulationID, Reflectivity, NBRCS, ...
                 RxPos, TxPos, RxVel, TxVel, ProcParams] = ...
                 extract_HydroGNSS(filename, start_hour, end_hour, LogPath);

                % Aggregate all extracted variables
                agg_TimeUTC      = [agg_TimeUTC; TimeUTC(:)];
                agg_Lat          = [agg_Lat; Lat(:)];
                agg_Lon          = [agg_Lon; Lon(:)];
                agg_SM           = [agg_SM; SM(:)];
                agg_LST          = [agg_LST; LST(:)];
                agg_TB           = [agg_TB; TB(:)];
                agg_QC           = [agg_QC; QC(:)];
                agg_DDM          = cat(3, agg_DDM, DDM);  % DDM is 2D, stacked in 3D
                agg_Noise        = [agg_Noise; Noise(:)];
                agg_SNR          = [agg_SNR; SNR(:)];
                agg_IncAngle     = [agg_IncAngle; IncAngle(:)];
                agg_Coherence    = [agg_Coherence; Coherence(:)];
                agg_PRN          = [agg_PRN; PRN(:)];
                agg_ModulationID = [agg_ModulationID; ModulationID(:)];
                agg_Reflectivity = [agg_Reflectivity; Reflectivity(:)];
                agg_NBRCS        = [agg_NBRCS; NBRCS(:)];
                agg_RxPos        = [agg_RxPos; RxPos];    % RxPos/TxPos are [N x 3]
                agg_TxPos        = [agg_TxPos; TxPos];
                agg_RxVel        = [agg_RxVel; RxVel];
                agg_TxVel        = [agg_TxVel; TxVel];
                agg_ProcParams   = [agg_ProcParams; ProcParams];

            catch ME
                warning(['  ⚠️ Error processing file: ', filename]);
                warning(['  Message: ', ME.message]);
                continue
            end
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Save Aggregated Data to .mat File %%%
% All days and blocks are saved together into one file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

daterangechar = [datestr(initdatenum,'yyyymmdd') '-' datestr(enddatenum,'yyyymmdd')];
outname = ['aggregated_HydroGNSS_' daterangechar '_6hBlocks.mat'];

save(fullfile(HydOutPath, outname), ...
    'Year', 'agg_TimeUTC', 'agg_Lat', 'agg_Lon', 'agg_SM', 'agg_LST', 'agg_TB', ...
    'agg_QC', 'agg_DDM', 'agg_Noise', 'agg_SNR', 'agg_IncAngle', 'agg_Coherence', ...
    'agg_PRN', 'agg_ModulationID', 'agg_Reflectivity', 'agg_NBRCS', ...
    'agg_RxPos', 'agg_TxPos', 'agg_RxVel', 'agg_TxVel', 'agg_ProcParams', '-v7.3');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Completion Message %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

duration_elapsed = duration(0,0,toc);
disp(['✅ Extraction complete. Total time: ', char(duration_elapsed)]);
