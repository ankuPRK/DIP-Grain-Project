lsdir = {'fg_good/','fp_good/'};

        I_orig = imread('test.jpg');
        I=I_orig(:,:,1);
        I2 = I_orig(:,:,2);
        I3 = I_orig(:,:,3);
        %b1 = imsharpen(I,'Radius',20,'Amount',20);
        %b=imadjust(I);
        %I2 = imtophat(b, strel('disk', 10));
        %level = graythresh(b);
        %BW = im2bw(I2,level);
        %se = strel('disk', 10);
        %binary_image = bwareaopen(b,5000);
        %binary_image = imopen(binary_image,se);
        se = strel('disk', 7);
        b=I2;
        b1 = ~im2bw(b,0.4);
        b1 = imopen(b1,se);
        b=I;
        se = strel('disk', 3);

        b2=im2bw(b,0.4);
        b2 = imopen(b2,se);
        binary_image = imadd(b1,b2);
        %binary_image=im2bw(b);
        %binary_image=imfill(binary_image);
        figure(1)
        imshow(b1);
        figure(2)
        imshow(b2);
        figure(3)
        imshow(I);
        figure(4)
        imshow(binary_image);
        imwrite(binary_image, 'test_b.jpg');


%binary_image = bwareaopen(binary_image,5000);
%----------------------------------------------------------------------------------------------------

X_fp = [];
X_fg = [];

t_fp = 1;
t_fg = 1;


        I_orig = imread('test.jpg');

        
        I=I_orig(:,:,1);
        I2 = I_orig(:,:,2);
        I3 = I_orig(:,:,3);
binary_image = imread('test_b.jpg');

%         se = strel('disk', 3);
%         binary_image = imopen(binary_image,se);

cc = bwconncomp(binary_image, 8); 

Iz={};
Iz1={};
Iz2={};
Iz3={};
segmented_im={};
latent_all={};

graindata = regionprops(cc,'basic');
grain_areas = [graindata.Area];
% figure
% histogram(grain_areas)
% title('Histogram of Rice Grain Area');

figure
imshow(I_orig);

num_grain=1;
for t=1:cc.NumObjects
    if grain_areas(t)>500
	A = cc.PixelIdxList{t};
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
    num_grain=num_grain+1;
    end
end

segmented_grain={};
t=1;
features=[];
disp('getting features');
tff = num_grain-1;
for num_grain=1:cc.NumObjects
    
    if grain_areas(num_grain) > 500
%        rectangle('Position',int32(graindata(num_grain).BoundingBox),'EdgeColor','r');
        segmented_grain{t}=Iz_new{t};
        features(t,1)=mean(mean(double(segmented_grain{t}(:,:,1)))) / 256.0;
        features(t,2)=mean(mean(double(segmented_grain{t}(:,:,2)))) / 256.0;
        features(t,3)=mean(mean(double(segmented_grain{t}(:,:,3)))) / 256.0;
        features(t,4:5)=latent_all{t}(1:2);
        features(t,6)=features(t,4)./features(t,5);
        features(t,7)=grain_areas(num_grain);
        %[coeff,score,latent]=pca(
        
        %{
        subplot(25,20,t);
        h=imshow(segmented_grain{t});
%}        
        t=t+1;
    end
	%title(num2str(num_grain));
end

num_grain_new=t-1;
mean_area = mean(features(:,7));
features(:,4:5) = features(:,4:5) / mean_area;
features(:,7) = features(:,7) / mean_area;

t=1;

features_new=bsxfun(@minus,features,mean(X_tr_s));
features_final=bsxfun(@rdivide, features_new, std(X_tr_s));
[label,score] = predict(model,features_final);


for num_grain=1:cc.NumObjects
    
    if grain_areas(num_grain) > 500
        if label(t) == 0
            rectangle('Position',int32(graindata(num_grain).BoundingBox),'EdgeColor','b');
        else
            rectangle('Position',int32(graindata(num_grain).BoundingBox),'EdgeColor','r');
        end
        %{
        subplot(25,20,t);
        h=imshow(segmented_grain{t});
%}        
        t=t+1;
    end
	%title(num2str(num_grain));
end


%for num_grain