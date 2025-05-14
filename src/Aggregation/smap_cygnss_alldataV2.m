
%%code that reads the smap data and cygnss data and maps them accordingly
%%with the help of easeconv grid and later groups them
%Inputs: doy & smap file
% numcols,numrows
%Modis_NDVI is saved in another file

%% reading the smap data
function smap_cygnss_alldataV2(resolution)

if resolution==36
    numcols=964;
    numrows=406;

elseif resolution==25
    numcols=1388;
    numrows=584;
end

directory= uigetdir(pwd, 'Select a folder');
files = dir(fullfile(directory, '*.h5'));
% % Display the names
latitude_n=[];
longitude_n=[];
vegetation_opacity_n=[];
retrieval_qual_flag_n=[];
roughness_coefficient_n=[];
soil_moisture_n=[];
soil_moisture_error_n=[];
albedo_n=[];
vegetation_water_content_n=[];

cygnss_data=load('D:\Hamed\CyGNSS\CyGNSS_V3.0\Extracted_V3.0\CYGNSS_Reflectivity_00_Global_2019_1-31_DATA_MATRIX.mat');%% new version 3.1
%  cygnss_data=load('../Auxiliary_Data/L2OP-SSM/CYGNSS-V3.1/CYGNSS_Reflectivity_00_Global_2019_DATA_MATRIX-001.mat');
doy_all=cygnss_data.DoY;
% doy_all=doy_all((doy_all==91:120));
cygnss_reflectivity_n=[];
cygnss_kurtosis_n=[];
cygnss_kurtosisdopp0_n=[];
cygnss_snr_n=[];
cygnss_theta_n=[];
cygnss_ddm_nbrcs_n=[];
doy_n=[];
cygnss_eirp_n=[];
cygnss_nf_n=[];
cygnss_pa_n=[];
cygnss_phi_n=[];
cygnss_qc_n=[];
cygnss_dc_n=[];
TE_WIDTH_n = [];
SSr_n=[];
SSp_n=[];


for i=1:length(files)
    filename(i,:)=string(files(i).name);
    % [file,path]=uigetfile('*.h5','Select the SMAP file','MultiSelect','on');%inputs
    filesplit=strsplit(string(filename(i)),'_');
    d=(filesplit{1,5});
    filename1=fullfile(directory,'\',filename(i));

    latitude_1=h5read(filename1,'/Soil_Moisture_Retrieval_Data_AM/latitude');

    longitude_1=h5read(filename1,'/Soil_Moisture_Retrieval_Data_AM/longitude');
    %%%%%%%%%%%%%%%%%%
    retrieval_qual_flag_1=h5read(filename1,'/Soil_Moisture_Retrieval_Data_AM/retrieval_qual_flag');
%%%%%%%%%%%%%%%%%% 
% %     retrieval_qual_flag_1(:,:,1) = h5read(filename1,'/Soil_Moisture_Retrieval_Data_AM/retrieval_qual_flag');
% %     retrieval_qual_flag_c2(:,:,1)=retrieval_qual_flag_1(:,:,1)';
% % 
% %     retrieval_qual_flag_1(:,:,2)=h5read(filename1,'/Soil_Moisture_Retrieval_Data_PM/retrieval_qual_flag_dca_pm');
% %     retrieval_qual_flag_c2(:,:,2)=retrieval_qual_flag_1(:,:,2)';
%%%%%%%%%%%%%%%%%%


    soil_moisture_1(:,:,1) = h5read(filename1,'/Soil_Moisture_Retrieval_Data_AM/soil_moisture');
    soil_moisture_c2(:,:,1)=soil_moisture_1(:,:,1)';%added on 1/3/2023

    soil_moisture_1(:,:,2)=h5read(filename1,'/Soil_Moisture_Retrieval_Data_PM/soil_moisture_dca_pm');
    soil_moisture_c2(:,:,2)=soil_moisture_1(:,:,2)';%added on 1/3/2023

    vegetation_opacity_1(:,:,1)=h5read(filename1,'/Soil_Moisture_Retrieval_Data_AM/vegetation_opacity');
    vegetation_opacity_1(:,:,2)=h5read(filename1,'/Soil_Moisture_Retrieval_Data_PM/vegetation_opacity_dca_pm');
    vegetation_water_content_1(:,:,1)=h5read(filename1,'/Soil_Moisture_Retrieval_Data_AM/vegetation_water_content');
    vegetation_water_content_1(:,:,2)=h5read(filename1,'/Soil_Moisture_Retrieval_Data_PM/vegetation_water_content_pm');
    roughness_coefficient_1=h5read(filename1,'/Soil_Moisture_Retrieval_Data_AM/roughness_coefficient');
    albedo_1=h5read(filename1,'/Soil_Moisture_Retrieval_Data_AM/albedo');
    soil_moisture_error_1=h5read(filename1,'/Soil_Moisture_Retrieval_Data_AM/soil_moisture_error');

    if  i <= length(files)-1 && i ~= 1

        filename_1=fullfile(directory,'\',files(i-1).name);
        filename_3=fullfile(directory,'\',files(i+1).name); % to be added
        if exist(filename_1) && exist(filename_3)
            vegetation_opacity_1(:,:,1)=h5read(filename_1,'/Soil_Moisture_Retrieval_Data_AM/vegetation_opacity');
            vegetation_opacity_1(:,:,2)=h5read(filename_1,'/Soil_Moisture_Retrieval_Data_PM/vegetation_opacity_dca_pm');
            vegetation_opacity_h(:,:,1)=computemean_smap(vegetation_opacity_1,3);
            vegetation_opacity_2(:,:,1)=h5read(filename1,'/Soil_Moisture_Retrieval_Data_AM/vegetation_opacity');
            vegetation_opacity_2(:,:,2)=h5read(filename1,'/Soil_Moisture_Retrieval_Data_PM/vegetation_opacity_dca_pm');
            vegetation_opacity_h(:,:,2)=computemean_smap(vegetation_opacity_2,3);
            vegetation_opacity_3(:,:,1)=h5read(filename_3,'/Soil_Moisture_Retrieval_Data_AM/vegetation_opacity');
            vegetation_opacity_3(:,:,2)=h5read(filename_3,'/Soil_Moisture_Retrieval_Data_PM/vegetation_opacity_dca_pm');
            vegetation_opacity_h(:,:,3)=computemean_smap(vegetation_opacity_3,3);
            vegetation_opacity_m=computemean_smap(vegetation_opacity_h,3);
            vegetation_water_content_1(:,:,1)=h5read(filename_1,'/Soil_Moisture_Retrieval_Data_AM/vegetation_water_content');
            vegetation_water_content_1(:,:,2)=h5read(filename_1,'/Soil_Moisture_Retrieval_Data_PM/vegetation_water_content_pm');
            vegetation_water_content_h(:,:,1)=computemean_smap(vegetation_water_content_1,3);
            vegetation_water_content_2(:,:,1)=h5read(filename1,'/Soil_Moisture_Retrieval_Data_AM/vegetation_water_content');
            vegetation_water_content_2(:,:,2)=h5read(filename1,'/Soil_Moisture_Retrieval_Data_PM/vegetation_water_content_pm');
            vegetation_water_content_h(:,:,2)=computemean_smap(vegetation_water_content_2,3);
            vegetation_water_content_3(:,:,1)=h5read(filename_3,'/Soil_Moisture_Retrieval_Data_AM/vegetation_water_content');
            vegetation_water_content_3(:,:,2)=h5read(filename_3,'/Soil_Moisture_Retrieval_Data_PM/vegetation_water_content_pm');
            vegetation_water_content_h(:,:,3)=computemean_smap(vegetation_water_content_3,3);
            vegetation_water_content_m=computemean_smap(vegetation_water_content_h,3);
        else
            vegetation_opacity_m(:,:,1)=computemean_smap(vegetation_opacity_1,3);
            vegetation_water_content_m(:,:,1)=computemean_smap(vegetation_water_content_1,3);
        end

    elseif i==1 || i==length(files)
        vegetation_opacity_m(:,:,1)=computemean_smap(vegetation_opacity_1,3);
        vegetation_water_content_m(:,:,1)=computemean_smap(vegetation_water_content_1,3);
    end
    if resolution ==36
        roughness_coefficient(:,:,1)=roughness_coefficient_1;
        latitude(:,:,1)=latitude_1;
        longitude(:,:,1)=longitude_1;
        albedo(:,:,1)=albedo_1;
        soil_moisture_error(:,:,1)=soil_moisture_error_1;
        soil_moisture=computemean_smap(soil_moisture_1,3);
        retrieval_qual_flag(:,:,1)=retrieval_qual_flag_1;
        vegetation_opacity(:,:,1)=vegetation_opacity_m;
        vegetation_water_content(:,:,1)=vegetation_water_content_m;
    elseif resolution==25
        %         latitude_1(latitude_1==-9999)=NaN;
        %         longitude_1(longitude_1==-9999)=NaN;
        %         latitude=cast(latitude_1(:),'double');
        %         longitude=cast(longitude_1(:),'double');
        %
        %         roughness_coefficient_1(roughness_coefficient_1==-9999)=NaN;
        %         albedo_1(albedo_1==-9999)=NaN;
        %         soil_moisture_error_1(soil_moisture_error_1==-9999)=NaN;
        %         retrieval_qual_flag_1(retrieval_qual_flag_1==-9999)=NaN;
        %         vegetation_opacity_m(vegetation_opacity_m==-9999)=NaN;
        %         vegetation_water_content_m(vegetation_water_content_m==-9999)=NaN;
        %         [smap_c,smap_r]=easeconv_grid(latitude,longitude,resolution);
        %         smap_r(isnan(smap_r))=1;
        %         smap_c(isnan(smap_c))=1;
        %         roughness_coefficient(:,:,1)=accumarray([(smap_r),(smap_c)],(roughness_coefficient_1(:)),[],@computemean,single(-9999));
        %         albedo(:,:,1)=accumarray([smap_r,smap_c],albedo_1(:),[],@computemean,single(-9999));
        %         soil_moisture_error(:,:,1)=accumarray([smap_r,smap_c],soil_moisture_error_1(:),[],@computemean,single(-9999));
        %         soil_moisture=computemean_smap(soil_moisture_1,3);
        %         soil_moisture(soil_moisture==-9999)=NaN;
        %         soil_moisture=accumarray([smap_r,smap_c],soil_moisture(:),[],@computemean,single(-9999));
        %         retrieval_qual_flag(:,:,1)=accumarray([smap_r,smap_c],retrieval_qual_flag_1(:),[],@computemean,-9999);
        %         vegetation_opacity(:,:,1)=accumarray([smap_r,smap_c],vegetation_opacity_m(:),[],@computemean,single(-9999));
        %         vegetation_water_content(:,:,1)=accumarray([smap_r,smap_c],vegetation_water_content_m(:),[],@computemean,single(-9999));
%         roughness_coefficient(:,:,1)=imresize(roughness_coefficient_1,[numrows,numcols],'bilinear');
%         latitude(:,:,1)=imresize(latitude_1,[numrows,numcols],'bilinear');
%         longitude(:,:,1)=imresize(longitude_1,[numrows,numcols],'bilinear');
%         albedo(:,:,1)=imresize(albedo_1,[numrows,numcols],'bilinear');
%         soil_moisture_error(:,:,1)=imresize(soil_moisture_error_1,[numrows,numcols],'bilinear');
%         soil_moisture=computemean_smap(soil_moisture_1,3);
%         soil_moisture=imresize(soil_moisture,[numrows,numcols],'bilinear');
%         retrieval_qual_flag(:,:,1)=imresize(retrieval_qual_flag_1,[numrows,numcols],'bilinear');
%         vegetation_opacity(:,:,1)=imresize(vegetation_opacity_m,[numrows,numcols],'bilinear');
%         vegetation_water_content(:,:,1)=imresize(vegetation_water_content_m,[numrows,numcols],'bilinear');


        %%removing -9999 from smap data before resizing for 25km res
        latitude_c=latitude_1;latitude_c(latitude_c==-9999)=NaN;latitude_c=latitude_c';
        longitude_c=longitude_1;longitude_c(longitude_c==-9999)=NaN;longitude_c=longitude_c';
        roughness_coefficient_c=roughness_coefficient_1;roughness_coefficient_c(roughness_coefficient_c==-9999)=NaN; roughness_coefficient_c=roughness_coefficient_c';
        vegetation_opacity_c=vegetation_opacity_m;vegetation_opacity_c(vegetation_opacity_c==-9999)=NaN; vegetation_opacity_c = vegetation_opacity_c';
        soil_moisture_c=soil_moisture_c2;soil_moisture_c(soil_moisture_c==-9999)=NaN; %soil_moisture_c(:,:,1)=soil_moisture_c(:,:,1)';soil_moisture_c(:,:,2)=soil_moisture_c(:,:,2)';
        retrieval_qual_flag_c=retrieval_qual_flag_1;retrieval_qual_flag_c(retrieval_qual_flag_c==-9999)=NaN; retrieval_qual_flag_c=retrieval_qual_flag_c';
        albedo_c=albedo_1;albedo_c(albedo_c==-9999)=NaN; albedo_c=albedo_c';
        soil_moisture_error_c=soil_moisture_error_1;soil_moisture_error_c(soil_moisture_error_c==-9999)=NaN; soil_moisture_error_c=soil_moisture_error_c';
        vegetation_water_content_c=vegetation_water_content_m;vegetation_water_content_c(vegetation_water_content_c==-9999)=NaN; vegetation_water_content_c=vegetation_water_content_c';


        %%resizing for 25km res
        roughness_coefficient(:,:,1)=imresize(roughness_coefficient_c,[numrows,numcols],'bilinear');
        latitude(:,:,1)=imresize(latitude_c,[numrows,numcols],'bilinear');
        longitude(:,:,1)=imresize(longitude_c,[numrows,numcols],'bilinear');
        albedo(:,:,1)=imresize(albedo_c,[numrows,numcols],'bilinear');
        soil_moisture_error(:,:,1)=imresize(soil_moisture_error_c,[numrows,numcols],'bilinear');
        soil_moisture=computemean_smap(soil_moisture_c,3);
        soil_moisture=imresize(soil_moisture,[numrows,numcols],'bilinear');
        retrieval_qual_flag(:,:,1)=imresize(retrieval_qual_flag_c,[numrows,numcols],'bilinear');
        vegetation_opacity(:,:,1)=imresize(vegetation_opacity_c,[numrows,numcols],'bilinear');
        vegetation_water_content(:,:,1)=imresize(vegetation_water_content_c,[numrows,numcols],'bilinear');

    end


%     latitude_c=latitude(:);latitude_c(latitude_c==-9999)=NaN;
%     longitude_c=longitude(:);longitude_c(longitude_c==-9999)=NaN;
%     roughness_coefficient_c=roughness_coefficient(:);roughness_coefficient_c(roughness_coefficient_c==-9999)=NaN;
%     vegetation_opacity_c=vegetation_opacity(:);vegetation_opacity_c(vegetation_opacity_c==-9999)=NaN;
%     soil_moisture_c=soil_moisture(:);soil_moisture_c(soil_moisture_c==-9999)=NaN;
%     retrieval_qual_flag_c=retrieval_qual_flag(:);retrieval_qual_flag_c(retrieval_qual_flag_c==-9999)=NaN;
%     albedo_c=albedo(:);albedo_c(albedo_c==-9999)=NaN;
%     soil_moisture_error_c=soil_moisture_error(:);soil_moisture_error_c(soil_moisture_error_c==-9999)=NaN;
%     vegetation_water_content_c=vegetation_water_content(:);vegetation_water_content_c(vegetation_water_content_c==-9999)=NaN;

    latitude_n=[latitude_n; latitude(:)];
    longitude_n=[longitude_n;longitude(:)];
    roughness_coefficient_n=[roughness_coefficient_n;roughness_coefficient(:)];
    vegetation_opacity_n=[vegetation_opacity_n;vegetation_opacity(:)];
    soil_moisture_n=[soil_moisture_n;soil_moisture(:)];
    retrieval_qual_flag_n=[retrieval_qual_flag_n;retrieval_qual_flag(:)];
    albedo_n=[albedo_n;albedo(:)];
    soil_moisture_error_n=[soil_moisture_error_n;soil_moisture_error(:)];
    vegetation_water_content_n=[vegetation_water_content_n;vegetation_water_content(:)];
    datetosmap=datetime(d,'InputFormat','yyyyMMdd ','Format','yyyy.MM.dd');
    doy_s=day(datetosmap,'dayofyear');

    index=find(doy_s==doy_all);

    splat=cygnss_data.SPLAT((index));
    splon=cygnss_data.SPLON(index);
    reflectivity_linear=cygnss_data.REFLECTIVITY_LINEAR_PA(index);
    KURTOSIS_DOPP_0=cygnss_data.KURTOSIS_DOPP_0(index);
    KURTOSIS=cygnss_data.KURTOSIS(index);
    SNR=cygnss_data.SNR(index);
    theta=cygnss_data.THETA(index);
    DDM_NBRCS=cygnss_data.DDM_NBRCS(index);
    EIRP=cygnss_data.EIRP(index);
    NF=cygnss_data.NF(index);
    PA=cygnss_data.PA(index);
    PHI=cygnss_data.PHI_Initial_sp_az_orbit(index);
    QC=cygnss_data.QC(index);
    tewidth=cygnss_data.TE_WIDTH(index);
    cygnssDC=cygnss_data.IndexDC(index);
% %     ssr=cygnss_data.SS_r(index);
% %     ssp=cygnss_data.SS_p(index);    


    %% longitude corrections for griddung 36km.
    if resolution == 36
        splon(find(splon==180))=179.66;
        splon(find(splon>180))=splon(find(splon>180))-360;
        [cygnss_c,cygnss_r]=easeconv_grid(splat,splon,resolution);
        cygnss_ref_linear_mean=accumarray([cygnss_c,cygnss_r],(reflectivity_linear),[],@computemean,-9999);
        cygnss_kurtosisdopp0_mean=accumarray([cygnss_c,cygnss_r],KURTOSIS_DOPP_0,[],@computemean,-9999);
        cygnss_kurtosis_mean=accumarray([cygnss_c,cygnss_r],KURTOSIS,[],@computemean,-9999);
        cygnss_snr_mean=accumarray([cygnss_c,cygnss_r],SNR,[],@computemean,-9999);
        cygnss_theta_mean=accumarray([cygnss_c,cygnss_r],theta,[],@computemean,-9999);
        cygnss_ddm_nbrcs_mean=accumarray([cygnss_c,cygnss_r],DDM_NBRCS,[],@computemean,-9999);
        cygnss_eirp_mean=accumarray([cygnss_c,cygnss_r],EIRP,[],@computemean,-9999);
        cygnss_nf_mean=accumarray([cygnss_c,cygnss_r],NF,[],@computemean,-9999);
        cygnss_pa_mean=accumarray([cygnss_c,cygnss_r],PA,[],@computemean,-9999);
        cygnss_phi_mean=accumarray([cygnss_c,cygnss_r],PHI,[],@computemean,-9999);
        cygnss_qc_mean=accumarray([cygnss_c,cygnss_r],QC,[],@computeFlag_mode_bitWise,-9999);
    elseif resolution ==25
        splon(find(splon==180))=179.66;
        splon(find(splon>180))=splon(find(splon>180))-360;
        [cygnss_c,cygnss_r]=easeconv_grid(splat,splon,resolution);
        cygnss_ref_linear_mean=accumarray([cygnss_r cygnss_c],(reflectivity_linear),[],@computemean,-9999);
        cygnss_kurtosisdopp0_mean=accumarray([cygnss_r cygnss_c],KURTOSIS_DOPP_0,[],@computemean,-9999);
        cygnss_kurtosis_mean=accumarray([cygnss_r cygnss_c],KURTOSIS,[],@computemean,-9999);
        cygnss_snr_mean=accumarray([cygnss_r cygnss_c],SNR,[],@computemean,-9999);
        cygnss_theta_mean=accumarray([cygnss_r cygnss_c],theta,[],@computemean,-9999);
        cygnss_ddm_nbrcs_mean=accumarray([cygnss_r cygnss_c],DDM_NBRCS,[],@computemean,-9999);
        cygnss_eirp_mean=accumarray([cygnss_r cygnss_c],EIRP,[],@computemean,-9999);
        cygnss_nf_mean=accumarray([cygnss_r cygnss_c],NF,[],@computemean,-9999);
        cygnss_pa_mean=accumarray([cygnss_r cygnss_c],PA,[],@computemean,-9999);
        cygnss_phi_mean=accumarray([cygnss_r cygnss_c],PHI,[],@computemean,-9999);
        cygnss_qc_mean=accumarray([cygnss_r,cygnss_c],QC,[],@computeFlag_mode_bitWise,-9999);

% %         ssr_mean=accumarray([cygnss_r cygnss_c],ssr,[],@computemean,-9999);
% %         ssp_mean=accumarray([cygnss_r cygnss_c],ssp,[],@computemean,-9999);        
        tewidth_mean=accumarray([cygnss_r cygnss_c],tewidth,[],@computemean,-9999);
        cygnssDC_mean=accumarray([cygnss_r cygnss_c],cygnssDC,[],@computemean,-9999);

        
    end

    %% mapping the values with grid column row
    %     cygnss_ref_linear_mean=accumarray([cygnss_r cygnss_c],(reflectivity_linear),[],@computemean,-9999);
    %     cygnss_kurtosisdopp0_mean=accumarray([cygnss_r cygnss_c],KURTOSIS_DOPP_0,[],@computemean,-9999);
    %     cygnss_kurtosis_mean=accumarray([cygnss_r cygnss_c],KURTOSIS,[],@computemean,-9999);
    %     cygnss_snr_mean=accumarray([cygnss_r cygnss_c],SNR,[],@computemean,-9999);
    %     cygnss_theta_mean=accumarray([cygnss_r cygnss_c],theta,[],@computemean,-9999);
    %     cygnss_ddm_nbrcs_mean=accumarray([cygnss_r cygnss_c],DDM_NBRCS,[],@computemean,-9999);
    %     cygnss_eirp_mean=accumarray([cygnss_r cygnss_c],EIRP,[],@computemean,-9999);
    %     cygnss_nf_mean=accumarray([cygnss_r cygnss_c],NF,[],@computemean,-9999);
    %     cygnss_pa_mean=accumarray([cygnss_r cygnss_c],PA,[],@computemean,-9999);
    %     cygnss_phi_mean=accumarray([cygnss_r cygnss_c],PHI,[],@computemean,-9999);
    %     %     cygnss_dc_mean=accumarray([cygnss_c cygnss_r],DC,[],@computemean,-9999);

    %% aligning the data similar to the smap grids
    [a,b]=size(cygnss_ref_linear_mean);
    %     [cygnss_reflectivity,cygnss_kurtosisdopp0,cygnss_kurtosis,cygnss_snr,cygnss_theta,cygnss_ddm_nbrcs,cygnss_eirp,cygnss_nf,cygnss_pa,cygnss_phi,cygnss_dc]=deal(NaN(size(soil_moisture)));%withDC
    [cygnssDC_n,te_with_n,cygnss_reflectivity,cygnss_kurtosisdopp0,cygnss_kurtosis,cygnss_snr,cygnss_theta,cygnss_ddm_nbrcs,cygnss_eirp,cygnss_nf,cygnss_pa,cygnss_phi, cygnss_qc]=deal(NaN(size(soil_moisture)));% no index dc
    cygnss_reflectivity(1:a,1:b)=cygnss_ref_linear_mean; cygnss_reflectivity((cygnss_reflectivity(:)==-9999))=NaN; cygnss_reflectivity=cygnss_reflectivity(:);
    cygnss_kurtosisdopp0(1:a,1:b)=cygnss_kurtosisdopp0_mean; cygnss_kurtosisdopp0((cygnss_kurtosisdopp0(:)==-9999))=NaN;cygnss_kurtosisdopp0=cygnss_kurtosisdopp0(:);
    cygnss_kurtosis(1:a,1:b)=cygnss_kurtosis_mean;cygnss_kurtosis((cygnss_kurtosis(:)==-9999))=NaN;cygnss_kurtosis=cygnss_kurtosis(:);
    cygnss_snr(1:a,1:b)=cygnss_snr_mean;cygnss_snr((cygnss_snr(:)==-9999))=NaN;cygnss_snr=cygnss_snr(:);
    cygnss_theta(1:a,1:b)=cygnss_theta_mean;cygnss_theta((cygnss_theta(:)==-9999))=NaN;cygnss_theta=cygnss_theta(:);
    cygnss_ddm_nbrcs(1:a,1:b)=cygnss_ddm_nbrcs_mean;cygnss_ddm_nbrcs((cygnss_ddm_nbrcs(:)==-9999))=NaN;cygnss_ddm_nbrcs=cygnss_ddm_nbrcs(:);
    cygnss_eirp(1:a,1:b)=cygnss_eirp_mean;cygnss_eirp((cygnss_eirp(:)==-9999))=NaN;cygnss_eirp=cygnss_eirp(:);
    cygnss_nf(1:a,1:b)=cygnss_nf_mean;cygnss_nf(cygnss_nf(:)==-9999)=NaN;cygnss_nf=cygnss_nf(:);
    cygnss_pa(1:a,1:b)=cygnss_pa_mean;cygnss_pa(cygnss_pa(:)==-9999)=NaN;cygnss_pa=cygnss_pa(:);
    cygnss_phi(1:a,1:b)=cygnss_phi_mean;cygnss_phi(cygnss_phi(:)==-9999)=NaN;cygnss_phi=cygnss_phi(:);
    cygnss_qc(1:a,1:b)=cygnss_qc_mean;cygnss_qc(cygnss_qc(:)==-9999)=NaN;cygnss_qc=cygnss_qc(:);

% %     ssrn(1:a,1:b)=ssr_mean;ssrn(ssrn(:)==-9999)=NaN;ssrn=ssrn(:);
% %     sspn(1:a,1:b)=ssp_mean;sspn(sspn(:)==-9999)=NaN;sspn=sspn(:);
    te_with_n(1:a,1:b)=tewidth_mean;te_with_n(te_with_n(:)==-9999)=NaN;te_with_n=te_with_n(:);
    cygnssDC_n(1:a,1:b)=cygnssDC_mean;cygnssDC_n(cygnssDC_n(:)==-9999)=NaN;cygnssDC_n=cygnssDC_n(:);    
    %     cygnss_dc(1:a,1:b)=cygnss_dc_mean;cygnss_dc(cygnss_dc(:)==-9999)=NaN;cygnss_dc=cygnss_dc(:);

    cygnss_reflectivity_n=[cygnss_reflectivity_n;cygnss_reflectivity];
    cygnss_kurtosis_n=[cygnss_kurtosis_n;cygnss_kurtosis];
    cygnss_kurtosisdopp0_n=[cygnss_kurtosisdopp0_n;cygnss_kurtosisdopp0];
    cygnss_snr_n=[cygnss_snr_n;cygnss_snr];
    cygnss_theta_n=[cygnss_theta_n;cygnss_theta];
    cygnss_ddm_nbrcs_n=[cygnss_ddm_nbrcs_n;cygnss_ddm_nbrcs];
    doy_c=repmat(doy_s,size(cygnss_kurtosisdopp0));
    doy_n=[doy_n;doy_c];
    cygnss_eirp_n=[cygnss_eirp_n;cygnss_eirp];
    cygnss_nf_n=[cygnss_nf_n;cygnss_nf];
    cygnss_pa_n=[cygnss_pa_n;cygnss_pa];
    cygnss_phi_n=[cygnss_phi_n;cygnss_phi];

    cygnss_qc_n=[cygnss_qc_n;cygnss_qc];
    SSr_n=[SSr_n;ssrn];
    SSp_n=[SSp_n;sspn];
    TE_WIDTH_n=[TE_WIDTH_n;te_with_n];
    cygnss_dc_n=[cygnss_dc_n,cygnssDC_n];
    %     cygnss_dc_n=[cygnss_dc_n,cygnss_dc];

end
  clearvars -except resolution TE_WIDTH_n SSp_n SSr_n cygnss_qc_n cygnss_dc_n soil_moisture_error_n vegetation_water_content_n albedo_n cygnss_eirp_n cygnss_nf_n cygnss_pa_n cygnss_phi_n cygnss_ddm_nbrcs_n cygnss_theta_n cygnss_snr_n doy_n cygnss_kurtosisdopp0_n cygnss_kurtosis_n cygnss_reflectivity_n latitude_n longitude_n vegetation_opacity_n retrieval_qual_flag_n roughness_coefficient_n soil_moisture_n

%%%%%%%%%%%%%% Masking to get all cygnss data %%%%%%%%%%%%%%%
nDyas = 2;
mask = load('D:\Hamed\Combined_dataset\2018-2019\mask.mat');
mask = repmat(mask.mask(:),nDyas,1);


cygnss_reflectivity_a=cygnss_reflectivity_n;
cygnss_kurtosis_a=cygnss_kurtosis_n;
cygnss_kurtosisdopp0_a=cygnss_kurtosisdopp0_n;
cygnss_snr_a=cygnss_snr_n;
cygnss_theta_a=cygnss_theta_n;
cygnss_ddm_nbrcs_a=cygnss_ddm_nbrcs_n;
cygnss_eirp_a=cygnss_eirp_n;
cygnss_nf_a=cygnss_nf_n;
cygnss_pa_a=cygnss_pa_n;
cygnss_phi_a=cygnss_phi_n;
cygnss_qc_a=cygnss_qc_n;
SSr_a = SSr_n;
SSp_a = SSp_n;
TE_WIDTH_a = TE_WIDTH_n;
cygnss_dc_a = cygnss_dc_n;

for i=1:size(mask)
    if isnan(mask(i))
        cygnss_reflectivity_a(i)=NaN;
        cygnss_kurtosis_a(i)=NaN;
        cygnss_kurtosisdopp0_a(i)=NaN;
        cygnss_snr_a(i)=NaN;
        cygnss_theta_a(i)=NaN;
        cygnss_ddm_nbrcs_a(i)=NaN;
        cygnss_eirp_a(i)=NaN;
        cygnss_nf_a(i)=NaN;
        cygnss_pa_a(i)=NaN;
        cygnss_phi_a(i)=NaN;
        cygnss_qc_a(i)=NaN;
        SSr_a(i) = NaN;
        SSp_a(i) = NaN;
        TE_WIDTH_a(i) = NaN;
        cygnss_dc_a(i) = NaN;        
    end
end
cygnss_reflectivity_all = cygnss_reflectivity_a(:);
cygnss_kurtosis_all = cygnss_kurtosis_a(:);
cygnss_kurtosisdopp0_all = cygnss_kurtosisdopp0_a(:);
cygnss_snr_all = cygnss_snr_a(:);
cygnss_theta_all = cygnss_theta_a(:);
cygnss_ddm_nbrcs_all = cygnss_ddm_nbrcs_a(:);
cygnss_eirp_all = cygnss_eirp_a(:);
cygnss_nf_all = cygnss_nf_a(:);
cygnss_pa_all = cygnss_pa_a(:);
cygnss_phi_all = cygnss_phi_a(:);
cygnss_qc_all = cygnss_qc_a(:);
SSr_all =  SSr_a(:);
SSp_all =  SSr_a(:);
TE_WIDTH_all =  TE_WIDTH_a(:);
cygnss_dc_all = cygnss_dc_a(:);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% % for i=1:size(vegetation_water_content_n)
% %     if isnan(soil_moisture_n(i))
% %         cygnss_reflectivity_n(i)=NaN;
% %         cygnss_kurtosis_n(i)=NaN;
% %         cygnss_kurtosisdopp0_n(i)=NaN;
% %         cygnss_snr_n(i)=NaN;
% %         cygnss_theta_n(i)=NaN;
% %         cygnss_ddm_nbrcs_n(i)=NaN;
% %         cygnss_eirp_n(i)=NaN;
% %         cygnss_nf_n(i)=NaN;
% %         cygnss_pa_n(i)=NaN;
% %         cygnss_phi_n(i)=NaN;
% %         cygnss_qc_n(i)=NaN;
% %         Modis_NDVI_n(i)=NaN;
% % 
% %                     %cygnss_dc_n(i)=NaN;
% %     end
% % end
%% arranging the values

% % cygnss_reflectivity=cygnss_reflectivity_n(:);
% % cygnss_kurtosis=cygnss_kurtosis_n(:);
% % cygnss_kurtosisdopp0=cygnss_kurtosisdopp0_n(:);
% % cygnss_snr=cygnss_snr_n(:);
% % cygnss_theta=cygnss_theta_n(:);
% % cygnss_ddm_nbrcs=cygnss_ddm_nbrcs_n(:);
% % cygnss_eirp=cygnss_eirp_n(:);
% % cygnss_nf=cygnss_nf_n(:);
% % cygnss_pa=cygnss_pa_n(:);
% % cygnss_phi=cygnss_phi_n(:);
% % cygnss_qc=cygnss_qc_n(:);
smap_soilmoisture=soil_moisture_n(:);
smap_vo=vegetation_opacity_n(:);
smap_rc=roughness_coefficient_n(:);
smap_rf=retrieval_qual_flag_n(:);
smap_smerror=soil_moisture_error_n(:);
smap_vwc=vegetation_water_content_n(:);
doy=doy_n(:);
latitude=latitude_n(:);
longitude=longitude_n(:);
% % Modis_NDVI_new=Modis_NDVI_n(:);
% cygnss_dc=cygnss_dc_n(:);

 clearvars -except resolution cygnss_dc_all TE_WIDTH_all SSr_all SSp_all cygnss_qc cygnss_qc_all cygnss_reflectivity cygnss_kurtosisdopp0 cygnss_kurtosis cygnss_snr cygnss_theta cygnss_ddm_nbrcs cygnss_eirp cygnss_nf cygnss_pa cygnss_phi smap_soilmoisture smap_vo smap_rc smap_rf smap_smerror smap_vwc doy latitude longitude cygnss_reflectivity_all cygnss_kurtosisdopp0_all cygnss_kurtosis_all cygnss_snr_all cygnss_theta_all cygnss_ddm_nbrcs_all cygnss_eirp_all cygnss_nf_all cygnss_pa_all cygnss_phi_all
year='2019_333-365';
resolution=num2str(resolution);
name=['collocateddata' '_' year '_' resolution '.mat'];
save(name,'resolution', 'cygnss_qc_all', 'smap_smerror', 'smap_vwc', 'smap_soilmoisture','smap_vo','smap_rc','smap_rf','doy','latitude','longitude', 'cygnss_reflectivity_all', 'cygnss_kurtosisdopp0_all', 'cygnss_kurtosis_all', 'cygnss_snr_all', 'cygnss_theta_all', 'cygnss_ddm_nbrcs_all', 'cygnss_eirp_all', 'cygnss_nf_all', 'cygnss_pa_all', 'cygnss_phi_all', 'cygnss_dc_all', 'TE_WIDTH_all', 'SSr_all', 'SSp_all');
% save('workspace_mayapril2019_v3.0.mat','cygnss_dc','smap_smerror','smap_vwc','cygnss_eirp','cygnss_nf','cygnss_pa','cygnss_phi','cygnss_ddm_nbrcs','cygnss_theta','cygnss_snr','cygnss_reflectivity','cygnss_kurtosis','cygnss_kurtosisdopp0','smap_soilmoisture','smap_vo','smap_rc','smap_rf','doy','latitude','longitude');
end