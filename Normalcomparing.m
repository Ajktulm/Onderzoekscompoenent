%Input
n = 1000; %#Training steps
Runs = 100000; %Amount of runs to compare with psychic
T = 50;
Lowerbound = 5;
Upperbound = 15;
mu = 0;
sigma = 3; 
Costs = Lowerbound: (Upperbound-Lowerbound)/49 : Upperbound;
M = length(Costs);


%Train algorithm
State = (Lowerbound + Upperbound)/2; %Starting state
[~,Estimatedstatenumber] = min(abs(State - Costs)); %Unnecesary when estimated state space is equal to true state space
Estimatedstate = Costs(Estimatedstatenumber);
Transitions = 0.001*eye(M); %To track transitions; not started at all zeros to avoid divide by 0 errors
for i =1:n %One step is one step of the Markov chain, not a full cycle
    Previousestimatedstate = Estimatedstate;
    Previousestimatedstatenumber = Estimatedstatenumber;
   
    State = State + normrnd(mu,sigma); %Go to new state
    State = max(Lowerbound,State);
    State = min(Upperbound,State);
   
    [~,Estimatedstatenumber] = min(abs(State - Costs)); %Estimate in which state we are
    Estimatedstate = Costs(Estimatedstatenumber);
   
    Transitions(Previousestimatedstatenumber,Estimatedstatenumber) = Transitions(Previousestimatedstatenumber,Estimatedstatenumber) + 1;
   
   
    %if(mod(i,n/100)==0) Will need to find a method to compare to (for me unknown) optimal policy
    %    Probmatrix = Estimatematrix(Transitions); %Estimate probabilitymatrix
    %    [Estimatedcostmatrix, Estimateddecisionmatrix] = ValueiterationMarkov(T,Costs,Probmatrix);
    %    Errors = sum(sum(abs(Estimateddecisionmatrix-Truedecisionmatrix)));
    %    Errorpercentage = Errors/L^2;
    %    Errorovertime(round(i/n*100)) = Errorpercentage;
    %end
end

Probmatrix = Estimatematrix(Transitions);
[Estimatedcostmatrix, Estimateddecisionmatrix] = ValueiterationMarkov(T,Costs,Probmatrix);

Thresholdcheck = 0;
for i = 1:T
   for j = 1:M-1
       if(Estimateddecisionmatrix(j,i) < Estimateddecisionmatrix(j+1,i))
          Thresholdcheck = Thresholdcheck + 1;
          break
       end
   end
end


%Compute threshold strategy
threshold = zeros(T,1);
for i = 1:T %Compute a "possible threshold" (for example if policy is to sell at values 1,2,3,6,8 the threshold is estimated at 3
   V =  Estimateddecisionmatrix(:,i);
   V = V';
   t = [diff(find([1,diff(V),1]))];
   if (length(t) == 1)
       threshold(i) = Costs(M);
   else
       threshold(i) = Costs(t(1));
   end
end



%Compare with psychic 
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
        end
    end
    
    
end
mean(Algocosts)/mean(Optimalcosts)
