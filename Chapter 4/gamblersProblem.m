classdef gamblersProblem < dynamicprops
    %GAMBLERSPROBLEM Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        ph = 0.4 % probability that coin turn up is heads
    end
    
    properties (Constant)
        max_capital = 100
        min_capital = 0
        reward_goal = 1
        gamma = 1
        theta = 1e-08
    end
    
    properties (Access = public)
        State
        StatePlus
        Policy
        Value
    end
    
    methods
        function obj = gamblersProblem(ph)
            %GAMBLERSPROBLEM Construct an instance of this class
            %   Detailed explanation goes here
            obj.ph = ph;
        end
        
        function valueIteration(obj)
            %Will run the value iteration algorithm
            obj.initialize;
            iteration = 0;
            
            %Run value iteration to get V*
            while true
                delta = 0;
                iteration = iteration + 1;
                old_value = obj.Value;
                for s = progress(obj.State)
                    v = obj.Value(s==obj.StatePlus);
                    a = obj.evaluateBestAction(s);
                    v_a = obj.evaluateValue(s,a);
                    obj.Value(s==obj.StatePlus) = v_a;
                    delta = max(delta,abs(v-obj.Value(s==obj.StatePlus)));
                end
                if delta < obj.theta
                    break
                end
                value_diff = abs(old_value - obj.Value);
                fprintf('Iteration : %d | Change in value : %.2f | Delta : %.3f \n',iteration,sum(value_diff(:)),delta)
            end
            
            %Get pi* from V*
            for s = obj.State
                obj.Policy(s==obj.StatePlus) = obj.evaluateBestAction(s);
            end
        end
        
        function best_action = evaluateBestAction(obj,s)
            res.valid_actions = validAction(s);
            value_action = -inf;
            for a  = res.valid_actions
                res.value_action(a==res.valid_actions) = obj.evaluateValue(s,a);
            end
            
            best_action = res.valid_actions(max(res.value_action)==res.value_action);
            best_action = datasample(best_action,1);
            function valid_actions = validAction(s)
                valid_actions = [1:1:min(s,obj.max_capital-s)];
            end
        end
        
        function value = evaluateValue(obj,s,a)
            s_head = s+a;
            s_tail = s-a;
            if( s_head >= 100 ) % we win "1" if we get a head
                v_head = obj.ph*( obj.reward_goal ); 
            else                % otherwise our reward is zero
                v_head = obj.ph*( 0 + obj.gamma*obj.Value(s_head==obj.StatePlus));
            end
            
            if( s_tail <= 0 )  % we loose all our money on a tail
                v_tail = (1-obj.ph)*0;
            else               % otherwise our reward is zero
                v_tail = (1-obj.ph)*( 0 + obj.gamma*obj.Value(s_tail==obj.StatePlus));
            end

            value = v_head + v_tail;
        end
        
        function initialize(obj)
            %initialize default values
            %   Detailed explanation goes here
            obj.State = 1:obj.max_capital-1;
            obj.StatePlus = 0:obj.max_capital;
            obj.Policy = zeros(1,obj.max_capital+1);
            obj.Value = zeros(1,obj.max_capital+1);
            obj.Value(end) = 1;
        end
        
        function plotResults(obj)
            figure
            subplot(1,2,1);
            plot(obj.StatePlus,obj.Value,'linewidth',1.5);xlabel('Capital');ylabel('Value Estimates');grid minor;;
            
            subplot(1,2,2);
            stairs(obj.StatePlus,obj.Policy,'linewidth',1.5);xlabel('Capital');ylabel('Final Policy');grid minor;
            
            set(findall(gcf,'-property','FontSize'),'FontWeight','Bold')
        end
    end
end

