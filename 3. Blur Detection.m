clear all
close all
clc
%% Initialization
image_length=300;

Ratio = zeros(image_length,2);
image_list = cell(image_length,1);
image_list2 = cell(image_length,1);

%read the csv file while contain the face location
data=importdata('Face_location.csv');

for i = 1:image_length
    str = ['.\Original image png\',num2str(i),'.png'];
    image_list{i,1} = str;    
end

for i = 1:image_length
    str = ['.\image png\',num2str(i),'.png'];
    image_list2{i,1} = str;    
end

%% Deepfakes
for i = 1:image_length
fprintf('%s %d %s %s \n','Processing on:',i,'/',num2str(image_length));% Show the processing
ima = image_list{i,1};
image = imread(ima);
[X,Y,~] = size(image);

LEFT = imcrop(image,[0,0,Y/2,X]);
RIGHT = imcrop(image,[Y/2,0,Y/2,X]);

%for example2, Manual cutting
% LEFT = imcrop(image,[0,0,410-34,X]);
% RIGHT = imcrop(image,[410+34,0,410-35,X]);

%% Face location read
bbox = str2num(data.textdata{i});

%% Crop operation
[number_face,~] = size(bbox);
left_ratio = 0;
right_ratio = 0;
    
if(number_face>1)
    
    if(bbox(2,1)>bbox(1,1))
         A=1;
         B=2;
    else
         A=2;
         B=1;
    end

    %bounding box of face Slightly smaller
    left=imcrop(image,[bbox(A,1)+1/8*bbox(A,3),bbox(A,2)+1/8*bbox(A,4),3/4*bbox(A,3),3/4*bbox(A,4)]);
    right=imcrop(image,[bbox(B,1)+1/8*bbox(B,3),bbox(B,2)+1/8*bbox(B,4),3/4*bbox(B,3),3/4*bbox(B,4)]);

    LEFT_bk = LEFT;
    RIGHT_bk = RIGHT;
    
    %% Laplace
    Lap =[1 1 1; 1 -8 1; 1 1 1];

    left2 = imfilter(left,Lap);
    right2 = imfilter(right,Lap);

    LEFT_bk2 = imfilter(LEFT_bk,Lap);
    RIGHT_bk2 = imfilter(RIGHT_bk,Lap);

    %% Calcualte the variance
    Tem_A=im2double(LEFT_bk2);
    Tem_A=Tem_A(:);
    Tem_B=im2double(RIGHT_bk2);
    Tem_B=Tem_B(:);

    left_var_tol=var(Tem_A);
    right_var_tol=var(Tem_B);
   
    Tem_A=im2double(left2);
    Tem_A=Tem_A(:);
    Tem_B=im2double(right2);
    Tem_B=Tem_B(:);

    left_var=var(Tem_A);
    right_var=var(Tem_B);

    left_ratio = left_var/left_var_tol;
    right_ratio = right_var/right_var_tol;
  
end
   
Ratio(i,1) = left_ratio;
Ratio(i,2) = right_ratio;

%% Output 
ima = image_list2{i,1};
image = imread(ima);
imshow(image);

if(number_face>1)
    if(Ratio(i,1)>Ratio(i,2)) %normal
     rectangle('Position',[bbox(B,1),bbox(B,2),bbox(B,3),bbox(B,4)],'Curvature',[1,1],'EdgeColor','r','LineWidth',4);
    else
      rectangle('Position',[bbox(A,1),bbox(A,2),bbox(A,3),bbox(A,4)],'Curvature',[1,1],'EdgeColor','r','LineWidth',4);
    end
end

F=getframe(gcf);
path = '.\Deepfakes 2\';
format='.png';
filename = num2str(i);
imwrite(F.cdata, [path,filename,format]);

end

%% Output Accuracy

Ratio(Ratio(:,1)==0,:)=[]; %remove the row whose element all zeros

accuracy = 0;
for i = 1:length(Ratio)
    if(Ratio(i,2)<Ratio(i,1))
        accuracy = accuracy +1;
    end
end

figure
plot(Ratio(:,1),'b--');
hold on
plot(Ratio(:,2),'r--');
legend('Original','Deepfakes');
title(['accuracy=' num2str(accuracy/length(Ratio))]);
xlim([0 length(Ratio)]);
xlabel('numbering of faces');
ylabel('Variance Ratio');

%% Output Threshold 
Resoulution = 500;

thRange = linspace(0,max(max(Ratio)),Resoulution);
Error = zeros(Resoulution,1);

for t = 1:Resoulution
    threshold = thRange(t);
    
    error = 0;
    
    for i = 1:length(Ratio)        
        if(Ratio(i,1)<threshold)            
            error = error +1;
        end
    
        if(Ratio(i,2)>threshold)
            error = error +1;
        end
    end

    Error(t) = 1 - (error/(2*length(Ratio)));
end

figure
plot(thRange,Error,'b--');
[~,x_max]=max(Error);
hold on
line([thRange(x_max) thRange(x_max)],[0 max(Error)],'color','r','LineStyle','--');
hold on
plot(thRange(x_max),max(Error),'r*');
title(['Threshold=',num2str(thRange(x_max)),'     Max accuracy=' num2str(max(Error))]);
xlabel('Threshold');
ylabel('Accuracy');
xlim([0 max(thRange)])