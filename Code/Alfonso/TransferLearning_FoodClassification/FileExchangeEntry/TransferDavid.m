% Copyright 2017 The MathWorks, Inc.

%% Load a pre-trained, deep, convolutional network
alex = convnet;
layers = convnet.Layers;

%% Modify the network to use five categories
layers(5) = fullyConnectedLayer(18); 
layers(7) = classificationLayer;

%% Set up our training data
% '/home/das/sources/IKEA/Code/letras'
allImages = imageDatastore('/home/das/sources/IKEA/Code/letras', 'IncludeSubfolders', true, 'LabelSource', 'foldernames');
[trainingImages, testImages] = splitEachLabel(allImages, 0.8, 'randomize');

%% Re-train the Network
opts = trainingOptions('sgdm', 'InitialLearnRate', 0.001, 'MaxEpochs', 20, 'MiniBatchSize', 64);
myNet = trainNetwork(trainingImages, layers, opts);

%% Measure network accuracy
predictedLabels = classify(myNet, testImages); 
accuracy = mean(predictedLabels == testImages.Labels)

