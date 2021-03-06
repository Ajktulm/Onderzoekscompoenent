tic

Simulations = 50;
x = 10:100;
hold on

Algoratios = zeros(1,90);
for p = 10:100
    Ratio = 0;
    for i = 1:Simulations
        Math = Rayleighestimate(1000,60,10,10000,p,0.1,100,5);
        Ratio = Ratio+Math;
    end
    Algoratios(p-9) = Ratio/Simulations; %fs,fD,mean,n,T,lowerbound,upperbound,Nstates
end
plot(x,Algoratios,'red')



for p = 10:100
    Ratio = 0;
    for i = 1:Simulations
        Math = Rayleighestimate(1000,60,10,10000,p,0.1,100,10);
        Ratio = Ratio+Math;
    end
    Algoratios(p-9) = Ratio/Simulations; %fs,fD,mean,n,T,lowerbound,upperbound,Nstates
end
plot(x,Algoratios,'blue')



for p = 10:100
    Ratio = 0;
    for i = 1:Simulations
        Math = Rayleighestimate(1000,60,10,10000,p,0.1,100,15);
        Ratio = Ratio+Math;
    end
    Algoratios(p-9) = Ratio/Simulations; %fs,fD,mean,n,T,lowerbound,upperbound,Nstates
end
plot(x,Algoratios,'green')



for p = 10:100
    Ratio = 0;
    for i = 1:Simulations
        Math = Rayleighestimate(1000,60,10,10000,p,0.1,100,20);
        Ratio = Ratio+Math;
    end
    Algoratios(p-9) = Ratio/Simulations; %fs,fD,mean,n,T,lowerbound,upperbound,Nstates
end
plot(x,Algoratios,'black')



for p = 10:100
    Ratio = 0;
    for i = 1:Simulations
        Math = Rayleighestimate(1000,60,10,10000,p,0.1,100,50);
        Ratio = Ratio+Math;
    end
    Algoratios(p-9) = Ratio/Simulations; %fs,fD,mean,n,T,lowerbound,upperbound,Nstates
end
plot(x,Algoratios,'cyan')


for p = 10:100
    Ratio = 0;
    for i = 1:Simulations
        Math = Rayleighestimate(1000,60,10,10000,p,0.1,100,100);
        Ratio = Ratio+Math;
    end
    Algoratios(p-9) = Ratio/Simulations; %fs,fD,mean,n,T,lowerbound,upperbound,Nstates
end
plot(x,Algoratios,'yellow')

legend('Nstates=5','Nstates=10','Nstates=15','Nstates=20','Nstates=50','Nstates=100')
hold off