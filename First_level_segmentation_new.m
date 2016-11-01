I_orig = imread('easy_1.jpg');
I=I_orig(:,:,1);
I2 = I_orig(:,:,2);
I3 = I_orig(:,:,3);

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
%binary_image=imfill(binary_image);
se = strel('disk', 3);
binary_image = imopen(binary_image,se);
%binary_image = bwareaopen(binary_image,5000);
%----------------------------------------------------------------------------------------------------
cc = bwconncomp(binary_image, 4); 

Iz={};
Iz1={};
Iz2={};
Iz3={};
segmented_im={};
latent_all={};
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
    data_vector=[Axx,Ayy];
    dvshift=bsxfun(@minus, data_vector, mean(data_vector));
    [coeff,score,latent]=princomp(dvshift);
    latent_all{num_grain}=latent;
    
	Iz{num_grain} = uint8(zeros(d_y, d_x)); %this is assuming a grayscale image
   Iz{num_grain}(A_n)=I(A);
   Iz1{num_grain} = uint8(zeros(d_y, d_x)); %this is assuming a grayscale image
   Iz1{num_grain}(A_n)=I2(A);
   Iz2{num_grain} = uint8(zeros(d_y, d_x)); %this is assuming a grayscale image
   Iz2{num_grain}(A_n)=I3(A);
  %{  
    Iz1 = uint8(zeros(d_y,d_x));
    Iz1(A_n)=I(A);
    Iz2 = uint8(zeros(d_y,d_x));
    Iz2(A_n)=I2(A);
    Iz3 = uint8(zeros(d_y,d_x));
    Iz3(A_n)=I3(A);

    Iz{num_grain} = cat(3,Iz3,Iz2,Iz1);
  %}  
   Iz_new{num_grain}=cat(3,Iz{num_grain},Iz1{num_grain},Iz2{num_grain});
%Iz = false([d_y+200, d_x+200]);
	%Iz{num_grain}(Axx,Ayy,1) = I_orig(A_x,A_y,1);
%	Iz{num_grain}(A_n,2) = I_orig(A,2);
%	Iz{num_grain}(A_n,3) = I_orig(A,3);
    
%	I_logical{num_grain}=im2bw(Iz{num_grain});

	%D = bwdist(~BW); % image B (above)
	%BW=I_logical{num_grain};
	%D = -bwdist(~BW);
	%D(~BW) = -Inf;
%	BW=Iz{num_grain};
	%segmented_im{num_grain}=segmentation(BW);

end

%Im = false(size(I,0),size(I,1));
%Im(cc.PixelIdxList{354}) = true;
%imshow(Im);

graindata = regionprops(cc,'basic');
grain_areas = [graindata.Area];
figure
histogram(grain_areas)
title('Histogram of Rice Grain Area');



segmented_grain={};
t=1;
features={};
for num_grain=1:cc.NumObjects
    
    if grain_areas(num_grain) > 500
        segmented_grain{t}=Iz_new{num_grain};
        features{t}(1)=mean(mean(segmented_grain{t}(:,:,1)));
        features{t}(2)=mean(mean(segmented_grain{t}(:,:,2)));
        features{t}(3)=mean(mean(segmented_grain{t}(:,:,3)));
        features{t}(4:5)=latent_all{num_grain}(1:2);
        features{t}(6)=features{t}(4)./features{t}(5);
        features{t}(7)=grain_areas(num_grain);
        %[coeff,score,latent]=pca(
        
        %{
        subplot(25,20,t);
        h=imshow(segmented_grain{t});
%}        
t=t+1;
    end
	%title(num2str(num_grain));
end





num_grain_new=t;
%for num_grain










