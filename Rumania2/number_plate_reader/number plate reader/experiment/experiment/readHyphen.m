function ok=readHyphen(snap)

hyphen1=imread('hyphen.bmp');
hyphen2=imread('hyphen2.bmp');
hyphen3=imread('hyphen3.bmp');%
hyphen4=imread('hyphen4.bmp');%
hyphen5=imread('hyphen5.bmp');
hyphen6=imread('hyphen6.bmp');
hy=[hyphen1 hyphen2 hyphen3 hyphen4 hyphen5 hyphen6];
HyphenTemplate=mat2cell(hy,34,[48 48 48 48 48 48]);

comp=[ ];
snap=imresize(snap,[34 48]);
for n=1:length(HyphenTemplate)
    sem=corr2(HyphenTemplate{1,n},snap);
    comp=[comp sem];
end
vd=find(comp==max(comp));

if vd==1 || vd==2 || vd==5 || vd==6
    ok=1;
else
    ok=0;
end