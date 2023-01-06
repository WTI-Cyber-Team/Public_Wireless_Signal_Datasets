function Rapp_out=PA_Rapp(Rapp_in,rapp_para)
%Rapp_in为N*1的
%alpha为饱和输出功率控制
%beta为光滑因子
%Rapp_x_max与Rapp_y_max用于输入输出归一化
a = rapp_para(1);
b = rapp_para(2);
c = rapp_para(3);
N = length(Rapp_in);
Rapp_abs = abs(Rapp_in);
Rapp_out=zeros(N,1);

for i=1:N
    s=(1+(a*Rapp_abs(i)/b)^(2*c))^(1/(2*c));
    Rapp_out(i)=a*Rapp_in(i)/s;
end