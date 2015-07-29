x= zeros(100,100);
y=single(x);
tic
g=gpuArray(y);
g2=g+1;
toc