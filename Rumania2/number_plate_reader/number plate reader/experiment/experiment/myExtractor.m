function[noPlate] = myExtractor(fullimageFileName)

I = imread(fullimageFileName);
%figure1
imshow(I);

I=imresize(I,[400 NaN]);
%figure2
%figure; imshow(I);

I = rgb2gray(I);
%figure3
%figure; imshow(I);

I = medfilt2(I,[3 3]);
%figure4
%figure; imshow(I);

s = strel('disk',1);
si = imdilate(I,s);
%figure5
%figure; imshow(si);
se = imerode(I,s);
%figure6
%figure; imshow(se);
I = imsubtract(si,se);
%figure7
%figure; imshow(I);

I = mat2gray(I);
%figure8
%figure; imshow(I);

I = conv2(I,[1 1;1 1]);
%figure9
%figure; imshow(I);

I = imadjust(I,[0.5 0.7],[0 1],0.1);
%figure10
%figure; imshow(I);

I = logical(I);
%figure11
%figure; imshow(I);

er = imerode(I,strel('line',70,0));
%figure12
%figure; imshow(er);
I = imsubtract(I,er);
%figure13
%figure; imshow(I);

I = imfill(I,'holes');
%figure14
%figure; imshow(I);

I = bwmorph(I,'thin',1);
%figure15
%figure; imshow(I);

I = imerode(I,strel('line',3,90));
%figure16
%figure; imshow(I);

copy_I=I;
%figure; imshow(copy_I);

I = bwareaopen(I,100);
%figure17
%figure; imshow(I);
%copy_I=I;
%figure; imshow(copy_I);


Iprops=regionprops(I,'BoundingBox','Image');
NR=cat(1,Iprops.BoundingBox);


NR2=[]; 
for i=1:size(NR,1)
    if  NR(i,1)>=0.05*size(I,2) && (NR(i,1)+NR(i,3))<(0.98*size(I,2)) && NR(i,2)>=0.125*size(I,1) && (NR(i,2)+NR(i,4))<0.875*size(I,1) && NR(i,3)>=10 && NR(i,4)>=30 
        NR2=cat(1,NR2,NR(i,:));
    end
end

%NR2

[Q,W]=hist(NR2(:,2),6);

for j=1:length(Q)
    if Q(1,j)>9
        Q(1,j)=0;
    end
end
ind=find(Q==max(Q));
sizew=W(2)-W(1);
container=[W(ind)-sizew/2 W(ind)+sizew/2];

NR3=[]; % Initialize the variable to an empty matrix.
for i=1:length(NR2)
    if NR2(i,2)>=container(1) && NR2(i,2)<=container(2) % finding boxes containing characters
        NR3=cat(1,NR3,NR2(i,:));
    end
end

%NR3

ten_percent_avg_length=0.1*((sum(NR3(:,4)))/size(NR3,1));
avg_y_coor=((sum(NR3(:,2)))/size(NR3,1));

corrected_container=[avg_y_coor-ten_percent_avg_length avg_y_coor+ten_percent_avg_length];

NR4=[]; % Initialize the variable to an empty matrix.
for i=1:size(NR2,1)
    if NR2(i,2)>=corrected_container(1) && NR2(i,2)<=corrected_container(2) % finding boxes containing characters
        NR4=cat(1,NR4,NR2(i,:));
    end
end

%NR4

%%%space
diff_x=zeros(1,size(NR4,1)-1);
for k=1:size(NR4,1)-1
    diff_x(k)=NR4(k+1,1)-(NR4(k,1)+NR4(k,3));
end
%diff_x
[T,D]=hist(diff_x,3);
cl_int=D(2)-D(1);
no_spc_boundary=[D(1)-(cl_int/2) D(end)-(cl_int/2)];

no_space=find(diff_x<no_spc_boundary(2));
space=find(diff_x>no_spc_boundary(2));

if (sum(diff_x(space))/length(space))>2*((sum(diff_x(no_space)))/length(no_space))
    space_ok=1;
else
    space_ok=0;
end

%%%%hyphen
if space_ok==1
    for p=1:length(space)
        up_left_x=(NR4(space(p),1)+NR4(space(p),3));
        up_left_y=NR4(space(p),2);
        width=diff_x(space(p))-20;
        height=NR4(space(p),4)-20;
        TT=imcrop(copy_I,[up_left_x+10 up_left_y+10 width height]);
        %figure;imshow(TT);
        hyphen=regionprops(TT,'Image');
        if isempty(hyphen)
            hyphen_ok(p)=0;
        else
            hyphen_snap={hyphen.Image};
            yy=hyphen_snap{1,1};
            %figure;imshow(yy);
            hyphen_ok(p)=readHyphen(yy);
        end
    end
end

%%%%%%%%%%%%%%%%% testing the extractions %%%%%%%%%%%%%%%%%
space_index=1;
r=[];
for k=1:size(NR4,1)
    var=find(NR4(k,1)==reshape(NR(:,1),1,[])); 
    r=[r var];
end

I2={Iprops.Image};
noPlate=[]; 

for v=1:length(r)
    %figure; imshow(I2{1,r(v)})
    N=I2{1,r(v)};
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
    if space_ok==1 && v<=space(end) && v==space(space_index)
        noPlate=[noPlate ' '];
        
        if hyphen_ok(space_index)==1
            noPlate=[noPlate '-' ' '];
        end
        space_index=space_index+1;
    end
end
%disp(noPlate);  




%%%%%%%%%%%%%%%%% testing the extractions %%%%%%%%%%%%%%%%%
%r=[];
%for k=1:size(NR2,1)
 %   var=find(NR2(k,1)==reshape(NR(:,1),1,[])); 
  %  r=[r var];
%end

%I2={Iprops.Image};
%for v=1:length(r)
%figure; imshow(I2{1,r(v)})
%end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%