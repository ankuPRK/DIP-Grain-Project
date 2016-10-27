I_orig = imread('3.jpg');
I=I_orig(:,:,1);
%imshow(I)
%hold on

b = imsharpen(I,'Radius',20,'Amount',20);
%imshow(b)
BW2 = bwareaopen(b,1000);
%imshow(BW2)
I_contour=imcontour(BW2);