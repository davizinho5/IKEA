% This example shows how to feed an image to a convolutional neural network
% and display the activations of different layers of the network. 
% Examine the activations and discover which features the network learns by
% comparing areas of activation with the original image. 

% Find out that channels in earlier layers learn simple features
% like color and edges, 
% while channels in the deeper layers learn complex features like eyes. 

% Identifying features in this way can help you understand 
% what the network has learned.

%% Load Pretrained Network and Data
load('trained_CNN.mat')

%% View Network Architecture
% Display the layers of the network to see which layers you can look at. 
% The convolutional layers perform convolutions with learnable parameters. 
% The network learns to identify useful features, often with one feature per channel. 
% Observe that the first convolutional layer has 96 channels.
convnet.Layers

% The Image Input layer specifies the input size. 
% You can resize the image before passing it through the network, 
% but the network also can process larger images.
% If you feed the network larger images, the activations also become larger.
% However, since the network is trained on images of size 227-by-227, 
% it is not trained to recognize objects or features larger than that size.

%% Show Activations of First Convolutional Layer
% Investigate features by observing which areas in the convolutional layers activate on an image and comparing with the corresponding areas in the original images. Each layer of a convolutional neural network consists of many 2-D arrays called channels. Pass the image through the network and examine the output activations of the conv1 layer.
act1 = activations(convnet,im,'conv','OutputAs','channels');

% The activations are returned as a 3-D array, with the third dimension 
% indexing the channel on the conv1 layer. To show these activations 
% using the montage function, reshape the array to 4-D.
% The third dimension in the input to montage represents the image color.
% Set the third dimension to have size 1 because the activations do not have color.
% The fourth dimension indexes the channel.
cd fotos21dec17/
cd produs2/
cd original
im_plato = imread('1.jpg');
im_plato=im_plato(:,:,1);
cd .., cd .., cd ..
cd letras/
cd E/
im_letra = imread('1.jpg');
im_letra=im_letra(:,:,1);
cd .., cd ..

sz_plato = size(im_plato);
sz_letra = size(im_letra);

% activacion plato
act_plato = activations(convnet,im_plato,'conv','OutputAs','channels');
sz = size(act_plato);
act_plato_mont = reshape(act_plato,[sz(1) sz(2) 1 sz(3)]);
% activacion letra
act_letra = activations(convnet,im_letra,'conv','OutputAs','channels');
sz = size(act_letra);
act_letra_mont = reshape(act_letra,[sz(1) sz(2) 1 sz(3)]);

% Now you can show the activations.
% Each activation can take any value, so normalize the output using mat2gray.
% All activations are scaled so that the minimum activation is 0
% and the maximum is 1. 
% Display a montage of the 96 images on an 3-by-9 grid,
% one for each channel in the layer.
montage(mat2gray(act_plato_mont),'Size',[3 9])
montage(mat2gray(act_letra_mont),'Size',[3 9])

%% Investigate the Activations in Specific Channels
% Each square in the montage of activations is the output of
% a channel in the conv1 layer. White pixels represent
% strong positive activations and black pixels represent
% strong negative activations. A channel that is mostly
% gray does not activate as strongly on the input image.
% The position of a pixel in the activation of a channel
% corresponds to the same position in the original image.
% A white pixel at some location in a channel indicates that
% the channel is strongly activated at that position.

% Resize the activations in channel 20 to have the same size
% as the original image and display the activations.

% You can see that this channel activates on red pixels,
% because the whiter pixels in the channel correspond to red
% areas in the original image.
act1ch20_plato = act_plato_mont(:,:,:,20);
act1ch20_plato = mat2gray(act1ch20_plato);
act1ch20_plato = imresize(act1ch20_plato,sz_plato);
imshowpair(im_plato,act1ch20_plato,'montage')

act1ch20_letra = act_letra_mont(:,:,:,20);
act1ch20_letra = mat2gray(act1ch20_letra);
act1cact1ch20_platoh32 = imresize(act1ch20_letra,sz_letra);
imshowpair(im_letra,act1ch20_letra,'montage')

%% Find the Strongest Activation Channel
% You also can try to find interesting channels
% by programmatically investigating channels with
% large activations. Find the channel with the largest activation
% using the max function, resize, and show the activations.

% Compare to the original image and notice that this channel
% activates on edges.
% It activates positively on light left/dark right edges,
% and negatively on dark left/light right edges.
[maxValue,maxValueIndex] = max(max(max(act_plato_mont)));
act1chMax_plato = act_plato_mont(:,:,:,maxValueIndex);
act1chMax_plato = mat2gray(act1chMax_plato);
act1chMax_plato = imresize(act1chMax_plato,sz_plato);
imshowpair(im_plato,act1chMax_plato,'montage')

[maxValue,maxValueIndex] = max(max(max(act_letra_mont)));
act1chMax_letra = act_letra_mont(:,:,:,maxValueIndex);
act1chMax_letra = mat2gray(act1chMax_letra);
act1chMax_letra = imresize(act1chMax_letra,sz_letra);
imshowpair(im_letra,act1chMax_letra,'montage')

%% Investigate a Deeper Layer
% Most convolutional neural networks learn to detect features
% like color and edges in their first convolutional layer.
% In deeper convolutional layers, the network learns
% to detect more complicated features. Later layers build up
% their features by combining features of earlier layers.
% Investigate the conv5 layer in the same way as the conv1 layer.
% Calculate, reshape, and show the activations in a montage.
act_conv_plato = activations(convnet,im_plato,'conv','OutputAs','channels');
sz = size(act_conv);
act_conv_plato = reshape(act_conv_plato,[sz(1) sz(2) 1 sz(3)]);
montage(imresize(mat2gray(act_conv_plato),[48 48]))

act_conv_letra = activations(convnet,im_letra,'conv','OutputAs','channels');
sz = size(act_conv_letra);
act_conv_letra = reshape(act_conv_letra,[sz(1) sz(2) 1 sz(3)]);
montage(imresize(mat2gray(act_conv_letra),[48 48]))

% There are too many images to investigate in detail,
% so focus on some of the more interesting ones.
% Display the strongest activation in the conv layer.
[maxValue5,maxValueIndex5] = max(max(max(act_conv_plato)));
act_conv_chMax = act_conv(:,:,:,maxValueIndex5);
imshow(imresize(mat2gray(act_conv_chMax),sz_plato))

[maxValue5,maxValueIndex5] = max(max(max(act_conv_letra)));
act_conv_chMax = act_conv(:,:,:,maxValueIndex5);
imshow(imresize(mat2gray(act_conv_chMax),sz_letra))

% In this case, the maximum activation channel is not as interesting
% for detailed features as some others, and shows strong negative (dark) as well as positive (light) activation.
% This channel is possibly focusing on faces.

% In the montage of all channels, there are channels that
% might be activating on eyes. Investigate channels 3 and 5 further.
montage(imresize(mat2gray(act_conv_plato(:,:,:,[3 5])),sz_plato))

montage(imresize(mat2gray(act_conv_letra(:,:,:,[3 5])),sz_letra))

% Many of the channels contain areas of activation that are
% both light and dark. These are positive and negative
% activations, respectively. However, only the positive
% activations are used because of the rectified linear unit
% (ReLU) that follows the conv5 layer. To investigate only
% positive activations, repeat the analysis to visualize the
% activations of the relu5 layer.
actrelu_plato = activations(net,im_plato,'relu','OutputAs','channels');
sz = size(actrelu_plato);
actrelu_plato = reshape(actrelu_plato,[sz(1) sz(2) 1 sz(3)]);
montage(imresize(mat2gray(actrelu_plato(:,:,:,[3 5])),imgSize))

actrelu_letra = activations(net,im_letra,'relu','OutputAs','channels');
sz = size(actrelu_letra);
actrelu_letra = reshape(actrelu_letra,[sz(1) sz(2) 1 sz(3)]);
montage(imresize(mat2gray(actrelu_letra(:,:,:,[3 5])),imgSize))

% Compared to the activations of the conv5 layer,
% the activations of the relu5 layer clearly pinpoint
% areas of the image that have strong facial features.


