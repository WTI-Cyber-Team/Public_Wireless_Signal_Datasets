function [out_save_IQ] = Single_Carrier_HW_Impairment(IQ,params)


% params.IQ_amp_imba 定义I路相对于Q路的不平衡量，以dB为单位
% params.IQ_phase_imba 定义了I路相对于Q路的相位角差别，以角度为单位
% scatterplot(IQ);

% IQ幅度和相位不平衡，直接引用matlab的示例代码
% gainI = 10.^(0.5*params.IQ_amp_imba/20);
% gainQ = 10.^(-0.5*params.IQ_amp_imba/20);
% imbI = real(IQ)*gainI*exp(-0.5i*params.IQ_phase_deviation*pi/180);
% imbQ = imag(IQ)*gainQ*exp(1i*(pi/2 + 0.5*params.IQ_phase_deviation*pi/180));
% IQ = imbI + 1j*imbQ;
IQ = iqimbal(IQ,params.IQ_amp_imba,params.IQ_phase_imba);

% 添加固定相偏以及随时间波动的频偏
pfo_block = comm.PhaseFrequencyOffset(PhaseOffset=params.phase_offset, FrequencyOffset=params.initial_CFO,SampleRate=params.samp_rate);

IQ = pfo_block(IQ);


%IQ信号功率归一化
IQ = IQ/sqrt(var(IQ));

%back-off
IQ = IQ*sqrt(1/(10^(params.BO/10)));

%hard-limiter(模仿功放限幅效应)
IQ = Hard_limiter(IQ,1);

% 调用功放行为模块
IQ = myPA_model_library(IQ,params.PA_index);

% IQ = awgn(IQ,params.snr,'measured');

out_save_IQ = IQ;



% %信道
% if params.channel == 1
%     %生成信道多径系数
%     alpha =  sqrt( params.channel_var(1) )* exp(1i*2*pi*rand(1));  %第一径系数，瑞丽分布
%     beta = sqrt( params.channel_var(2) )* exp(1i*2*pi*rand(1));    %第二径系数，瑞丽分布
%     gamma = sqrt( params.channel_var(3) )* exp(1i*2*pi*rand(1));   %第三径系数，瑞丽分布
% 
%     %生成不同路径下的数据
%     IQ_PA = [zeros(params.len_stf,1);IQ];                          %需要满足params.len_stf大于params.channel_delay(3)         
%     IQ_path(:,1) = alpha*circshift(IQ_PA,params.channel_delay(1)); %第一径数据
%     IQ_path(:,2) = beta*circshift(IQ_PA,params.channel_delay(2));  %第二径数据
%     IQ_path(:,3) = gamma*circshift(IQ_PA,params.channel_delay(3)); %第三径数据
%     IQ_total = sum(IQ_path.').';
%     IQ_out = IQ_total(params.len_stf+1:end,1);                     %去掉前面的0序列
% else
%     IQ_out = IQ;
% end


% %保留第二个到第10个STF符号，去掉LTF与Payload每个符号里面的CP
% num_stf_bgn = 5*params.len_stf + 1;                                                               %保存的STF数据的起始符号位置
% num_stf_end = 10*params.len_stf ;                                                               %保存的STF数据的结束符号位置
% num_ltf_bgn = 10*params.len_stf + 0.5*params.len_ltf + 1;                                       %保存的STF数据的起始符号位置
% num_ltf_end = 10*params.len_stf + 2.5*params.len_ltf;                                           %保存的STF数据的结束符号位置
% out_preamble = [IQ_out(num_stf_bgn:num_stf_end,1);IQ_out(num_ltf_bgn:num_ltf_end,1)];           %需要保存的前导码数据
% out_payload = reshape(IQ_out(num_ltf_end+1:end,1),1.25*params.len_scr,params.Sybnum);           %串并变换
% out_data = reshape(out_payload(0.25*params.len_scr+1:end,:),params.Sybnum*params.len_scr,1);    %去掉数据段中的冗余

% %测试信道响应是否平滑
% data1 = IQ_PA(1280+256+1:1280+1280,1);
% plot(abs(fft(out_data(1:1024))./fft(data1)))

% out_save_IQ = [out_preamble;out_data];

%观察无噪声下的CFO估计，信道不影响频偏估计
% CFO1 = CFO_estimate(out_preamble(64*9+1:64*9+256*2),256)
% CFO2 = CFO_estimate(out_preamble(1:128),64)
% params.initial_CFO

end












