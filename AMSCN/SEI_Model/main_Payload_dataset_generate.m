clc;
clear;
close all;

%%%%%% 设定：信道带宽为160MHz
%%%%%% step1: 生成OFDM数据段信号，2个OFDM symbol
%%%%%% step2: 调用HW_Impairment模块
%%%%%% step3: 保存无噪声与多径无噪声的接收机的前导码IQ数据
%%%%%% 每种情景保存样本总数为2*sample_num*device_num

% fc = 2.4e9;                               %ISM频段
% ppm = 2e-5;

%%%==========设置wi-fi信号的环境================================
cfgVHT = wlanVHTConfig('ChannelBandwidth', 'CBW80');
IQData_STF = wlanLSTF(cfgVHT);
IQData_LTF = wlanLLTF(cfgVHT);


%===========设置函数参数================================

params.samp_rate = 80e6;                  % Hz,采样率等于带宽

params.BO = 9;                            % 相对饱和功率的信号平均功率的back-off大小

params.len_scr = 512;                     % payload中的符号长度，不加CP

params.len_stf = length(IQData_STF)/10;   % 每个STF符号长度

params.len_ltf = length(IQData_LTF)/2.5;  % 每个LTF符号长度

params.Sybnum = 4;                        % 设定的PPDU里面payload的OFDM数

params.channel_var = [0.8,0.15,0.05];     % 信道系数方差

params.channel_delay = [0,1,3];           % 信道时延

device_num = 12;                          % 设备总数

same_ture = 1;                            %是否是相同pattern的数据

M = 16;                                   % QAM调制阶数

len_save = params.len_stf*5+params.len_ltf*2+params.Sybnum*params.len_scr; %5个STF符号，2个LTF符号，params.Sybnum个symbol

sample_num = 400; %每设备保存的信号样本数


%%%%%%=======设备的参数控制=================================================

%IQ增益和角度不平衡参数
IQ_gain_ratio = -0.97:0.17:0.90;
IQ_phase = [-11:1.8:-2, 2:1.8:11];

%中心CFO参数设置 
%params.samp_rate/2/len_save;%需要注意的是initial_CFO值必须要小于CFO_max，不然无法消除频偏（）
CFO_center = (-1100:200:1100)*5;  %中心点间隔350Hz
CFO_scale = 320*5;                %以中心点开始，CFO波动范围为300Hz，采用均匀分布

%存储数据矩阵预设定
OFDM_sym_channel = zeros(sample_num*device_num,len_save);  %保存的sample里面已经去CP了，只要两个symbol位置
OFDM_sym_awgn = zeros(sample_num*device_num,len_save);     %保存的sample里面已经去CP了，只要两个symbol位置
CFO_save = zeros(sample_num*device_num,1);                 %保存的sample里面每次的initial_CFO值


%随机产生某种固定pattern的OFDM符号
% msg1 = randi([0 M-1],params.len_scr,params.Sybnum);
load('msg1_sybnum4.mat') %params.Sybnum = 4时随机固定的symbol记录

% IQ有损调制过程
for i =1:device_num %发射机编号
    %发射机静态参数设定(IQ不平衡以及设备号对应的非线性)
    params.PA_index = i;                              % 设备编号
    params.IQ_amp_imba = IQ_gain_ratio(i);            % dB
    params.IQ_phase_imba = IQ_phase(i);               % 角度        
    for j =1:sample_num    
        %发射机动态参数设定(频偏以及相偏)
        params.phase_offset = 360*(rand(1)-0.5);                                  % 角度-180,180随机相位
        params.initial_CFO = CFO_center(i) + CFO_scale*(rand(1)-0.5);             % Hz
        
        %payload信号产生
        if same_ture == 1
            msg = msg1;
        else
            msg = randi([0 M-1],params.len_scr,params.Sybnum);                                       % generate 0~1 random bit            
        end
        symb = qammod(msg,M);                                                     % mapping to QPSK
        IQData1 = ifft(symb);                                                     % OFDM调制 
        
        %incert CP
        IQData2 = [IQData1(0.75*params.len_scr+1:params.len_scr,:);IQData1];                     % 加CP,CP长度占符号长度的25%
        
        %串并变换
        IQData3 = reshape(IQData2,1.25*params.len_scr*params.Sybnum,1);
        
        %组简化帧，不考虑SIG字段
        IQData = [IQData_STF; IQData_LTF; IQData3/sqrt(var(IQData3))];       
        
        %指纹信号产生
        params.channel = 0;                                                       % 1为ture，加入信道干扰，0为false
        OFDM_sym_awgn((i-1)*sample_num+j,:) = HW_Impairment(IQData,params);       % 没有加噪声
        params.channel = 1;                                                       % 1为ture，加入信道干扰，0为false
        OFDM_sym_channel((i-1)*sample_num+j,:) = HW_Impairment(IQData,params);    % 没有加噪声
        CFO_save((i-1)*sample_num+j,1) = params.initial_CFO;
    end
end

if same_ture == 1
    save('Data_SamePayload_80MHz_12device_1800samples_AWGN_and_MPFC_Noisefree','OFDM_sym_awgn','OFDM_sym_channel','CFO_save')
else
    save('Data_RandPayload_80MHz_12device_1800samples_AWGN_and_MPFC_Noisefree','OFDM_sym_awgn','OFDM_sym_channel','CFO_save')
end




