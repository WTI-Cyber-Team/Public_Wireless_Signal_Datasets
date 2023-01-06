function Poly_output=PA_Saleh(Poly_input,saleh_parameter)
a1 = saleh_parameter(1);
b1 = saleh_parameter(2);
a2 = saleh_parameter(3);
b2 = saleh_parameter(4);
input_abs = abs(Poly_input);
input_phase = angle(Poly_input);

%幅度非线性
denominator1 = a1*input_abs;
numerator1 = 1+b1*input_abs.^2;
signal_abs = denominator1./numerator1;


%相位非线性偏移
denominator2 = a2*input_abs.^2;
numerator2 = 1+b2*input_abs.^2;
signal_phase_degree = denominator2./numerator2; %弧度制
signal_phase = exp(1i*(signal_phase_degree+input_phase));
Poly_output = signal_abs.*signal_phase;
% scatter(input_abs,signal_abs)
% hold on
% scatter(abs(Poly_input),angle(Poly_output./Poly_input))


end