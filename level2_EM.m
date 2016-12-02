for itr = 122:438
img = im2double(Iz_new{itr});
im = (img(:,:,1)+img(:,:,2)+img(:,:,3))/3;

sz = size(im);
im(im>0.35) = 1;
im(im<=0.35) = 0;

se = strel('disk', 6);
im2 = imerode(im, se);
im = imclose(im, strel('disk', 4));

cc_new = bwconncomp(im2, 8);
S = regionprops(cc_new,'Centroid');
[x,y]=ind2sub(sz,find(img(:,:,1)>0.3));
N = cc_new.NumObjects;
init = zeros(cc_new.NumObjects,2);
for i = 1:N
    if size(cc_new.PixelIdxList{i},1)<100
        N = N-1;
    else
        init(i,:) = S(i).Centroid;
    end
end
% plot(x, y, '.b', init(:,2), init(:,1), '*k');
init = [init(:,2) init(:,1)];
[idx, ~, ~] = emAlgo([x,y], N, init);


%     cc.NumObjects = cc.NumObjects + N - 1;
%     for i = 1:N
%         [x, y] = ind2sub(sz,find(im(idx == i)));
%         y = y + min(A_x);
%         x = x + min(A_y);
%             plot(y, x, '.b');
% 
%         if(t == 171) 
%             2;
%         end
%         cel = mat2cell(sub2ind(size(I), y, x)', 1, size(x,1));
%         if(i == 1)
%             cc.PixelIdxList{t} = cel;
%         else
%             cc.PixelIdxList = [cc.PixelIdxList, cel];
%         end
%     end

subplot(2,2,[1,3]);
plot(y(idx==1), x(idx==1), '.b', y(idx==2), x(idx==2), '.g', y(idx==3), x(idx==3), '.r', y(idx==4), x(idx==4), '.y');
subplot(2,2,2);
imshow(flip(img,1));
subplot(2,2,4);
imshow(flip(im2,1));
% set(gca,'xdir','reverse')
drawnow;
end

