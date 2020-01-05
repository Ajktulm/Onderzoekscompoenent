function [swek] = Rayleighestimate(fs,fd,Mean,n,T,Lowerbound,Upperbound,Nstates)
nRuns = round(n/T)-1;
Process = Rayleigh_fading(fs,fd,Mean,n);
Process = max(Process,Lowerbound);
Process = min(Process,Upperbound);
Previousincreasing = true;
Increasing = true;

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
[~,Estimatedstatenumber] = min(abs(State - Cheatedcosts));
Estimatedstate = Cheatedcosts(Estimatedstatenumber);
Transitions = 0.001*eye(Nstates);


Algocosts = zeros(1,nRuns);
Optimalcosts = zeros(1,nRuns);

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
    end
end

Probmatrix = Estimatematrix(Transitions);
[Estimatedcostmatrix, Estimateddecisionmatrix] = ValueiterationMarkov(T,1./Costs,Probmatrix);


for i = round(nRuns/5)+1:nRuns
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
               break
           end
        else
            if(Estimateddecisionmatrix(Estimatedstatenumber+Nstates/2,k) == 1) %Making threshold much less severe results in significantly lower costs;
               Algocosts(i) = 1/Run(k); 
               break
            end
        end 
    end 
    if(Algocosts(i) == 0) %Edgecase if deadline is not met;
        Algocosts(i) = Run(T); 
    end
end
swek = mean(Algocosts(round(nRuns/5):nRuns))/mean(Optimalcosts(round(nRuns/5):nRuns));
end