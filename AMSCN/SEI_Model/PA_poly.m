function Poly_output=PA_poly(Poly_input,Poly_order,PA_coefficient)
Poly_input_matrix = creat_matrix(Poly_input , Poly_order);
Poly_output=Poly_input_matrix*PA_coefficient;