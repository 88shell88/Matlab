numColumns = 10;
numLines = 10;
inSize = 7;
weight = single(zeros(numColumns*numLines*inSize,1));
in = single(zeros(inSize,1));
map = gpuArray(single(zeros(numLines*numColumns,1)));
tic
weight_d= gpuArray(weight);
map_d= gpuArray(map);
in_d = gpuArray(in);
map_d=map_d+1;
weight_d = weight_d+1;
map=gather(map_d);
weight=gather(weight_d);
toc
map;
weight;