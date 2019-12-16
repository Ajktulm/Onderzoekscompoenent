T = 100;
Lowerbound = 5;
Upperbound = 15;
mu = 0;
sigma = 1; %Works incredibly bad for sigma=1 (or other low values)
Costs = Lowerbound: (Upperbound-Lowerbound)/49 : Upperbound;
M = length(Costs);
n = 100000; %Number of simulations
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

if(Thresholdcheck == 0)
   threshold = zeros(T);
   disp('Estimated optimal policy is thresholdbased')
   for i = 1:T
      threshold(i) = Costs(sum(Estimateddecisionmatrix(:,i)));
   end
   figure
   Y = 1:T;
   plot(Y,threshold)
   title('Thresholds')
   xlabel('Epoch')
   ylabel('Threshold')
else
    threshold = zeros(T,1);
    disp('Estimated optimal policy is not thresholdbased')
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
   figure
   Y = 1:T;
   plot(Y,threshold)
   title('Thresholds')
   xlabel('Epoch')
   ylabel('Threshold')
end