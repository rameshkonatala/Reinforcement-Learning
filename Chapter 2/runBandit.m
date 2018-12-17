%% clear all;
clear; clc;

%% plot the reward distribution 
currentBandit = bandit; currentBandit.initialize;samples = 10000;
reward_dist = zeros(samples,currentBandit.arms);
for i = 1:currentBandit.arms
    reward_dist(:,i) = [normrnd(currentBandit.q_true(i),1,[1,samples])]';
end
violin(reward_dist); xlabel("Actions");ylabel("Reward Distribution"); grid minor; legend('off');
hline = refline([0 0]);hline.LineStyle = '--';hline.Color = 'k';
garyfyFigure;

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
    subplot(1,2,1);
    plot(results.avg_reward{i},'DisplayName',strcat('Epsilon : ',num2str(results.epsilons(i))));
    xlabel('Steps');ylabel('Average reward'); grid on;
    pbaspect([1 1 1]);
    legend('-DynamicLegend','Location','southeast'); 
    hold on
end

for i = [1:numel(epsilons)]
    subplot(1,2,2);
    plot(100*results.opt_action{i},'DisplayName',strcat('Epsilon : ',num2str(results.epsilons(i))));
    xlabel('Steps');ylabel('% Optimal action'); grid on;
    pbaspect([1 1 1]);
    legend('-DynamicLegend','Location','southeast'); 
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
subplot(1,2,1);
plot(mean(sample_average_avg,1),'DisplayName','sample average');xlabel('Steps');ylabel('Average reward');grid on;
hold on
plot(mean(fixed_step_avg,1),'DisplayName','fixed step');
legend('-DynamicLegend','Location','southeast');
pbaspect([1 1 1]);


subplot(1,2,2);
plot(100*mean(sample_average_opt,1),'DisplayName','sample average');xlabel('Steps');ylabel('% Optimal action');grid on;
hold on
plot(100*mean(fixed_step_opt,1),'DisplayName','fixed step');
legend('-DynamicLegend','Location','southeast');
pbaspect([1 1 1]);

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
plot(100*mean(baseline_opt,1),'DisplayName','\textbf{Realistic $\epsilon$-greedy}');
hold on
plot(100*mean(initial_value_opt,1),'DisplayName','\textbf{Optimistic greedy}');
leg = legend('-DynamicLegend','Location','southeast');
set(leg,'Interpreter','latex');
xlabel('Steps');ylabel('% Optimal action');grid on;
set(gca,'FontSize',13,'FontWeight','Bold')  

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
plot(mean(baseline_avg,1),'DisplayName','\textbf{$\epsilon$-greedy}')
hold on
plot(mean(UCB_avg,1),'DisplayName','\textbf{UCB c=2}')
xlabel('Steps');ylabel('Average reward');grid on;
leg = legend('-DynamicLegend','Location','southeast');
set(leg,'Interpreter','latex');
set(gca,'FontSize',13,'FontWeight','Bold')

%%  gradient bandit algorithms
gradient_bandit = bandit;
gradient_bandit.gradient = true;
gradient_bandit.q_true_mean = 4;

gradient_without_baseline_bandit = bandit;
gradient_without_baseline_bandit.gradient = true;
gradient_without_baseline_bandit.gradient_baseline = false;
gradient_without_baseline_bandit.q_true_mean = 4;

[~,gradient_opt] = gradient_bandit.simulate;
[~,gradient_without_baseline_opt] = gradient_without_baseline_bandit.simulate;

close all;
figure
plot(100*mean(gradient_opt,1),'DisplayName','\textbf{with baseline}');
hold on
plot(100*mean(gradient_without_baseline_opt,1),'DisplayName','\textbf{without baseline}');
leg = legend('-DynamicLegend','Location','southeast');
set(leg,'Interpreter','latex');
xlabel('Steps');ylabel('% Optimal action');grid on;
set(gca,'FontSize',13,'FontWeight','Bold')