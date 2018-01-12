

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

