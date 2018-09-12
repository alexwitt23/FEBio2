function[error] = Objective_Function(param)
 
% clear all
% close all
% clc

tic

param = param*1e6;

fprintf('Parameter Values: %12.10f, %12.10f, %12.10f, %12.10f %12.10f\n',param)

% Old parameters that may be helpful as good initial guess for 'x0'
% param(1) = 0.0124065083;
% param(1) = 10;
% param(2) = 0.0000013515;
% param(3) = 0.3384459828;
% param(4) = 0.1000000000;
% param(5) = 0;

%% READ EXPERIMENTAL DATA

load('data.mat'); %load compression data in a structure

%data = compression_data.WM1_132_1.RawNoPreload; %specific test data called

%% New Resampling try

for i = 1:length(data)
    
    if data(i,3) < 0 
        
        disp('please choose somthing different--some force values are negative')
        
        break;
        
    end
    
end

for r = 2:length(data)

        if data(r,3) <= data(r-1,3)

            newData50 = data(1:r-1,1:4);

            rowEnd50 = r-1; 
            
            break;

        end
        
end

    
for r = rowEnd50+1:length(data)

        if data(r,3) >= data(r-1,3) && data(r,3) - data(r-1,3) >= 1

            rowBegin100 = r;

            break; 
        else 
            
            continue;

        end    
        
end 
    
for r = rowBegin100+1:length(data)
        
    if data(r,3) <= data(r-1,3)

        newData100 = data(rowBegin100+1:r-1,1:4);

        rowEnd100 = r-1;

        break;

    end    
        
end 

    
for x = rowEnd100+1:length(data)
        
    if data(x,3) >= data(x-1,3) && data(x,3) - data(x-1,3) >= 1

        rowBegin150 = x;
        break; 
    else
        rowBegin150 = 0;
        continue;

    end
        
end 
if rowBegin150 > 0   
    for z = rowBegin150+1:length(data)

        if data(z,3) <= data(z-1,3)

            newData150 = data(rowBegin150+1:z-1,1:4);

            rowEnd150 = z-1;

            break

        end    

    end 
else 
    disp('Cannot determine 150mmHg load spike')

end 

% Creation of sample array 

loadNumber = 50; %50, 100, 150

if loadNumber == 50
    
    if data(rowBegin100-1,3) < data(1,3)
        i = 1;
        while data(1,3) < data(rowEnd50+i,3)
            i = i + 1;
        end
        endof50 = rowEnd50+i;
        
        sampling_length = 150;
        sampling_array = [1:10:rowEnd50-1,rowEnd50,round(linspace(rowEnd50+1,endof50,sampling_length))];
        height     = abs(data(1,2));
        total_time = data(sampling_array,1)-data(1,1);
        time_array = data(sampling_array,1)-data(1,1);
        disp_array = -(data(sampling_array,2)-data(1,2));
        forc_array = (data(sampling_array,3)-data(1,3))/1000;
        step_size = time_array(2);
        
    else    
        sampling_length = 150;
        %sampling_array = [1:10:rowEnd50-1,rowEnd50,rowEnd50+1:10:rowEnd50+100,round(linspace(rowEnd50+101,rowBegin100-1,sampling_length))];
        sampling_array = [1:10:rowEnd50-1,rowEnd50,round(linspace(rowEnd50+1,rowBegin100-1,sampling_length))];
        height     = abs(data(1,2));
        total_time = data(sampling_array,1)-data(1,1);
        time_array = data(sampling_array,1)-data(1,1);
        disp_array = -(data(sampling_array,2)-data(1,2));
        forc_array = (data(sampling_array,3)-data(1,3))/1000;
        step_size = time_array(2);              
    end 
        
elseif loadNumber == 100
    
    sampling_length = 150;
    %sampling_array = [rowBegin100:15:rowEnd100-1,rowEnd100,rowEnd100+1:10:rowEnd100+4000,round(linspace(rowEnd100+4001,rowBegin150-1,sampling_length))];
    %sampling_array = [rowBegin100-1:15:rowEnd100-1,rowEnd100,round(linspace(rowEnd100+41,rowBegin150-1,sampling_length))];
    sampling_array = [rowBegin100-1:15:rowEnd100-1,rowEnd100,round(linspace(rowEnd100+1,rowBegin150-1,sampling_length))];

    height     = abs(data(rowBegin100-1,2));
    total_time = data(sampling_array,1)-data(rowBegin100-1,1);
    time_array = data(sampling_array,1)-data(rowBegin100-1,1);
    disp_array = -(data(sampling_array,2)-data(rowBegin100-1,2));
    forc_array = (data(sampling_array,3)-data(rowBegin100-1,3))/1000;

    step_size = time_array(2);
    
elseif loadNumber == 150
    
    sampling_length = 50;
    sampling_array = [rowBegin150:5:rowEnd150-1,rowEnd150,round(linspace(rowEnd150+1,length(data),sampling_length))];

    height     = abs(data(rowBegin150,2));
    total_time = data(sampling_array,1)-data(rowBegin150,1);
    time_array = data(sampling_array,1)-data(rowBegin150,1);
    disp_array = -(data(sampling_array,2)-data(rowBegin150,2));
    forc_array = (data(sampling_array,3)-data(rowBegin150,3))/1000;

    step_size = time_array(2);
else 
    
    disp('Check desried loadNumber')
    
end 
%% READ REFERENCE COORDINATES
% 
% num_nodes = 2093;
% 
% fid1 = fopen('Reference_Coordinates.txt','r');
% 
% for i = 1 : num_nodes
%     
%     line     = fgetl(fid1);
%     xR(i,1:4) = sscanf(line,'%d %f %f %f');
%     
% end
% 
% fclose(fid1);
% 
% X = xR(:,2:4);
% 
% X(:,3) = X(:,3)/3*height;

%plot3(X(:,1),X(:,2),X(:,3),'ro')

%% WRITE GEOMETRY FILE
% 
% fid2 = fopen(['Nodes.txt'],'w');
% 
% fprintf(fid2,'<?xml version="1.0" encoding="ISO-8859-1"?>\n');
% fprintf(fid2,'<febio_spec version="2.5">\n');
% fprintf(fid2,'<Geometry>\n');
% fprintf(fid2,'<Nodes>\n');
% 
% for i = 1 : num_nodes
%     
%     fprintf(fid2,['<node id="',num2str(i),'">',num2str(X(i,1)),',',num2str(X(i,2)),',',num2str(X(i,3)),'</node>\n']);
%     
% end
% 
% fprintf(fid2,'</Nodes>\n');
% fclose(fid2);
% 
% system('del Geometry.feb');
% system('copy Nodes.txt+Elements.txt Geometry.feb')  

%% WRITE CONTROL FILE

system('del Control.feb');

fid4 = fopen('Control.feb','w');

fprintf(fid4,'<?xml version="1.0" encoding="ISO-8859-1"?>\n');
fprintf(fid4,'<febio_spec version="2.5">\n');
fprintf(fid4,'\t <Control>\n');
fprintf(fid4,'\t <time_steps>%f</time_steps>\n',total_time(end)/step_size);
fprintf(fid4,'\t <step_size>%f</step_size>\n',step_size);
fprintf(fid4,'\t <plot_level>PLOT_MUST_POINTS</plot_level>\n');
fprintf(fid4,'\t <output_level>OUTPUT_MUST_POINTS</output_level>\n');
fprintf(fid4,'\t <max_refs>15</max_refs>\n');
fprintf(fid4,'\t <max_ups>0</max_ups>\n');
fprintf(fid4,'\t <dtol>0.001</dtol>\n');
fprintf(fid4,'\t <etol>0.01</etol>\n');
fprintf(fid4,'\t <rtol>0</rtol>\n');
fprintf(fid4,'\t <ptol>0.01</ptol>\n');
fprintf(fid4,'\t <lstol>0.9</lstol>\n');
fprintf(fid4,'\t <time_stepper>\n');
fprintf(fid4,'\t <dtmin>0.0001</dtmin>\n');
fprintf(fid4,'\t <dtmax lc="3">1</dtmax>\n');
fprintf(fid4,'\t <max_retries>5</max_retries>\n');
fprintf(fid4,'\t <opt_iter>10</opt_iter>\n');
fprintf(fid4,'\t </time_stepper>\n');
fprintf(fid4,'\t </Control>\n');
fprintf(fid4,'</febio_spec>\n');

fclose(fid4);

%% WRITE PARAMETER FILE (adjusted to perm-const-iso...)

fid5 = fopen('Parameters.feb','w');

fprintf(fid5,'<?xml version="1.0" encoding="ISO-8859-1"?>\n');
fprintf(fid5,'<febio_spec version="2.5">\n');
fprintf(fid5,'\t<Parameters>\n');
fprintf(fid5,'<param name="E0">%12.8f</param>\n',param(1)); %0.05
fprintf(fid5,'<param name="B0">%12.8f</param>\n',param(2)); %0.3
fprintf(fid5,'<param name="v0">%12.8f</param>\n',param(3)); %10
fprintf(fid5,'<param name="r0">%12.8f</param>\n',param(4));
fprintf(fid5,'<param name="M0">%12.8f</param>\n',param(5));
fprintf(fid5,'<param name="a0">%12.8f</param>\n',param(6));
fprintf(fid5,'\t</Parameters>\n');
fprintf(fid5,'</febio_spec>\n');

fclose(fid5);

%% WRITE LOADCURVE FILE

fid2 = fopen('LoadCurves.feb','w');

fprintf(fid2,'<?xml version="1.0" encoding="ISO-8859-1"?>\n');
fprintf(fid2,'<febio_spec version="2.5">\n');
fprintf(fid2,'\t <LoadData>\n');
fprintf(fid2,'\t\t <loadcurve id="1" type="linear">\n');
fprintf(fid2,'\t\t\t <point>0,0</point>\n');
fprintf(fid2,'\t\t\t <point>1,1</point>\n');
fprintf(fid2,'\t\t </loadcurve>\n');
fprintf(fid2,'\t\t <loadcurve id="2" type="linear">\n');

for i = 1 : length(time_array)
    
    fprintf(fid2,['\t\t\t <point>%f,%f</point>\n'],[time_array(i),disp_array(i)]);
    
end

fprintf(fid2,'\t\t </loadcurve>\n');

%Must Point Load Curve

fprintf(fid2,'\t\t <loadcurve id="3" type="step">\n');
fprintf(fid2,'\t\t\t <point>0,0</point>\n');

for i = 1 : length(time_array)
    
    fprintf(fid2,['\t\t\t <point>%f,%f</point>\n'],[time_array(i),100]);
    
end

fprintf(fid2,'\t\t </loadcurve>\n');
fprintf(fid2,'\t </LoadData>\n');
fprintf(fid2,'</febio_spec>\n');

%% RUN FEBIO

system('"C:/Program Files/FEBio2.8.2/bin/FEBio2" -i ./FourthModel.feb');

%% READ OUTPUT FILE

fid3 = fopen('Fz.txt','r');

%junk = fgetl(fid3);

i = 0;

while 1
    
    i = i + 1;
    
    junk1 = fgetl(fid3);
    
    if junk1 == -1
        
        break;
        
    else
        
        junk = fgetl(fid3);
        junk = fgetl(fid3);
        
        line1 = fgetl(fid3);
        
        data1 = sscanf(line1,'%i %f');
        
        Fz(i) = -data1(2);
        
    end
    
end

Fz = [0,Fz];

fclose(fid3);

figure

plot(Fz);
hold on;
plot(forc_array);
title(['parameters: ' num2str(param(1)) ', ' num2str(param(2)) ', ' num2str(param(3)) ', ' num2str(param(4)) ', ' num2str(param(5)) ', ' num2str(param(6))]);

error = Fz'-forc_array; %turned Fz' into Fz for matrix dimension agreement


save('Fz.mat','Fz','forc_array');
fprintf('Norm of Error: %f \n',norm(error));
toc
