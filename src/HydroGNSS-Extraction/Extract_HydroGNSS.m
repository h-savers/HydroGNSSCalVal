%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% HydroGNSS Extraction Script - Test for File Availability Only %%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all
close all

% ===== Define Configuration File Path
conf_dir = 'C:\Users\syedw\Desktop\testcalval\conf\';
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
end

% ===== Extract values from GUI
initdate = Answer{2};
enddate  = Answer{3};

HydInPath = 'C:\Users\syedw\Desktop\sapienza\datasets\PDGS_nas\HydroGNSS-1\DataRelease\L1A_L1B';

% ===== Date Range
initdatenum = datenum(initdate, 'dd/mm/yyyy');
enddatenum  = datenum(enddate, 'dd/mm/yyyy');
datelist    = initdatenum:enddatenum;

% ===== 6-Hour Time Blocks
time_blocks = [0 6; 6 12; 12 18; 18 24];

% ===== File Check Loop
for ii = 1:length(datelist)
    datechar = datestr(datelist(ii), 'yyyymmdd');
    Year     = datechar(1:4);
    Month    = datechar(5:6);
    Day      = datechar(7:8);

    disp(['📅 Checking date: ' datechar]);

    for b = 1:size(time_blocks, 1)
        start_hour = time_blocks(b, 1);
        end_hour   = time_blocks(b, 2);
        block_name = sprintf('H%02d', start_hour);

        % Construct file path
        subfolder = fullfile(HydInPath, [Year '-' Month], Day, block_name);
        filename  = fullfile(subfolder, 'metadata_L1_merged.nc');

        % Message formatting
        if isfile(filename)
            disp(['✅ Found file for ' datechar ' | Block: ' block_name]);
        else
            disp(['❌ Missing file for ' datechar ' | Block: ' block_name]);
        end
    end
end

disp('✔️ File check complete.');
