function cc = components_extractor(bw)
bw1= bw;
D=bwdist(~bw1);
D = -D;
D(~bw1) = -Inf;
D = imhmin(D,3); 
L = watershed(D);
bw1(L==0)=0;
se = strel('disk', 10);
bw1 = imopen(bw1,se);
cc = bwconncomp(bw1, 8);
end