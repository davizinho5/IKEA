
cd fotos21dec17/
% cd produs1/
cd produs2/
cd original

%% Lista todos los archivos con la extension ".bag"
filesBAG = dir('*.jpg');

for num_file = 1:length(filesBAG) % Ciclo para cada archivo

    I = imread(filesBAG(num_file).name);  
    Ig = rgb2gray(I);

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
%     figure,imshow(Ibw); hold on;
%     rectangle('position',Asorted(1).BoundingBox,'edgecolor','r','linewidth',2);
%     hold off

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
%         figure(20),clf, imshow(I_letters)
%         figure(10),clf, subplot(2,1,1), imshow(Ic), ...
%                         subplot(2,1,2), imshow(I_edge), hold on, ...
%                         for i = 1:size(AA,1)
% rectangle('Position', AA(i).BoundingBox,'EdgeColor','r', 'linewidth', 2)
%                         end
%                         hold off
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         figure, imshow(I_letters)        
        % Find individual letters
        Ig = rgb2gray(I_letters);
        Ig_c = wiener2(Ig,[2 2]);
        Ig_ca = imadjust(Ig_c); 
        Ig_cac = wiener2(Ig_ca,[4 4]);
        I_edge = edge(Ig_cac,'Canny');
        figure, imshow(I_edge)
        Ibw = bwareaopen(I_edge, 40, 8);
        figure, imshow(Ibw)
        SE = strel('disk',4);
        Ibw2 = imerode(Ibw2,SE);
        
        
        % Edge detection
%         I_edge = edge(Ig_ad,'Canny',0.16827,2.0);         
         % Dilate edge 
        SE  = strel('Disk',10,4);
        I_edge = imdilate(I_edge, SE);      
         % Estilizar edge
        SE  = strel('Disk',4,4);
        I_edge = imopen(I_edge, SE);          
        
        %% Oriented Boxes
        % compute image labels, using minimal connectivity
        lbl = bwlabel(I_edge, 4);
        nLabels = max(lbl(:));
        % display label image
        rgb = label2rgb(lbl, jet(nLabels), 'w', 'shuffle');
       
        %% Compute enclosing oriented boxes
        boxes = imOrientedBox(lbl);
        %% Read the boxes
        for ii=size(boxes,1):-1:1
             % Este numero es ... muy AD-HOC
            if (boxes(ii,3)<45) || (boxes(ii,3)>300) %(boxes(ii,3)>125)
                boxes(ii,:)=[];
            end
        end
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
 
