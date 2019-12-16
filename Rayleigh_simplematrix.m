fs = 1000;
fd = 60;
Mean = 10;
n = 1000;
T = 10;
nRuns = n/T;
Lowerbound = 0.1;
Upperbound = 100;
Nstates = 20;

Process = Rayleigh_fading(fs,fd,Mean,n);
Process = max(Process,Lowerbound);
Process = min(Process,Upperbound);

Cheat = sort(Process);
Cheatedcosts = zeros(1,Nstates);
Cheatedcosts(1) = Lowerbound;
Cheatedcosts(Nstates) = Upperbound;
for i = 2:19
   Cheatedcosts(i) = Cheat(i*n/Nstates); 
end


State = Process(1);
[~,Estimatedstatenumber] = min(abs(State - Cheatedcosts));
Estimatedstate = Cheatedcosts(Estimatedstatenumber);
Transitions = 0.001*eye(Nstates);


Algocosts = zeros(1,nRuns);
Optimalcosts = zeros(1,nRuns);
Deadlinefails = 0;
for i = 1:nRuns/5 %Training algorithm, using very simple decision rule
    Run = zeros(1,T);
    for j = 1:T
        Previousestimatedstate = Estimatedstate;
        Previousestimatedstatenumber = Estimatedstatenumber;

        State = Process(T*(i-1)+j);
        Run(j) = State;

        [~,Estimatedstatenumber] = min(abs(State - Cheatedcosts)); %Estimate in which state we are
        Estimatedstate = Cheatedcosts(Estimatedstatenumber);

        Transitions(Previousestimatedstatenumber,Estimatedstatenumber) = Transitions(Previousestimatedstatenumber,Estimatedstatenumber) + 1;
    end
    
    Optimalcosts(i) = 1/max(Run);
    for k = 1:T-1
        if(Run(k) >= Upperbound/20)
           Algocosts(i) = 1/Run(k); 
           break
        end
        
    end 
    if(Algocosts(i) == 0) %Edgecase if deadline is not met;
        Algocosts(i) = Run(T); 
        Deadlinefails = Deadlinefails + 1;
    end
end

mean(Algocosts(1:nRuns/5))/mean(Optimalcosts(1:nRuns/5)) 
Deadlinefails = Deadlinefails/(nRuns/5)

Deadlinefails = 0;
for i = nRuns/5:nRuns
    if(mod(i,10) == 0) %Update threshold estimates
        Probmatrix = Estimatematrix(Transitions);
        [Estimatedcostmatrix, Estimateddecisionmatrix] = ValueiterationMarkov(T,1./Cheatedcosts,Probmatrix);
        
        threshold = zeros(T,1);
        for k = 1:T %Compute a "possible threshold" (for example if policy is to sell at values 1,2,3,6,8 the threshold is estimated at 3)
            V =  Estimateddecisionmatrix(:,k);
            V = V';
            t = [diff(find([1,diff(V),1]))];
            if (length(t) == 1)
                threshold(k) = 1/Cheatedcosts(Nstates);
            else
                threshold(k) = 1/Cheatedcosts(t(1));
            end
        end
    end
    
    
    
    Run = zeros(1,T);
    for j = 1:T
        Previousestimatedstate = Estimatedstate;
        Previousestimatedstatenumber = Estimatedstatenumber;
        State = Process(T*(i-1)+j);
        Run(j) = State;

        [~,Estimatedstatenumber] = min(abs(State - Cheatedcosts)); %Estimate in which state we are
        Estimatedstate = Cheatedcosts(Estimatedstatenumber);

        Transitions(Previousestimatedstatenumber,Estimatedstatenumber) = Transitions(Previousestimatedstatenumber,Estimatedstatenumber) + 1;
    end
    
    Optimalcosts(i) = 1/max(Run);
    for k = 1:T-1
        if(1/Run(k) <= threshold(k)) 
           Algocosts(i) = 1/Run(k); 
           break
        end
        
    end   
    if(Algocosts(i) == 0) %Edgecase if deadline is not met;
        Algocosts(i) = Run(T); 
        Deadlinefails = Deadlinefails + 1;
    end
end
mean(Algocosts(nRuns/5:nRuns))/mean(Optimalcosts(nRuns/5:nRuns))
Deadlinefails = Deadlinefails/(nRuns/5*4)