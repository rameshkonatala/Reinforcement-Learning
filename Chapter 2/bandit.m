classdef bandit < dynamicprops
    %BANDIT: a multi armed bandit problem
    % Detailed explanation goes here
    
    properties
        epsilon = 0.1        
        arms = 10
        runs = 2000
        iterations = 1000
        timestep = 0
        true_reward = 0
        initial_estimate = 0
        step_size = 0.1
        UCB_c = 2
        average_reward = 0
        q_true_mean = 0
        
        sample_average = false
        UCB = false
        gradient = false
        gradient_baseline = true
        nonstationary = false
        
        q_true
        q_estimate
        action_count
        action_prob
    end
    
    methods
        function initialize(obj)
            %METHOD1 Summary of this method goes here
            %Detailed explanation goes here
            if obj.nonstationary
                obj.q_true              = zeros(1,obj.arms);
            else
                obj.q_true              = normrnd(obj.q_true_mean,1,[1,obj.arms]);
            end
            
            obj.q_estimate          = zeros(1,obj.arms)+...
                obj.initial_estimate;
            obj.action_count        = zeros(1,obj.arms);
            obj.timestep = 0;
        end
        
        function action = act(obj)
            if rand < obj.epsilon
                action = datasample([1:numel(obj.q_estimate)],1);
            elseif obj.UCB
                UCB_estimation  = obj.q_estimate+...
                    obj.UCB_c*(sqrt(log(obj.timestep+1)./(10^-7+obj.action_count)));
                action = datasample(find(UCB_estimation==max(UCB_estimation)),1);
            elseif obj.gradient
                obj.action_prob = exp(obj.q_estimate)./sum(exp(obj.q_estimate));
                action = randsample([1:numel(obj.q_estimate)],1,true,obj.action_prob);
            else
                action = datasample(find(obj.q_estimate==max(obj.q_estimate)),1);
            end
        end
        
        function reward = advanceTimeStep(obj,action)
            obj.action_count(action)= obj.action_count(action) + 1;
            obj.timestep = obj.timestep +1;
            if obj.nonstationary
                obj.q_true = obj.q_true + normrnd(0,0.01,[1,10]);
            end
            
            reward                  = normrnd(0,1) + obj.q_true(action);
            if obj.sample_average
                obj.q_estimate(action)  = obj.q_estimate(action)+...
                    ((1/obj.action_count(action))*...
                    (reward-obj.q_estimate(action)));
            elseif obj.gradient
                obj.average_reward = ((obj.average_reward*(obj.timestep-1)) + reward)/obj.timestep;
                if ~obj.gradient_baseline
                    obj.average_reward = 0;
                end
                obj.q_estimate(action)  = obj.q_estimate(action)+...
                    ((obj.step_size)*...
                    (reward-obj.average_reward)*(1-obj.action_prob(action)));
            else
                obj.q_estimate(action)  = obj.q_estimate(action)+...
                    ((obj.step_size)*...
                    (reward-obj.q_estimate(action)));
            end
        end
        
        function [avg_reward,optimal_action] = simulate(obj)
            avg_reward = zeros(obj.runs,obj.iterations);
            optimal_action = zeros(size(avg_reward));
            for r = progress(1:obj.runs)
                obj.initialize
                for t = (1:obj.iterations)
                    action = obj.act;
                    reward = obj.advanceTimeStep(action);
                    avg_reward(r,t) = reward;
                    if action == find(obj.q_true == max(obj.q_true),1)
                        optimal_action(r,t) = 1;
                    end
                end
            end
        end
        
    end
end