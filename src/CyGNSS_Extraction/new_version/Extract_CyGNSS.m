%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Main code to extracts CyGNSS observables by also computing reflectivity
% and Trailing Edge and outputting them as trackwise files. Code developed
% by Emanuele Santi (e.santi@ifac.cnr.it) by reapprising previous
% implementations hosted at Università la Sapienza - Rome (IT)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all
close all
addpath('functions/')
%%%%%%%%%%%%%%%%%% Starting parallel computation %%%%%%%%%%%%%%%%%%%%%%%%%%
% p = gcp('nocreate');
% if isempty(p)
%    parpool
% end
%%%%%%%%%%%%%%%%%%%%%% Defining init and end date %%%%%%%%%%%%%%%%%%%%%%%%%
initdate='20/06/2019';
enddate='21/06/2019';
%%%%%%%%%%%%%%%%% Defining the steps of processing %%%%%%%%%%%%%%%%%%%%%%%%
savespace='yes';                                                           % to apply the CYGNSS land flag before saving (it significantly reduces the size of output file and speeds up the processing
aggregate_data = True;                                                     % to aggregate data from different days and save it in a single file

for i=171:171 % #TODO What is this loop for? There's a loop over all the days below. 

    %%%%%%%%%%%%%%%%%%%%%%%%% DEFINING PATHS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    CyGinpath=['D:\Hamed\CyGNSS\CyGNSS_V3.0\NewApproach_Emanuele\Extract_CYGNSS_Standalone\test201906\' num2str(i) '\'];                              % input CyGNSS .nc data
    CyGoutpath='D:\Hamed\CyGNSS\CyGNSS_V3.0\NewApproach_Emanuele\Extract_CYGNSS_Standalone\test201906\';                            % Path to save output matfile containing daily trackwise CYGNSS data (all 8 satellites)
    CyGfigurepath='D:\Hamed\CyGNSS\CyGNSS_V3.0\NewApproach_Emanuele\Extract_CYGNSS_Standalone\test201906\FigureOUT\';                       % Path to save output figures for verification
    logpath='D:\Hamed\CyGNSS\CyGNSS_V3.0\NewApproach_Emanuele\Extract_CYGNSS_Standalone\test201906\LOGS\';                                         % Error log path 
    
    %%%%%%%%%%%%%%%%%%%%%% AGB, LCC DEM, and SLOPE %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % % auxfile='auxiliary.mat';                                                   
    
    %%%%%%%%%%%%%%%%%%% DEFINING GENERAL PARAMETERS %%%%%%%%%%%%%%%%%%%%%%%%%%%
    LatMin=-90;
    LatMax=90;
    LonMin=-180;
    LonMax=180;
    %%%%%%%%%%%%%%%% Parameters for CyGNSS extraction %%%%%%%%%%%%%%%%%%%%%%%%%
    CA_chip_delay = 0.2552;                                                    % around 1/4 of CA code chip
    delay_vector = 0:CA_chip_delay:16*CA_chip_delay;
    Doppler_bins=1:1:17; 
    Power_threshold=0.7;
    lambda=0.1903;                                                             % 0.19 m --> 19 cm  
    nsat=8;                                                                    % CyGNSS constellation
    resolution=36;                                                             % Km for ease grid converter
    
    %%%%%%%%%%%%%%%%%% VERIFYING OUTPUT DIRECTORIES %%%%%%%%%%%%%%%%%%%%%%%%%%%
    verifydir(CyGoutpath)
    verifydir(CyGfigurepath)
    verifydir(logpath)
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    initdatenum=datenum(initdate,'dd/mm/yyyy');
    enddatenum=datenum(enddate,'dd/mm/yyyy');
    datelist=initdatenum:enddatenum;

    %%%%%%%%%%%%%%%%%%%%% INITIALIZING EMPTY VARIABLES FOR AGGREGATED SINGLE OUTPUT FILE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if aggregate_data:
        daterangechar = [datestr(initdatenum,'yyyymmdd') '-' datestr(enddatenum,'yyyymmdd')]; % date range for aggregated output file
        disp(['% Processing data from ' daterangechar ' and saving in a single output file'])

        agg_SCID=[];                                % CYGNSS sat ID
        agg_SoD=[];                                 % second of the day
        agg_DoY=[];                                 % day of the year
        agg_PRN=[];                                 % PRN --> Prn code = prn -->trasmettitore (1 10 22 etc..)
        agg_SPLAT=[];                               % SP lat on ground
        agg_SPLON=[];                               % SP lon on ground
        agg_THETA=[];                               % incidence angle
        agg_PHI_Initial_sp_az_orbit=[];             % azimuth angle in specular point orbit frame
        agg_GAIN=[];                                % gain of receiver antenna [dBi]
        agg_EIRP=[];                                % EIRP [W]
        agg_SNR=[];                                 % SNR of reflected signal - NOTE: calculated from the uncalibrated DDM in counts [dB]
        agg_PA=[];                                  % peak power
        agg_NF=[];                                  % noise floor
        agg_RXRANGE=[];                             % Rx range [m]
        agg_TXRANGE=[];                             % Tx range [m]
        agg_NST=[];                                 % overall quality
        agg_LF=[];                                  % land flag
        agg_QC=[];                                  % Quality Flag
        agg_DDM_NBRCS=[];                           % NBRCS
        agg_KURTOSIS=[];                            % Kurtosis
        agg_KURTOSIS_DOPP_0=[];                     % Kurtosis zero-doppler
        agg_TE_WIDTH = [];                          % Trailing Edge (Carreno-Luengo 2020)
        agg_REFLECTIVITY_LINEAR=[];                 % Reflectivity
        agg_BRCS=[];                                % added by Hamed to save full ddm
    else
        disp('% Processing each day separately and saving individual output files')
    end

    %%%%%%%%%%%%%%%%%%%%% STARTING THE MAIN LOOP %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    tic
    % % figure;
    for ii=1:length(datelist)     % loop on all the days 
        disp(['% now processing day ' num2str(ii) ' out of ' num2str(length(datelist))])
        datechar=datestr(datelist(ii),'yyyymmdd');
        Year=datechar(1:4);
        d=datetime(datechar,'InputFormat','yyyyMMdd');
        doy=day(d,'dayofyear');
    %%%%%%%%%%%%%%%%%%%%%% CyGNSS data extraction %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        chkCyGNSSfile=dir([CyGinpath 'cyg0*.ddmi.s' datechar '*.nc']);   
        if  ~isempty(chkCyGNSSfile)
            disp('% Extracting CyGNSS data ...')
            [DoY,SoD,SCID,PRN,SPLAT,SPLON,THETA,EIRP,SNR,PHI_Initial_sp_az_orbit, ...
                REFLECTIVITY_LINEAR,KURTOSIS,KURTOSIS_DOPP_0,TE_WIDTH,DDM_NBRCS,PA,QC,NF,LF, BRCS]= ...
                extract_CyGNSS(nsat,datechar,doy,CyGinpath,logpath,lambda,Doppler_bins,savespace,delay_vector,Power_threshold);            
        %%%%%%%%%%%%%%%%%%%%%%%%%%%% SAVING %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if aggregate_data:
                disp('% cat variables from day ' + datechar);
                agg_DoY=cat(1,DoY,dayofyear(:));
                agg_SoD=cat(1,SoD,ts(:));
                agg_SCID=cat(1,SCID,scid(:));
                agg_PRN=cat(1,PRN, prn(:));
                agg_SPLAT=cat(1,SPLAT, sp_lat(:));
                agg_SPLON=cat(1,SPLON, sp_lon(:));
                agg_THETA=cat(1,THETA, theta(:));
                agg_EIRP=cat(1,EIRP, eirp(:));
                agg_SNR=cat(1,SNR, snr(:));
                agg_PHI_Initial_sp_az_orbit=cat(1,PHI_Initial_sp_az_orbit, phi_Initial_sp_az_orbit(:));
                agg_REFLECTIVITY_LINEAR=cat(1,REFLECTIVITY_LINEAR,reflectivity_linear(:));
                agg_KURTOSIS=cat(1,KURTOSIS, Kurtosis(:));
                agg_KURTOSIS_DOPP_0=cat(1,KURTOSIS_DOPP_0, Kurtosis_dopp0(:)); 
                agg_TE_WIDTH=cat(1,TE_WIDTH, TE_width(:)); 
                agg_GAIN=cat(1,GAIN, gain(:));
                agg_DDM_NBRCS=cat(1,DDM_NBRCS, ddm_nbrcs(:)); 
                agg_PA=cat(1,PA, reflectivity_linear(:));
                agg_QC=cat(1,QC, qc(:)); 
                agg_NF=cat(1,NF, nf(:));
                agg_LF=cat(1,LF,lf(:));
                agg_BRCS=cat(3, BRCS, brcs);                                      
                % agg_RXRANGE=cat(1,RXRANGE,rxrange); #TODO: these variables are extracted in extract_CyGNSS function, but then they are not passed to the function output. Ask Hamed why
                % agg_TXRANGE=cat(1,TXRANGE,txrange);
                % agg_NST=cat(1,NST,nst_full);
            else:
                disp('% saving CyGNSS data')
                save([CyGoutpath datechar '_2.mat'], 'Year', 'DoY', 'SoD', 'SCID', ...  % #TODO Why there is "_2" in the filename? Ask Hamed
                    'PRN', 'SPLAT', 'SPLON', 'THETA', 'EIRP', 'SNR', 'PHI_Initial_sp_az_orbit', ...
                    'REFLECTIVITY_LINEAR', 'KURTOSIS', 'KURTOSIS_DOPP_0', 'TE_WIDTH', 'DDM_NBRCS','PA','QC', 'NF','LF', '-v7.3')
            end
        %%%%%%%%%%%%%%%%%%%%% Displaying Output %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % %          scattermap(real(10.*log10(REFLECTIVITY_LINEAR)),SPLAT,SPLON,datechar,-40,0)
    % %          print(gcf,[CyGfigurepath datechar '.png'],'-dpng','-r300')   
        else
            disp('% CyGNSS data files missing for the selected date, output file not saved .... ')
        end      
    end
    %%%%%%%%%%%%%%%%%%%%%%%%% END OF THE MAIN LOOP %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if aggregate_data:
        disp('% Saving aggregated data in a single output file')
        save([CyGoutpath 'CyGNSS_' daterangechar '_2.mat'], 'agg_SCID', 'agg_SoD', 'agg_DoY', ...
            'agg_PRN', 'agg_SPLAT', 'agg_SPLON', 'agg_THETA', 'agg_EIRP', 'agg_SNR', ...
            'agg_PHI_Initial_sp_az_orbit', 'agg_REFLECTIVITY_LINEAR', 'agg_KURTOSIS', ...
            'agg_KURTOSIS_DOPP_0', 'agg_TE_WIDTH', 'agg_DDM_NBRCS','agg_PA','agg_QC', ...
            'agg_NF','agg_LF','agg_BRCS','-v7.3')
    end
    s=duration(0,0,toc);
    close all
    disp(['total duration is ' char(duration(0,0,toc))])
end




















 