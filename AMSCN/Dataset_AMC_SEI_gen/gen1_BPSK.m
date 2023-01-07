clc;
clear;
close all;


addpath("C:\\Users\\yingshanchuan\\Desktop\\untitledfolder\\SEI_Model");




rng(2021);   % �̶��������
% generate source bit sequence
M = 2;
len_seq = 20000; % �����20000�����ŵ�
msg = randi([0 M-1],len_seq,1); % generate 0~1 random bit
symb = pskmod(msg,M,0);           % mapping to BPSK

scatterplot(symb);

% % ��IQ�ֱ��ֵ��һ��������������һ��
% max_v = max([real(symb); imag(symb)]);
% symb = symb/max_v;
% 
% scatterplot(symb);

% raised cosine shaping filter  
rolloff = 0.25;  % ��������
span = 10;       % �ضϳ���
sps = 8;         % �ϲ�������
mode = 'sqrt';   % normal���������˲���sqrt�Ǹ��������˲�
rrcFilter=rcosdesign(rolloff,span,sps,mode); 
IQData = upfirdn(symb,rrcFilter,sps,1);

sig_len = length(symb);
delay_N = sps*span/2;
IQData = IQData(delay_N+1:delay_N+sig_len*sps);  % ȥ����ͷ�ͽ�β���˲���Ⱥ�ӳٵĵ�

params = init_params2();



for snr=-20:4:20
    for i=1:5
        rxIQData = Single_Carrier_HW_Impairment(IQData,params(i));
        rxIQData = awgn(rxIQData,snr,'measured');    
    
        % ������һ��
        rxIQData = rxIQData / sqrt(var(rxIQData));
        rxIQData = rxIQData - mean(rxIQData);

        save(sprintf('../Dataset02_raw/BPSK_%ddB_Device%d.mat',snr,i), "rxIQData");
    end
end




disp("done!!");

 
