%% Plot the convergence of phase optimization algorithm

clear all; 
close all; clc;

gamma_th_dB = 60; % SNR threshold for outage
sigma_n_sqr_dBm = -60; % Noise Power
p_sig_dBm = 30; % Signal power
n_trials = 10; % no. of trials
n_angle_realizations = 20; % angle realizations
fc = 24.2; % 24.2 GHz
error_th = 1e-10;
path_loss_enabled = 1;
K_r = 1; % IRS subgroup row size
K_c = 1; % IRS subgroup column size
sigma_sqr = 1; % Variance of Rician distribution
L=8; % number of discrete levels
early_stop = 0;
iteration_count = 100;

sim = simulation(sigma_n_sqr_dBm, gamma_th_dB,p_sig_dBm, n_trials,...
    fc, error_th, n_angle_realizations, path_loss_enabled, K_r,...
    K_c, sigma_sqr,iteration_count, L,early_stop);


% define IRS
id_irs = 1;
pos_irs = [0;0;1];
Nx_irs = 1;
Ny_irs = 16;
Nz_irs = 16;
delta_irs = 0.5;
gain_irs = 10;
irs_256 = node(id_irs, Nx_irs, Ny_irs, Nz_irs, delta_irs, pos_irs, gain_irs);
Ny_irs = 8;
Nz_irs = 8;
irs_64 = node(id_irs, Nx_irs, Ny_irs, Nz_irs, delta_irs, pos_irs, gain_irs);

%define BS
id_bs = 2;
pos_bs = [20;-10;2];
Nx_bs = 4;
Ny_bs = 1;
Nz_bs = 2;
delta_bs = 0.5;
gain_bs = 5;
bs = node(id_bs, Nx_bs, Ny_bs, Nz_bs, delta_bs, pos_bs, gain_bs);

% define car
id_car = 2;
pos_car = [1.5;0;1];
Nx_car = 1;
Ny_car = 1;
Nz_car = 1;
delta_car = 0.5;
gain_car = 5;
car = node(id_car, Nx_car, Ny_car, Nz_car, delta_car, pos_car, gain_car);
[history_256] = simulate(bs,irs_256,car, sim);
[history_64]  = simulate(bs,irs_64,car, sim);
%%
fig1 = figure;
hold on;
n=1:iteration_count+1;
plot(n,history_256(:,1),'LineWidth',1.5);
plot(n,history_64(:,1),'LineWidth',1.5);
plot(n,history_256(:,2),'--','LineWidth',1.5);
plot(n,history_64(:,2),'--','LineWidth',1.5);
hold off;
grid on;
xlabel('iteration');
ylabel('objective value');
legend('IRS(256) obj value','IRS(64) obj value',...
'IRS(256) max obj value','IRS(64) max obj value','Location','best');
title('Convergence of phase optimization algorithm');
print(gcf,'convergence.png','-dpng','-r400');
% date = datestr(now,'YYYY.mm.dd.HH.MM');

%%
function [history] = simulate(bs, irs, car,sim)
    d_d = dist_3d(bs.pos, car.pos);
    d_r = dist_3d(bs.pos, irs.pos);
    d_v = dist_3d(irs.pos, car.pos);
    h_d = generate_MIMO_channel(car, bs, d_d,...
        sim.fc, 0, 1e15, 1, sim.path_loss_enabled);
    H_r = generate_MIMO_channel(irs, bs, d_r,...
        sim.fc, 0, 2, 2, sim.path_loss_enabled);
    h_v = generate_MIMO_channel(car, irs, d_v,...
        sim.fc, 0, 1, 1, sim.path_loss_enabled);
    
    [~,~,history] = optimal_phase_shift(h_d, H_r, h_v,...
        sim.error_th,sim.sigma_n_sqr,sim.p_sig, sim.iteration_count,...
        sim.L,sim.early_stop);
end









