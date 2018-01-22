
I = I_letters;

figure; imshow(I)
Ig = rgb2gray(I);
I_edge = edge(Ig,'Canny',0.474,1.95);

SE  = strel('Disk',3,4);
I_edge = imdilate(I_edge, SE);
% figure; imshow(I_edge)

%% Oriented Boxes
% compute image labels, using minimal connectivity
lbl = bwlabel(bin, 4);
nLabels = max(lbl(:));

% display label image
rgb = label2rgb(lbl, jet(nLabels), 'w', 'shuffle');

%% Compute enclosing oriented boxes
boxes = imOrientedBox(lbl);
for i=size(boxes,1):-1:1 % Filtrar por AREA
    if (boxes(i,3)*boxes(i,4)<1950) || ...
        (boxes(i,3)*boxes(i,4)>6300) 
        boxes(i,:)=[];
    end
end
% display result
figure, imshow(rgb), hold on;
drawOrientedBox(boxes, 'linewidth', 2);

cx    = boxes(:,1);
cy    = boxes(:,2);
hl    = boxes(:,3) /2;
hw    = boxes(:,4) /2;
theta = boxes(:,5);

keys={};
for i=1:size(boxes,1)
    % pre-compute angle data
    cot = cosd(theta(i));
    sit = sind(theta(i));
    % x and y shifts
    lc = hl(i) * cot;
    ls = hl(i) * sit;
    wc = hw(i) * cot;
    ws = hw(i) * sit;
    % coordinates of box vertices
    vx = cx(i) + [-lc + ws; lc + ws ; lc - ws ; -lc - ws];
    vy = cy(i) + [-ls - wc; ls - wc ; ls + wc ; -ls + wc];

    Ic=imcrop(I_letters,[min(vx), min(vy), max(vx)-min(vx), max(vy)-min(vy)]);
    Ir=imrotate(Ic, theta(i));
    
    % Hay que ajustar más el tamaño de la ventana  
    %% V1
    if size(I3,1) > size(I3,1)
        if hl(i) > hw(i)
            df = hl(i); 
            dc = hw(i);
        else
            dc = hl(i); 
            df = hw(i);
        end
    else
        if hl(i) > hw(i)
            dc = hl(i); 
            df = hw(i);
        else
            df = hl(i); 
            dc = hw(i);
        end
    end
    vf = floor(size(I3,1)/2) + [df -df];
    vc = floor(size(I3,2)/2) + [dc -dc];
    keys{i}=imcrop(Ir,[min(vc), min(vf), max(vc)-min(vc), max(vf)-min(vf)]);
    figure, imshow(keys{i})
end
    
   