% Author: Raine Chang
% Last updated: Thursday 1 May 2025 (Happy Holiday!)

% Set up t-test
x=5; % Number of PEKs
N=89; % Number of data points
df=N-2;
alpha=0.05;
critical_t = tinv(1 - alpha/2, N);
disp('The level of confidence of this test is 95%');

% Initialize tables
fileName = 'PEKs.xlsx';
% Get the names of all sheets in the Excel file
[~, sheetNames] = xlsfinfo(fileName);
AQMS = readtable("KTAQMS.csv");

% Initialize variables
PEK_conc_PM25 = zeros(N,x);
PEK_conc_PM10 = zeros(N,x);
PEK_conc_NO2 = zeros(N,x);
PEK_conc_O3 = zeros(N,x);
r_PM25 = zeros(x,1);
r_PM10 = zeros(x,1);
r_NO2 = zeros(x,1);
r_O3 = zeros(x,1);
t_PM25 = zeros(x,1);
t_PM10 = zeros(x,1);
t_NO2 = zeros(x,1);
t_O3 = zeros(x,1);
coeff_PM25 = zeros(2, length(sheetNames));  % [slope; intercept]
coeff_PM10 = zeros(2, length(sheetNames));
coeff_NO2 = zeros(2, length(sheetNames));
coeff_O3 = zeros(2, length(sheetNames));

% Loop through each sheet name
for i = 1:length(sheetNames)
    % Read the current sheet into a table
    PEK = readtable(fileName, 'Sheet', sheetNames{i});
    fprintf('%s:\n', sheetNames{i});
    % Extract the concentrations of each pollutant
    PEK_conc_PM25(:,i) = PEK.PM25;
    PEK_conc_PM10(:,i) = PEK.PM10;
    PEK_conc_NO2(:,i) = PEK.NO2;
    PEK_conc_O3(:,i) = PEK.O3;
    % Calculate Pearson's correlation coefficient for each pollutant
    r_PM25(i) = corr(PEK_conc_PM25(:, i), AQMS.PM25);
    r_PM10(i) = corr(PEK_conc_PM10(:, i), AQMS.PM10);
    r_NO2(i) = corr(PEK_conc_NO2(:, i), AQMS.NO2);
    r_O3(i) = corr(PEK_conc_O3(:, i), AQMS.O3);
    % Perform linear regression for each pollutant
    coeff_PM25(:, i) = polyfit(PEK_conc_PM25(:, i), AQMS.PM25,1);
    coeff_PM10(:, i) = polyfit(PEK_conc_PM10(:, i), AQMS.PM10,1);
    coeff_NO2(:, i) = polyfit(PEK_conc_NO2(:, i), AQMS.NO2,1);
    coeff_O3(:, i) = polyfit(PEK_conc_O3(:, i), AQMS.O3, 1);
    % Calculate t
    t_PM25(i) = r_PM25(i)*sqrt(N-2)/sqrt(1-r_PM25(i)^2);
    t_PM10(i) = r_PM10(i)*sqrt(N-2)/sqrt(1-r_PM10(i)^2);
    t_O3(i) = r_O3(i)*sqrt(N-2)/sqrt(1-r_O3(i)^2);
    t_NO2(i) = r_NO2(i)*sqrt(N-2)/sqrt(1-r_NO2(i)^2);
    % Display whether the correlation is significant
    if t_PM25(i) > critical_t
        fprintf('  is correlated with AQMS for PM25\n');
        fprintf('PM25: Slope = %.4f, Intercept = %.4f\n', coeff_PM25(1, i), coeff_PM25(2, i));
        scatter(AQMS.PM25, PEK_conc_PM25(:, i));
        xlabel('AQMS PM25');
        ylabel('PEK PM25');
        title('Scatter plot of PM25 data')
    else 
        fprintf('  is not correlated with AQMS for PM25\n');
    end

    if t_PM10(i) > critical_t
        fprintf('  is correlated with AQMS for PM10\n');
        fprintf('PM10: Slope = %.4f, Intercept = %.4f\n', coeff_PM10(1, i), coeff_PM10(2, i));
    else 
        fprintf('  is not correlated with AQMS for PM10\n');
    end

    if t_NO2(i) > critical_t
        fprintf('  is correlated with AQMS for NO2\n');
        fprintf('NO2: Slope = %.4f, Intercept = %.4f\n', coeff_NO2(1, i), coeff_NO2(2, i));
    else 
        fprintf('  is not correlated with AQMS for NO2\n');
    end

    if t_O3(i) > critical_t
        fprintf('  is correlated with AQMS for O3\n');
        fprintf('O3: Slope = %.4f, Intercept = %.4f\n', coeff_O3(1, i), coeff_O3(2, i));
    else 
        fprintf('  is not correlated with AQMS for O3\n');
    end
end

disp(transpose(r_PM25));
disp(transpose(t_PM25));

disp(transpose(r_PM10));
disp(transpose(t_PM10));

disp(transpose(r_NO2));
disp(transpose(t_NO2));

disp(transpose(r_O3));
disp(transpose(t_O3));
