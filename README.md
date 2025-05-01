# 3.4 Analysis of Exposure Variations based on TCS Groups and MEs (Appendices II-IV)
1. Use Gen_2_months to convert 1 day of data into 2 months repeated data
	-> the data are saved in OfficeWorker_2months.csv

2. Use API_CallData_v3 to generate 2 months of simulation data from OfficeWorker_2months.csv
	-> the data are saved in SimulationOutput.csv

3. Use APIplot to calculate 2 months average and plot daily exposure graphs
	-> Specify in line 8 the date you want for graph to be plotted (currently set as 2024/9/2)
	-> Specify number of days SimulationOutput contains for average calculation in line 12 (currently set as 61 days)

