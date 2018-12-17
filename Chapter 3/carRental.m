classdef carRental < dynamicprops
    %CARRENTAL Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        profit_rent_car     = 10
        cost_car_move       = 2 %cost for moving car
        max_cars            = 20
        cars_LOC_A          = 20
        cars_LOC_B          = 20
        max_car_move        = 5 %maximum cars that can be moved during...
        %night A-->B is +ve
        parking_limit       = 10
        rent_parking        = 4
        
        max_poisson_dist    = 10
        lambda_request_LOC_A    = 3
        lambda_request_LOC_B    = 4
        lambda_return_LOC_A     = 3
        lambda_return_LOC_B     = 2
        gamma                   = 0.9 %discount rate
        theta                   = 0.1 %small value for stopping iteration
        
        State %No of cars at LOC A and B represented in A x B grid
        Value %A function of returns or rewards for a given policy
        Actions %-5:1:5
        %'+':cars moving from A to B ...
        %'-':cars moving from B to A
        Policy %Policy subsetof Actions
        Policies
        poisson_dist
        max_lambda
        problem_setting
        available_problem_settings
    end
    
    methods
        
        function policyIteration(obj)
            %Initialize parameters
            obj.initializeParameters;
            %1.Initialize value and policy
            obj.initializeVAndPi;
            
            while true
                %2.Policy evaluation
                iteration = 0;
                while true
                    iteration = iteration + 1;
                    delta = 0;
                    old_value = obj.Value;
                    for s = progress(1:numel(obj.State))
                        [state.A,state.B] = find(obj.State == s); %get index of state
                        v = obj.Value(state.A,state.B);
                        action = obj.Policy(state.A,state.B);
                        obj.Value(state.A,state.B) = obj.evaluateValue(state,action);
                        delta = max(delta,abs(v - obj.Value(state.A,state.B)));
                    end
                    value_diff = abs(obj.Value-old_value);
                    fprintf('Iteration : %d | Change in value : %.2f | Delta : %.2f \n',iteration,sum(value_diff(:)),delta)
                    if delta < obj.theta
                        break
                    end
                end
                
                %3.Policy improvement
                policy_stable = true;
                updated_states = 0;
                for s = progress(1:numel(obj.State))
                    [state.A,state.B] = find(obj.State == s); %get index of state
                    old_action = obj.Policy(state.A,state.B);
                    obj.Policy(state.A,state.B) = obj.newPolicy(state);
                    if old_action ~= obj.Policy(state.A,state.B)
                        policy_stable = false;
                        updated_states = updated_states+1;
                    end
                end
                fprintf('Policy changed for %d states \n',updated_states)
                obj.Policies = cat(3,obj.Policies,obj.Policy);
                if policy_stable
                    break
                end
            end
        end
        
        
        function initializeParameters(obj)
            counter = 0;
            for i = 1:obj.cars_LOC_A+1
                for j = 1:obj.cars_LOC_B+1
                    counter = counter+1;
                    obj.State(i,j) = counter;
                end
            end
            obj.Actions = [-obj.max_car_move:1:obj.max_car_move];
            obj.max_lambda = max([obj.lambda_request_LOC_A,...
                obj.lambda_request_LOC_B,...
                obj.lambda_return_LOC_A,...
                obj.lambda_return_LOC_B]);
            obj.poisson_dist = zeros(obj.max_poisson_dist,obj.max_lambda);
            for n = 0:obj.max_poisson_dist
                for lambda = 1:obj.max_lambda
                    obj.poisson_dist(n+1,lambda) = poisspdf(n,lambda);
                end
            end
            obj.available_problem_settings = {'original','modified-1'};
            obj.problem_setting =  obj.available_problem_settings{2};
        end
        
        function initializeVAndPi(obj)
            %CARRENTAL Construct an instance of this class
            %   Detailed explanation goes here
            obj.Value = zeros(obj.cars_LOC_A+1,obj.cars_LOC_B+1);
            obj.Policy = zeros(obj.cars_LOC_A+1,obj.cars_LOC_B+1);
            obj.Policies = obj.Policy;
        end
        
        function value = evaluateValue(obj,s,a)
            %Calculate the value of the state for a given action according
            %to a policy
            
            %trasition of state s to new state after taking action a
            s.A = s.A - a;
            s.B = s.B + a;
            
            cost_moving = obj.cost_car_move * abs(a);
            cost_parking = 0;
            if strcmp(obj.problem_setting, 'modified-1')
                if a>0 %cost lessend by one car if it has to move from AtoB
                    cost_moving = obj.cost_car_move * (a-1);
                end
                cost_parking = (min(1,(floor(s.A/obj.parking_limit)))+...
                    min(1,floor(s.B/obj.parking_limit)))*obj.rent_parking;
            end
            
            %valid car requests or returns is dependent on state
            %max requests or returns capped at 10 to reduce computation
            valid_A_req = 0:min(obj.max_poisson_dist,s.A-1);
            valid_B_req = 0:min(obj.max_poisson_dist,s.B-1);
            valid_A_ret = 0:min(obj.max_poisson_dist,obj.cars_LOC_A+1-s.A);
            valid_B_ret = 0:min(obj.max_poisson_dist,obj.cars_LOC_B+1-s.B);
            max_valid_A_req = max(valid_A_req);
            max_valid_B_req = max(valid_B_req);
            max_valid_A_ret = max(valid_A_ret);
            max_valid_B_ret = max(valid_B_ret);
            
            value = 0;
            sum_p_i = 0;
            for i = valid_A_req
                if i == max_valid_A_req
                    p_i = 1 - sum_p_i;
                else
                    p_i = obj.poisson_dist(i+1,obj.lambda_request_LOC_A);
                    sum_p_i = sum_p_i + p_i;
                end
                sum_p_j = 0;
                for j = valid_B_req
                    if j == max_valid_B_req
                        p_j = 1 - sum_p_j;
                    else
                        p_j = obj.poisson_dist(j+1,obj.lambda_request_LOC_B);
                        sum_p_j = sum_p_j + p_j;
                    end
                    sum_p_k = 0;
                    for k = valid_A_ret
                        if k == max_valid_A_ret
                            p_k = 1 - sum_p_k;
                        else
                            p_k = obj.poisson_dist(k+1,obj.lambda_return_LOC_A);
                            sum_p_k = sum_p_k + p_k;
                        end
                        sum_p_l = 0;
                        for l = valid_B_ret
                            if l == max_valid_B_ret
                                p_l = 1 - sum_p_l;
                            else
                                p_l = obj.poisson_dist(l+1,obj.lambda_return_LOC_B);
                                sum_p_l = sum_p_l + p_l;
                            end
                            reward = (i+j)*obj.profit_rent_car;
                            value = value + (p_i*p_j*p_k*p_l)*(reward-cost_moving-cost_parking+(obj.gamma*obj.Value(s.A-i+k,s.B-j+l)));
                        end
                    end
                end
            end
        end
        
        function best_action = newPolicy(obj,s)
            %Create a new policy for the given state
            valid_action = obj.makeValidAction(s);
            best_action = obj.Policy(s.A,s.B);
            value_action = -inf;
            for action = valid_action
                current_value_action = obj.evaluateValue(s,action);
                if current_value_action > value_action
                    best_action = action;
                    value_action = current_value_action;
                end
            end
        end
        
        function valid_action = makeValidAction(obj,s)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            valid_action = [];
            for action = obj.Actions
                new_s.A = s.A - action;
                new_s.B = s.B + action;
                if new_s.A-1 >= 0 && new_s.A-1 <= obj.cars_LOC_A
                    if new_s.B-1 >= 0 && new_s.B-1 <= obj.cars_LOC_B
                        valid_action = [valid_action,action];
                    end
                end
            end
        end
        
        function plotResults(obj)
            figure
            counter = 0;
            [X,Y] = meshgrid(0:obj.cars_LOC_A,0:obj.cars_LOC_B);
            min_c = ceil(sqrt(size(obj.Policies,3)));
            c = min_c; r = ceil((1+size(obj.Policies,3))/c);
            while counter<size(obj.Policies,3)
                counter = counter+1;
                Z = obj.Policies(:,:,counter);
                subplot(r,c,counter);
                colormap bone;
                pcolor(X,Y,Z);pbaspect([1 1 1]);
                xlabel('# cars at 2nd Location');
                ylabel('# cars at 1st Location');
                title(strcat('\pi_',string(counter-1)));
                if counter ==3
                    colorbar;
                end
            end
            subplot(r,c,counter+1);
            surf(X,Y,obj.Value);colorbar;pbaspect([1 1 1]);
            grid minor;
            zlabel('Value');
            title(sprintf('$v_%d$',4),'Interpreter','latex');
            set(findall(gcf,'-property','FontSize'),'FontWeight','Bold');
            garyfyFigure
        end
        
    end
end


