%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% HydroGNSS Extraction Script - Test for File Availability and Extract %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all
close all

% ===== Define Configuration File Path
conf_dir = 'D:\Hamed\HydroGNSS_CalVal\HydroGNSSCalVal\conf\';
conf_file = fullfile(conf_dir, 'Configuration.mat');
cfg_file = fullfile(conf_dir, 'Configuration.txt');

% ===== Verify or Create Configuration Directory
if ~exist(conf_dir, 'dir')
    mkdir(conf_dir);
end

% ===== GUI Prompt
prompt = {'Taskname: ', ...
          'Init date (dd/mm/yyyy): ', ...
          'End date (dd/mm/yyyy): ', ...
          'Savespace: ', ...
          'Mainpath: ', ...
          'Hydoutpath: ', ...
          'LatMin: ', ...
          'LatMax: ', ...
          'LonMin: ', ...
          'LonMax: ', ...
          'Include DDM? (Yes/No): '};

name = 'Soil moisture L2 processor by Sapienza-CRAS';
numlines = repmat([1 40], 11, 1);
defaultanswer = {'TestTask', '14/08/2018', '15/08/2018', 'yes', ...
                 'C:\HydroGNSS\main\', 'C:\HydroGNSS\out\', ...
                 '-90', '90', '-180', '180', 'No'};

opts.Resize = 'on';
opts.WindowStyle = 'normal';
opts.Interpreter = 'tex';

% ===== Load previous if exists
if isfile(conf_file)
    loaded = load(conf_file, 'Answer');
    if isfield(loaded, 'Answer') && numel(loaded.Answer) >= 11
        defaultanswer = loaded.Answer;
    end
end

Answer = inputdlg(prompt, name, numlines, defaultanswer, opts);

% ===== Save config if dialog not cancelled
if ~isempty(Answer)
    save(conf_file, 'Answer');

    % Save human-readable txt config
    fid = fopen(cfg_file, 'w');
    for i = 1:length(prompt)
        fprintf(fid, '%s %s\n', prompt{i}, Answer{i});
    end
    fclose(fid);
else
    disp('❌ Script canceled by user.');
    return;
end

% ===== Extract values from GUI
initdate    = Answer{2};
enddate     = Answer{3};
savespace   = strcmpi(Answer{4}, 'yes');
mainpath    = Answer{5};
HydOutPath  = Answer{6};

% ===== Static inputs
HydInPath       = 'D:\Hamed\Datasets_processor\TDS-1\Gabrielle_2018_08\HydroGNSS-1\DataRelease\L1A_L1B';
lambda          = 0.19;         % L-band wavelength in meters
Doppler_bins    = 17;           % Doppler bin count (customize as needed)
delay_vector    = [];           % Optional
Power_threshold = 0;            % Optional
logpath         = '';           % Optional

% ===== Date Range
initdatenum = datenum(initdate, 'dd/mm/yyyy');
enddatenum  = datenum(enddate, 'dd/mm/yyyy');
datelist    = initdatenum:enddatenum;

% ===== Define 6-Hour Time Blocks
time_blocks = [0 6; 6 12; 12 18; 18 24];

% ===== Loop through each date and block
for ii = 1:length(datelist)
    datechar = datestr(datelist(ii), 'yyyymmdd');
    Year     = datechar(1:4);
    Month    = datechar(5:6);
    Day      = datechar(7:8);

    disp(['📅 Checking date: ' datechar]);

    % Get DoY
    datevec_now = datevec(datelist(ii));
    doy = datenum(datevec_now) - datenum(datevec_now(1),1,0);

    for b = 1:size(time_blocks, 1)
        start_hour = time_blocks(b, 1);
        block_name = sprintf('H%02d', start_hour);

        % Construct path to metadata
        subfolder = fullfile(HydInPath, [Year '-' Month], Day, block_name);
        filename  = fullfile(subfolder, 'metadata_L1_merged.nc');

        if isfile(filename)
            disp(['✅ Found file for ' datechar ' | Block: ' block_name]);
            disp('% Extracting HydroGNSS data ...');

            % Extraction: hardcoded for 1 satellite
            nsat = 1;
            SCID = 1;

            try
                [DoY, SoD, SCID, PRN, SPLAT, SPLON, THETA, EIRP, SNR, ...
                 PHI_Initial_sp_az_orbit, REFLECTIVITY_LINEAR, ...
                 KURTOSIS, KURTOSIS_DOPP_0, TE_WIDTH, DDM_NBRCS, ...
                 PA, QC, NF, LF, BRCS] = ...
                 extract_HydroGNSS(nsat, datechar, doy, subfolder, ...
                 logpath, lambda, Doppler_bins, savespace, ...
                 delay_vector, Power_threshold);

                % Optional: Save extracted variables
                outFile = fullfile(HydOutPath, ...
                    sprintf('HydroGNSS_Extract_%s_%s.mat', datechar, block_name));
                save(outFile, 'DoY', 'SoD', 'SCID', 'PRN', 'SPLAT', 'SPLON', ...
                    'THETA', 'EIRP', 'SNR', 'PHI_Initial_sp_az_orbit', ...
                    'REFLECTIVITY_LINEAR', 'KURTOSIS', 'KURTOSIS_DOPP_0', ...
                    'TE_WIDTH', 'DDM_NBRCS', 'PA', 'QC', 'NF', 'LF', 'BRCS');

                disp('✅ Extraction complete.');

            catch ME
                warning(['⚠️ Extraction failed for ' datechar ' ' block_name ': ' ME.message]);
            end

        else
            disp(['❌ Missing file for ' datechar ' | Block: ' block_name]);
        end
    end
end

disp('✔️ File check and extraction complete.');
