close all
% load images
load('letters431.mat')
% load('letters331.mat')
% I1 = keys{1};
% I2 = keys{2};
% I3 = keys{3};

letras = {};
n=1;
for i=1:1:3
    img=keys{i};
%     figure,imshow(img)
%     rgbIndices = rgb2ind(img,6);    
%     mask = ismember(rgbIndices,[5]);
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
    %% V2
% % %     if size(keys{i},2) == 105 % 4 letras
% % %         col = 1;
% % %         for j=1:4
% % %             while YProj(col) == 0
% % %                 col= col+1;
% % %             end
% % %             letras{n} = img(:,max(col-1,1):min(col+24,size(YProj,2)),:);
% % %             figure,imshow(letras{n})
% % %             n=n+1;
% % %             col = col+15;
% % %         end
% % %     elseif size(keys{i},2) == 81 % 3 letras
% % %         col = 1;
% % %         for j=1:4
% % %             while YProj(col) == 0
% % %                 col = col+1;
% % %             end
% % %             letras{n} = img(:,max(col-1,1):min(col+24,size(YProj,2)),:);
% % %             figure,imshow(letras{n})
% % %             n=n+1;
% % %             col = col+15;
% % %         end           
% % %     else % 1 letra
% % %         col = 1;
% % %         while YProj(col) == 0
% % %             col = col+1;
% % %         end
% % %         letras{n} = img(:,max(col-1,1):min(col+24,size(YProj,2)),:);
% % %         figure,imshow(letras{n})
% % %         n=n+1;
% % %     end    


    
%% V1
% % %     thresholds = multithresh(K2,8);            
% % %     [~,quantIndex] = imquantize(K2,thresholds);
% % %     mask = ismember(quantIndex,1); 
% % %     if size(keys{i},2) == 105 % 4 letras
% % %         letras{n} = img(:,1:26,:);
% % %         figure,imshow(letras{n})
% % %         n=n+1;
% % %         letras{n} = img(:,27:52,:);
% % %         figure,imshow(letras{n})
% % %         n=n+1;
% % %         letras{n} = img(:,53:78,:);
% % %         figure,imshow(letras{n})      
% % %         n=n+1;        
% % %         letras{n} = img(:,79:104,:);
% % %         figure,imshow(letras{n})       
% % %         n=n+1;        
% % %     elseif size(keys{i},2) == 81 % 3 letras
% % %         letras{n} = img(:,1:27,:);
% % %         figure,imshow(letras{n})       
% % %         n=n+1;
% % %         letras{n} = img(:,28:54,:);
% % %         figure,imshow(letras{n})       
% % %         n=n+1;
% % %         letras{n} = img(:,55:81,:);
% % %         figure,imshow(letras{n})       
% % %         n=n+1;              
% % %     else % 1 letra
% % %         letras{n} = img;
% % %         n=n+1;
% % %     end    
    




pause;





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