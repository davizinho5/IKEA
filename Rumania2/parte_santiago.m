
        
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
