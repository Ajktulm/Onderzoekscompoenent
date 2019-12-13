Runs = 100000;
T = 10;
Lowerbound = 5;
Upperbound = 15;
mu = 0;
sigma = 1; %Works incredibly bad for sigma=1 (or other low values)
Costs = Lowerbound: (Upperbound-Lowerbound)/49 : Upperbound;
M = length(Costs);

State = zeros(T,1);
Optimalcosts = zeros(Runs,1);
Algocosts = zeros(Runs,1);

for i = 1:Runs
    normal = normrnd(mu,sigma,T-1,1);
    State(1) = Lowerbound + (Upperbound-Lowerbound)*rand;
    for j = 2:T
        State(j) = State(j-1) + normal(j-1); %Go to new state
        State(j) = max(Lowerbound,State(j));
        State(j) = min(Upperbound,State(j)); 
    end
    Optimalcosts(i) = min(State);
    
    for k = 1:T
        if(State(k) <= threshold(k))
           Algocosts(i) = State(k); 
           break
           disp("x")
        end
    end
    
    
end
sum(Algocosts - Optimalcosts)/Runs
