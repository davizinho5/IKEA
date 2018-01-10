function[noPlate] = final(fullimageFileName,no)


I = imread(fullimageFileName);
imshow(I);


%% the following segment removes noise from the original image based on
% median filtering
I=imresize(I,[400 NaN]);
I = rgb2gray(I);
I = medfilt2(I,[3 3]);
s = strel('disk',1);
si = imdilate(I,s);
se = imerode(I,s);
I = imsubtract(si,se);
I = mat2gray(I);
I = conv2(I,[1 1;1 1]);
I = imadjust(I,[0.5 0.7],[0 1],0.1);
I = logical(I);
er = imerode(I,strel('line',50,0));
I = imsubtract(I,er);
I = imfill(I,'holes');
I = bwmorph(I,'thin',1);
I = imerode(I,strel('line',3,90));
I = bwareaopen(I,100);


%% seperating each character of the filtered image
Iprops=regionprops(I,'BoundingBox','Image');% drawing boundary box around each connected component in the image
NR=cat(1,Iprops.BoundingBox);% string of all boundary boxes, the properties in the string are x coordinate,y coordinate, x width, y width
r=controlling(NR,no);
if ~isempty(r) 
    I={Iprops.Image};
    noPlate=[]; 
    for v=1:length(r)
        N=I{1,r(v)}; % trying to locate the connected component from teh binary image corresponding to each bounding boxes
        letter=readLetter(N); 
        while letter=='O' || letter=='0' 
            if v<=3                      
                letter='O';              
            else                         
                letter='0';              
            end                          
            break;                       
        end
        while letter == 'Z' || letter == '2'
            if v<=3
                letter = 'Z';
            else
                letter ='2';
            end
            break;
        end
        noPlate=[noPlate letter]; 
    end
%  disp(noPlate);  
else
    disp('Unable to extract the characters from the number plate.');
    disp('The characters on the number plate might not be clear or touching with each other or boundries.\n');
end
end