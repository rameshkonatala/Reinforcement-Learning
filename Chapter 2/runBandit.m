%% clear all;
clear; clc;

%% run epsilon greedy algorithm
clear
epsilons = [0 0.01 0.1]; results.epsilons = epsilons;
bandits = [];
for eps = epsilons
    currentBandit = bandit; currentBandit.epsilon = eps;
    bandits = [bandits;currentBandit];
end

counter = 1;
for bandit = [bandits]'
    bandit.sample_average = true;
    [avg,opt] = bandit.simulate;
    results.avg_reward{counter}= mean(avg,1); results.opt_action{counter}= mean(opt,1);
    counter = counter +1;
end

close all;
figure
for i = [1:numel(epsilons)]
    plot(results.avg_reward{i},'DisplayName',strcat('Epsilon : ',num2str(results.epsilons(i))));
    xlabel('Steps');ylabel('Average reward'); grid on;
    legend('-DynamicLegend'); 
    hold on
end

figure
for i = [1:numel(epsilons)]
    plot(100*results.opt_action{i},'DisplayName',strcat('Epsilon : ',num2str(results.epsilons(i))));
    xlabel('Steps');ylabel('% Optimal action'); grid on;
    legend('-DynamicLegend');
    hold on
end

%% compare sample average vs fixed step for nonstationary
clear
sample_average_bandit = bandit;
sample_average_bandit.iterations = 10000; 
sample_average_bandit.nonstationary = true;
sample_average_bandit.sample_average = true;
[sample_average_avg,sample_average_opt] = sample_average_bandit.simulate;

fixed_step_bandit = bandit;
fixed_step_bandit.iterations = 10000;
fixed_step_bandit.nonstationary = true;
[fixed_step_avg,fixed_step_opt] = fixed_step_bandit.simulate;

close all;
figure
plot(mean(sample_average_avg,1),'DisplayName','?-greedy');xlabel('Steps');ylabel('Average reward');grid on;
hold on
plot(mean(fixed_step_avg,1),'DisplayName','fixed step');
legend('-DynamicLegend');


figure
plot(100*mean(sample_average_opt,1),'DisplayName','?-greedy');xlabel('Steps');ylabel('% Optimal action');grid on;
hold on
plot(100*mean(fixed_step_opt,1),'DisplayName','fixed step');
legend('-DynamicLegend');

%% compare optimistic initial value algorithm
clear
baseline_bandit = bandit;
baseline_bandit.epsilon = 0.1;

initial_value_bandit = bandit;
initial_value_bandit.epsilon = 0;
initial_value_bandit.initial_estimate = 5;

[~,baseline_opt] = baseline_bandit.simulate;
[~,initial_value_opt] = initial_value_bandit.simulate;

close all;
figure
plot(100*mean(baseline_opt,1),'DisplayName','Realistic ?-greedy');
hold on
plot(100*mean(initial_value_opt,1),'DisplayName','Optimistic greedy');
legend('-DynamicLegend');
xlabel('Steps');ylabel('% Optimal action');grid on;

%% UCB algorithm
clear
baseline_bandit = bandit;
baseline_bandit.sample_average = true; 

UCBbandit = bandit;
UCBbandit.UCB = true;
UCBbandit.sample_average = true;
UCBbandit.epsilon = 0;

[baseline_avg,~] = baseline_bandit.simulate;
[UCB_avg,~] = UCBbandit.simulate;

close all;
figure
plot(mean(baseline_avg,1),'DisplayName','?-greedy')
hold on
plot(mean(UCB_avg,1),'DisplayName','UCB c=2')
xlabel('Steps');ylabel('Average reward');grid on;
legend('-DynamicLegend');

%%  gradient bandit algorithms
gradient_bandit = bandit;
gradient_bandit.gradient = true;
gradient_bandit.q_true_mean = 4;

gradient_without_baseline_bandit = bandit;
gradient_without_baseline_bandit.gradient = true;
gradient_without_baseline_bandit.gradient_baseline = false;
gradient_without_baseline_bandit.q_true_mean = 0;

[~,gradient_opt] = gradient_bandit.simulate;
[~,gradient_without_baseline_opt] = gradient_without_baseline_bandit.simulate;

close all;
figure
plot(100*mean(gradient_opt,1),'DisplayName','with baseline');
hold on
plot(100*mean(gradient_without_baseline_opt,1),'DisplayName','without baseline');
legend('-DynamicLegend');
xlabel('Steps');ylabel('% Optimal action');grid on;