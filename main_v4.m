%Author: Raine Chang
%Last updated: Wednesday 5/8/2025 

% Load the table
ttemp1 = readtable('Praise.csv'); 

% Pre-processing for duplicate timestamps
[~, uniqueIdx] = unique(ttemp1.record_timestamp, 'last');
ttemp2 = ttemp1(uniqueIdx, :);
Praise = sortrows(ttemp2, 'record_timestamp');
clear ttemp1 ttemp2;
disp('Finished sorting of Praise')
dateInput = '20250204'; % To be adjusted in use
num_dateInput = str2double(dateInput);

Table_name = ["PEK.csv","PEK_home.csv","AQMS.csv"];
all_hourly_exposure=zeros(24,length(Table_name));
all_pm25_in_hour=zeros(24,length(Table_name));
all_pm10_in_hour=zeros(24,length(Table_name));
all_o3_in_hour=zeros(24,length(Table_name));
all_no2_in_hour=zeros(24,length(Table_name));
parfor i1=1:length(Table_name)
    [all_hourly_exposure(:,i1),all_pm25_in_hour(:,i1),all_pm10_in_hour(:,i1),all_o3_in_hour(:,i1),all_no2_in_hour(:,i1)]=f_PEK(num_dateInput,Table_name(i1));
end
disp('Finished calling f_PEK');

PEK_hourly_exposure=all_hourly_exposure(:,1);
PEK_PM25_in_hour=all_pm25_in_hour(:,1);
PEK_PM10_in_hour=all_pm10_in_hour(:,1);
PEK_O3_in_hour=all_o3_in_hour(:,1);
PEK_NO2_in_hour=all_no2_in_hour(:,1);

PEKhome_hourly_exposure=all_hourly_exposure(:,2);
PEKhome_PM25_in_hour=all_pm25_in_hour(:,2);
PEKhome_PM10_in_hour=all_pm10_in_hour(:,2);
PEKhome_O3_in_hour=all_o3_in_hour(:,2);
PEKhome_NO2_in_hour=all_no2_in_hour(:,2);

AQMS_hourly_exposure=all_hourly_exposure(:,3);
AQMS_PM25_in_hour=all_pm25_in_hour(:,3);
AQMS_PM10_in_hour=all_pm10_in_hour(:,3);
AQMS_O3_in_hour=all_o3_in_hour(:,3);
AQMS_NO2_in_hour=all_no2_in_hour(:,3);

disp('Finished conversion of PEK, PEK home and AQMS')

% Validate the input date format
if ~isempty(dateInput) && length(dateInput) == 8 && all(isstrprop(dateInput, 'digit'))
    % Construct the lower and upper bounds
    lowerBound = str2double([dateInput '000000']); % e.g., '20230101000000'
    upperBound = str2double([dateInput '235959']); % e.g., '20230101235959'

    % Filter the rows within the specified range
    filteredData = Praise(Praise.record_timestamp >= lowerBound & Praise.record_timestamp <= upperBound, :);

    % Check if there are any rows in the filtered data
    if ~isempty(filteredData)
        % Find the minimum value and its row number
        minValue = min(filteredData.record_timestamp);
        minRow = find(Praise.record_timestamp == minValue, 1); % Get the first occurrence
        
        % Find the maximum value and its row number
        maxValue = max(filteredData.record_timestamp);
        maxRow = find(Praise.record_timestamp == maxValue, 1); % Get the first occurrence
    else
        disp('No records found in the specified range.');
    end
else
    disp('Invalid date format. Please enter a valid date in the format yyyymmdd.');
end

% Calculate IR
factor=f_cal_factor_v2;


IO = 0; % 1.HOME, 2.SCHOOL, 3.OFFICE, 4.OTHERINDOOR, 5.VEHICLE, 6.OUTDOOR
ME_Variable = zeros(3,1); 
% Window: 1.OPEN, 2.CLOSE, AC: 1.OFF, 2.ON, Air purifier/Recirculation: 1.OFF, 2.ON

%Praise
IO_in_hour=zeros(8,24);
daily_IO_exposure=zeros(8,1);
PM25_in_hour=zeros(24,1);
PM10_in_hour=zeros(24,1);
O3_in_hour=zeros(24,1);
NO2_in_hour=zeros(24,1);
%Praise Outdoor
Outdoor_in_hour=zeros(24,1);
Outdoor_PM25_in_hour = zeros(24,1);
Outdoor_PM10_in_hour = zeros(24,1);
Outdoor_O3_in_hour = zeros(24,1);
Outdoor_NO2_in_hour = zeros(24,1);


for i = minRow:maxRow

    % Find concentrations from Praise.csv
    conc_NO2 = Praise{i,'NO2'};
    conc_SO2 = Praise{i,'SO2'};
    conc_O3 = Praise{i,'O3'};
    conc_PM10 = Praise{i,'PM10'};
    conc_PM2_5 = Praise{i,'PM25'};

    % Find IO from Praise.csv
    if Praise{i,'exposure_parameter'}{1} == "{""IO"":""Bus and Minibus""}"
        IO = 8;
    elseif Praise{i,'exposure_parameter'}{1} == "{""IO"":""MTR""}"
        IO = 7;
    elseif Praise{i,'exposure_parameter'}{1} == "{""IO"":""Outdoor""}"
        IO = 6;
    elseif Praise{i,'exposure_parameter'}{1} == "{""IO"":""Vehicle""}"
        IO = 5;
    elseif Praise{i,'exposure_parameter'}{1} == "{""IO"":""Other Indoor""}"
        IO = 4;
    elseif Praise{i,'exposure_parameter'}{1} == "{""IO"":""Office""}"
        IO = 3; 
    elseif Praise{i,'exposure_parameter'}{1} == "{""IO"":""School""}"
        IO = 2;
    elseif Praise{i,'exposure_parameter'}{1} == "{""IO"":""Home""}"
        IO = 1;
    end
    
    ME_value = Praise{i,'micro_environment'}{1};
   
    % Check Windows 1.OPEN or 2.CLOSE from Praise.csv
    if contains(ME_value, '"Factor":"Window","Option":"OPEN"')
        ME_Variable(1) = 1;
    elseif contains(ME_value, '"Factor":"Window","Option":"CLOSE"')
        ME_Variable(1) = 2;
    else
        ME_Variable(1) = 2; 
    end
    
    % Check AC 1.OFF or 2.ON from Praise.csv
    if contains(ME_value, '"Factor":"Air Conditioner","Option":"OFF"')
        ME_Variable(2) = 1;
    elseif contains(ME_value, '"Factor":"Air Conditioner","Option":"ON"')
        ME_Variable(2) = 2;
    else
        ME_Variable(2) = 1; 
    end

    % Check Air Purifier/Recirculation 1.OFF or 2.ON from Praise.csv
    if contains(ME_value, '"Factor":"Air Purifier","Option":"OFF"')
        ME_Variable(3) = 1;
    elseif contains(ME_value, '"Factor":"Air Purifier","Option":"ON"')
        ME_Variable(3) = 2;
    elseif contains(ME_value, '"Factor":"Recirculation","Option":"OFF"')
        ME_Variable(3) = 1;
    elseif contains(ME_value, '"Factor":"Recirculation","Option":"ON"')
        ME_Variable(3) = 2;
    else
        ME_Variable(3) = 1; 
    end
    
    if Praise{i,'location_name'}{1} == "AIA Kowloon Tower"
        IO = 3;
        ME_Variable(1) = 2;
        ME_Variable(2) = 2;
        ME_Variable(3) = 2;
    end

    % Calculate the AR of each timestamp
    conc_to_AR = f_conc(conc_NO2, conc_PM10, conc_PM2_5, conc_O3, conc_SO2, ...
        factor(:,ME_Variable(1),ME_Variable(2),ME_Variable(3),IO));
    conc_to_AR_outdoor = f_conc_outdoor(conc_NO2, conc_PM10, conc_PM2_5, conc_O3, ...
    conc_SO2);
    %Print AR and timestamp
    time_stamp = Praise.record_timestamp(i);
    valueStr = num2str(time_stamp);
    year = valueStr(1:4);      % First 4 digits for year
    month = valueStr(5:6);     % Next 2 digits for month
    day = valueStr(7:8);       % Next 2 digits for day
    hour = valueStr(9:10);     % Next 2 digits for hour
    minute = valueStr(11:12);  % Next 2 digits for minute
    formattedDateTime = sprintf('%s/%s/%s %s:%s', year, month, day, hour, minute);
    % fprintf('%%AR at %s is %.2f%%\n', formattedDateTime, conc_to_AR);

% Exposure = Sum(AR * duration) for 1-hr intervals
    %Calculate duration
    % Define the datetime values
    time1 = Praise.record_timestamp(i-1); % First time
    time2 = Praise.record_timestamp(i); % Second time
    
    % Convert the numeric values to datetime
    dt1 = datetime(num2str(time1), 'InputFormat', 'yyyyMMddHHmmss');
    dt2 = datetime(num2str(time2), 'InputFormat', 'yyyyMMddHHmmss');
    
    % Calculate the difference
    timeDifference = dt2 - dt1; % This will be a duration object
    
    % Convert the difference to hours
    duration = hours(timeDifference);

    value_hour = str2double(hour);
    %Total Exposure
    exposure=conc_to_AR * duration;
    exposure_outdoor = conc_to_AR_outdoor * duration;

    %Praise AR for each polllutant
    beta_NO2 = 0.0004462559;
    beta_O3 = 0.0005116328;
    beta_PM10 = 0.0002821751;
    AR_NO2 = exp(beta_NO2*conc_NO2)-1;
    AR_O3 = exp(beta_O3*conc_O3)-1;
    AR_PM10 = exp(beta_PM10*conc_PM10)-1;
    % exposure_PM25 = AR_PM25 * factor(2) * duration;
    exposure_PM10 = AR_PM10 * factor(1) * duration*100;
    exposure_O3 = AR_O3 * factor(4) * duration*100;
    exposure_NO2 = AR_NO2 * factor(3) * duration*100;

    %Praise Outdoor AR for each pollutant
    outdoor_exposure_PM10 = AR_PM10 * duration*100;
    outdoor_exposure_O3 = AR_O3 * duration*100;
    outdoor_exposure_NO2 = AR_NO2 * duration*100;

% Calculate total exposure of each IO
    %Praise
    daily_IO_exposure(IO)=daily_IO_exposure(IO)+exposure;
    IO_in_hour(IO, value_hour+1)= IO_in_hour(IO, value_hour+1)+exposure;
    % PM25_in_hour(value_hour+1)=PM25_in_hour(value_hour+1)+exposure_PM25;
    PM10_in_hour(value_hour+1)=PM10_in_hour(value_hour+1)+exposure_PM10;
    O3_in_hour(value_hour+1)=O3_in_hour(value_hour+1)+exposure_O3;
    NO2_in_hour(value_hour+1)=NO2_in_hour(value_hour+1)+exposure_NO2;
    %Praise Outdoor
    Outdoor_in_hour(value_hour+1)=Outdoor_in_hour(value_hour+1)+exposure_outdoor;
    % Outdoor_PM25_in_hour(value_hour+1)=Outdoor_PM25_in_hour(value_hour+1)+outdoor_exposure_PM25;
    Outdoor_PM10_in_hour(value_hour+1)=Outdoor_PM10_in_hour(value_hour+1)+outdoor_exposure_PM10;
    Outdoor_O3_in_hour(value_hour+1)=Outdoor_O3_in_hour(value_hour+1)+outdoor_exposure_O3;
    Outdoor_NO2_in_hour(value_hour+1)=Outdoor_NO2_in_hour(value_hour+1)+outdoor_exposure_NO2;

end

Praise_in_hour = sum(IO_in_hour, 1);

%print
disp('%Difference:')
disp((sum(daily_IO_exposure)-sum(PEK_hourly_exposure))/sum(daily_IO_exposure)*100);
disp('Total Transport Exposure:')
disp(daily_IO_exposure(5)+daily_IO_exposure(7)+daily_IO_exposure(8));

% Create a figure for the subplots
figure;

% Plot Exposure Bar Chart
subplot(2, 3, 5); % Use 1 row and 2 columns for the bar chart
x = 0:23;
bar_chart = bar(x, transpose(IO_in_hour), "stacked");

% Add legend for bar chart
xticks(0:23);
xlabel('Hour');
ylabel('%AR');
title('Daily Exposure Summary');
colors = [
    0.8, 0.2, 0.2;  % Home
    0.25, 0.88, 0.82;  % School
    0.2, 0.6, 0.8;  % Office
    0.5, 0.2, 0.8;   % Other Indoor
    0.3961, 0.2627, 0.1294; % Vehicle
    0.2, 0.8, 0.2;  % Outdoor
    0.4961, 0.2627, 0.1294; % MTR
    0.5, 0.4, 0.1; % Bus and Minibus
];

% Apply colors to each bar segment
for i = 1:length(bar_chart)
    bar_chart(i).FaceColor = 'flat';  % Enable flat coloring
    bar_chart(i).CData = colors(i, :);  % Set color for each segment
end

% Overlay step line chart using PEK_hourly_exposure
hold on;  % Retain current plot
step_data = PEK_hourly_exposure;  % Your data for the step line
dark_blue = [0, 0, 0.5];  % Define dark blue color
lighter_blue = [0.678, 0.847, 0.902];
hStepLine = plot(x, step_data, '-o', 'LineWidth', 2, 'Color', dark_blue, 'MarkerFaceColor', dark_blue); % Use dark blue
step_data4 = PEKhome_hourly_exposure;
hStepLine4 = plot(x, step_data4, '--o', 'LineWidth', 2, 'Color', lighter_blue, 'MarkerFaceColor', lighter_blue); % Use lighter blue
step_data2 = AQMS_hourly_exposure;
green_AQMS = [0.2, 0.8, 0.4];
hStepLine2 = plot(x, step_data2, '-o', 'LineWidth', 2, 'Color', green_AQMS, 'MarkerFaceColor', green_AQMS);
step_data3 = Outdoor_in_hour;
black = [0,0,0];
hStepLine3 = plot(x, step_data3, '-o', 'LineWidth', 2, 'Color', black, 'MarkerFaceColor', black);
hold off;  % Release the plot hold

% Create legend for exposure
legendLabels = {
    ['Home: ', num2str(round(daily_IO_exposure(1),3,'significant'))], 
    ['School: ', num2str(round(daily_IO_exposure(2),3,'significant'))], 
    ['Office: ', num2str(round(daily_IO_exposure(3),3,'significant'))], 
    ['Other Indoor: ', num2str(round(daily_IO_exposure(4),3,'significant'))], 
    ['Vehicle: ', num2str(round(daily_IO_exposure(5),3,'significant'))], 
    ['Outdoor: ', num2str(round(daily_IO_exposure(6),3,'significant'))], 
    ['MTR: ', num2str(round(daily_IO_exposure(7),3,'significant'))], 
    ['Bus and Minibus: ', num2str(round(daily_IO_exposure(8),3,'significant'))], 
    ['PEK25: ', num2str(round(sum(PEK_hourly_exposure),3,'significant'))], 
    ['PEK09: ', num2str(round(sum(PEKhome_hourly_exposure),3,'significant'))], 
    ['Kwun Tong AQMS: ', num2str(round(sum(AQMS_hourly_exposure),3,'significant'))],
    ['PRAISE Outdoor:', num2str(round(sum(Outdoor_in_hour),3,'significant'))]
};
legend(legendLabels, 'Location', 'best');
x1= 0:23;

% Plot Total AR
subplot(2, 3, 4);
hold on;
plot(x1, transpose(Praise_in_hour), 'r-', 'DisplayName', ['PRAISE: ', num2str(round(sum(daily_IO_exposure),3,'significant'))],'LineWidth', 2);
plot(x1, PEK_hourly_exposure, 'b-', 'DisplayName', ['PEK25: ', num2str(round(sum(PEK_hourly_exposure),3,'significant'))],'LineWidth', 2);
plot(x1, PEKhome_hourly_exposure, 'Color', [0.678, 0.847, 0.902], 'LineStyle', '--', 'DisplayName', 'PEK09', 'LineWidth', 2);
plot(x1, AQMS_hourly_exposure, 'g-', 'DisplayName', 'Kwun Tong AQMS','LineWidth', 2);
plot(x1, Outdoor_in_hour,'k-','DisplayName', 'PRAISE Outdoor','LineWidth', 2);
hold off;
xlabel('Hour');
ylabel('%AR');
title('%AR Total');
legend show
xlim([0 23]);

% Plot PM10
subplot(2, 3, 1);
hold on;
plot(x1, PM10_in_hour, 'r-', 'DisplayName', 'PRAISE','LineWidth', 2);
plot(x1, PEK_PM10_in_hour, 'b-', 'DisplayName', 'PEK25','LineWidth', 2);
plot(x1, PEKhome_PM10_in_hour, 'Color', [0.678, 0.847, 0.902], 'LineStyle', '--', 'DisplayName', 'PEK09', 'LineWidth', 2);
plot(x1, AQMS_PM10_in_hour, 'g-', 'DisplayName', 'Kwun Tong AQMS','LineWidth', 2);
plot(x1, Outdoor_PM10_in_hour,'k-','DisplayName', 'PRAISE Outdoor','LineWidth', 2);
hold off;
xlabel('Hour');
ylabel('%AR');
title('PM10 %AR Contribution');
% legend show;
xlim([0 23]);

% Plot O3
subplot(2, 3, 2);
hold on;
plot(x1, O3_in_hour, 'r-', 'DisplayName', 'PRAISE','LineWidth', 2);
plot(x1, PEK_O3_in_hour, 'b-', 'DisplayName', 'PEK25','LineWidth', 2);
plot(x1, PEKhome_O3_in_hour, 'Color', [0.678, 0.847, 0.902], 'LineStyle', '--', 'DisplayName', 'PEK09', 'LineWidth', 2);
plot(x1, AQMS_O3_in_hour, 'g-', 'DisplayName', 'Kwun Tong AQMS','LineWidth', 2);
plot(x1, Outdoor_O3_in_hour,'k-','DisplayName', 'PRAISE Outdoor','LineWidth', 2);
hold off;
xlabel('Hour');
ylabel('%AR');
title('O3 %AR Contribution');
% legend show;
xlim([0 23]);

% Plot NO2
subplot(2, 3, 3);
hold on;
plot(x1, NO2_in_hour, 'r-', 'DisplayName', 'PRAISE','LineWidth', 2);
plot(x1, PEK_NO2_in_hour, 'b-', 'DisplayName', 'PEK25','LineWidth', 2);
plot(x1, PEKhome_NO2_in_hour, 'Color', [0.678, 0.847, 0.902], 'LineStyle', '--', 'DisplayName', 'PEK09', 'LineWidth', 2);
plot(x1, AQMS_NO2_in_hour, 'g-', 'DisplayName', 'Kwun Tong AQMS','LineWidth', 2);
plot(x1, Outdoor_NO2_in_hour,'k-','DisplayName', 'PRAISE Outdoor','LineWidth', 2);
hold off;
xlabel('Hour');
ylabel('%AR');
title('NO2 %AR Contribution');
% legend show;
xlim([0 23]);

% Adjust layout
sgtitle(dateInput); 

hold off;