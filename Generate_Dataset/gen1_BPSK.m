clc;
clear;
close all;


addpath("/Users/yingshanchuan/WorkSpace/3��ʵ���ҹ���/��8��AMC��SEIģ���ں�/���ݼ�����/�������ݼ�����/SEI_Model");
addpath("/Users/yingshanchuan/WorkSpace/3��ʵ���ҹ���/��8��AMC��SEIģ���ں�/���ݼ�����/�������ݼ�����/AMC_SEI_Data");




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

params = init_params();


for snr=0:5:30
    for i=1:5
        rxIQData = Single_Carrier_HW_Impairment(IQData,params(i));
        rxIQData = awgn(rxIQData,snr,'measured');    
    
        % ������һ��
        rxIQData = rxIQData / sqrt(var(rxIQData));
        rxIQData = rxIQData - mean(rxIQData);
%         scatterplot(rxIQData);
        save(sprintf('AMC_SEI_Mat/BPSK_%ddB_Device%d.mat',snr,i), "rxIQData");
    end
end




disp("done!!");

 
