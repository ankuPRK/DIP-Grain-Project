I_orig = imread('3.jpg');
I=I_orig(:,:,1);
%I=rgb2gray(I_orig);

%b1 = imsharpen(I,'Radius',20,'Amount',20);
%b=I;
b=imadjust(I);
%I2 = imtophat(b, strel('disk', 10));
%level = graythresh(b);
%BW = im2bw(I2,level);
%se = strel('disk', 10);
%binary_image = bwareaopen(b,5000);
%binary_image = imopen(binary_image,se);
binary_image=im2bw(b);
%----------------------------------------------------------------------------------------------------
cc = bwconncomp(binary_image, 4); 

Iz={};
segmented_im={};
for num_grain=1:cc.NumObjects
	A = cc.PixelIdxList{num_grain};
	Ht = size(I,1);
	A_x = fix(A/Ht);
	A_y = rem(A,Ht);
	d_x = max(A_x) - min(A_x) + 1;
	d_y = max(A_y) - min(A_y) + 1;
	sz = size(A);
	Ayy = A_y - min(A_y) ;
	Axx = A_x - min(A_x) ;

	A_n = Axx*d_y + Ayy + 1;
	Iz{num_grain} = uint8(zeros(d_y, d_x)); %this is assuming a grayscale image
%Iz = false([d_y+200, d_x+200]);
	Iz{num_grain}(A_n) = I(A);
	I_logical{num_grain}=im2bw(Iz{num_grain});

	%D = bwdist(~BW); % image B (above)
	%BW=I_logical{num_grain};
	%D = -bwdist(~BW);
	%D(~BW) = -Inf;
	BW=Iz{num_grain};
	%segmented_im{num_grain}=segmentation(BW);

end

%Im = false(size(I,0),size(I,1));
%Im(cc.PixelIdxList{354}) = true;
%imshow(Im);






for num_grain=1:cc.NumObjects
	subplot(40,40,num_grain);
	h=imshow(Iz{num_grain});
	%title(num2str(num_grain));
end



%{
D = -bwdist(~BW2);
D(~BW2) = -Inf;
L = watershed(D);
imshow(label2rgb(L,'jet','w'))
%}

%imshow(b)

%imshow(BW2)
%I_contour=imcontour(BW2);

