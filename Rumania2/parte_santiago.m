
        
        % Estilizar edge
        SE  = strel('Disk',4,4);
        I_edge = imopen(I_edge, SE);    

        %% Oriented Boxes
        % compute image labels, using minimal connectivity
        lbl = bwlabel(I_edge, 4);
        nLabels = max(lbl(:));
        % display label image
        rgb = label2rgb(lbl, jet(nLabels), 'w', 'shuffle');
%         figure(4); clf; imshow(rgb);
        
        %% Compute enclosing oriented boxes
        boxes = imOrientedBox(lbl);
        %% Read the boxes
        for ii=size(boxes,1):-1:1
             % Este numero es ... muy AD-HOC
            if (boxes(ii,3)<45) || (boxes(ii,3)>300) %(boxes(ii,3)>125)
                boxes(ii,:)=[];
            end
        end
              
        cx    = boxes(:,1);
        cy    = boxes(:,2);
        hl    = boxes(:,3) / 2;
        hw    = boxes(:,4) / 2;
        theta = boxes(:,5);
        radio = sqrt(hl(:).^2+hw(:).^2);

%         keys={};
        for ii=1:size(boxes,1)
            I2=imcrop(Ic,[cx(ii)-radio(ii),cy(ii)-radio(ii),2*radio(ii),2*radio(ii)]);
            I3=imrotate(I2,theta(ii));
%             C=size(I3)/2;
%             I4=imcrop(I3,[C(1)-hl(ii),C(2)-hw(ii),2*hl(ii),2*hw(ii)]);
keys{ii}=imcrop(I3,[(size(I3,1)/2)-hl(ii),(size(I3,2)/2)-hw(ii),2*hl(ii),2*hw(ii)]);
%   I_crop = imcrop(I,Asorted(1).BoundingBox);
%             figure(7); clf; imshow(I4);


% % % %         for ii=1:size(AA,1)
% % % % %             I3=imrotate(Ic,Acell(4,ii));              
% % % %             keys{ii}=imcrop(Ic, AA(ii).BoundingBox);
% % % % %             figure(3), imshow(keys{ii})
% % % % %             pause;
% % % %         end
        end

        
        
        
        
        
        
         %% V1
% % % %     vx = floor(size(I3,1)/2) + [-lc + ws; lc + ws ; lc - ws ; -lc - ws];
% % % %     vy = floor(size(I3,1)/2) + [-ls - wc; ls - wc ; ls + wc ; -ls + wc];
% % % %     I4=imcrop(I3,[min(vx), min(vy), max(vx)-min(vx), max(vy)-min(vy)]);
% % % %     figure, imshow(I4), hold on, hold on,
% % % %     plot(vx, vy, 'g')
% % % %     hold off
    
    %% V2 
% % %     Ig = rgb2gray(I3);
% % %     Ig(find(Ig == 0)) = sum(Ig(find(Ig ~= 0)))/size(find(Ig ~= 0),1);
% % %     I_edge = edge(Ig,'Canny',0.5,2.95);
% % %     SE  = strel('Disk',1,8);
% % %     I_edge = imdilate(I_edge, SE);
% % %     figure; imshow(I_edge)

    %% V3
    stats = [regionprops(Ibw); regionprops(not(Ibw))];
    vert = [];
    for i = 1:numel(stats)
        vert((i-1)*4+1,:) = stats(i).BoundingBox(1:2);
        vert((i-1)*4+2,:) = stats(i).BoundingBox(1:2)+[stats(i).BoundingBox(3) 0];
        vert((i-1)*4+3,:) = stats(i).BoundingBox(1:2)+[0 stats(i).BoundingBox(4)];
        vert((i-1)*4+4,:) = stats(i).BoundingBox(1:2)+[stats(i).BoundingBox(3),stats(i).BoundingBox(4)];
    end
    vert(find(vert(:,1)<1),:) =[];  
    vert(find(vert(:,2)<1),:) =[];
    vert(find(vert(:,1)>size(I3,2)),:) =[];
    vert(find(vert(:,2)>size(I3,1)),:) =[];  
    vert
    
    X=vert(:,1);
    Y=vert(:,2);
    minX = floor(min(X));
    maxX = ceil(max(X));
    minY = floor(min(Y));
    maxY = ceil(max(Y));
    keys{i}=imcrop(I3,[floor(min(X)), floor(min(Y)), ceil(max(X))-floor(min(X)), ceil(max(Y))-floor(min(Y))]);
    figure, imshow(keys{i})
    pause;
        
    
    
% % % 
% % %     lbl = bwlabel(I_edge, 4);
% % %     nLabels = max(lbl(:));
% % %     box = imOrientedBox(lbl);
% % %     if size(box,1) > 1
% % %         maxBox = 0;
% % %         ind=0;
% % %         for j=1:1:size(box,1) 
% % %            maxBox=max(maxBox, box(j,3)*box(j,4));
% % %            if (maxBox == box(j,3)*box(j,4))
% % %               ind = j;
% % %            end
% % %         end
% % %     else
% % %         ind = 1;
% % %     end
% % %     cot = cosd(box(ind,5));
% % %     sit = sind(box(ind,5));
% % %     % x and y shifts
% % %     lc = (box(ind,3)/2) * cot;
% % %     ls = (box(ind,3)/2) * sit;
% % %     wc = (box(ind,4)/2) * cot;
% % %     ws = (box(ind,4)/2) * sit;
% % %     % coordinates of box vertices
% % %     vx = box(ind,1) + [-lc + ws; lc + ws ; lc - ws ; -lc - ws];
% % %     vy = box(ind,2) + [-ls - wc; ls - wc ; ls + wc ; -ls + wc]; 
% % %     keys{i}=imcrop(I_letters,[min(vx), min(vy), max(vx)-min(vx), max(vy)-min(vy)]);
% % % end
% figure, imshow(I3)

% % figure, imshow(keys{1})
% % figure, imshow(keys{2})
% % figure, imshow(keys{3})



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

