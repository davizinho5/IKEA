
cd fotos21dec17/
% cd produs1/
cd produs2/
cd original

PINTAR = 0;

%% Lista todos los archivos con la extension ".bag"
filesBAG = dir('*.jpg');
% Ciclo para cada archivo
for num_file = 1:length(filesBAG) 

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
disp(filesBAG(num_file).name)        
num_file
% message = sprintf('Im: %, Circularity: %.3f, so the object is a rectangle', num_file, circularity);
%         disp(message);

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
            figure, imshow(Ibw), hold on
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
        
        Ig = rgb2gray(I_letters);
        boxes=[];
        disk_size=2;       
        canny_thesh = 0.475;
        tries = 1;
        white_points = [1400 1500 1600];
        % We want 3 groups of letters
        while(size(boxes,1) ~= 3) || (sum(sum(aux)) < 50)
            if(disk_size > 8)
                disk_size=2;
            end    
            I_edge = edge(Ig,'Canny',canny_thesh,1.95);
            while (sum(sum(I_edge)) < white_points(tries)) 
                canny_thesh = canny_thesh-0.025;
                I_edge = edge(Ig,'Canny',canny_thesh,1.95);               
            end

            disk_size = disk_size + 1;
            SE  = strel('Disk',disk_size,8);
            I_edge = imdilate(I_edge, SE);
            % Add a black frame 
            aux = zeros(size(I_edge) + [2 2]);
            aux(2:size(I_edge,1)+1,2:size(I_edge,2)+1) = I_edge;
            I_edge = aux;
                        
            %% Oriented Boxes
            % compute image labels, using minimal connectivity
            lbl = bwlabel(I_edge, 4);
            nLabels = max(lbl(:));

            %% Compute enclosing oriented boxes
            boxes = imOrientedBox(lbl);
            % Filter the boxes by the expected area
            for i=size(boxes,1):-1:1 
                if (boxes(i,3)*boxes(i,4)<1100) || ...
                    (boxes(i,3)*boxes(i,4)>7000) 
                    boxes(i,:)=[];
                end
            end
            % ONLY IN DEBUG MODE
            if PINTAR && nLabels > 0 
                rgb = label2rgb(lbl, jet(nLabels), 'w', 'shuffle');
                figure, imshow(I_edge), hold on;
                drawOrientedBox(boxes, 'linewidth', 2);
            end
        end
        
        % Add area value
        boxes = [boxes  zeros(size(boxes,1),1)];
        for p=1:1:size(boxes,1)
            boxes(p,size(boxes,2)) = boxes(p,3)*boxes(p,4);
        end       
        % Find order by area
        index = [0 0 3 2 1];
        [min_a,small]=min(boxes(:,6));
        [max_a,large]=max(boxes(:,6));
        med = index(small+large);

        cx    = boxes(:,1);
        cy    = boxes(:,2);
        hl    = boxes(:,3) /2;
        hw    = boxes(:,4) /2;
        theta = boxes(:,5);

        keys={};
        df = 26;

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

            % Fix size rectangles
            if small == i
                disp('rotar')
                Ir=imrotate(Ir, 90);
                dc = 15;
            elseif large == i && (boxes(large,6)/boxes(med,6) > 1.15)               
                    dc = 52;
            else
                    dc = 40;
            end
            vf = floor(size(Ir,1)/2) + [df -df];
            vc = floor(size(Ir,2)/2) + [dc -dc];
            keys{i}=imcrop(Ir,[min(vc), min(vf), max(vc)-min(vc), max(vf)-min(vf)]);
            figure, imshow(keys{i})
            
            letras = {};
            n=1;
            for i=1:1:3
                img=keys{i};
                Ig = rgb2gray(img);
                J1 = histeq(Ig);
                K1 = wiener2(J1,[3 3]);
                J2 = histeq(K1);
                K2 = wiener2(J2,[3 3]);
            %     figure,imshow(K2)
                imgout = imadjust(K2,[0.03; 0.92],[0.00; 1.00],2.88);
            %     figure,imshow(imgout)
                thresholds = multithresh(imgout,8);            
                [~,quantIndex] = imquantize(imgout,thresholds);
                mask = ismember(quantIndex,[9]);   
                Ibw = bwareaopen(mask, 4,4);
                SE  = strel('Disk',1,4);
                I_edge = imdilate(Ibw, SE);

                % proyeccion sobre eje X
                YProj = sum(I_edge,1);
                figure,plot(YProj) 
                % busca las caidas a cero
                ind = find([0,diff((YProj == 0))>0] & (YProj == 0))
                % elimina los valles de menos de 3 pixels
                for k=size(ind,2):-1:1
                    if sum(YProj(ind(k):min(ind(k)+3,size(YProj,2)))) > 0
                        ind(k) = [];
                    end
                end

                if size(keys{i},2) == 105 % 4 letras
                    col = 1;
                    while YProj(col) == 0
                        col= col+1;
                    end
                    letras{n} = img(:,max(col-1,1):min(col+24,size(YProj,2)),:);
                    figure,imshow(letras{n})
                    n=n+1;
                    for j=1:3
                        col = ind(j);      
                        while YProj(col) == 0
                            col= col+1;
                        end
                        letras{n} = img(:,max(col-1,1):min(col+24,size(YProj,2)),:);
                        figure,imshow(letras{n})
                        n=n+1;
                    end
                elseif size(keys{i},2) == 81 % 3 letras
                    col = 1;
                    while YProj(col) == 0
                        col= col+1;
                    end
                    letras{n} = img(:,max(col-1,1):min(col+24,size(YProj,2)),:);
                    figure,imshow(letras{n})
                    n=n+1;        
                    for j=1:2
                        col = ind(j);      
                        while YProj(col) == 0
                            col= col+1;
                        end
                        letras{n} = img(:,max(col-1,1):min(col+24,size(YProj,2)),:);
                        figure,imshow(letras{n})
                        n=n+1;
                    end         
                else % 1 letra
                    col = 1;
                    while YProj(col) == 0
                        col = col+1;
                    end
                    letras{n} = img(:,max(col-1,1):min(col+24,size(YProj,2)),:);
                    figure,imshow(letras{n})
                    n=n+1;
                end    
            pause;
            end


        end 
           
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
        
%     pause;
end

 cd ..
 cd ..
 cd ..
 
