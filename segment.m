close all;
clear;
Img = im2double(imread('IMG_20161008_141733.jpg'));
figure(1);
imshow(Img);
img = Img;
[M, N, ~] = size(img);

im = imerode(img(:,:,1),strel('disk',8));
for i = 1:M
    for j = 1:N
        if im(i,j)<0.1
            img(i,j,:)=[0,0,0];
        end
    end
end
figure(2);
imshow(img);

res = bwconncomp(img(:,:,1),6);

for k=1:100
    l = res.PixelIdxList{k};
    [i, j] = ind2sub([M,N], l);
    a = zeros(max(i)-min(i), max(j)-min(j), 3);
    a(i-min(i)+1,j-min(j)+1,:) = img(i,j,:);
    imshow(a);
    pause(2);
end


