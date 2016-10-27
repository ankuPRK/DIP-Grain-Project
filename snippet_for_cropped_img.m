I = imread('original.jpg'); %assuming I to be a grayscale image

%%%%%%%%%%%%%%
% segmentation here; o/p of segmentation has to be a binary image
%%%%%%%%%%%%%%

cc = bwconncomp(binary_image, 4); 
%will create a list of contour structures;

A = cc.PixelIdxList{10};
Ht = size(I,1);
A_x = fix(A/Ht);
A_y = rem(A,Ht);
d_x = max(A_x) - min(A_x) + 1;
d_y = max(A_y) - min(A_y) + 1;
sz = size(A);
Ayy = A_y - min(A_y) ;
Axx = A_x - min(A_x) ;

A_n = Axx*d_y + Ayy + 1;

Iz = uint8(zeros(d_y, d_x)); %this is assuming a grayscale image
%Iz = false([d_y+200, d_x+200]);
Iz(A_n) = I(A);
figure(11)
imshow(Iz);

%Iz is the image to be saved.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

