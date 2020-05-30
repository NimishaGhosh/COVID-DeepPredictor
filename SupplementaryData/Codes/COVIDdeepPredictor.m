function [net,virusname]=COVIDdeepPredictor()

% COVIDdeepPredictor takes genomic sequence of a virus and the corresponding virus name as inputs for
% training and gives the virus name of a provided genomic sequence (by user) as output.
% The entire input sequence can be either taken for training or can be
% divided into training and validation set. For taking validation set, 
% cross-validation technique (cvpartition) has been applied. nmercount has
% been used to divide the input genomic sequence into motifs of sequences.
% The second argument in nmercunt can be changed to specify the length of
% the genomic sequence that will be used for training (Please be careful to use the same length
% in the training, validation and testing data sets as well).
% From the prepared motifs Bag-of-Words (BoWs) are created using
% tokenizedDocument and wordEncoding. COVIDdeepPredictor is then trained with the input data using Long-Short Term Memory for six virus classes.
% For reproducibility, the trained model can be saved using the save command (Here,it is commented. User can uncomment it if he/she wants to save a trained model). 
% The trained model can now be used to identify a virus type based on its
% genomic sequence. For ease of a
% user, training and testing files are provided to make her/him acquainted with the function.
% Trainingdata.csv is the input file for training and Testdata-1.csv, Testdata-2.csv, Testdata-3.csv and Testdata-4.csv are the input files with the
% genome sequence whose virus type needs to be identified. The results of the prediction 
% will have the sequence ID, predicted virus name, along with its sequence which will be stored in Results.csv.
 clear All;
 nmersVirusSeq=[];
 tabData1 = readtable('Trainingdata.csv', 'delimiter', ',', 'ReadVariableNames', false, 'HeaderLines', 1);
 dataSeqID=tabData1(:,1);
 dataSeqClass=table2cell(tabData1(:,3));
 dataSeq=table2cell(tabData1(:,4));
 cvp=cvpartition(dataSeq,'Holdout',0.6);
 dataTrain=dataSeq(training(cvp),:);
 dataValidation=dataSeq(test(cvp),:);
 YTrain=dataSeqClass(training(cvp),:);
 YValidation=dataSeqClass(test(cvp),:);
 
 for i=1:size(dataTrain,1)
     tempSeq=char(dataTrain(i,:));
     tempnmerSeq=nmercount(tempSeq,4);%change k
     tempnmerSeqStr=join(string(tempnmerSeq(:,1))," ");
     nmersVirusSeq=[nmersVirusSeq;tempnmerSeqStr];
 end
 toknmersVirusSeqTrain = tokenizedDocument(nmersVirusSeq);
 nmersVirusSeq=[];
  
 for i=1:size(dataValidation,1)
     tempSeq=char(dataValidation(i,:));
     tempnmerSeq=nmercount(tempSeq,4);
     tempnmerSeqStr=join(string(tempnmerSeq(:,1))," ");
     nmersVirusSeq=[nmersVirusSeq;tempnmerSeqStr];
 end
 toknmersVirusSeqValidation = tokenizedDocument(nmersVirusSeq);
 enc = wordEncoding(toknmersVirusSeqTrain);

  

 sequenceLength = 10;
 XTrain = doc2sequence(enc,toknmersVirusSeqTrain,'Length',sequenceLength);
 XValidation = doc2sequence(enc,toknmersVirusSeqValidation,'Length',sequenceLength);
 
 inputSize = 1;
 embeddingDimension = 50;
 numHiddenUnits = 80;

 numWords = enc.NumWords;
 numClasses = 6;
 YTrain=categorical(YTrain);
 YValidation=categorical(YValidation);
 
 layers = [ ...
    sequenceInputLayer(inputSize)
    wordEmbeddingLayer(embeddingDimension,numWords)
    lstmLayer(numHiddenUnits,'OutputMode','last')
    fullyConnectedLayer(numClasses)
    softmaxLayer
    classificationLayer];

 options = trainingOptions('adam', ...
    'MiniBatchSize',16, ...
    'GradientThreshold',2, ...
    'Shuffle','every-epoch', ...
    'Plots','training-progress', ...
    'ValidationData',{XValidation,YValidation}, ... 
    'Verbose',false);
    
 net = trainNetwork(XTrain,YTrain,layers,options);
 
%  trainnet_1=net;
%  save('trainnet_1');

  tabData = readtable('Testdata-1.csv', 'delimiter', ',', 'ReadVariableNames', false, 'HeaderLines', 1);

sequenceID=table2cell(tabData(:,1));
  datalabels=table2cell(tabData(:,2));
Sequence=table2cell(tabData(:,3));


 nmersVirusSeq=[];
 for i=1:size(dataSeqTest,1)
     tempSeq=char(dataSeqTest(i,:));
     tempnmerSeq=nmercount(tempSeq,4);
     tempnmerSeqStr=join(string(tempnmerSeq(:,1))," ");
     nmersVirusSeq=[nmersVirusSeq;tempnmerSeqStr];
 end
 toknmersVirusSeqTest = tokenizedDocument(nmersVirusSeq);
 XNewVirus = doc2sequence(enc,toknmersVirusSeqTest,'Length',sequenceLength);
 virusname= classify(net,XNewVirus);
 
  
 
T1 = table(sequenceID,virusname,Sequence);
writetable(T1,'Results.csv'); 

      
 