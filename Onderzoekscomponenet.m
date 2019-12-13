T = 10; %Simple moderately realistic example
L = 10;
Costs = 1:L;
K = length(Costs);
Probmatrix = 1/L * ones(K,K);
Decisionmatrix = zeros(K,T); 
Costmatrix = zeros(K,T); 
[Costmatrix, Decisionmatrix] = ValueiterationMarkov(T,Costs,Probmatrix)





T=3; %Example proving decision method is not always thresholdbased
Costs = [1,2,3,4];
Probmatrix = [0,1,0,0;1,0,0,0;0,0,0,1;0,0,1,0];
[Costmatrix, Decisionmatrix] = ValueiterationMarkov(T,Costs,Probmatrix)