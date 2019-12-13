T = 10; 
L = 10;
Truecosts = 1:L;
K = length(Truecosts);
Trueprobmatrix = 1/L * ones(K,K);
[Truecostmatrix, Truedecisionmatrix] = ValueiterationMarkov(T,Truecosts,Trueprobmatrix);

Costs = Truecosts; %ASSUMPTION STATES ARE KNOWN
M = length(Costs);
n = 100000; %Number of simulations
Statenumber = 1; %Starting state for simulation
State = Truecosts(Statenumber); 
Estimatedstatenumber = Statenumber;
Estimatedstate = Costs(Estimatedstatenumber); 
Transitions = 0.001*eye(M); %To track transitions; not started at all zeros to avoid divide by 0 errors
Errorovertime = zeros(100);
for i =1:n %One step is one step of the Markov chain, not a full cycle
    Previousstate = State;
    Previousstatenumber = Statenumber;
    Previousestimatedstate = Estimatedstate;
    Previousestimatedstatenumber = Estimatedstatenumber;
    
    this_step_distribution = Trueprobmatrix(State,:); %Simulate news tep
    cumulative_distribution = cumsum(this_step_distribution); %Placed here for understandability, can be taken outside of loop to slightly improve performance
    r = rand();
    Statenumber = find(cumulative_distribution>r,1); 
    State = Truecosts(Statenumber);
    
    Estimatedstatenumber = Statenumber;
    Estimatedstate = Costs(Estimatedstatenumber); 
    
    Transitions(Previousestimatedstatenumber,Estimatedstatenumber) = Transitions(Previousestimatedstatenumber,Estimatedstatenumber) + 1;
    
    
    if(mod(i,n/100)==0) %Only calculate Probmatrix, decisionmatrix and errors 100 times to save computational effort
        Probmatrix = Estimatematrix(Transitions); %Estimate probabilitymatrix
        [Estimatedcostmatrix, Estimateddecisionmatrix] = ValueiterationMarkov(T,Costs,Probmatrix);
        Errors = sum(sum(abs(Estimateddecisionmatrix-Truedecisionmatrix)));
        Errorpercentage = Errors/L^2;
        Errorovertime(round(i/n*100)) = Errorpercentage;
    end
end

Y = 1:100;
Y = n/100*Y;
subplot(2,1,1)
plot(Y,Errorovertime)
title('Errorpercentage compared to optimal strategy over time')
ylabel('Percentage of wrong decisions')
xlabel('Total amount of Markov steps')
%A wrong decision is for example selling at time epoch 5 and cost 3, when the optimal policy would not sell to minimize expected cost

Thresholdcheck = 0;
for i = 1:T
   for j = 1:L-1
       if(Estimateddecisionmatrix(j,i) < Estimateddecisionmatrix(j+1,i))
          Thresholdcheck = Thresholdcheck + 1; 
       end
   end
end

if(Thresholdcheck == 0)
   threshold = zeros(T);
   disp('Estimated optimal policy is thresholdbased')
   for i = 1:T
      threshold(i) = Costs(sum(Estimateddecisionmatrix(:,i))); 
   end
   subplot(2,1,2)
   Y = 1:T;
   plot(Y,threshold)
   title('Thresholds')
   xlabel('Epoch')
   ylabel('Threshold')
else
    disp('Estimated optimal policy is not thresholdbased')
end

