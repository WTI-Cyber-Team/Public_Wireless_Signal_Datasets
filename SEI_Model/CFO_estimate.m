function CFO_out = CFO_estimate(STF_signal,STF_num,samp_rate)
%STF_signal为送入的STF信号，STF_num为该段信号重复的STF符号数,STF_num大于等于2
Num1 = length(STF_signal);
STF_each = Num1/STF_num;
STF = reshape(STF_signal,STF_each,STF_num);
CFO_rad = zeros(STF_num-1,1);
for i=1:STF_num-1
    CFO_rad(i) = phase(STF(:,i)'*STF(:,i+1))/(STF_each); 
    CFO_rad(i) = samp_rate*CFO_rad(i)/2/pi;
end
CFO_out = mean(CFO_rad);