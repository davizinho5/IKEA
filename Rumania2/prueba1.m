I=imread('IMG_3836.JPG');
% I=imread('mod.jpg');

figure(1), imshow(I)

I = rgb2gray(I);
I=imresize(I,[400 NaN]);
figure(3), imshow(I)

I = medfilt2(I,[3 3]);
I1=I;

[I,threshOut] = edge(I,'Canny',0.086875,1.00);
figure(2), imshow(I)

SE  = strel('Disk',7,4);
I = imdilate(I, SE);
figure(4), imshow(I)

SE  = strel('Disk',11,4);
I = imopen(I, SE);
figure(5), imshow(I)

bin = imclearborder(I, 4);
figure(6),imshow(bin);


%% Oriented Boxes

% compute image labels, using minimal connectivity
lbl = bwlabel(bin, 4);
nLabels = max(lbl(:));

% display label image
rgb = label2rgb(lbl, jet(nLabels), 'w', 'shuffle');
figure(7), clf;
imshow(rgb);


%% Compute enclosing oriented boxes

% call the function
boxes = imOrientedBox(lbl);

% display result
hold on;
drawOrientedBox(boxes, 'linewidth', 2);


%% Read the boxes
ii=4;

I2=imcrop(I1,[201-51,338-51,100,100]);
figure(8), clf, imshow(I2);

I3=imrotate(I2,65);
figure(9), clf, imshow(I3);

I4=imcrop(I3,[67-50,67-22,100,50]);
figure(10), clf,imshow(I4);



