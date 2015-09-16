numColumns = 10;
numLines = 10;
inputSize = 40;
weight = single(zeros(numColumns*numLines*inputSize,1));
weight = weight+0.5;
input = [ 53.214, 19.155, 52.349, 18.924,53.560, 19.221, 49.763, 19.076,53.280, 19.167, 52.758, 18.790,	53.111, 19.220, 52.988, 18.920,54.200, 19.210, 53.719, 19.194,	54.390, 19.185, 53.684, 19.031,	53.848, 19.079, 54.058, 19.269,53.721, 19.170, 54.076, 19.399,	53.603, 19.027, 54.390, 19.399,	53.494, 18.969, 49.763, 18.790 ];


inputX = single(zeros(1,inputSize/2));
inputY = single(zeros(1,inputSize/2));
for i = 1 : inputSize 
    j=floor(i/2);
    t=mod(i,2);
    if mod(i,2) == 0 
        inputY(j)=input(i);
        inputX(j)=input(i-1);
    end    
end
inputY;
inputX;
maxInputY=max(inputY);
maxInputX=max(inputX);
minInputX=min(inputX);
minInputY=min(inputY);

operateTop=zeros(1,inputSize);
operateBottom=zeros(1,inputSize);
x=zeros(1,inputSize/2);
x=x-((minInputX+maxInputX)/2);
y(1:20)=-(minInputY+maxInputY)/2;
operateTop(1:2:2*length(x))=x;
operateTop(2:2:2*length(y))=y;

bottomX(1:inputSize/2)=maxInputX-minInputX;
bottomY(1:inputSize/2)=maxInputY-minInputY;
operateBottom(1:2:2*length(bottomX))=bottomX;
operateBottom(2:2:2*length(bottomY))=bottomY;


map = single(zeros(numLines*numColumns,1));

tic
weight_d= gpuArray(weight);
map_d= gpuArray(map);
input_d = gpuArray(single(input));
input_d=bsxfun(@plus,input_d,operateTop);
input_d=bsxfun(@rdivide,input_d,operateBottom);
for epoch = 1:1000
    hI=gpuArray(single(zeros(1,inputSize/2)));
    input_d(1);
    hR1=bsxfun(@times,weight(1:2:inputSize)/2,input_d(1));
    hR2=bsxfun(@times,weight(2:2:inputSize)/2,input_d(2));
    hR=bsxfun(@plus,hR1,hR2);
    hI=min(hI,hR');
    
    
end

weight=gather(weight_d);
toc