
%coger imagen con numeros grabados y convertir en bw
rgbIndices = rgb2ind(img,18);                                   
mask = ismember(rgbIndices,[0   4   5   8   9  11  15  16  17]);


%level set
demo_2;% para calcular la posición de los números

%mostrar caja
phi2=(phi<-1.95);
lbl = bwlabel(phi2, 4);
boxes = imOrientedBox(lbl);
hold on;
drawOrientedBox(boxes, 'linewidth', 2);


% Hay que cortar la imagen para tener sólo un número

IMG=segtool_1;
SE  = strel('Disk',2,8);
morphed1 = imclose(IMG, SE);
figure;imshow(morphed1);