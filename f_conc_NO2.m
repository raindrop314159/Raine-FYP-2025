function conc_to_AR_NO2 = f_conc_NO2(conc_NO2, conc_PM10, conc_PM2_5, conc_O3, ...
    conc_SO2,factor)
% Convert concentrations to %AR Indoor
beta_NO2 = 0.0004462559;
beta_SO2 = 0.0001393235;
beta_O3 = 0.0005116328;
beta_PM10 = 0.0002821751;
beta_PM2_5 = 0.0002180567;

conc_PM = max(conc_PM2_5, conc_PM10);
if conc_PM == conc_PM2_5
    beta_PM = beta_PM2_5;
    IR_PM = factor(2);
else 
    beta_PM = beta_PM10;
    IR_PM = factor(1);
end

AR_NO2 = exp(beta_NO2*conc_NO2)-1;
AR_SO2 = exp(beta_SO2*conc_SO2)-1;
AR_O3 = exp(beta_O3*conc_O3)-1;
AR_PM = exp(beta_PM*conc_PM)-1;

conc_to_AR_NO2 = AR_NO2*factor(3)*100;

end