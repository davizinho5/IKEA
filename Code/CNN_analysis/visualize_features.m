
% This example shows how to visualize the features learned by convolutional neural networks.

% Convolutional neural networks use features to classify images. The network learns these features itself during the training process. What the network learns during training is sometimes unclear. However, you can use the deepDreamImage function to visualize the features learned.

% The convolutional layers of a network output multiple 2-D arrays. Each array (or channel) corresponds to a filter applied to the layer input. The channels output by fully connected layers correspond to high-level combinations of the features learned by earlier layers.

% You can visualize what the learned features look like by using deepDreamImage to generate images that strongly activate a particular channel of the network layers.

%% Load Pretrained Network and Data
load('trained_CNN.mat')

convnet.Layers

%% Features on Convolutional Layer 1
% Set layer to be the first convolutional layer. This layer is the second layer in the network and is named 'conv1'.
layer = 2;
name = net.Layers(layer).Name

% Visualize the first 56 features learned by this layer using deepDreamImage by setting channels to be the vector of indices 1:56. Set 'PyramidLevels' to 1 so that the images are not scaled. To display the images together, you can use montage (Image Processing Toolbox).

% deepDreamImage uses a compatible GPU, by default, if available. Otherwise it uses the CPU. A CUDA® enabled NVIDIA® GPU with compute capability 3.0 or higher is required for training on a GPU.

channels = 1:56;
I = deepDreamImage(convnet,layer,channels, 'PyramidLevels',1);

figure
montage(I)
title(['Layer ',name,' Features'])

% These images mostly contain edges and colors, which indicates that the filters at layer 'conv1' are edge detectors and color filters. The edge detectors are at different angles, which allows the network to construct more complex features in the later layers.

%% Features on Convolutional Layer 2
% These features are created using the features from layer 'conv1'. The second convolutional layer is named 'conv2', which corresponds to layer 6. Visualize the first 30 features learned by this layer by setting channels to be the vector of indices 1:30.
layer = 6;
channels = 1:30;

I = deepDreamImage(net,layer,channels,...
    'PyramidLevels',1);

figure
montage(I)
name = convnet.Layers(layer).Name;
title(['Layer ',name,' Features'])

%% Features on Convolutional Layers 3–5
% For each of the remaining convolutional layers, visualize the first 30 features learned. To suppress detailed output on the optimization process, set 'Verbose' to 'false' in the call to deepDreamImage. Notice that the layers which are deeper into the network yield more detailed filters.
layers = [10 12 14];
channels = 1:30;

for layer = layers
    I = deepDreamImage(convnet,layer,channels,...
        'Verbose',false, ...
        'PyramidLevels',1);

    figure
    montage(I)
    name = net.Layers(layer).Name;
    title(['Layer ',name,' Features'])
end


%% Visualize Fully Connected Layers
% There are three fully connected layers in the AlexNet model. The fully connected layers are towards the end of the network and learn high-level combinations of the features learned by the earlier layers.
% Select the first two fully connected layers (layers 17 and 20).
layers = [17 20];
channels = 1:6;

for layer = layers
    I = deepDreamImage(net,layer,channels, ...
        'Verbose',false, ...
        'NumIterations',50);

    figure
    montage(I)
    name = net.Layers(layer).Name;
    title(['Layer ',name,' Features'])
end

% To produce images that resemble each class the most closely, select the final fully connected layer, and set channels to be the indices of the classes.
layer = 23;
channels = [9 188 231 563 855 975];

% The class names are stored in the ClassNames property of the output layer (the last layer). You can view the names of the selected classes by selecting the entries in channels.
convnet.Layers(end).ClassNames(channels)

% Generate detailed images that strongly activate these classes.
I = deepDreamImage(net,layer,channels, ...
    'Verbose',false, ...
    'NumIterations',50);

figure
montage(I)
name = convnet.Layers(layer).Name;
title(['Layer ',name,' Features'])





