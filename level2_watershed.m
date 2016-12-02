function new_grain=test_overlap(image_g,bin_s)

%image_g=segmented_grain1{2};
%b1 = imsharpen(bw1,'Radius',10,'Amount',10);
image_g_r=image_g(:,:,1);
image_g_g=image_g(:,:,2);
image_g_b=image_g(:,:,3);

bw=bin_s;
%bw=im2bw(image_g_r);
%se = strel('disk', 3);
%bw = imclose(bw,se);


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
%figure
%imshow(D,[],'InitialMagnification','fit')
%title('Distance transform of ~bw')
D = -D;
D(~bw1) = -Inf;
D = imhmin(D,3); 
%D=imfill(D,'holes');
%D=imimposemin(D, fg|~bg);
L = watershed(D);
rgb = label2rgb(L,'jet',[.5 .5 .5]);
%figure
%imshow(rgb,'InitialMagnification','fit')
%title('Watershed transform of D')

bw1(L==0)=0;
se = strel('disk', 3);
bw1 = imopen(bw1,se);
cc1 = bwconncomp(bw1, 8);

%graindata = regionprops(cc1,'basic');
%grain_areas = [graindata.Area];
%figure
%histogram(grain_areas)
%title('Histogram of Rice Grain Area');

new_grain={};
new_grain1={};
new_grain2={};
new_grain3={};
for num_grain=1:cc1.NumObjects
    A = cc1.PixelIdxList{num_grain};
	Ht = size(bw1,1);
	A_x = fix(A/Ht);
	A_y = rem(A,Ht);
	d_x = max(A_x) - min(A_x) + 1;
	d_y = max(A_y) - min(A_y) + 1;
	sz = size(A);
	Ayy = A_y - min(A_y) ;
	Axx = A_x - min(A_x) ;

	A_n = Axx*d_y + Ayy + 1;
    
	new_grain1{num_grain} = uint8(zeros(d_y, d_x)); %this is assuming a grayscale image
    new_grain1{num_grain}(A_n)=image_g_r(A);
    new_grain1{num_grain}=padarray(new_grain1{num_grain},[2,2]);
    new_grain2{num_grain} = uint8(zeros(d_y, d_x)); %this is assuming a grayscale image
    new_grain2{num_grain}(A_n)=image_g_g(A);
    new_grain2{num_grain}=padarray(new_grain2{num_grain},[2,2]);
    new_grain3{num_grain} = uint8(zeros(d_y, d_x)); %this is assuming a grayscale image
    new_grain3{num_grain}(A_n)=image_g_b(A);
    new_grain3{num_grain}=padarray(new_grain3{num_grain},[2,2]);
    new_grain{num_grain}=cat(3,new_grain1{num_grain},new_grain2{num_grain},new_grain3{num_grain});
   % if grain_areas(num_grain) > 500
   %    segmented_grain{t}=new_grain{num_grain};
        
        %subplot(5,3,num_grain);
       % h=imshow(new_grain{num_grain});
       % t=t+1;
   % end
	%title(num2str(num_grain));
end

%rgb = label2rgb(L,'jet',[.5 .5 .5]);
%figure
%imshow(rgb,'InitialMagnification','fit')
%title('Watershed transform of D')
