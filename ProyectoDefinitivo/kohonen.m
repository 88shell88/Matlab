clear 
clc
inputPrompt = inputdlg({'Introduzca el nombre del archivo que contiene el mapa:',
     'Introduzca el numero de epocas para la primera fase de aprendizaje:',
     'Introduzca el numero de epocas para la segunda fase de aprendizaje :',
     'Introduzca el numero a partir del cual la segunda fase se convierte en la tercera :',
     'Introduzca el numero de veces mas grande que tiene que ser el mapa con respecto a la entrada :',
     'Introduzca el valor de aprendizaje para las dos primeras fases de aprendizaje :',
     'Introduzca el valor de aprendizaje para la tercera fase de aprendizaje :'},...
              'Kohonen', [1 70; 1 70; 1 70; 1 70; 1 70; 1 70; 1 70]);

inputFile = inputPrompt(1);
numEpoch1=str2num(cell2mat(inputPrompt(2)));
numEpoch2=str2num(cell2mat(inputPrompt(3)));
numEpoch3=str2num(cell2mat(inputPrompt(4)));
timesMap=str2num(cell2mat(inputPrompt(5)));
eta1=single(str2num(cell2mat(inputPrompt(6))));
eta2=single(str2num(cell2mat(inputPrompt(7))));

t = datestr(now,30);

path = importdata('path');

input = importdata(strjoin([path,'\',inputFile],''));

makeDir =cell2mat(strcat(path,'\MATLAB-',t,'-',inputFile,'-',num2str(numEpoch1),'-',num2str(numEpoch2),'-',num2str(numEpoch3),'-',num2str(timesMap),'-',num2str(eta1),'-',num2str(eta2)));
mkdir(makeDir);

[numInputs,inputSize]=size(input);

angulo = 360 / (numInputs * timesMap);
map = single(zeros(inputSize,timesMap*numInputs));
for i=0:numInputs*timesMap-1
   map(1,i+1)=cos(angulo*i*pi/180);
   map(2,i+1)=sin(angulo*i*pi/180);
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
map2=map';
save(aux,'map2');

tic
hits_d= gpuArray(ones(numInputs,timesMap*numInputs));
map_d= gpuArray(map);
input_d = gpuArray(inputNorm);
distance_d = gpuArray(zeros(numInputs * timesMap, numInputs));

fun_distance = @(A,B) (A-B).^2;

for epoch = 1:numEpoch1
    eta=eta1;
    hI=gpuArray(zeros(size(map_d)));
    input_aux=gpuArray(zeros(size(map_d)));
    %Calcular distancia euclidea
%     for i=1:numInputs
%         distance_d(:,i)=bsxfun(@times,sqrt(bsxfun(@plus,bsxfun(@minus,map_d(1,:),input_d(i,1)).^2 , bsxfun(@minus,map_d(2,:),input_d(i,2)).^2)),hits_d(1,i)/epoch);
%     end  
    distance_d=sqrt(bsxfun(@plus,bsxfun(@minus,map_d(1,:),input_d(:,1)).^2 , bsxfun(@minus,map_d(2,:),input_d(:,2)).^2));
    distance_d=bsxfun(@times,distance_d',hits_d');
    maxMapInd1=0;
    for i=1:numInputs * timesMap
        [hI(1,i),hI(2,i)]=min(distance_d(i,:));
        input_aux(1,i)=input_d(hI(2,i),1);
        input_aux(2,i)=input_d(hI(2,i),2);
        bool=0;
        for j=1:numInputs * timesMap
            if hI(2,i)==j && bool==0
                hits_d(j,:)=bsxfun(@plus,hits_d(j,:),1);
                bool=1;
            end
        end
    end
    
    mapInd=hI(2,i);
        if mapInd>maxMapInd1
            maxMapInd1=mapInd;
        end
    map_d=bsxfun(@plus,map_d,eta*bsxfun(@minus,input_aux,map_d));
end
for epoch = 1:numEpoch2
    eta=eta1 - eta1 /100;
    hI2=gpuArray(zeros(size(input_d')));
    %hI2=gpuArray(zeros(size(map_d)));
    input_aux2=gpuArray(zeros(size(map_d)));
    map_aux0=gpuArray(zeros(size(map_d)));
    map_aux1=gpuArray(zeros(size(map_d)));
    %Calcular distancia euclidea
%     for i=1:numInputs
%         distance_d(:,i)=sqrt(bsxfun(@plus,bsxfun(@minus,map_d(1,:),input_d(i,1)).^2 , bsxfun(@minus,map_d(2,:),input_d(i,2)).^2));
%     end
    distance_d=sqrt(bsxfun(@plus,bsxfun(@minus,map_d(1,:),input_d(:,1)).^2 , bsxfun(@minus,map_d(2,:),input_d(:,2)).^2));
    if (epoch>numEpoch3)
        eta=eta2;
        
    end
    maxMapInd=0;
    for i=1:numInputs
        [hI2(1,i),hI2(2,i)]=min(distance_d(i,:));        
        mapInd=hI2(2,i);
        if mapInd>maxMapInd
            maxMapInd=mapInd;
        end
    end  
        [C,ia,ic]=unique(hI2(2,:));
        map_aux0(1,C)=map_d(1,C);
        map_aux0(2,C)=map_d(2,C);
        
        input_aux2(1,C)=input_d(ia,1);
        input_aux2(2,C)=input_d(ia,2);
        
        %map_d(1,mapInd)=map_d(1,mapInd)+eta*(input_d(i,1)-map_d(1,mapInd));
        %map_d(2,mapInd)=map_d(2,hI2(2,i))+eta*(input_d(i,2)-map_d(2,mapInd));
        map_d=bsxfun(@plus,map_d,eta*bsxfun(@minus,map_aux0,input_aux2));
        
        %mapInd=mod((mapInd+1),numInputs*timesMap)+1;
        
        if (epoch<=numEpoch3)
            C1=C+1;
            C1(1,C1(1,:)==61)=1;
            map_aux0(1,C)=map_d(1,C1);
            map_aux0(2,C)=map_d(2,C1);
            map_d=bsxfun(@plus,map_d,eta*0.5*bsxfun(@minus,input_aux2,map_aux0));
            
            C2=C+2;
            C2(1,C2(1,:)==61)=1;
            C2(1,C2(1,:)==62)=2;
            map_aux0(1,C)=map_d(1,C2);
            map_aux0(2,C)=map_d(2,C2);
            map_d=bsxfun(@plus,map_d,eta*0.25*bsxfun(@minus,input_aux2,map_aux0));
            
            Cm1=C-1;
            Cm1(1,Cm1(1,:)==0)=60;
            map_aux0(1,C)=map_d(1,Cm1);
            map_aux0(2,C)=map_d(2,Cm1);
            map_d=bsxfun(@plus,map_d,eta*0.5*bsxfun(@minus,input_aux2,map_aux0));
            
            Cm2=C-2;
            Cm2(1,Cm2(1,:)==0)=60;
            Cm2(1,Cm2(1,:)==-1)=59;
            map_aux0(1,C)=map_d(1,Cm2);
            map_aux0(2,C)=map_d(2,Cm2);
            map_d=bsxfun(@plus,map_d,eta*0.25*bsxfun(@minus,input_aux2,map_aux0));
        
         end
    
    
end

toc
map=gather(double(map_d'));
aux = strcat(makeDir,'\mapAfter.txt');
save(aux,'map');