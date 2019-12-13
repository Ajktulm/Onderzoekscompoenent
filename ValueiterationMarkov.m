function [Costmatrix, Decisionmatrix] = ValueiterationMarkov(T,Costs,Probmatrix)
    %For decisionmatrix element i,j says whether to sell (1) or not (0) when at state i and time j
    %For costmatrix element i,j represents expected cost at state i and time j
    K = length(Costs);
    Costmatrix = zeros(K,T);
    Decisionmatrix = zeros(K,T);
    for i = 1:K %Fill last columns
       Costmatrix(i,T) = Costs(i); 
       Decisionmatrix(i,T) = 1;
    end

    for i = T-1:-1:1 %Compute columns, working from right to left
        for j = 1:K
            if (Costs(j) <= Probmatrix(j,:) * Costmatrix(:,i+1)) 
                Decisionmatrix(j,i) = 1;
                Costmatrix(j,i) = Costs(j);
            else
                Decisionmatrix(j,i) = 0;
                Costmatrix(j,i) = Probmatrix(j,:) * Costmatrix(:,i+1);
            end
        end

    end
end