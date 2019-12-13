function [Probmatrix] = Estimatematrix(Transitions)
    Q = length(Transitions(1,:));
    Probmatrix = zeros(Q,Q);

    for i = 1:Q
        Total = sum(Transitions(i,:));
        for j = 1:Q
           Probmatrix(i,j) = Transitions(i,j)/Total; 
        end
    end
end
