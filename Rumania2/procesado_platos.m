
cd fotos21dec17/
% cd produs1/
cd produs2/
cd original

%% Lista todos los archivos con la extension ".bag"
filesBAG = dir('*.jpg');

for num_file = 1:length(filesBAG) % Ciclo para cada archivo

    I = imread(filesBAG(num_file).name);
%     figure,imshow(I); hold on;
    
    Ig = rgb2gray(I);

    %% Elegir circulo y rectangulos
    Ibw = im2bw(Ig,graythresh(Ig));
    stat = regionprops(Ibw,'boundingbox','Area','Perimeter');
    % Se ordenan por AREA 
    Afields = fieldnames(stat);
    Acell = struct2cell(stat);
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
%     figure,imshow(Ibw); hold on;
%     rectangle('position',Asorted(1).BoundingBox,'edgecolor','r','linewidth',2);
%     hold off
    
    % Para elegir entra circulos y rectangulos calculamos la circularidad
    circularity = Asorted(1).Perimeter^2 / (4 * pi * [Asorted(1).Area]);
    %% CIRCULAR    
    if circularity  < 1.14
        message = sprintf('Circularity: %.3f, so the object is a circle', circularity);
        disp(message);
        % Recortar - plato circular (1689*1686)
        I1 = imcrop(I,Asorted(1).BoundingBox);
     %% FIJO [XMIN YMIN WIDTH HEIGHT]
        BB = [330 330 1020 1020]; 
        Ic = imcrop(I1, BB);
        
        % Conversion a BN
        Ibw = im2bw(rgb2gray(Ic),graythresh(rgb2gray(Ic)));
        
        % find interior cilcle
        stats = regionprops('table',Ibw,'Centroid','MajorAxisLength','MinorAxisLength');
        diameters = mean([stats.MajorAxisLength stats.MinorAxisLength],2);
%         radii = diameters/2;
        big_diam = diameters(diameters > 950);
        centers = stats.Centroid(diameters > 950);
        center_image = size(Ibw)/2;
        for i=1:1:size(centers,1)
          dist_center(i) = sqrt(sum(center_image - centers(i,:)).^2);
        end
        [min_dist, ind] = min(dist_center);
        
        radii = big_diam(ind)/2;
        for i=1:1:size(Ic,1)
            for j=1:1:size(Ic,2)
                if sqrt(sum((center_image - [i,j]).^2)) >= radii;
                    Ic(i,j,:) = 255;
                end
            end
        end
%         figure, imshow(Ic);
        
        Ig = rgb2gray(Ic);
        Ig_ad = imadjust(Ig);
        
        % Edge detection
        [I_edge,threshOut] = edge(Ig_ad,'Canny',0.16827,2.11);
         % Dilate edge 
        SE  = strel('Disk',6,4);
        I_edge = imdilate(I_edge, SE);
        % Estilizar edge
        SE  = strel('Disk',4,4);
        I_edge = imopen(I_edge, SE);
       
%         bin = imclearborder(I_edge, 4);

        %% Oriented Boxes
        % compute image labels, using minimal connectivity
        lbl = bwlabel(I_edge, 4);
        nLabels = max(lbl(:));
        % display label image
        rgb = label2rgb(lbl, jet(nLabels), 'w', 'shuffle');
%         figure(4); clf; imshow(rgb);
        
        %% Compute enclosing oriented boxes
        boxes = imOrientedBox(lbl);
        % display result
%         figure, imshow(Ic)
%         hold on;
%         drawOrientedBox(boxes, 'linewidth', 2);       
        
        %% Read the boxes
        for ii=size(boxes,1):-1:1
             % Este numero es ... muy AD-HOC
            if (boxes(ii,3)<45) || (boxes(ii,3)>125)
                boxes(ii,:)=[];
            end
        end

        cx    = boxes(:,1);
        cy    = boxes(:,2);
        hl    = boxes(:,3) / 2;
        hw    = boxes(:,4) / 2;
        theta = boxes(:,5);
        radio = sqrt(hl(:).^2+hw(:).^2);

        for ii=1:size(boxes,1)
            I2=imcrop(Ic,[cx(ii)-radio(ii),cy(ii)-radio(ii),2*radio(ii),2*radio(ii)]);
            I3=imrotate(I2,theta(ii));
%             C=size(I3)/2;
%             I4=imcrop(I3,[C(1)-hl(ii),C(2)-hw(ii),2*hl(ii),2*hw(ii)]);
keys{ii}=imcrop(I3,[(size(I3,1)/2)-hl(ii),(size(I3,2)/2)-hw(ii),2*hl(ii),2*hw(ii)]);
%   I_crop = imcrop(I,Asorted(1).BoundingBox);
%             figure(7); clf; imshow(I4);

        %      I5 = imadjust(I4); 
        %      figure(8); clf; imshow(I5);
        end

        figure,subplot(2,3,1),imshow(I), ...
               subplot(2,3,2),imshow(Ic), ...
               subplot(2,3,3),imshow(I_edge), hold on,drawOrientedBox(boxes, 'linewidth', 2), hold off;
               subplot(2,3,4),imshow(keys{1}), ...
               subplot(2,3,5),imshow(keys{2}), ...
               subplot(2,3,6),imshow(keys{3});

           
    %% RECTANGULAR    
    elseif circularity < 1.8
        message = sprintf('Circularity: %.3f, so the object is a rectangle', circularity);
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
 
