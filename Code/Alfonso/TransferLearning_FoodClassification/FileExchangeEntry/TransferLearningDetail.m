% Copyright 2017 The MathWorks, Inc.

%% Deep Learning: Transfer Learning in 10 Lines of MATLAB Code 
% Transfer learning is a very practical way to use deep learning by 
% modifying an existing deep network(usually trained by an expert) to work 
% with your data. 

%% Problem statement  
% The problem we tried to solve with transfer learning is to distinguish
% between 5 categories of food - cupcakes, burgers, apple pie, hot dogs and
% ice cream. To get started you need two things:
% 
% # Training images of the different object classes
% # A pre-trained deep neural network (AlexNet)
% You can substitute these categories for any of your own based on what
% image data you have avaliable.  

%% Load Training Images
% In order for imageDataStore to parse the folder names as category labels,
% you would have to store image categories in corresponding sub-folders.
allImages = imageDatastore('TrainingData', 'IncludeSubfolders', true,...
    'LabelSource', 'foldernames');


%% Split data into training and test sets 
[trainingImages, testImages] = splitEachLabel(allImages, 0.8, 'randomize');
 
%% Load Pre-trained Network (AlexNet)
% AlexNet is a pre-trained network trained on 1000 object categories.
% AlexNet is avaliable as a support package on FileExchange. 
alex = alexnet; 

%% Review Network Architecture 
layers = alex.Layers 

%% Modify Pre-trained Network 
% AlexNet was trained to recognize 1000 classes, we need to modify it to
% recognize just 5 classes. 
layers(23) = fullyConnectedLayer(5); % change this based on # of classes
layers(25) = classificationLayer

%% Perform Transfer Learning
% For transfer learning we want to change the weights of the network ever so slightly. How
% much a network is changed during training is controlled by the learning
% rates. 
opts = trainingOptions('sgdm', 'InitialLearnRate', 0.001,...
    'MaxEpochs', 20, 'MiniBatchSize', 64);

%% Set custom read function 
% One of the great things about imageDataStore it lets you specify a
% "custom" read function, in this case it is simply resizing the input
% images to 227x227 pixels which is what AlexNet expects. You can do this by
% specifying a function handle of a function with code to read and
% pre-process the image. 

trainingImages.ReadFcn = @readFunctionTrain;

%% Train the Network 
% This process usually takes about 5-20 minutes on a desktop GPU. 
myNet = trainNetwork(trainingImages, layers, opts);


%% Test Network Performance
% Now let's the test the performance of our new "snack recognizer" on the test set.
testImages.ReadFcn = @readFunctionTrain;
predictedLabels = classify(myNet, testImages); 
accuracy = mean(predictedLabels == testImages.Labels)

