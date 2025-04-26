%Author: Raine Chang
%Last updated: Saturday 12 Apr 2025 

% Read the original CSV file
OfficeWorker = readtable('OfficeWorker.csv');

% Initialize an empty table to hold the new data
extendedData = [];

% Define the start and end dates for the repetition
startDate = datenum(2024, 9, 2);  % September 2, 2024
endDate = datenum(2024, 10, 31);   % October 31, 2024

% Loop through each day from start to end date
for currentDate = startDate:endDate
    % Get the formatted date string in MMDD format
    dateStr = datestr(currentDate, 'mmdd');
    
    % Create a copy of the original data to modify for the current date
    currentData = OfficeWorker;
    
    % Modify the startTime and endTime in the copied data
    currentData.startTime = strrep(string(currentData.startTime), '0902', dateStr);
    currentData.endTime = strrep(string(currentData.endTime), '0902', dateStr);
    
    % Append the modified data for the current date to extendedData
    extendedData = [extendedData; currentData]; %#ok<AGROW>
end

% Write the extended data to a new CSV file
writetable(extendedData, 'OfficeWorker_2months.csv');

fprintf('Data successfully saved to OfficeWorker_2months.csv\n');