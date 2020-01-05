fs = 1000;
fd = 60;
Mean = 10;
n = 100000;
Sell = zeros(1,800);
T = 100;
nRuns = n/T;
Lowerbound = 0.1;
Upperbound = 100;
Nstates = 20;
Increasing = true; %Indicator variable whether process is increasing or decreasing

Process = Rayleigh_fading(fs,fd,Mean,n);
Process = max(Process,Lowerbound);
Process = min(Process,Upperbound);

Cheat = sort(Process);
Cheatedcosts = zeros(1,Nstates);
Cheatedcosts(1) = Lowerbound;
Cheatedcosts(Nstates) = Upperbound;
for i = 2:Nstates-1
   Cheatedcosts(i) = Cheat(i*n/Nstates); 
end
Cheatedcostsincreasing = Cheatedcosts;
Cheatedcostsdecreasing = Cheatedcosts;


State = Process(1);
[~,Estimatedstatenumber] = min(abs(State - Cheatedcosts));
Estimatedstate = Cheatedcosts(Estimatedstatenumber); 
Transitionsincreasing = 0.001*eye(Nstates);
Transitionsdecreasing = 0.001*eye(Nstates);


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
        
        if(Increasing == true)
            Transitionsincreasing(Previousestimatedstatenumber,Estimatedstatenumber) = Transitionsincreasing(Previousestimatedstatenumber,Estimatedstatenumber) + 1;
        else
            Transitionsdecreasing(Previousestimatedstatenumber,Estimatedstatenumber) = Transitionsdecreasing(Previousestimatedstatenumber,Estimatedstatenumber) + 1;
        end

        if(State >= Previousestimatedstate)
            Increasing = true;
        else
            Increasing = false;
        end

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
Sellincreasing = 0;
Selldecreasing = 0;
for i = nRuns/5:nRuns
    if(mod(i,10) == 0) %Update threshold estimates
        Probmatrixincreasing = Estimatematrix(Transitionsincreasing);
        [Estimatedcostmatrixincreasing, Estimateddecisionmatrixincreasing] = ValueiterationMarkov(T,1./Cheatedcosts,Probmatrixincreasing);
        
        Probmatrixdecreasing = Estimatematrix(Transitionsdecreasing);
        [Estimatedcostmatrixdecreasing, Estimateddecisionmatrixdecreasing] = ValueiterationMarkov(T,1./Cheatedcosts,Probmatrixdecreasing);
        
        Thresholdincreasing = zeros(T,1);
        for k = 1:T %Compute a "possible threshold" (for example if policy is to sell at values 1,2,3,6,8 the threshold is estimated at 3)
            V =  Estimateddecisionmatrixincreasing(:,k);
            V = V';
            t = [diff(find([1,diff(V),1]))];
            if (length(t) == 1)
                Thresholdincreasing(k) = 1/Cheatedcosts(Nstates);
            else
                Thresholdincreasing(k) = 1/Cheatedcosts(t(1));
            end
        end
        
        Thresholddecreasing = zeros(T,1);
        for k = 1:T %Compute a "possible threshold" (for example if policy is to sell at values 1,2,3,6,8 the threshold is estimated at 3)
            V =  Estimateddecisionmatrixdecreasing(:,k);
            V = V';
            t = [diff(find([1,diff(V),1]))];
            if (length(t) == 1)
                Thresholddecreasing(k) = 1/Cheatedcosts(Nstates);
            else
                Thresholddecreasing(k) = 1/Cheatedcosts(t(1));
            end
        end
    end
    
    
    
    Run = zeros(1,T);
    for j = 1:T %Do a run and update transitionmatrix;
        Previousestimatedstate = Estimatedstate;
        Previousestimatedstatenumber = Estimatedstatenumber;

        State = Process(T*(i-1)+j);
        Run(j) = State;
        
        [~,Estimatedstatenumber] = min(abs(State - Cheatedcosts)); %Estimate in which state we are
        Estimatedstate = Cheatedcosts(Estimatedstatenumber);
        
        if(Increasing == true) %Depends on if PREVIOUS step was increasing
            Transitionsincreasing(Previousestimatedstatenumber,Estimatedstatenumber) = Transitionsincreasing(Previousestimatedstatenumber,Estimatedstatenumber) + 1;
        else
            Transitionsdecreasing(Previousestimatedstatenumber,Estimatedstatenumber) = Transitionsdecreasing(Previousestimatedstatenumber,Estimatedstatenumber) + 1;
        end

        if(State >= Previousestimatedstate)
            Increasing = true;
        else
            Increasing = false;
        end
    end
    
    Optimalcosts(i) = 1/max(Run);
    for k = 1:T-1
        if(k==1)
           Increasing = true;
        else
            if(Run(k)>= Run(k-1))
                Increasing = true;
            else
                Increasing = false;
            end
        end
        
        if(Increasing == true)
           if(1/Run(k) <= Thresholdincreasing(k)) 
               Algocosts(i) = 1/Run(k); 
               Sellincreasing = Sellincreasing + 1;
               Sell(i-199) = k;
               break
           end
        else
            if(1/Run(k) <= Thresholddecreasing(k)) 
               Algocosts(i) = 1/Run(k); 
               Selldecreasing = Selldecreasing+1;
               Sell(i-199)=k;
               break
            end
        end 
    end 
    if(Algocosts(i) == 0) %Edgecase if deadline is not met;
        Algocosts(i) = 1/Run(T); 
        Deadlinefails = Deadlinefails + 1;
    end
end
mean(Algocosts(nRuns/5:nRuns))/mean(Optimalcosts(nRuns/5:nRuns))
Deadlinefails = Deadlinefails/(nRuns/5*4)

mean(Algocosts)
mean(Optimalcosts)

sign(Probmatrixincreasing - Probmatrixdecreasing) check if there is a
clear trend.