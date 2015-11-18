inputPrompt = inputdlg({'Introduzca el nombre del archivo que contiene el mapa:',
     'Introduzca el numero de epocas para la primera fase de aprendizaje:',
     'Introduzca el numero de epocas para la segunda fase de aprendizaje :',
     'Introduzca el numero a partir del cual la segunda fase se convierte en la tercera :',
     'Introduzca el numero de veces mas grande que tiene que ser el mapa con respecto a la entrada :',
     'Introduzca el valor de aprendizaje para las dos primeras fases de aprendizaje :',
     'Introduzca el valor de aprendizaje para la tercera fase de aprendizaje :'},...
              'Kohonen', [1 70; 1 70; 1 70; 1 70; 1 70; 1 70; 1 70]);

inputFile = inputPrompt(1)
numEpoch1=str2num(cell2mat(inputPrompt(2)))
numEpoch2=str2num(cell2mat(inputPrompt(3)))
numEpoch3=str2num(cell2mat(inputPrompt(4)))
timesMap=str2num(cell2mat(inputPrompt(5)))
eta1=single(str2num(cell2mat(inputPrompt(6))))
eta2=single(str2num(cell2mat(inputPrompt(7))))

t = datestr(now,30)

path = importdata('path')

input = importdata(strjoin([path,'\',inputFile],''))

makeDir =cell2mat(strcat(path,'\MATLAB-',t,'-',inputFile,'-',num2str(numEpoch1),'-',num2str(numEpoch2),'-',num2str(numEpoch3),'-',num2str(timesMap),'-',num2str(eta1),'-',num2str(eta2)));
mkdir(makeDir)

[numInputs,inputSize]=size(input);

angulo = 360 / (numInputs * timesMap);
map = single(zeros(inputSize,timesMap*numInputs));
for i=0:numInputs*timesMap-1
   map(1,i*inputSize+1)=cos(angulo*i*pi/180);
   map(2,i*inputSize+1)=sin(angulo*i*pi/180);
end

maxInputY=max(input(:,2));
maxInputX=max(input(:,1));
minInputX=min(input(:,1));
minInputY=min(input(:,2));

inputNorm= single(zeros(size(input)));

inputNorm(:,1)=bsxfun(@minus,input(:,1),(minInputX + maxInputX)/2);
inputNorm(:,1)=bsxfun(@rdivide,inputNorm(:,1)*1.5,(maxInputX - minInputX));

inputNorm(:,2)=bsxfun(@minus,input(:,2),(minInputY + maxInputY)/2);
inputNorm(:,2)=bsxfun(@rdivide,inputNorm(:,2)*1.5,(maxInputY - minInputY));

aux = strcat(makeDir,'\input.txt');
save(aux,'inputNorm');
aux = strcat(makeDir,'\mapOrig.txt');
save(aux,'map');

tic
hits_d= gpuArray(zeros(1,numInputs));
map_d= gpuArray(map);
input_d = gpuArray(inputNorm);

for epoch = 1:numEpoch1
    hI=gpuArray(single(zeros(1,numInputs)));
    
    hR1=bsxfun(@times,weight(1:2:inputSize*numInputs)/2,input_d(1));
    hR2=bsxfun(@times,weight(2:2:inputSize*numInputs)/2,input_d(2));
    hR=bsxfun(@plus,hR1,hR2);
    hI=min(hI,hR');
    
    
end
for epoch = 1:numEpoch2
    if (epoch<numEpoch3)
        
    end
    if (epoch<numEpoch3)
        
    end
end

weight=gather(weight_d);
toc
aux = strcat(makeDir,'\mapAfter.txt');
save(aux,'map');