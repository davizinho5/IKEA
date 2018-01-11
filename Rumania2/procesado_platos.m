
cd fotos21dec17/
cd produs1/
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
    figure(1),imshow(Ibw); hold on;
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

    %% RECTANGULAR    
    elseif circularity < 1.8
        message = sprintf('Circularity: %.3f, so the object is a rectangle', circularity);
        disp(message);
        % Orientar
        Ibw = imcrop(Ibw,Asorted(1).BoundingBox);
        Ibw = imfill(Ibw,'holes');
        [I,threshOut] = edge(Ibw,'Sobel');

        % I_rot = imrotate(I1,65);
        % Recortar  - plato rectangular (922*1840)        
        I1 = imcrop(I,Asorted(1).BoundingBox);


    %%  ¿AUTOMATICO?
% %         I1g = rgb2gray(I1);
% %         sigma = 6;
% %         smoothImage = imgaussfilt(I1g,sigma);
% %         smoothGradient = imgradient(smoothImage,'CentralDifference');
% %         I2 = histeq(smoothGradient);
% %         Ibw = imbinarize(I2,graythresh(I2));
% %         % ByN
% %         stat = regionprops(Ibw,'boundingbox','Area','Perimeter');
% %         figure(2),imshow(I1), hold on;
% %         for cnt = 1 : numel(stat)
% %             if (stat(cnt).Area > 50000) & (stat(cnt).Area < 70000)
% %                 BB(cnt,:) = [stat(cnt).BoundingBox(1:2) abs(stat(cnt).BoundingBox(1:2)-stat(cnt).BoundingBox(3:4))];
% %                 rectangle('position',stat(cnt).BoundingBox,'edgecolor','r','linewidth',2);
% %             end
% %         end
% %         hold off
% %         pause;

     %%  ¿FIJO? [XMIN YMIN WIDTH HEIGHT]
        BB = [130 148 (630-130) (775-148); 660 148 (1160-660) (775-148); 1200 148 (1700-1200) (775-148)]; 
        Ic1 = imcrop(I, BB(1,:));
        Ic2 = imcrop(I, BB(2,:));
        Ic3 = imcrop(I, BB(3,:));
        figure(2),imshow(I1), hold on;
        rectangle('position', BB(1,:),'edgecolor','r','linewidth',2);
        rectangle('position', BB(2,:),'edgecolor','b','linewidth',2);
        rectangle('position', BB(3,:),'edgecolor','g','linewidth',2);
        hold off;
        pause;
  
    else
        message = sprintf('Wrong detection');
    end
    % uiwait(msgbox(message));

end

 cd ..
 cd ..
 cd ..
 
