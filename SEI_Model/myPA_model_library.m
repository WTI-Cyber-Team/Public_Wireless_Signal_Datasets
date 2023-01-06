function PA_out = myPA_model_library(input_signal,device_code)
%PA进入的信号input
%device_code；设备编号
[a,b] = size(input_signal);
PA_out = zeros(a,b);
PA_maxin = 1; %设定的最大输入幅度

if device_code == 1
    saleh_para = 1.44*[1/1.2,0.25,0.25,0.26];  %截断1.2，参数按照比例变化缩放
    PA_out = PA_Saleh(input_signal,saleh_para);
    PA_maxout = abs(PA_Saleh(PA_maxin,saleh_para));
    PA_out = PA_out/PA_maxout; %保持输出的最大功率归一化
elseif device_code == 2
    rapp_para = [1.2,2,1];   %截断1.2，
    PA_out = PA_Rapp(input_signal,rapp_para);
    PA_maxout = abs(PA_Rapp(PA_maxin,rapp_para));
    PA_out = PA_out/PA_maxout; %保持输出的最大功率归一化
elseif device_code == 3
    saleh_para = [1.9638, 0.9945,2.5293,2.8168]; %截断1
    PA_out = PA_Saleh(input_signal,saleh_para);
    PA_maxout = abs(PA_Saleh(PA_maxin,saleh_para));
    PA_out = PA_out/PA_maxout; %保持输出的最大功率归一化
elseif device_code == 4
    cmos_para = [0.5*4.65,0.81,0.58,44.68,0.114,2.4,2.3];   %截断0.8
    PA_out = PA_Rapp(input_signal,cmos_para);
    PA_maxout = abs(PA_Rapp(PA_maxin,cmos_para));
    PA_out = PA_out/PA_maxout; %保持输出的最大功率归一化
elseif device_code == 5
    saleh_para = [2.1587,1.1517,4.0033,9.1040]; %截断1
    PA_out = PA_Saleh(input_signal,saleh_para);
    PA_maxout = abs(PA_Saleh(PA_maxin,saleh_para));
    PA_out = PA_out/PA_maxout; %保持输出的最大功率归一化
elseif device_code == 6
    saleh_para = 0.0441*[88.2564/0.21,24.0216,318.9741,1030.5488]; %截断0.21
    PA_out = PA_Saleh(input_signal,saleh_para);
    PA_maxout = abs(PA_Saleh(PA_maxin,saleh_para));
    PA_out = PA_out/PA_maxout; %保持输出的最大功率归一化
elseif device_code == 7
    poly_para = [0.9798-0.2887i,0,-0.2901+0.4350i]./(0.9798-0.2887i); %截断1
    PA_out = PA_poly(input_signal,length(poly_para),poly_para.');
    PA_maxout = abs(PA_poly(PA_maxin,length(poly_para),poly_para.'));
    PA_out = PA_out/PA_maxout; %保持输出的最大功率归一化
elseif device_code == 8
    poly_para = [14.8562-0.1337i,0,-23.1899+6.9785i,0,30.5226-1.9699i,0,-21.5517-4.7097i,0,6.0311+2.7527i]; %截断1
    PA_out = PA_poly(input_signal,length(poly_para),poly_para.');
    PA_maxout = abs(PA_poly(PA_maxin,length(poly_para),poly_para.'));
    PA_out = PA_out/PA_maxout; %保持输出的最大功率归一化
elseif device_code == 9
    saleh_para = 1.05^2*[2/1.05,1,4,9]; %截断1.05
    PA_out = PA_Saleh(input_signal,saleh_para);
    PA_maxout = abs(PA_Saleh(PA_maxin,saleh_para));
    PA_out = PA_out/PA_maxout; %保持输出的最大功率归一化
elseif device_code == 10
    rapp_para = [1,1,2];   %截断1，
    PA_out = PA_Rapp(input_signal,rapp_para);
    PA_maxout = abs(PA_Rapp(PA_maxin,rapp_para));
    PA_out = PA_out/PA_maxout; %保持输出的最大功率归一化
elseif device_code == 11
    rapp_para = [7.5,6.5,3.5];   %截断1，
    PA_out = PA_Rapp(input_signal,rapp_para);
    PA_maxout = abs(PA_Rapp(PA_maxin,rapp_para));
    PA_out = PA_out/PA_maxout; %保持输出的最大功率归一化
elseif device_code == 12
    saleh_para = 16*[1.6623/4, 0.0552,0.1533,0.3456]; %截断4
    PA_out = PA_Saleh(input_signal,saleh_para);
    PA_maxout = abs(PA_Saleh(PA_maxin,saleh_para));
    PA_out = PA_out/PA_maxout; %保持输出的最大功率归一化
end