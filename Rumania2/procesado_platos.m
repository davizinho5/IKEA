
cd fotos21dec17/
% cd produs1/
cd produs2/
cd original

PINTAR = 1;

%% Lista todos los archivos con la extension ".bag"
filesBAG = dir('*.jpg');

for num_file = 1:length(filesBAG) % Ciclo para cada archivo

    I = imread(filesBAG(num_file).name);  
    Ig = rgb2gray(I);
    
    if PINTAR
        figure, imshow(I)
    end
    
    %% Elegir circulo y rectangulos
    Ibw = im2bw(Ig,graythresh(Ig));
    Ibw2 = bwareaopen(Ibw, 80, 8);
    SE = strel('disk',4);
    Ibw2 = imerode(Ibw2,SE);
    
    stats = regionprops(Ibw2,'boundingbox','Area','Perimeter');
    % Se ordenan por AREA 
    Afields = fieldnames(stats);
    Acell = struct2cell(stats);
    sz = size(Acell);   
    % Convert to a matrix
    Acell = reshape(Acell, sz(1), []);      % Px(MxN)
    % Make each field a column
    Acell = Acell';                         % (MxN)xP
    % Sort by first field "AREA"
    Acell = sortrows(Acell, 1, 'descend');
    % Put back into original cell array format
    Acell = reshape(Acell', sz);
    % Convert to Struct
    Asorted = cell2struct(Acell, Afields, 1);

    % Se pinta el cuadrado más grande
    if PINTAR
        figure,imshow(Ibw); hold on;
        rectangle('position',Asorted(1).BoundingBox,'edgecolor','r','linewidth',2);
        hold off
    end

    % Para elegir entra circulos y rectangulos calculamos la circularidad
    circularity = Asorted(1).Perimeter^2 / (4 * pi * [Asorted(1).Area]);
    %% CIRCULAR    
    if circularity  < 1.15
message = sprintf('Im: %d, Circularity: %.3f, so the object is a rectangle', num_file, circularity);
        disp(message);
        % Recortar - plato circular (1689*1686)
        I1 = imcrop(I,Asorted(1).BoundingBox);
     %% FIJO [XMIN YMIN WIDTH HEIGHT]
        BB = [330 330 1020 1020]; 
        Ic = imcrop(I1, BB);
        
        if PINTAR
            figure, imshow(I1)
        end
        
        % Conversion a BN
        Ibw = im2bw(rgb2gray(Ic),graythresh(rgb2gray(Ic)));
        
        % find interior cilcle
        stats = regionprops('table',Ibw,'Centroid','MajorAxisLength','MinorAxisLength');
        diameters = mean([stats.MajorAxisLength stats.MinorAxisLength],2);
        big_diam = diameters(diameters > 950,:);
        centers = stats.Centroid(diameters > 950);
        center_image = size(Ibw)/2;
        
        dist_center=[];
        for i=1:1:size(centers,1)
          dist_center(i) = sqrt(sum(center_image - centers(i,:)).^2);
        end
        [min_dist, ind] = min(dist_center);      

        if PINTAR
            figure, imshow(I1), hold on
            viscircles(center_image,big_diam(ind)/2) , hold off
        end
        
        radii = big_diam(ind)/2;
        rad_offset = 25;
        if radii > 500
            rad_offset = 80;
        end 
        for i=1:1:size(Ic,1)
            for j=1:1:size(Ic,2)
                if sqrt(sum((center_image - [i,j]).^2)) >= (radii-rad_offset)
                    Ic(i,j,:) = 255;                   
                end
            end
        end
             
        % Find Letters Area        
        % Mejorar el ajuste sin contar con los blancos?
        Ig = rgb2gray(Ic);
        Ig_ad = imadjust(Ig);      
        % Edge detection
        I_edge = edge(Ig_ad,'Canny',0.16827,2.0);  
        % Eliminate small objects
        I_edge = bwareaopen(I_edge, 60, 8);
        % Dilate edge 
        SE  = strel('Disk',10,4);
        I_edge = imdilate(I_edge, SE);
                              
        stats = regionprops(I_edge, 'Area','BoundingBox','Orientation');
        Afields = fieldnames(stats);
        Acell = struct2cell(stats);
        minX=size(Ic,1);
        minY=size(Ic,2);
        maxX=0;
        maxY=0;
        for ii=size(stats,1):-1:1
             % Este numero es ... muy AD-HOC
            if (stats(ii).Area > 18000) % (stats(ii).Area < 1500) ||(stats(ii).Area > 5400) 
                Acell(:,ii)=[];
            else
                minX=min(stats(ii).BoundingBox(1),minX);
                minY=min(stats(ii).BoundingBox(2),minY);
                maxX=max(stats(ii).BoundingBox(1)+stats(ii).BoundingBox(3),maxX);
                maxY=max(stats(ii).BoundingBox(2)+stats(ii).BoundingBox(4),maxY);
              
            end
        end
        AA = cell2struct(Acell, Afields, 1);
       
        %% FIJO [XMIN YMIN WIDTH HEIGHT]
        I_letters=imcrop(Ic, [minX minY (maxX-minX) (maxY-minY)]);
        
        if PINTAR
            figure, imshow(I_letters)   
            
            figure(20),clf, imshow(I_letters)
            figure(10),clf, subplot(2,1,1), imshow(Ic), ...
                subplot(2,1,2), imshow(I_edge), hold on, ...
                for i = 1:size(AA,1)
rectangle('Position', AA(i).BoundingBox,'EdgeColor','r', 'linewidth', 2)
                end
            hold off
        end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        % Find individual letters
    I = I_letters;
I = rgb2gray(I);
% I=imresize(I,[600 NaN]);
figure; imshow(I)

% I = Ig_cac;
% I = medfilt2(I,[4 4]);
I=imgaussfilt(I,1);
figure; imshow(I)

I1=I;
[I,threshOut] = edge(I,'Canny',0.474,1.95);
figure; imshow(I)

SE  = strel('Disk',5,4);
bin = imdilate(I, SE);
figure; imshow(I)

lbl = bwlabel(bin, 4);
nLabels = max(lbl(:));

% display label image
rgb = label2rgb(lbl, jet(nLabels), 'w', 'shuffle');
figure(4); clf;imshow(rgb);

%% Compute enclosing oriented boxes
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
cx    = box(:,1);
cy    = box(:,2);
hl    = box(:,3) / 2;
hw    = box(:,4) / 2;
theta = box(:,5);
radio = sqrt(hl(:).^2+hw(:).^2);

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

        
        figure(10),clf,subplot(1,2,1),imshow(I_letters), ...
                       subplot(1,2,2),imshow(I_edge), hold on
        drawOrientedBox(boxes, 'linewidth', 2);
        hold off;

% % % %         cx    = boxes(:,1);
% % % %         cy    = boxes(:,2);
% % % %         hl    = boxes(:,3) / 2;
% % % %         hw    = boxes(:,4) / 2;
% % % %         theta = boxes(:,5);
% % % %         radio = sqrt(hl(:).^2+hw(:).^2);
% % % % 
% % % % %         keys={};
% % % %         for ii=1:size(boxes,1)
% % % %             I2=imcrop(I_letters,[cx(ii)-radio(ii),cy(ii)-radio(ii),2*radio(ii),2*radio(ii)]);
% % % %             I3=imrotate(I2,theta(ii));
% % % % keys{ii}=imcrop(I3,[(size(I3,1)/2)-hl(ii),(size(I3,2)/2)-hw(ii),2*hl(ii),2*hw(ii)]);       
% % % %         end
% % % %                
% % % %         figure(10),clf,subplot(1,2,1),imshow(I_letters), ...
% % % % %                subplot(1,3,2),imshow(I_edge), ...
% % % %                subplot(1,2,2),imshow(I_edge), hold on, ...
% % % %                for i = 1:size(keys,2)
% % % % rectangle('Position', AA(i).BoundingBox,'EdgeColor','r', 'linewidth', 2)
% % % %                end
% % % %                hold off;
% % % % %                subplot(2,3,4),imshow(keys{1}), ...
% % % % %                subplot(2,3,5),imshow(keys{2}), ...
% % % % %                subplot(2,3,6),imshow(keys{3});

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        
        
        
        
        
        
        
           
    %% RECTANGULAR    
    elseif circularity < 1.8
message = sprintf('Im: %f, Circularity: %.3f, so the object is a rectangle', num_file, circularity);
        disp(message);
        % Orientar
        Ibw = imcrop(Ibw,Asorted(1).BoundingBox);
        Ibw = imfill(Ibw,'holes');
        [Gmag, Gdir] = imgradient(Ibw,'sobel');
        [Gx, Gy] = imgradientxy(Ibw,'sobel');
        direction_mat = Gy(1:50,400:1400);

        % direccion de la linea
        [H,theta,rho] = hough(direction_mat,'RhoResolution',1,'ThetaResolution',0.05);
        peaks  = houghpeaks(H,5);
        lines = houghlines(direction_mat,theta,rho,peaks);
        angle = sum(lines(:).theta/numel(lines))-sign(sum(lines(:).theta/numel(lines)))*90;
        %  Recortar (922*1840) y Rotar
        I_crop = imcrop(I,Asorted(1).BoundingBox);
        I_rot = imrotate(I_crop,angle);

     %% FIJO [XMIN YMIN WIDTH HEIGHT]
        BB = [155 180 490 610; 670 180 490 610; 1210 180 490 610]; 
        Ic1 = imcrop(I_rot, BB(1,:));
        Ic2 = imcrop(I_rot, BB(2,:));
        Ic3 = imcrop(I_rot, BB(3,:));
        figure,imshow(I_rot), hold on;
        rectangle('position', BB(1,:),'edgecolor','r','linewidth',2);
        rectangle('position', BB(2,:),'edgecolor','b','linewidth',2);
        rectangle('position', BB(3,:),'edgecolor','g','linewidth',2);
        hold off;
        figure,subplot(1,3,1),imshow(Ic1),subplot(1,3,2),imshow(Ic2),subplot(1,3,3),imshow(Ic3);
  
    else
        message = sprintf('Wrong detection');
    end
    % uiwait(msgbox(message));
        
    pause;
end

 cd ..
 cd ..
 cd ..
 
