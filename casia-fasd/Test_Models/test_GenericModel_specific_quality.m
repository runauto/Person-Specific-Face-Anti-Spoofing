function test_GenericModel_specific_quality(Feats_train_SL, Labels_train_SL, Feats_test_SL, Labels_test_SL, Feat_Type, Quality_Type_train, Quality_Type_test, method )
%TEST_GENERICMODELS Summary of this function goes here
%   Detailed explanation goes here
%   Input:
%        Feats_train_SL: feature set of first 20 subjects
%        Labels_train_SL: label set of first 20 subjects
%        Feats_test_SL: feature set of remaining 30 subjects
%        Labels_test_SL: feature set of remaning 30 subjects
%        Feat_Type: type of feature used for face anti-spoofing
%        Quality_Type_train: quality type of training data
%        Quality_Type_test: quality type of testing data

% Step 1: Organize genuine and fake training samples for the both source subjects and target subjects
dims = [833 361 378 256];
name = {'MsLBP' 'LBP' 'HOG' 'LPQ'};
QualityType_Gen = strcat(Quality_Type_test, 'P');
QualityType_Fake = strcat(Quality_Type_test, 'N');

SUB_NUM_S = 20;
SUB_NUM_T = 30;
SUB_NUM = SUB_NUM_S + SUB_NUM_T;

SubIDs_train  = Labels_train_SL.SubID_train;
TLabels_train = Labels_train_SL.TLabels_train;
QLabels_train = Labels_train_SL.QLabels_train;
Feats_train   = Feats_train_SL.Feats_train;

SubIDs_test   = Labels_test_SL.SubID_test;
TLabels_test  = Labels_test_SL.TLabels_test;
QLabels_test = Labels_test_SL.QLabels_test;
Feats_test    = Feats_test_SL.Feats_test;

SubIDs_test   = SubIDs_test + 20;

% concatenate train and test information
SubIDs = [SubIDs_train, SubIDs_test];
TLabels = [TLabels_train, TLabels_test];
QLabels = [QLabels_train, QLabels_test];
Feats   = [Feats_train, Feats_test];

% initialize 
samples_label_subject_genuine = zeros(length(SubIDs), 1);
samples_label_subjects_genuine = cell(1, SUB_NUM);

samples_label_subject_fake = zeros(length(SubIDs), 1);
samples_label_subjects_fake = cell(1, SUB_NUM);

for s = 1:SUB_NUM
    samples_label_subjects_genuine{s} = uint8(samples_label_subject_genuine);
    samples_label_subjects_fake{s} = uint8(samples_label_subject_fake);    
end

for i = 1:length(SubIDs)
    s = SubIDs(i);
    if strcmp(QLabels(i), QualityType_Gen)
        samples_label_subjects_genuine{s}(i) = 1;
    elseif strcmp(QLabels(i), QualityType_Fake)
        samples_label_subjects_fake{s}(i) = 1;
    end
end

% global samples_data_subjects_genuine;
% global samples_data_subjects_fake;

global samples_stype_subjects_genuine;
global samples_qtype_subjects_genuine;

global samples_stype_subjects_fake;
global samples_qtype_subjects_fake;

samples_data_subjects_genuine = cell(1, SUB_NUM);
samples_data_subjects_fake = cell(1, SUB_NUM);

samples_stype_subjects_genuine = cell(1, SUB_NUM);
samples_stype_subjects_fake = cell(1, SUB_NUM);

samples_qtype_subjects_genuine = cell(1, SUB_NUM);
samples_qtype_subjects_fake = cell(1, SUB_NUM);

for s = 1:SUB_NUM
    samples_data_subjects_genuine{s} = zeros(sum(samples_label_subjects_genuine{s}), dims(Feat_Type));
    samples_data_subjects_fake{s} = zeros(sum(samples_label_subjects_fake{s}), dims(Feat_Type));    
    
    samples_stype_subjects_genuine{s} = cell(sum(samples_label_subjects_fake{s}), 1);
    samples_stype_subjects_fake{s} = cell(sum(samples_label_subjects_fake{s}), 1);

    samples_qtype_subjects_genuine{s} = cell(sum(samples_label_subjects_fake{s}), 1);
    samples_qtype_subjects_fake{s} = cell(sum(samples_label_subjects_fake{s}), 1);    
end

sample_sub_id_genuine = ones(1, SUB_NUM);
sample_sub_id_fake = ones(1, SUB_NUM);

for i = 1:length(SubIDs)
    s = SubIDs(i);
    if sum(strcmp(QLabels(i), QualityType_Gen)) > 0
        if Feat_Type == 1
            samples_data_subjects_genuine{s}(sample_sub_id_genuine(s), :) = Feats(i).MsLBP{1};
        elseif Feat_Type == 2
            samples_data_subjects_genuine{s}(sample_sub_id_genuine(s), :) = Feats(i).LBP{1};
        elseif Feat_Type == 3
            samples_data_subjects_genuine{s}(sample_sub_id_genuine(s), :) = Feats(i).HOG{1};
        elseif Feat_Type == 4
            samples_data_subjects_genuine{s}(sample_sub_id_genuine(s), :) = Feats(i).LPQ{1};
        end
        samples_stype_subjects_genuine{s}(sample_sub_id_genuine(s)) = TLabels(i);
        samples_qtype_subjects_genuine{s}(sample_sub_id_genuine(s)) = QLabels(i);
        sample_sub_id_genuine(s) = sample_sub_id_genuine(s) + 1;
    elseif sum(strcmp(QLabels(i), QualityType_Fake)) > 0
        if Feat_Type == 1
            samples_data_subjects_fake{s}(sample_sub_id_fake(s), :) = Feats(i).MsLBP{1};
        elseif Feat_Type == 2
            samples_data_subjects_fake{s}(sample_sub_id_fake(s), :) = Feats(i).LBP{1};
        elseif Feat_Type == 3
            samples_data_subjects_fake{s}(sample_sub_id_fake(s), :) = Feats(i).HOG{1};
        elseif Feat_Type == 4
            samples_data_subjects_fake{s}(sample_sub_id_fake(s), :) = Feats(i).LPQ{1};
        end
        samples_stype_subjects_fake{s}(sample_sub_id_fake(s)) = TLabels(i);
        samples_qtype_subjects_fake{s}(sample_sub_id_fake(s)) = QLabels(i);
        sample_sub_id_fake(s) = sample_sub_id_fake(s) + 1;
    end
end

% Use only the fisrt 1/3 part of samples for training person-specific face anti-spoofing classifier
%{
QualityTypes_Genuine = {'LP' 'MP' 'HP'};
QualityTypes_Fake = {'HN' 'MN' 'LN'};
SpoofingTypes = {'CPN' 'WPN' 'VN'};

for s = 1:SUB_NUM
    % reassign genuine samples
    samples_gen_data_sub = [];
    for q = 1:3
        ind = find(strcmp(samples_qtype_subjects_genuine{s}, QualityTypes_Genuine{q}));
        samples_gen_data_sub = [samples_gen_data_sub; samples_data_subjects_genuine{s}(ind(int16(2*length(ind)/3)+1:end), :)];
    end
    samples_data_subjects_genuine{s} = samples_gen_data_sub;
    
    if s <= SUB_NUM_S
        % reassign fake samples for development in source subject domains
        samples_fake_data_sub = [];
        for a = 1:3
            for q = 1:3
                ind = find(strcmp(samples_stype_subjects_fake{s}, SpoofingTypes{a}) & strcmp(samples_qtype_subjects_fake{s}, QualityTypes_Fake{q}));
                samples_fake_data_sub = [samples_fake_data_sub; samples_data_subjects_fake{s}(ind(1+int16(2*length(ind)/3):end), :)];
            end
        end
        samples_data_subjects_fake{s} = samples_fake_data_sub;
    else
        % reassign fake samples for development in target subject domains
        samples_fake_data_sub = [];
        for a = 1:3
            for q = 1:3
                ind = find(strcmp(samples_stype_subjects_fake{s}, SpoofingTypes{a}) & strcmp(samples_qtype_subjects_fake{s}, QualityTypes_Fake{q}));
                samples_fake_data_sub = [samples_fake_data_sub; samples_data_subjects_fake{s}(ind(1+int16(length(ind)/2):end), :)];
            end
        end
        samples_data_subjects_fake{s} = samples_fake_data_sub;
    end
   
end
%}

% Use only the fisrt 1/2 part of samples for training person-specific face anti-spoofing classifier
SpoofingTypes = {'CPN' 'WPN' 'VN'};

for s = 1:SUB_NUM
    % reassign genuine samples
    % samples_gen_data_sub = [];
    % for q = 1:length(QualityType_Gen)
    %    ind = find(strcmp(samples_qtype_subjects_genuine{s}, QualityType_Gen));
    %    samples_gen_data_sub = [samples_gen_data_sub; samples_data_subjects_genuine{s}(1:int16(length(ind)/2), :)];  % the first half samples
    % end
    ind = find(strcmp(samples_qtype_subjects_genuine{s}, QualityType_Gen));
    samples_data_subjects_genuine{s} = samples_data_subjects_genuine{s}(1+int16(length(ind)/2):end, :);  % the first half samples
    
    
    % reassign fake samples for development in target subject domains
    samples_fake_data_sub = [];
    % for q = 1:length(QualityType_Fake)
        for a = 1:length(SpoofingTypes)        
            ind = find(strcmp(samples_stype_subjects_fake{s}, SpoofingTypes{a}) & strcmp(samples_qtype_subjects_fake{s}, QualityType_Fake));
            samples_fake_data_sub = [samples_fake_data_sub; samples_data_subjects_fake{s}(ind(1+int16(length(ind)/2):end), :)];
        end
    % end
    samples_data_subjects_fake{s} = samples_fake_data_sub;
    
end
%{
% Assemble genuine (fake)  samples from all subjects
samples_data_train_fld_pos = [];
samples_data_train_fld_neg = [];

for s = 1:SUB_NUM
    samples_data_train_fld_pos = [samples_data_train_fld_pos; samples_data_subjects_genuine{s}];
    samples_data_train_fld_neg = [samples_data_train_fld_neg; samples_data_subjects_fake{s}];
end

samples_data_fld_train  =  [samples_data_train_fld_pos; samples_data_train_fld_neg];
samples_label_fld_train =  [ones(size(samples_data_train_fld_pos, 1), 1); -1*ones(size(samples_data_train_fld_neg, 1), 1)];

% L2 Normalize feature vectors
samples_data_fld_train = bsxfun(@rdivide, samples_data_fld_train, sqrt(sum(samples_data_fld_train.^2, 2)));
%}
% svm_param = ['-t 0 -c 0.5'];


suffix = '';
for i = 1:length(Quality_Type_train)
    suffix = strcat(suffix, Quality_Type_train{i});
end

% ---------------- train SVM model ---------------- %
if exist(strcat('..\Train_Models\GenericModel_', name{Feat_Type}, '_', method, '_', suffix, '.mat'))
    load(strcat('..\Train_Models\GenericModel_', name{Feat_Type}, '_', method, '_', suffix, '.mat'));
    model = GenericModel;
    % [~,~, Scores] = svmpredict(samples_label_fld_train,samples_data_fld_train,model);
else
    return;
    % model = svmtrain(samples_label_fld_train, samples_data_fld_train, svm_param);
end

load(strcat('..\Develop_Models\GenericPerf_devel_', name{Feat_Type}, '_', method, '_', suffix, '_', Quality_Type_test, '.mat'));

Scores_subs_gen = cell(SUB_NUM, 1);
Scores_subs_fake = cell(SUB_NUM, 1);

%{
if matlabpool('size')<=0 %判断并行计算环境是否已然启动
    matlabpool('open','local',4); %若尚未启动，则启动并行环境
else
    disp('Already initialized'); %说明并行环境已经启动。
end
%}

for s = 1:SUB_NUM
    disp(strcat('Subject: ', num2str(s)));
    
    samples_data_train_fld_pos = samples_data_subjects_genuine{s};
    samples_data_train_fld_neg = samples_data_subjects_fake{s};

    samples_data_fld_train  =  [samples_data_train_fld_pos; samples_data_train_fld_neg];
    samples_label_fld_train =  [ones(size(samples_data_train_fld_pos, 1), 1); -1*ones(size(samples_data_train_fld_neg, 1), 1)];

    % L2 Normalize feature vectors
    samples_data_fld_train = bsxfun(@rdivide, samples_data_fld_train, sqrt(sum(samples_data_fld_train.^2, 2)));

    % ------------- test trained SVM model by trainning data --------------- %
    [~, ~, scores] = svmpredict(samples_label_fld_train,samples_data_fld_train,model);
    
    Scores_subs_gen{s} = scores(samples_label_fld_train == 1);
    Scores_subs_fake{s} = scores(samples_label_fld_train == -1);
    
end

Scores_gen = [];
Scores_fake = [];

for s = 1:SUB_NUM
    Scores_gen = [Scores_gen; Scores_subs_gen{s}(:)];
    Scores_fake = [Scores_fake; Scores_subs_fake{s}(:)]; 
end


% Compute EER for all development samples
[EER, ~] = compute_EER(Scores_gen, Scores_fake);

FAR = sum(Scores_fake >= Perf.Threshold_overall)/(length(Scores_fake));
FRR = sum(Scores_gen < Perf.Threshold_overall)/(length(Scores_gen));
HTER = (FAR + FRR)/2;    
disp(strcat('EER: ', num2str(EER), ' HTER: ', num2str(HTER)));

% Compute HTER for each subject
HTERs = zeros(SUB_NUM, 1);

for s = 1:SUB_NUM
    FAR = sum(Scores_subs_fake{s} >= Perf.Threshold_overall)/(length(Scores_subs_fake{s}));
    FRR = sum(Scores_subs_gen{s} < Perf.Threshold_overall)/(length(Scores_subs_gen{s}));
    HTERs(s) = (FAR + FRR)/2;    
end

Scores_gen = [];
Scores_fake = [];
for s = 1:SUB_NUM_S
    Scores_gen = [Scores_gen; Scores_subs_gen{s}(:)];
    Scores_fake = [Scores_fake; Scores_subs_fake{s}(:)];   
end

[EER_S, ~] = compute_EER(Scores_gen, Scores_fake);

Scores_gen = [];
Scores_fake = [];
for s = 1+SUB_NUM_S:SUB_NUM
    Scores_gen = [Scores_gen; Scores_subs_gen{s}(:)];
    Scores_fake = [Scores_fake; Scores_subs_fake{s}(:)];   
end

[EER_T, ~] = compute_EER(Scores_gen, Scores_fake);

Perf.EER_S = EER_S;
Perf.EER_T = EER_T;
Perf.EER = EER;
Perf.HTERs = HTERs;
Perf.HTER = HTER;
Perf.Scores_gen = Scores_subs_gen;
Perf.Scores_fake = Scores_subs_fake;

save(strcat('GenericPerf_test_', name{Feat_Type}, '_', method, '_', suffix, '_', Quality_Type_test, '.mat'), 'Perf');

end

