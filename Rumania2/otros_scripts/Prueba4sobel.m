clear
im_DB = imresize(rgb2gray(imread('orig.jpg')),0.5);
imop=imopen(im2bw(imadjust(im_DB),0.35),strel('disk',10));
imc=imclose(imop,strel('disk',9));
im_DB=im_DB.*uint8(imc);
im_DB_logical=(im_DB>20);
DB_prop = regionprops('table',im_DB_logical,'Centroid','MajorAxisLength','MinorAxisLength');
center1= DB_prop.Centroid;MajorAxis1=DB_prop.MajorAxisLength;MinorAxis1=DB_prop.MinorAxisLength;
MajorAxis1h=ceil(MajorAxis1/2);MinorAxis1h=ceil(MinorAxis1/2);
rect1=[round(center1(1))-MajorAxis1h-10,round(center1(2))-MinorAxis1h-10,MajorAxis1+20,MinorAxis1+20];
im_DB_crop=imcrop(im_DB,rect1);
Low_High=stretchlim(im_DB_crop);
I=imadjust(im_DB_crop,Low_High);
imshow(I);

% 4. Findout Gradient Magnitude of the Images using Sobel mask.

mg= edge(I,'Sobel',[0.04],'Both');
imshow(mg);
mgBw = mg > 0.3*max(mg(:));
imshow(mgBw);
mgBw = imclose(mgBw,strel('disk',1));
imshow(mgBw);
mgBw = bwareaopen(mgBw,10);
imshow(mgBw);
%%

%  mgBw = imfill(mgBw,'holes');
%  imshow(mgBw);
BWoutline = bwperim(mgBw);
Segout = imoverlay(I, BWoutline, [1 0 0]); 
imshow(Segout)
figure
imshow(im_DB_crop);hold on
[r,c]=find(BWoutline);
plot(c,r,'.r');