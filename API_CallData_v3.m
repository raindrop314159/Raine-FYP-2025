% Author: Raine Chang
% Last updated: Saturday 12 Apr 2025 

% Initialize Table
SyntheticDiary = readtable('OfficeWorker_2months.csv');
% SyntheticDiary = readtable('OfficeWorker.csv');

% Prepare an array to hold the results
results = []; % To hold results for CSV export

% Pollutant names
pollutants = {'PM10', 'NO2', 'O3'};  

for i = 1 : height(SyntheticDiary)
    % Initialize Variables
    startTime = SyntheticDiary.startTime(i);
    endTime = SyntheticDiary.endTime(i);
    longitude = SyntheticDiary.longitude(i);
    latitude = SyntheticDiary.latitude(i);
    
    % Extract additional information for new columns
    LocationName = SyntheticDiary.LocationName{i};  % Get the location name
    exposure_parameter = SyntheticDiary.exposure_parameter{i};  % Get the exposure parameter
    micro_environment = SyntheticDiary.micro_environment{i};  % Get the micro environment

    % Initialize a container for timestamps and values
    pollutantValues = nan(1, length(pollutants));  
    timestamps = {};  % Initialize to hold timestamps for this diary entry

    % Set API call outside the loop to retrieve data
    API = ['https://envf.ust.hk/uwsgi/praise-service?todo=get_data&t0=', ...
        num2str(startTime), '&t1=', num2str(endTime), ...
        '&lng=', num2str(longitude, '%.2f'), '&lat=', ...
        num2str(latitude, '%.2f') ...
        '&pids=PM10,NO2,O3&apikey=fter4Qh2QSjZ&myid=jimmyc.dev'];

    % Set web options with a timeout
    options = weboptions('Timeout', 15); 
    
    try
        % Call the API
        response = webread(API, options);
        disp(response);  % Print the response to check structure and content

        % Store timestamps
        timestamps = response.ts;  % Get the timestamps
        
        % Loop through each timestamp and retrieve pollutant values
        for t = 1:length(timestamps)
            % Store pollutant values, checking if they exist and are not NaN
            if isfield(response, 'PM10') && ~isnan(response.PM10(t))
                pollutantValues(1) = response.PM10(t);  % Store PM10 values
            end
            if isfield(response, 'NO2') && ~isnan(response.NO2(t))
                pollutantValues(2) = response.NO2(t);  % Store NO2 values
            end
            if isfield(response, 'O3') && ~isnan(response.O3(t))
                pollutantValues(3) = response.O3(t);  % Store O3 values
            end
            
            % Only add a valid row if all pollutants have values
            if all(~isnan(pollutantValues))  % Check if all pollutants have values
                Start_1 = num2str(startTime); % initial startime
                End_1 = num2str(endTime); % initial endtime
                currenttime = num2str(timestamps{t}); % initial timestamp time (hour only)
                if str2num(Start_1(9:10)) == str2num(currenttime(9:10)) && str2num(End_1(9:10)) ~= str2num(Start_1(9:10)) % setting first hour
                    End_1 = num2str(strcat(currenttime, '59'));
                    results = [results; {i, LocationName, latitude, longitude, exposure_parameter, micro_environment, num2str(startTime),  End_1, pollutantValues(1), pollutantValues(2), pollutantValues(3)}];
                elseif str2num(End_1(9:10))>str2num(currenttime(9:10)) % setting other hours except first and last hour
                    Start_1 = num2str(strcat(num2str(str2num(currenttime)-1), '59'));
                    End_1 = num2str(strcat(currenttime, '59'));
                    results = [results; {i, LocationName, latitude, longitude, exposure_parameter, micro_environment, Start_1, End_1, pollutantValues(1), pollutantValues(2), pollutantValues(3)}];
                elseif str2num(End_1(9:10)) == str2num(currenttime(9:10)) && t ~= 1 % Set last hour data for case of start hour ~= end hour
                    Start_1 =  num2str(strcat(num2str(str2num(currenttime)-1), '59'));
                    results = [results; {i, LocationName, latitude, longitude, exposure_parameter, micro_environment, Start_1, num2str(endTime), pollutantValues(1), pollutantValues(2), pollutantValues(3)}];
                else % Set last hour data for case of start hour == end hour
                    results = [results; {i, LocationName, latitude, longitude, exposure_parameter, micro_environment, num2str(startTime), num2str(endTime), pollutantValues(1), pollutantValues(2), pollutantValues(3)}];
                end
            end
        end
        
    catch ME
        % If an error occurs, log an error entry
        fprintf('Error calling the API for Diary Index: %d\n', i);
        disp(ME.message);
    end   
end

% Convert results to a table
resultTable = cell2table(results, 'VariableNames', {'DiaryIndex', 'location_name', 'latitude', 'longitude', 'exposure_parameter', 'micro_environment', 'startTime','endTime', 'PM10', 'NO2', 'O3'}); % Added start and end time

% Write results to CSV file
csvFileName = 'SimulationOutput.csv'; 
writetable(resultTable, csvFileName);

disp('Data successfully exported to SimulationOutput.csv');