function [arrayOne, arrayTwo, arrayThree, arrayFour, arrayFive, arraySix, arraySeven, arrayEight] = JPEG2000Proj(inputImage, qVal)
%% this code is made to work on grayscale images.
close all
%%%Lossy compression
img = imread(inputImage);
if size(img, 3) == 3
    img = rgb2gray(img);
end
figure('Name', 'grayImg');
imshow(img);
[r, c, chan] = size(img);
centeredImg = zeros(r, c, chan);

%%%Centering the grayscale intensity values step 1.
centeredImg(:, :) = img(:, :) - 127;
 centeredImg =  int8(centeredImg);
 figure('Name', 'centered image');
 imshow(int8(centeredImg));
%%%Transformation using DWT with the 'db1' filter step 2.
[cA1, cH1, cV1, cD1] = dwt2(centeredImg, 'db1');
[cA2, cH2, cV2, cD2] = dwt2(cA1, 'db1');
[cA3, cH3, cV3, cD3] = dwt2(cA2, 'db1');

%%%Quantization of all the blocks except cA2 and cA1 as we don't need step3
% stepSize = -4000:qVal:4000;
%%%third iteration quantization
[r3, c3, ~] = size(cA3);
for i3 = 1: r3
    for j3 = 1: c3
%         [~, vA] = histc(cA3(i3, j3), stepSize);
%         [~, vH] = histc(cH3(i3, j3), stepSize);
%         [~, vV] = histc(cV3(i3, j3), stepSize);
%         [~, vD] = histc(cD3(i3, j3), stepSize);
        cA3(i3, j3) = floor(cA3(i3, j3)/qVal)*qVal;
        cH3(i3, j3) = floor(cH3(i3, j3)/qVal)*qVal;
        cV3(i3, j3) = floor(cV3(i3, j3)/qVal)*qVal;
        cD3(i3, j3) = floor(cD3(i3, j3)/qVal)*qVal;
    end
end
%%%second iteration quantization
[r2, c2, ~] = size(cA2);
for i2 = 1: r2
    for j2 = 1: c2
%         [~, vH] = histc(cH2(i2, j2), stepSize);
%         [~, vV] = histc(cV2(i2, j2), stepSize);
%         [~, vD] = histc(cD2(i2, j2), stepSize);
        cH2(i2, j2) = floor(cH2(i2, j2)/qVal)*qVal;
        cV2(i2, j2) = floor(cV2(i2, j2)/qVal)*qVal;
        cD2(i2, j2) = floor(cD2(i2, j2)/qVal)*qVal;
    end
end
%%%First iteration quantization
[r1, c1, ~] = size(cA1);
for i1 = 1: r1
    for j1 = 1: c1
%         [~, vH] = histc(cH1(i1, j1), stepSize);
%         [~, vV] = histc(cV1(i1, j1), stepSize);
%         [~, vD] = histc(cD1(i1, j1), stepSize);
        cH1(i1, j1) = floor(cH1(i1, j1)/qVal)*qVal;
        cV1(i1, j1) = floor(cV1(i1, j1)/qVal)*qVal;
        cD1(i1, j1) = floor(cD1(i1, j1)/qVal)*qVal;
    end
end
%%%%%%%%%%%%%% reconstructing image.
cA2New = idwt2(cA3, cH3, cV3, cD3, 'db1');
[~, cNew, ~] = size(cA2New);
cA1New = idwt2(cA2New(:,1:cNew-1), cH2, cV2, cD2, 'db1');
newImage = idwt2(cA1New, cH1, cV1, cD1, 'db1');
% figure('Name', 'newImage');
% imshow(int8(newImage))
% max(max(int8(newImage)))

%%%%%%Encoding step 4.
newImage = int8(newImage);        %%%%%% changing image to signed 
[rNew, cNew, ~] = size(newImage);
binaryOutput = zeros(rNew, cNew, 8);
for i = 1: rNew
    for j = 1: cNew
        binaryNum = bitget(newImage(i, j), 8:-1:1);
        binaryOutput(i, j, 8) = binaryNum(1);
        binaryOutput(i, j, 7) = binaryNum(2);
        binaryOutput(i, j, 6) = binaryNum(3);
        binaryOutput(i, j, 5) = binaryNum(4);
        binaryOutput(i, j, 4) = binaryNum(5);
        binaryOutput(i, j, 3) = binaryNum(6);
        binaryOutput(i, j, 2) = binaryNum(7);
        binaryOutput(i, j, 1) = binaryNum(8);
    end
end

%%% run length encoding part

arrayOne = {37883,2};
counter1 = 1;
counterArray1 = 1;
curr1 = binaryOutput(1, 1, 1);
for i = 1: rNew
    for j = 1: cNew
        if i~=1 || j~=1
            if binaryOutput(i, j, 1) == curr1
                counter1 = counter1 + 1;
            else
                arrayOne{counterArray1, 1} = counter1;
                arrayOne{counterArray1, 2} = curr1;
                curr1 = binaryOutput(i, j, 1);
                counter1 = 1;
                counterArray1 = counterArray1 + 1;
            end
        end 
    end    
end
%%%%%%%%
arrayTwo = {65711,2};
counter2 = 1;
counterArray2 = 1;
curr2 = binaryOutput(1, 1, 2);
for i = 1: rNew
    for j = 1: cNew
        if i~=1 || j~=1
            if binaryOutput(i, j, 2) == curr2
                counter2 = counter2 + 1;
            else
                arrayTwo{counterArray2, 1} = counter2;
                arrayTwo{counterArray2, 2} = curr2;
                curr2 = binaryOutput(i, j, 2);
                counter2 = 1;
                counterArray2 = counterArray2 + 1;
            end
        end 
    end    
end
%%%%%%%%%%%%%
arrayThree = {110831,2};
counter3 = 1;
counterArray3 = 1;
curr3 = binaryOutput(1, 1, 3);
for i = 1: rNew
    for j = 1: cNew
        if i~=1 || j~=1
            if binaryOutput(i, j, 3) == curr3
                counter3 = counter3 + 1;
            else
                arrayThree{counterArray3, 1} = counter3;
                arrayThree{counterArray3, 2} = curr3;
                curr3 = binaryOutput(i, j, 3);
                counter3 = 1;
                counterArray3 = counterArray3 + 1;
            end
        end 
    end    
end
%%%%%%%%%%%%%%%%
arrayFour = {103563,2};
counter4 = 1;
counterArray4 = 1;
curr4 = binaryOutput(1, 1, 4);
for i = 1: rNew
    for j = 1: cNew
        if i~=1 || j~=1
            if binaryOutput(i, j, 4) == curr4
                counter4 = counter4 + 1;
            else
                arrayFour{counterArray4, 1} = counter4;
                arrayFour{counterArray4, 2} = curr4;
                curr4 = binaryOutput(i, j, 4);
                counter4 = 1;
                counterArray4 = counterArray4 + 1;
            end
        end 
    end    
end
%%%%%%%%
arrayFive = {94004,2};
counter5 = 1;
counterArray5 = 1;
curr5 = binaryOutput(1, 1, 5);
for i = 1: rNew
    for j = 1: cNew
        if i~=1 || j~=1
            if binaryOutput(i, j, 5) == curr5
                counter5 = counter5 + 1;
            else
                arrayFive{counterArray5, 1} = counter5;
                arrayFive{counterArray5, 2} = curr5;
                curr5 = binaryOutput(i, j, 5);
                counter5 = 1;
                counterArray5 = counterArray5 + 1;
            end
        end 
    end    
end
%%%%%%%%%%
arraySix = {80617,2};
counter6 = 1;
counterArray6 = 1;
curr6 = binaryOutput(1, 1, 6);
for i = 1: rNew
    for j = 1: cNew
        if i~=1 || j~=1
            if binaryOutput(i, j, 6) == curr6
                counter6 = counter6 + 1;
            else
                arraySix{counterArray6, 1} = counter6;
                arraySix{counterArray6, 2} = curr6;
                curr6 = binaryOutput(i, j, 6);
                counter6 = 1;
                counterArray6 = counterArray6 + 1;
            end
        end 
    end    
end
%%%%%%%%%
arraySeven = {63319,2};
counter7 = 1;
counterArray7 = 1;
curr7 = binaryOutput(1, 1, 7);
for i = 1: rNew
    for j = 1: cNew
        if i~=1 || j~=1
            if binaryOutput(i, j, 7) == curr7
                counter7 = counter7 + 1;
            else
                arraySeven{counterArray7, 1} = counter7;
                arraySeven{counterArray7, 2} = curr7;
                curr7 = binaryOutput(i, j, 7);
                counter7 = 1;
                counterArray7 = counterArray7 + 1;
            end
        end 
    end    
end
%%%%%%%%%%
arrayEight = {31997,2};
counter8 = 1;
counterArray8 = 1;
curr8 = binaryOutput(1, 1, 8);
for i = 1: rNew
    for j = 1: cNew
        if i~=1 || j~=1
            if binaryOutput(i, j, 8) == curr8
                counter8 = counter8 + 1;
            else
                arrayEight{counterArray8, 1} = counter8;
                arrayEight{counterArray8, 2} = curr8;
                curr8 = binaryOutput(i, j, 8);
                counter8 = 1;
                counterArray8 = counterArray8 + 1;
            end
        end 
    end    
end
%%%%%%%%%%
end