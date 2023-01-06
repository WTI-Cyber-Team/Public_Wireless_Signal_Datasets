function PA_out = PA_CMOS(Rapp_in,cmos_para)
%这个模型是个杂交模型
a = cmos_para(1);
b = cmos_para(2);
c = cmos_para(3);
d = cmos_para(4);
e = cmos_para(5);
f = cmos_para(6);
g = cmos_para(7);
N = length(Rapp_in);
Rapp_abs = abs(Rapp_in);
PA_out=zeros(N,1);

for i=1:N
    s=(1+(a*Rapp_abs(i)/b)^(2*c))^(1/(2*c));
    Rapp_out=a*Rapp_in(i)/s;
    phase1 = d*(Rapp_abs(i)^f)/(1+(Rapp_abs(i)/e)^g);
    PA_out(i) = Rapp_out*exp(1i*phase1);
end



s=(1+(a*Rapp_abs(i)/b)^(2*c))^(1/(2*c));