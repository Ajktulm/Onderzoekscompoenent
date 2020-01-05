fs = 1000;
fd = 60;
Mean = 10;
n = 100000;
T = 1000;
nRuns = n/T;
Lowerbound = 0.1;
Upperbound = 100;
Nstates = 20;
Previousincreasing = true;
Increasing = true;

Process = Rayleigh_fading(fs,fd,Mean,n);
Process = max(Process,Lowerbound);
Process = min(Process,Upperbound);

Cheat = sort(Process);
Cheatedcosts = zeros(1,Nstates);
Cheatedcosts(1) = Lowerbound;
Cheatedcosts(Nstates) = Upperbound;
for i = 2:Nstates-1
   Cheatedcosts(i) = Cheat(round(i*n/Nstates)); 
end
Costs = [Cheatedcosts,Cheatedcosts];
Nstates = 2*Nstates;


State = Process(1);
[~,Estimatedstatenumber] = min(abs(State - Costs));
Estimatedstate = Costs(Estimatedstatenumber);
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
        
        Previousincreasing = Increasing;
        
        if(State >= Previousestimatedstate)
            Increasing = true;
        else
            Increasing = false;
        end
        
        if(Previousincreasing == true)
            if(Increasing == true)
                Transitions(Previousestimatedstatenumber,Estimatedstatenumber) = Transitions(Previousestimatedstatenumber,Estimatedstatenumber) + 1;
            else
                Transitions(Previousestimatedstatenumber,Estimatedstatenumber+Nstates/2) = Transitions(Previousestimatedstatenumber,Estimatedstatenumber+Nstates/2) + 1;
            end
        else
            if(Increasing == true)
                Transitions(Previousestimatedstatenumber+Nstates/2,Estimatedstatenumber) = Transitions(Previousestimatedstatenumber+Nstates/2,Estimatedstatenumber) + 1;
            else
                Transitions(Previousestimatedstatenumber+Nstates/2,Estimatedstatenumber+Nstates/2) = Transitions(Previousestimatedstatenumber+Nstates/2,Estimatedstatenumber+Nstates/2) + 1;
            end     
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
Sellincreasing = 0;
Selldecreasing = 0;

Deadlinefails = 0;
for i = nRuns/5:nRuns
    if(mod(i,10) == 0) %Update threshold estimates
        Probmatrix = Estimatematrix(Transitions);
        [Estimatedcostmatrix, Estimateddecisionmatrix] = ValueiterationMarkov(T,1./Costs,Probmatrix);
    end
    
    
    
    Run = zeros(1,T);
    for j = 1:T
        Previousestimatedstate = Estimatedstate;
        Previousestimatedstatenumber = Estimatedstatenumber;
        State = Process(T*(i-1)+j);
        Run(j) = State;

        [~,Estimatedstatenumber] = min(abs(State - Cheatedcosts)); %Estimate in which state we are
        Estimatedstate = Cheatedcosts(Estimatedstatenumber);

        Previousincreasing = Increasing;
        
        if(State >= Previousestimatedstate)
            Increasing = true;
        else
            Increasing = false;
        end
        
        if(Previousincreasing == true)
            if(Increasing == true)
                Transitions(Previousestimatedstatenumber,Estimatedstatenumber) = Transitions(Previousestimatedstatenumber,Estimatedstatenumber) + 1;
            else
                Transitions(Previousestimatedstatenumber,Estimatedstatenumber+Nstates/2) = Transitions(Previousestimatedstatenumber,Estimatedstatenumber+Nstates/2) + 1;
            end
        else
            if(Increasing == true)
                Transitions(Previousestimatedstatenumber+Nstates/2,Estimatedstatenumber) = Transitions(Previousestimatedstatenumber+Nstates/2,Estimatedstatenumber) + 1;
            else
                Transitions(Previousestimatedstatenumber+Nstates/2,Estimatedstatenumber+Nstates/2) = Transitions(Previousestimatedstatenumber+Nstates/2,Estimatedstatenumber+Nstates/2) + 1;
            end     
        end
    end
    
    Optimalcosts(i) = 1/max(Run);
    for k = 1:T-1
        State = Run(k);
        [~,Estimatedstatenumber] = min(abs(State - Cheatedcosts));
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
           if(Estimateddecisionmatrix(Estimatedstatenumber,k) == 1) 
               Algocosts(i) = 1/Run(k); 
               Sellincreasing = Sellincreasing + 1;
               break
           end
        else
            if(Estimateddecisionmatrix(Estimatedstatenumber+Nstates/2,k) == 1) %Making threshold much less severe results in significantly lower costs;
               Algocosts(i) = 1/Run(k); 
               Selldecreasing = Selldecreasing+1;
               break
            end
        end 
    end
    if(Algocosts(i) == 0) %Edgecase if deadline is not met;
        Algocosts(i) = Run(T); 
        Deadlinefails = Deadlinefails + 1;
    end
end
mean(Algocosts(nRuns/5:nRuns))/mean(Optimalcosts(nRuns/5:nRuns))
Deadlinefails = Deadlinefails/(nRuns/5*4)