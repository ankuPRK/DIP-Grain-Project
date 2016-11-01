bw1=Iz{490};
%b1 = imsharpen(bw1,'Radius',10,'Amount',10);
bw=im2bw(bw1);


hy = fspecial('sobel');
hx = hy';
Iy = imfilter(double(bw1), hy, 'replicate');
Ix = imfilter(double(bw1), hx, 'replicate');
gradmag = sqrt(Ix.^2 + Iy.^2);
figure(2)
imshow(gradmag,[]), title('Gradient magnitude (gradmag)')

%{
%sure background
se = strel('disk', 10);
Io1 = imopen(bw, se);
bg = imdilate(Io1,se);
figure
imshow(bg), title('Sure background (Io)')
%

fg1 = bwdist(~bg);
fg=zeros(size(fg1));
fg(fg1>0.6*max(max(fg1)))=1;
%D = -D;
%D(~bw) = -Inf;
%D = imhmin(D,15); 
figure
imshow(fg,[],'InitialMagnification','fit')
title('Sure foreground')
%h=im2bw(D,0.7*
%}
bw1=bw;
%bw1 = imfill(bw1,'holes');
D=bwdist(~bw1);
figure
imshow(D,[],'InitialMagnification','fit')
title('Distance transform of ~bw')
D = -D;
D(~bw1) = -Inf;
D = imhmin(D,3); 
%D=imfill(D,'holes');
%D=imimposemin(D, fg|~bg);
L = watershed(D);
rgb = label2rgb(L,'jet',[.5 .5 .5]);
figure
imshow(rgb,'InitialMagnification','fit')
title('Watershed transform of D')
