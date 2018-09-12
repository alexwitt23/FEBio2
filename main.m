% Solid model: Neo-Hookean /// Permeability model: Constant-Isotropic-Permeability
clear all
close all
clc

%% Neo-hookean solid material with const-perm
    load('C:\Users\alexw\OneDrive\UT Austin\Research\Compression\compression_data.mat');
    fields = fieldnames(compression_data);

    loadTest = 'P50mmHg'; %p50mmHg, p100mmHg, p150mmHg This is for dynamic structure naming
    %load('C:\Users\alexw\OneDrive\UT Austin\Research\Compression\results.mat');

for i = 1:4

    test = fields{i};

    preData = getfield(compression_data,test);

    data = getfield(preData, 'RawNoPreload');
    
    if any(data(:,3)<0)
        
        disp('the sample choosen has negative force values')
        continue
    
    end 
    
    save('data.mat','data');

    options = optimoptions(@lsqnonlin,'PlotFcn',@optimplotresnorm,'Display','iter-detailed');

    %x0 =[.04,.5,.1,.09,.1,.1]*1e-6; %[Young's Modulus,Beta,Poisson Ratio,Permeability,M,alpha]
    %x0 =[.03,.46,.01,.8,.1,.1]*1e-6;
    x0 =[.022,.46,.01,.95,.001,.001]*1e-6;
    
    [x,resnorm] = lsqnonlin(@Objective_Function_noplot,x0,[0.01*1e-1,0,-.999*1e-1,0,0,0]*1e-5,[10,10*1e-1,.49999e-1,10*1e-1,10*1e-1,10*1e-1]*1e-5,options);

    %results.NeoS_ConstP.(test).(loadTest).x = x;
    %results.NeoS_ConstP.(test).(loadTest).resnorm = resnorm;
    %results = results;
    %save('C:\Users\alexw\OneDrive\UT Austin\Research\Compression\results.mat', 'results');
    
    Objective_Function(x)
    saveas(gcf, [test,'_',loadTest,'.png'])
    
    fclose('all');
end 






