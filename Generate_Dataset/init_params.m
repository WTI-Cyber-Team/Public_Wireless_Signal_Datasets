function [params] = init_params()


% device1 settings
params(1).IQ_amp_imba = -0.5;
params(1).IQ_phase_imba = -10;
params(1).phase_offset = 0;
params(1).initial_CFO = 100;
params(1).samp_rate = 1e6;
params(1).BO = 3;           % 9
params(1).PA_index = 1;

% device2 settings
params(2).IQ_amp_imba = -0.3;
params(2).IQ_phase_imba = -6;
params(2).phase_offset = 15;
params(2).initial_CFO = 50;
params(2).samp_rate = 1e6;
params(2).BO = 3;           % 9
params(2).PA_index = 2;


% device3 settings
params(3).IQ_amp_imba = -0.1;
params(3).IQ_phase_imba = -2;
params(3).phase_offset = 30;
params(3).initial_CFO = 0;
params(3).samp_rate = 1e6;
params(3).BO = 3;           % 9
params(3).PA_index = 3;


% device4 settings
params(4).IQ_amp_imba = 0.1;
params(4).IQ_phase_imba = 2;
params(4).phase_offset = 45;
params(4).initial_CFO = -50;
params(4).samp_rate = 1e6;
params(4).BO = 3;           % 9
params(4).PA_index = 4;


% device5 settings
params(5).IQ_amp_imba = 0.3;
params(5).IQ_phase_imba = 6;
params(5).phase_offset = 60;
params(5).initial_CFO = -100;
params(5).samp_rate = 1e6;
params(5).BO = 3;           % 9
params(5).PA_index = 5;


end