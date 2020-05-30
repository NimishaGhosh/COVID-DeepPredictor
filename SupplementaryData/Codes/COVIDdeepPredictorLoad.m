function [virusname]=COVIDdeepPredictorLoad()

% COVIDdeepPredictorLoad loads a pre-trained model (trainnet_42.mat) and gives results on test data.
% The results of the prediction will have the sequence ID, predicted virus name, along 
% with its sequence which will be stored in Results.csv.

clear all

warning off

load('trainnet_42');

net=trainnet_42;

tabData = readtable('Testdata-1.csv', 'delimiter', ',', 'ReadVariableNames', false, 'HeaderLines', 1);

sequenceID=table2cell(tabData(:,1));
  datalabels=table2cell(tabData(:,2));
 Sequence=table2cell(tabData(:,3));

 
 nmersVirusSeq=[];
 for i=1:size(Sequence,1)
     tempSeq=char(Sequence(i,:));
     tempnmerSeq=nmercount(tempSeq,4);
     tempnmerSeqStr=join(string(tempnmerSeq(:,1))," ");
     nmersVirusSeq=[nmersVirusSeq;tempnmerSeqStr];
 end
 toknmersVirusSeqTest = tokenizedDocument(nmersVirusSeq);
 XNewVirus = doc2sequence(enc,toknmersVirusSeqTest,'Length',sequenceLength);
virusname = classify(net,XNewVirus);
 
T1 = table(sequenceID,virusname,Sequence);
writetable(T1,'Results.csv'); 