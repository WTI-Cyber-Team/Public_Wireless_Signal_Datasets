%函数 output = Hard_limiter(输入幅度向量，最大幅度输入）
function output = Hard_limiter(input,max_input)
N=length(input);
output=zeros(N,1);
for i=1:N
    if abs(input(i))<max_input
        output(i)=input(i);
    else
        output(i)=max_input*input(i)/abs(input(i));
    end
end