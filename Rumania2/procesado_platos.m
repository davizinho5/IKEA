
cd fotos21dec17/
cd produs1/
% cd produs2/
cd original

%% Lista todos los archivos con la extension ".bag"
filesBAG = dir('*.jpg');

for num_file = 1:length(filesBAG) % Ciclo para cada archivo

    I=imread(filesBAG(num_file).name);
    % I=imread('orig_circ.jpg');
    
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
    figure,imshow(Ibw); hold on;
    rectangle('position',Asorted(1).BoundingBox,'edgecolor','r','linewidth',2);
    hold off
    
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
        
        
        pause;

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

end

 cd ..
 cd ..
 cd ..
 
