lsdir = {'fg_good/','fp_good/'};

% for i=1:1:2
%     for j=1:1:14
%         I_orig = imread(strcat(lsdir{i},num2str(j),'.jpg'));
%         I=I_orig(:,:,1);
%         I2 = I_orig(:,:,2);
%         I3 = I_orig(:,:,3);
%         %b1 = imsharpen(I,'Radius',20,'Amount',20);
%         b=I;
%         %b=imadjust(I);
%         %I2 = imtophat(b, strel('disk', 10));
%         %level = graythresh(b);
%         %BW = im2bw(I2,level);
%         %se = strel('disk', 10);
%         %binary_image = bwareaopen(b,5000);
%         %binary_image = imopen(binary_image,se);
%         binary_image=im2bw(b);
%         %binary_image=im2bw(b);
%         %binary_image=imfill(binary_image);
%         se = strel('disk', 3);
%         binary_image = imopen(binary_image,se);
%         imwrite(binary_image, strcat(lsdir{i},num2str(j),'_b.jpg'));
%     end
% end


%binary_image = bwareaopen(binary_image,5000);
%----------------------------------------------------------------------------------------------------

X_fp = [];
X_fg = [];

t_fp = 1;
t_fg = 1;

for i=1:1:2
    for j=1:1:14

disp([i j]);

        I_orig = imread(strcat(lsdir{i},num2str(j),'.jpg'));

        
        I=I_orig(:,:,1);
        I2 = I_orig(:,:,2);
        I3 = I_orig(:,:,3);
binary_image = imread(strcat(lsdir{i},num2str(j),'_b.jpg'));

        se = strel('disk', 3);
        binary_image = imopen(binary_image,se);

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

% X_fg = features;
% Y_fg = linspace(0,0,num_grain_new).';
length=size(features,1);
disp(length);

if i==1
    X_fg(t_fg:t_fg+length-1,:) = features;
    t_fg = t_fg+length
    disp(size(X_fg));
else
    X_fp(t_fp:t_fp+length-1,:) = features;
    t_fp = t_fp+length
    disp(size(X_fp));
end
disp('done...');
    end
end

l_fg = linspace(0,0,size(X_fg,1)).';
l_fp = linspace(1,1,size(X_fp,1)).';

save('X_fg.mat','X_fg');
save('X_fp.mat','X_fp');
save('l_fg.mat','l_fg');
save('l_fp.mat','l_fp');

% random = randsample(1:size(X_fg,1),size(X_fp,1));
% 
% X_fg2 = X_fg(random,:);
% X_fp2 = X_fp;
% Y_fp2 = l_fp;
% Y_fg2 = l_fg(random);
% 
% l1 = size(X_fg2,1);
% r1 = randsample(1:l1,l1);
% X_fg_s=X_fg2(r1,:);
% l2 = size(X_fp2,1);
% r2 = randsample(1:l2,l2);
% X_fp_s=X_fp2(r2,:);
% 
% X_tr = [X_fg_s(1:fix(0.8*l1),:);X_fp_s(1:fix(0.8*l2),:)];
% Y_tr = [Y_fg2(1:fix(0.8*l1));Y_fp2(1:fix(0.8*l2))];
% 
% X_tst = [X_fg_s(fix(0.8*l1)+1:l1,:);X_fp_s(fix(0.8*l2):l2,:)];
% Y_tst = [Y_fg2(fix(0.8*l1):l1);Y_fp2(fix(0.8*l2):l2)];
% 
% rtr = randsample(1:size(X_tr,1),size(X_tr,1));
% X_tr_s = X_tr(rtr,:);
% Y_tr_s = Y_tr(rtr);
% 
% rtst = randsample(1:size(X_tst,1),size(X_tst,1));
% X_tst_s = X_tst(rtst,:);
% Y_tst_s = Y_tst(rtst);
% 
% X_tr_new=bsxfun(@minus,X_tr_s,mean(X_tr_s));
% X_tr_final = bsxfun(@rdivide, X_tr_new, std(X_tr_s));
% X_tst_new=bsxfun(@minus,X_tst_s,mean(X_tr_s));
% X_tst_final=bsxfun(@rdivide, X_tst_new, std(X_tr_s));
% 
% model = fitcknn(X_tr_final, Y_tr_s);
% model.NumNeighbors = 2;
% %model.DistanceWeight = 'inverse';
% % model = fitcsvm(X_tr_final, Y_tr_s,'KernelFunction','rbf');
% [label,score] = predict(model,X_tst_final);
% accu = 1 - sum(abs(label-Y_tst_s))/size(Y_tst_s,1);
% [C, order] = confusionmat(Y_tst_s, label);
% disp(strcat('accuracy: ',num2str(accu)));
% disp(C);
% disp(order);
% 
% disp('accu for all the grains:');
% X_bulk_new=bsxfun(@minus,X_fg,mean(X_tr_s));
% X_bulk_final=bsxfun(@rdivide, X_bulk_new, std(X_tr_s));
% [label2,score2] = predict(model,X_bulk_final);
% accu = 1 - sum(label2) / size(label2,1)
% size(label2,1)

%for num_grain