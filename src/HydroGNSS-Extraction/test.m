%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Extract HydroGNSS observables in 6-hour blocks, aggregate across days
% Developed by [Your Name], based on CyGNSS legacy extraction code
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all
close all

addpath('src\HydroGNSS_Extraction\functions\')  % Adjust if path differs

%%%%%%%%%%%%%%% Define Paths %%%%%%%%%%%%%%%%%%%%%%%%%%%
HydInPath     = 'C:\Users\syedw\Desktop\HydroGNSS validation\InPath\';
HydOutPath    = 'C:\Users\syedw\Desktop\HydroGNSS validation\OutPath\';
HydFigurePath = 'C:\Users\syedw\Desktop\HydroGNSS validation\FigurePath\';
LogPath       = 'C:\Users\syedw\Desktop\HydroGNSS validation\LogPath\';

verifydir(HydOutPath);
verifydir(HydFigurePath);
verifydir(LogPath);

%%%%%%%%%%%%%% Date Range to Process %%%%%%%%%%%%%%%%%%%
initdate   = '02/10/2021';
enddate    = '03/10/2021';
initdatenum = datenum(initdate, 'dd/mm/yyyy');
enddatenum  = datenum(enddate, 'dd/mm/yyyy');
datelist    = initdatenum:enddatenum;

%%%%%%%%%%%%%% Define 6-Hour Time Blocks %%%%%%%%%%%%%%%
time_blocks = [0 6; 6 12; 12 18; 18 24];

%%%%%%%%%%%%%% Aggregated Output Variables %%%%%%%%%%%%%
agg_TimeUTC = [];
agg_Lat     = [];
agg_Lon     = [];
agg_SM      = [];
agg_LST     = [];
agg_TB      = [];
agg_QC      = [];

%%%%%%%%%%%%%% Main Loop Over Days %%%%%%%%%%%%%%%%%%%%%
tic
for ii = 1:length(datelist)
    datechar = datestr(datelist(ii), 'yyyymmdd');
    Year     = datechar(1:4);
    d        = datetime(datechar, 'InputFormat', 'yyyyMMdd');
    doy      = day(d, 'dayofyear');
    
    disp(['Processing date ' datechar ' (DoY ' num2str(doy) ') ...']);

    % Input folder for the current day
    DoYfolder = [HydInPath, num2str(doy), '/'];
    files = dir([DoYfolder 'hydrognss*.nc']);

    if isempty(files)
        disp(['No HydroGNSS files found for DoY ', num2str(doy)]);
        continue
    end

    % Loop over each 6-hour block
    for b = 1:size(time_blocks, 1)
        start_hour = time_blocks(b,1);
        end_hour   = time_blocks(b,2);
        disp(['  Block: ', num2str(start_hour), '–', num2str(end_hour), ' UTC']);

        for f = 1:length(files)
            filename = fullfile(DoYfolder, files(f).name);
            
            try
                [TimeUTC, Lat, Lon, SM, LST, TB, QC] = extract_HydroGNSS(filename, start_hour, end_hour, LogPath);
                
                % Concatenate to aggregated variables
                agg_TimeUTC = [agg_TimeUTC; TimeUTC(:)];
                agg_Lat     = [agg_Lat; Lat(:)];
                agg_Lon     = [agg_Lon; Lon(:)];
                agg_SM      = [agg_SM; SM(:)];
                agg_LST     = [agg_LST; LST(:)];
                agg_TB      = [agg_TB; TB(:)];
                agg_QC      = [agg_QC; QC(:)];

            catch ME
                warning(['  Error processing file: ', filename]);
                warning(['  Message: ', ME.message]);
                continue
            end
        end
    end
end

%%%%%%%%%%%%%% Save Aggregated Data %%%%%%%%%%%%%%%%%%%%
daterangechar = [datestr(initdatenum,'yyyymmdd') '-' datestr(enddatenum,'yyyymmdd')];
outname = ['aggregated_HydroGNSS_' daterangechar '_6hBlocks.mat'];

save(fullfile(HydOutPath, outname), ...
    'Year', 'agg_TimeUTC', 'agg_Lat', 'agg_Lon', ...
    'agg_SM', 'agg_LST', 'agg_TB', 'agg_QC', '-v7.3');

duration_elapsed = duration(0,0,toc);
disp(['✅ Extraction complete. Total time: ', char(duration_elapsed)]);
