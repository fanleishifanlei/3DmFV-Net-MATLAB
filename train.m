clear all
close all
clc

%% Initialize variables
trainset_path = 'C:\Users\Itzik\Documents\Datasets\ModelNet40\matlab_dataset\train\'; 
testset_path  = 'C:\Users\Itzik\Documents\Datasets\ModelNet40\matlab_dataset\test\';

%GMM variables
n_gaussians = 8;
variance = (1/n_gaussians)^2;
normalize = true;
flatten = false;
inputSize = [n_gaussians, n_gaussians, n_gaussians, 20];
%Training variables
numClasses = 40;
max_epoch = 4;
ValidationFrequency = 30;
MiniBatchSize = 2;
ExecutionEnvironment = 'cpu';
optimizer = 'adam';
InitialLearnRate = 0.001;
LearnRateSchedule = 'piecewise';
LearnRateDropPeriod = 20;
LearnRateDropFactor = 0.7;


%% set up the data 
[GMM] = get_3d_grid_gmm(n_gaussians, variance);
[train_pc_ds] =pc_3dmfv_data_store(trainset_path, GMM, normalize, flatten);
[test_pc_ds] =pc_3dmfv_data_store(testset_path, GMM, normalize, flatten);

%fv_train = readimage(train_pc_ds,1);
%disp('DONE');

%% set up the network and train
 lgraph = net_3DmFV(inputSize, numClasses);
 
 options = trainingOptions(optimizer, ...
    'MaxEpochs',max_epoch, ...
    'ValidationData',test_pc_ds, ...
    'ValidationFrequency',ValidationFrequency, ...
    'Verbose',false, ...
    'MiniBatchSize', MiniBatchSize,...
    'ExecutionEnvironment',ExecutionEnvironment,...
    'InitialLearnRate', InitialLearnRate,...
    'LearnRateSchedule', LearnRateSchedule,...
    'LearnRateDropPeriod', LearnRateDropPeriod,...
    'LearnRateDropFactor', LearnRateDropFactor,...
    'Plots','training-progress');

net = trainNetwork(train_pc_ds, lgraph, options);
 save('3DmFV_Net.mat','net', 'GMM', 'options', 'lgraph'); % save the trained model and training variables
%% test the network performance
YPred = classify(net, test_pc_ds);
YValidation = test_pc_ds.Labels;
accuracy = mean(YPred == YValidation)