function [PEK_hourly_exposure, PEK_PM25_in_hour, PEK_PM10_in_hour, PEK_O3_in_hour, PEK_NO2_in_hour] = f_PEK(dateInput,data_path)

% dateInput = 20250120;

PEK = readtable(data_path);
PEK_hourly_exposure =zeros(24,1);
PEK_PM25_in_hour = zeros(24,1);
PEK_PM10_in_hour = zeros(24,1);
PEK_O3_in_hour = zeros(24,1);
PEK_NO2_in_hour = zeros(24,1);

for i = 2:height(PEK)
    PEK_DateTime = PEK.DateTime(i);
    PEK_Year = year(PEK_DateTime);       
    PEK_Month = month(PEK_DateTime);    
    PEK_Day = day(PEK_DateTime);   
    PEK_Hour = hour(PEK_DateTime);
    % Combining the extracted digits
    PEK_Date=PEK_Year*10000+PEK_Month*100+PEK_Day;

    if PEK_Date == dateInput
        % Check for blank cells for NO2
        if isnan(PEK.NO2(i))
            %originalIndex = originalIndex - 1;  % Decrement the index
            PEK.NO2(i) = PEK.NO2(i-1);
            PEK_conc_NO2 = PEK.NO2(i);
        else 
            PEK_conc_NO2 = PEK.NO2(i);
        end
    
        % Retrieve and check O3
        if isnan(PEK.O3(i))
            %originalIndex = originalIndex - 1;  % Decrement the index
            PEK.O3(i) = PEK.O3(i-1);
            PEK_conc_O3 = PEK.O3(i);
        else
            PEK_conc_O3 = PEK.O3(i);
        end
    
        % Retrieve and check PM10
        if isnan(PEK.PM10(i))
            %originalIndex = originalIndex - 1;  % Decrement the index
            PEK.PM10(i) = PEK.PM10(i-1);
            PEK_conc_PM10 = PEK.PM10(i);
        else
            PEK_conc_PM10 = PEK.PM10(i);
        end
    
        % Retrieve and check PM2.5
        if isnan(PEK.PM25(i))
            %originalIndex = originalIndex - 1;  % Decrement the index
            PEK.PM25(i) = PEK.PM25(i-1);
            PEK_conc_PM2_5 = PEK.PM25(i);
        else
            PEK_conc_PM2_5 = PEK.PM25(i);
        end    
        
    % Convert concentrations to %AR Indoor
        beta_NO2 = 0.0004462559;
        % beta_SO2 = 0.0001393235;
        beta_O3 = 0.0005116328;
        beta_PM10 = 0.0002821751;
        beta_PM2_5 = 0.0002180567;
        
        PEK_conc_PM = max(PEK_conc_PM2_5, PEK_conc_PM10);
    
        if PEK_conc_PM == PEK_conc_PM2_5
            beta_PM = beta_PM2_5;
        else 
            beta_PM = beta_PM10;
        end
        
        PEK_AR_NO2 = exp(beta_NO2*PEK_conc_NO2)-1;
        % PEK_AR_SO2 = exp(beta_SO2*PEK_conc_SO2)-1;
        PEK_AR_O3 = exp(beta_O3*PEK_conc_O3)-1;
        PEK_AR_PM = exp(beta_PM*PEK_conc_PM)-1;
        PEK_AR_PM10 = exp(beta_PM10*PEK_conc_PM10)-1;
        PEK_conc_to_AR = (PEK_AR_NO2 + PEK_AR_O3 + PEK_AR_PM)*100;
    
        % Exposure = Sum(AR * duration) for 1-hr intervals
        PEK_duration = 0.01666666666;
        PEK_exposure = PEK_conc_to_AR * PEK_duration;
        % PEK_PM25_exposure = PEK_AR_PM2_5 * PEK_duration*100;
        PEK_PM10_exposure = PEK_AR_PM10 * PEK_duration*100;
        PEK_O3_exposure = PEK_AR_O3 * PEK_duration*100;
        PEK_NO2_exposure = PEK_AR_NO2 * PEK_duration*100;


        PEK_hourly_exposure(PEK_Hour+1)= PEK_hourly_exposure(PEK_Hour+1)+PEK_exposure;
        % PEK_PM25_in_hour(PEK_Hour+1)= PEK_PM25_in_hour(PEK_Hour+1)+PEK_PM25_exposure;
        PEK_PM10_in_hour(PEK_Hour+1)= PEK_PM10_in_hour(PEK_Hour+1)+PEK_PM10_exposure;
        PEK_O3_in_hour(PEK_Hour+1)= PEK_O3_in_hour(PEK_Hour+1)+PEK_O3_exposure;
        PEK_NO2_in_hour(PEK_Hour+1)= PEK_NO2_in_hour(PEK_Hour+1)+PEK_NO2_exposure;

    end
end
