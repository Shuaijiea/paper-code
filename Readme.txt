The submitted codes contain two parts. One part is borrowing the codes from https://github.com/yanlirock/Multi-task_Survival_Analysis to implement the MTL_Cox model learning. Besides, another part is to implement the task of personalized prediction.

Each disease is a task, in which the data of each task has been recorded in the "*.csv" file. We give sample data for three diseases. Each sample is represented as a row in the file, with the first three columns of eid, survival_times, and censored_indicators. The following points need to be noted when data is used as input to the MTL-Cox model:
[1] The eid column needs to be removed;
[2] The column name needs to be removed, i.e. the table header is removed and only the data is kept;
[3] The continuous variables need to be normalized.

[The description of the first part]
In the MTL_Cox model learning part, the users can first run “multi_cox_prepare.m” to generate the training and testing file from the original files. The function contains two input parameters, the first one indicates the input path of the data, and the second parameter stands for the number of cross-validation folds.
multi_cox_prepare '/data/' 5

Then the work can be started by running the  “example_cox_L21.m” to learn the MTL_Cox model, in which the following six parameters have been initiated:
[1] the Folder where the training and testing file stored
[2] name of the training file
[3] name of the testing file
[4] number of searching parameter
[5] the rate of the smallest search parameter compares to the largest one
[6] the scale of the first searching point (usually set as 1)


Demo of code running：
>> cd('D:\project\code_and_data')   
%First store the code and processed data under the same path, and locate the path where the code and data are located.

>> multi_cox_prepare '/' 5    
%Divide the data into 5 folds, and store the divided data sets train_1~train_5 and test_1~test_5 in a folder named "data", for example, the storage path is 'D:\project\code_and_data\data'.

>> example_cox_L21 '/' 'train_1' 'test_1' 50 0.01 1   
%Traing model.

The above operation allows the output of beta values, for example, the output reads "(1,3) 0.8", which represents the beta value of 0.8 for the 1st variable of the 3rd disease, respectively. Multiple diseases (i.e. multiple tasks) are sorted by initials. For example, if two diseases are predicted, lung cancer and coronary heart disease, "(*,1)" represents the first disease, i.e. coronary heart disease, and "(*,2) "The beta values are stored in a column vector in an "xlsx" file as input to "MTL_Cox_Personalized_Prediction.R".



[The description of the second part]
"MTL_Cox_Personalized_Prediction.R" and "Traditional_Cox_Model" are the personalized prediction codes of the MTL_Cox model and traditional Cox model, respectively. The details are marked up in the code.