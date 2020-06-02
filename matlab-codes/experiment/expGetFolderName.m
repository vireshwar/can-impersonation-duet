function folderName=expGetFolderName(carExp,FsampKS,iterationCount,corruption,trainingPhase,corruptByte,ideaExp)

folderName0=strcat('../../data_stored/voltage_data/');


if(strcmp(ideaExp,'Duet'))
    folderName1=strcat('Duet/');
elseif(strcmp(ideaExp,'Nmap'))
    folderName1=strcat('Nmap/');
end

if(carExp==0)
    folderName2='Testbed/';
elseif(carExp==11)
    folderName2='Cruze-Bus-1/';
elseif(carExp==12)
    folderName2='Cruze-Bus-2/';
elseif(carExp==21)
    folderName2='Impala-Bus-1/';   
elseif(carExp==22)
    folderName2='Impala-Bus-2/';      
end
folderName3=strcat('FsampKS_',num2str(FsampKS),'/iteration', num2str(iterationCount),'/');

if(trainingPhase)
    folderName4='train_';
else
    folderName4='test_';          
end 

if(corruption)
    folderName5=strcat(num2str(corruptByte),'_byte_Corruption/');
else
    folderName5='benign/';
end

folderName=strcat(folderName0,folderName1,folderName2,folderName3,folderName4,folderName5);