%接收信号的预处理（频谱循环移位相除）
%可以控制SNR，设置不同信噪比下的谱商信号
%采用moose算法估计频偏，two-step方案

clc;
clear;
close all;

%首先每帧信道的数据结构确定了，设定信噪比，对无噪声数据进行加噪
%其次需要对每帧数据进行粗同步
%然后需要对每帧数据进行精同步
%最后提取谱商信号，数据增强方案

load('Data_RandPayload_80MHz_12device_1800samples_AWGN_and_MPFC_Noisefree.mat')
same_ture = 0;

% load('Data_SamePayload_80MHz_12device_1800samples_AWGN_and_MPFC_Noisefree.mat')
% same_ture = 1;

%%%===========================手动调整参数（设定的帧结构参数）===============================
[len_s , col_s] = size(OFDM_sym_awgn);
k = 3;                                 %数据增强倍数，即最大循环移位数
SNR = 30;                              %设置信噪比
len_stf = 64;
len_ltf = 256;
len_syb = 512;
syb_num = 4;
STF_num = 5;
LTF_num = 2;
device_num = 12;
samp_rate = 80e6;
SQ_num = syb_num*len_s/device_num;  %每个设备的谱商信号样本

OFDM_sym_awgn1 = zeros(len_s,col_s);
OFDM_sym_channel1 = zeros(len_s,col_s);

%%%====================信号加噪==========================================
for i = 1:len_s
    OFDM_sym_awgn1(i,:) = awgn(OFDM_sym_awgn(i,:),SNR,'measured');
    OFDM_sym_channel1(i,:) = awgn(OFDM_sym_channel(i,:),SNR,'measured');
end

%%%===================信号拆分====================================
STF_awgn = OFDM_sym_awgn1(:,1:len_stf*STF_num);
LTF_awgn = OFDM_sym_awgn1(:,len_stf*STF_num+1:len_stf*STF_num+len_ltf*LTF_num);
SYB_awgn = OFDM_sym_awgn1(:,len_stf*STF_num+len_ltf*LTF_num+1:end);

STF_chan = OFDM_sym_channel1(:,1:len_stf*STF_num);
LTF_chan = OFDM_sym_channel1(:,len_stf*STF_num+1:len_stf*STF_num+len_ltf*LTF_num);
SYB_chan = OFDM_sym_channel1(:,len_stf*STF_num+len_ltf*LTF_num+1:end);


%%%=============粗频偏估计与抵消===============================
CFO_coarse_awgn = zeros(len_s,1);
CFO_coarse_chan = zeros(len_s,1);
for i = 1:len_s
    %%估计
    CFO_coarse_awgn(i) = CFO_estimate(STF_awgn(i,:),STF_num,samp_rate);    %CFO频率
    CFO_coarse_chan(i) = CFO_estimate(STF_chan(i,:),STF_num,samp_rate);    %CFO频率
    
    %%抵消，需注意抵消完之后，每段symbol残留的相偏不一样了，理想差异为频偏的整数倍，原因是用于抵消的载波起始位置变化了
    CFO_rad_awgn = 2*pi*CFO_coarse_awgn(i)/samp_rate;                      %相邻采样点的频偏
    CFO_rad_chan = 2*pi*CFO_coarse_chan(i)/samp_rate;                      %相邻采样点的频偏
    
    %LTF信号的粗频偏纠正
    carrier_LTF_awgn = exp(-1i*(1:1:len_ltf*LTF_num)*CFO_rad_awgn);        %生成抵消载波序列
    carrier_LTF_chan = exp(-1i*(1:1:len_ltf*LTF_num)*CFO_rad_chan);        %生成抵消载波序列
    LTF_awgn(i,:) = LTF_awgn(i,:).*carrier_LTF_awgn;
    LTF_chan(i,:) = LTF_chan(i,:).*carrier_LTF_chan;
    
    %SYB信号的粗频偏纠正
    carrier_SYB_awgn = exp(-1i*(1:1:len_syb*syb_num)*CFO_rad_awgn);        %生成抵消载波序列
    carrier_SYB_chan = exp(-1i*(1:1:len_syb*syb_num)*CFO_rad_chan);        %生成抵消载波序列
    SYB_awgn(i,:) = SYB_awgn(i,:).*carrier_SYB_awgn;
    SYB_chan(i,:) = SYB_chan(i,:).*carrier_SYB_chan;
    
end

%%观测频偏消除的误差统计分布
% CFO_coarse_error_awgn = CFO_coarse_awgn - CFO_save;
% CFO_coarse_error_chan = CFO_coarse_chan - CFO_save;
% figure
% h1 = histogram(CFO_coarse_error_awgn,'Normalization','probability');
% figure
% h2 = histogram(CFO_coarse_error_chan,'Normalization','probability');


%%%===========精频偏估计与抵消=======================================
CFO_fine_awgn = zeros(len_s,1);
CFO_fine_chan = zeros(len_s,1);
for i = 1:len_s
    %%估计
    CFO_fine_awgn(i) = CFO_estimate(LTF_awgn(i,:),LTF_num,samp_rate);
    CFO_fine_chan(i) = CFO_estimate(LTF_chan(i,:),LTF_num,samp_rate);
    
    %%抵消，需注意抵消完之后，每段symbol残留的相偏不一样了，理想差异为频偏的整数倍，原因是用于抵消的载波起始位置变化了
    %SYB信号的精频偏纠正
    CFO_rad_awgn = 2*pi*CFO_fine_awgn(i)/samp_rate;
    CFO_rad_chan = 2*pi*CFO_fine_chan(i)/samp_rate;    
    carrier_SYB_awgn = exp(-1i*(1:1:len_syb*syb_num)*CFO_rad_awgn);  %生成抵消载波序列
    carrier_SYB_chan = exp(-1i*(1:1:len_syb*syb_num)*CFO_rad_chan);  %生成抵消载波序列
    SYB_awgn(i,:) = SYB_awgn(i,:).*carrier_SYB_awgn;
    SYB_chan(i,:) = SYB_chan(i,:).*carrier_SYB_chan;
    
end

%%观测频偏消除的误差统计分布
% CFO_fine_error_awgn = CFO_fine_awgn + CFO_coarse_error_awgn;
% CFO_fine_error_chan = CFO_fine_chan + CFO_coarse_error_chan;
% figure
% h1 = histogram(CFO_fine_error_awgn,'Normalization','probability');
% figure
% h2 = histogram(CFO_fine_error_chan,'Normalization','probability');

%%%=================谱商信号生成===========================
%%定义空矩阵，需要保存的变量
SYB_awgn = reshape(SYB_awgn.',len_syb,len_s*syb_num);   %矩阵变换
SYB_chan = reshape(SYB_chan.',len_syb,len_s*syb_num);   %矩阵变换
% scatterplot(fft(SYB_awgn(:,1))) %应该是随机相偏噪声扰动的星座图
% scatterplot(fft(SYB_chan(:,1))) %看不出来星座图的样子
label = zeros(len_s*syb_num,1);
SQ_signal_awgn = zeros(1,len_s*syb_num);
SQ_signal_chan = zeros(1,len_s*syb_num);

for i = 1:device_num
    for j = 1:SQ_num
        col = (i-1)*SQ_num + j;
        %读取数据
        data_awgn = SYB_awgn(:,col);
        data_chan = SYB_chan(:,col);
        
        %添加label
        label(col,1) = i;        
        
        %傅里叶变换
        data_awgn_FD = fft(data_awgn);
        data_chan_FD = fft(data_chan);
        
        %k倍增强方案
        len_last = 1;
        for a = 1:k
            SQ_signal_awgn_part = SQ_generate(data_awgn_FD,a);
            SQ_signal_chan_part = SQ_generate(data_chan_FD,a);
            len_sq = length(SQ_signal_awgn_part);
            SQ_signal_awgn(len_last:len_last+len_sq-1,col) = SQ_signal_awgn_part;
            SQ_signal_chan(len_last:len_last+len_sq-1,col) = SQ_signal_awgn_part;
            len_last = len_last+len_sq;
        end        
    end
end

% SQ_signal_awgn = SQ_signal_awgn.';
% 
% SQ_signal_chan = SQ_signal_chan.';
SQ_signal_awgn_aug = SQ_signal_awgn.';

SQ_signal_chan_aug = SQ_signal_chan.';

if same_ture == 1
    save('SQ_signal_30dB_3aug_same','SQ_signal_awgn_aug','SQ_signal_chan_aug','label')
else
    save('SQ_signal_30dB_3aug_rand','SQ_signal_awgn_aug','SQ_signal_chan_aug','label')
end




