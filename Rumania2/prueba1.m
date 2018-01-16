% I=imread('IMG_3836.JPG');
% I = rgb2gray(I);
% I=imresize(I,[600 NaN]);
% figure; imshow(I)

I = Ig_cac;
% I = medfilt2(I,[4 4]);
% I=imgaussfilt(I,1);
% figure; imshow(I)

I1=I;
[I,threshOut] = edge(I,'Canny',0.16827,2.11);
figure; imshow(I)

SE  = strel('Disk',6,4);
I = imdilate(I, SE);
figure; imshow(I)

SE  = strel('Disk',4,4);
bin = imopen(I, SE);
figure; imshow(I)

% bin = imclearborder(I, 4);
% imshow(bin);

%% Oriented Boxes

% compute image labels, using minimal connectivity
lbl = bwlabel(bin, 4);
nLabels = max(lbl(:));

% display label image
rgb = label2rgb(lbl, jet(nLabels), 'w', 'shuffle');
figure(4); clf;
imshow(rgb);


%% Compute enclosing oriented boxes

% call the function
boxes = imOrientedBox(lbl);

%% Read the boxes
for ii=size(boxes,1):-1:1
    if (boxes(ii,3)<45) || (boxes(ii,3)>125)
        boxes(ii,:)=[];
    end
end

% display result
hold on;
drawOrientedBox(boxes, 'linewidth', 2);

box=boxes;
cx  = box(:,1);
cy  = box(:,2);
hl   = box(:,3) / 2;
hw   = box(:,4) / 2;
theta = box(:,5);
radio=sqrt(hl(:).^2+hw(:).^2);

for ii=1:size(boxes,1)

    I2=imcrop(I1,[cx(ii)-radio(ii),cy(ii)-radio(ii),2*radio(ii),2*radio(ii)]);
%     figure(5); clf; imshow(I2);

    I3=imrotate(I2,theta(ii));
%     figure(6); clf; imshow(I3);

    C=size(I3)/2;
    I4=imcrop(I3,[C(1)-hl(ii),C(2)-hw(ii),2*hl(ii),2*hw(ii)]);
    figure, imshow(I4);

%      I5 = imadjust(I4); 
%      figure(8); clf; imshow(I5);

    %leer(I5)
end

% figure,subplot(2,3,1),imshow(I), ...
%        subplot(2,3,2),imshow(Ic), ...
%        subplot(2,3,3),imshow(I_edge), hold on,drawOrientedBox(boxes, 'linewidth', 2), hold off;
%        subplot(2,3,4),imshow(keys{1}), ...
%        subplot(2,3,5),imshow(keys{2}), ...
%        subplot(2,3,6),imshow(keys{3});

