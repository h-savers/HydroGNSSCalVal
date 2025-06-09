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
             disp('% saving CyGNSS data')
             save([CyGoutpath datechar '_2.mat'], 'Year', 'DoY', 'SoD', 'SCID', ...
                 'PRN', 'SPLAT', 'SPLON', 'THETA', 'EIRP', 'SNR', 'PHI_Initial_sp_az_orbit', ...
                 'REFLECTIVITY_LINEAR', 'KURTOSIS', 'KURTOSIS_DOPP_0', 'TE_WIDTH', 'DDM_NBRCS','PA','QC', 'NF','LF', '-v7.3')
         
         %%%%%%%%%%%%%%%%%%%%% Displaying Output %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % %          scattermap(real(10.*log10(REFLECTIVITY_LINEAR)),SPLAT,SPLON,datechar,-40,0)
    % %          print(gcf,[CyGfigurepath datechar '.png'],'-dpng','-r300')   
         else
             disp('% CyGNSS data files missing for the selected date, output file not saved .... ')
         end      
     end
     s=duration(0,0,toc);
     close all
     disp(['total duration is ' char(duration(0,0,toc))])
end




















 