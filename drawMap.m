input = importdata('C:\Users\Shelley\Dropbox\Proyecto\Cuda\ProyectoDefinitivo\Kohonen\Kohonen\input.txt');
mapOrig = importdata('C:\Users\Shelley\Dropbox\Proyecto\Cuda\ProyectoDefinitivo\Kohonen\Kohonen\mapOrig.txt');
mapAfter = importdata('C:\Users\Shelley\Dropbox\Proyecto\Cuda\ProyectoDefinitivo\Kohonen\Kohonen\mapAfter.txt');
hold on
scatter(input(:,1),input(:,2))
scatter(mapOrig(:,1),mapOrig(:,2))
labels = cellstr( num2str([1:60]') );
text(mapAfter(:,1), mapAfter(:,2),labels)

plot(mapAfter(:,1), mapAfter(:,2),'rx');

hold off
