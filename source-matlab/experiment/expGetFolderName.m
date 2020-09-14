function folderName=expGetFolderName(carExp,FsampKS,iterationCount,corruption,trainingPhase,corruptByte)

folderName1=strcat('../recorded-data/');


if(carExp==0)
    folderName2='testbed/';
elseif(carExp==11)
    folderName2='Cruze-Bus-1/';
elseif(carExp==12)
    folderName2='Cruze-Bus-2/';
elseif(carExp==21)
    folderName2='Impala-Bus-1/';   
elseif(carExp==22)
    folderName2='Impala-Bus-2/';      
end
folderName3=strcat('sampling-',num2str(FsampKS),'-KS','/iteration', num2str(iterationCount),'/');

if(trainingPhase)
    folderName4='train-';
else
    folderName4='test-';          
end 

if(corruption)
    folderName5=strcat(num2str(corruptByte),'-byte-Corruption/');
else
    folderName5='benign/';
end

folderName=strcat(folderName1,folderName2,folderName3,folderName4,folderName5);