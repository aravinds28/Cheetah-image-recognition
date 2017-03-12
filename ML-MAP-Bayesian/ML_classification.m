function[p_err] = ML_classification(dataset)

data = importdata('TrainingSamplesDCT_subsets_8.mat');
alpha = importdata('Alpha.mat');
p_err = zeros(9,1);
if dataset ==1
    FG = data.D1_FG;
    BG = data.D1_BG;
end
if dataset ==2
    FG = data.D2_FG;
    BG = data.D2_BG;
end
if dataset ==3
    FG = data.D3_FG;
    BG = data.D3_BG;
end
if dataset ==4
    FG = data.D4_FG;
    BG = data.D4_BG;
end

%calculate the mean and covariance 
mean_BG = mean(BG)';
mean_FG = mean(FG)';
cov_BG = cov(BG);
cov_FG = cov(FG);
%set up other parameters
I = imread('cheetah.bmp');
I = im2double(I);
p_FG = 0.2;
p_BG = 0.8;
image = zeros(64714,1);
count = 1;

for i = 0:246
    
    for j = 0:261
        m = i+1;
        A = zeros(8,8);
        x = 1;
        
        for a = 1:8  %assign the values in 8x8 blocks starting in the first row
            n = j+1;  %get the current columncoun
            y = 1;    %reset to the first rown in A
            for b = 1:8 %column
                A(x,y) = I(m,n);     %assign the values in 8x8 blocks to A
                y = y + 1;
                n = n + 1;
            end
            x = x + 1;      %update row number in 8x8 block
            m = m + 1;      %update row number in A
            
        end
        
        A = dct2(A);
        %A is zig-zag pattern, reshape it
        ind = reshape(1:numel(A), size(A));         %# indices of elements
        ind = fliplr( spdiags( fliplr(ind) ) );     %# get the anti-diagonals
        ind(:,1:2:end) = flipud( ind(:,1:2:end) );  %# reverse order of odd columns
        ind(ind==0) = [];
        A = A(ind);
        X = A';
        
        %%classify the8x8 block A with the best 8 features
        state_FG = log(mvnpdf(X,mean_FG,cov_FG)) + log(p_FG);
        state_BG = log(mvnpdf(X,mean_BG,cov_BG)) + log(p_BG);
        if state_FG > state_BG
            image(count,1) = 1;
        else
            image(count,1) = 0;
        end
    
        count = count+1;
        
           
    end
    
end
image = reshape(image, [262,247]);
image = image';
a = zeros(247,8);
image = [image a];
a = zeros(8,270);
image = [image; a];
%imagesc(image);
%colormap(gray(255));

%calculate the probability of error
mask = imread('cheetah_mask.bmp');
mask = im2double(mask);

count_one = 0;
count_zero = 0;
one_diff = 0;
zero_diff = 0;
for i = 1:255
    for j = 1:270
        if mask(i,j) == 1
            count_one = count_one + 1;
            if image(i,j) == 0
                one_diff = one_diff + 1;
            end
        end
        if mask(i,j) == 0
            count_zero = count_zero + 1;
            if image(i,j) == 1
                zero_diff = zero_diff + 1;
            end
        end
        
    end
end

p_one_error = one_diff / count_one;
p_zero_error = zero_diff / count_zero;
p_err(1:9,1) = p_one_error * p_FG + p_zero_error * p_BG;


semilogx(alpha,p_err,'r');
xlabel('alpha value');
ylabel('probability of error');


end