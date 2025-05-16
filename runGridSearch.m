function runGridSearch()
% Add paths
addpath(genpath('./datasets'));
addpath(genpath('./functions'));
warning('off');

% ===== User-defined section =====
target_datasets = {'NGs'}; % Dataset folder names
per_list = {'0.10','0.30', '0.50'}; % Missing rates
run_max = 10; % validation runs (lower than 30)
% ===============================

% Create results directory
if ~exist('ResultGrid', 'dir')
    mkdir('ResultGrid');
end

% Define output headers
headers = {'Dataset', 'MissingRate', 'Stage', 'k', 'm', 'Run', 'ACC', 'NMI', ...
    'Purity', 'Precision', 'Recall', 'Fscore', 'ARI', 'Entropy', 'Time'};

% Main experiment loop
for dataset_idx = 1:length(target_datasets)
    dataset_name = target_datasets{dataset_idx};

    % Initialize Excel file
    excel_filename = fullfile('ResultGrid', sprintf('%s_parameter_search_results.xlsx', dataset_name));
    if exist(excel_filename, 'file')
        delete(excel_filename);
    end

    for per_idx = 1:length(per_list)
        per = per_list{per_idx};
        filename = sprintf('processed_%s_zp%s_30.mat', dataset_name, per);
        filepath = fullfile('datasets', dataset_name, filename);
        
        % Create all worksheets
        writecell(headers, excel_filename, 'Sheet', 'AllResults');
        writecell(headers(1:5), excel_filename, 'Sheet', 'BestParams');
        summary_headers = {'Dataset', 'MissingRate', 'k', 'm', 'Mean_ACC', 'Std_ACC', ...
            'Mean_NMI', 'Std_NMI', 'Mean_Purity', 'Std_Purity', ...
            'Mean_Time', 'Std_Time'};
        writecell(summary_headers, excel_filename, 'Sheet', 'Summary');
        fprintf('\n==== Processing %s (Missing rate: %s) ====\n', dataset_name, per);

        % Check if file exists
        if ~exist(filepath, 'file')
            fprintf('File not found: %s\n', filepath);
            continue;
        end

        try
            % Load data
            data = load(filepath);
            label = data.label;
            inds = data.inds;

            % Data preprocessing
            viewFields = fieldnames(data);
            viewFields = viewFields(startsWith(viewFields, 'V'));
            numViews = length(viewFields);
            dataViews = cell(1, numViews);
            for v = 1:numViews
                dataViews{v} = double(data.(sprintf('V%d', v)));
                dataViews{v} = (normcols(dataViews{v}'))';
            end

            % Get data size
            n = size(dataViews{1}, 1); % Assuming same number of samples across views

            % Dynamically determine k_values based on data size
            if n < 10000
                % For small datasets, use k values relative to data size
                k_values = unique(round([n/2, n/3, n/5, n*(1-str2double(per))]));
                % Ensure k values are between 10 and n
                k_values = k_values(k_values >= 10 & k_values <= n);
                if isempty(k_values)
                    k_values = min(500, n); % Default value
                end
                % Define neighbor count candidates, ensuring not exceeding n/5
                max_m = floor(n/5);
                m_values = [2, 5, 10, 15, 20, 25, 50, 100]; % Neighbor count candidates
                m_values = m_values(m_values <= max_m);     % Filter values not exceeding max_m
            else
                % For large datasets, use fixed large k values
                k_values = [500, 1500, 3000, 5000];
                m_values = [2,5,10];%, 15, 20, 25, 50, 100];
            end

            fprintf('Data size: %d, Using k candidates: [%s]\n', n, strjoin(cellstr(num2str(k_values(:))), ', '));

            % ========== Stage 1: Parameter Optimization ==========
            fprintf('\n---- Parameter Optimization Stage ----\n');
            best_acc = -1;
            best_params = struct('k', 0, 'm', 0);
            all_results = [];

            for k = k_values
                for m = m_values
                    M = length(unique(label));

                    % Only use first run for parameter optimization
                    run = 1;
                    ind = inds{run};

                    tic;
                    scLabel = ASMI(dataViews, ind, k, m, M);
                    elapsedTime = toc;

                    metrics = Clustering8Measure(scLabel, label);
                    current_acc = metrics(1);

                    % Record results
                    result_row = {dataset_name, per, 'ParameterSearch', k, m, run, metrics, elapsedTime};
                    writecell(result_row, excel_filename, 'Sheet', 'AllResults', 'WriteMode', 'append');

                    % Save to memory for later processing
                    all_results = [all_results; [k, m, run, metrics, elapsedTime]];

                    fprintf('k=%d, m=%d: ACC=%.4f, Time=%.2fs\n', k, m, current_acc, elapsedTime);

                    % Update best parameters
                    if current_acc > best_acc
                        best_acc = current_acc;
                        best_params.k = k;
                        best_params.m = m;
                    end
                end
            end

            % Save best parameters
            best_param_row = {dataset_name, per, 'BestParams', best_params.k, best_params.m};
            writecell(best_param_row, excel_filename, 'Sheet', 'BestParams', 'WriteMode', 'append');

            fprintf('\nBest parameters: k=%d, m=%d (ACC=%.4f)\n', best_params.k, best_params.m, best_acc);

            % ========== Stage 2: Best Parameter Validation ==========
            fprintf('\n---- Best Parameter Validation Stage ----\n');
            validation_results = [];

            % Use run_max for validation runs
            for run = 2:run_max
                ind = inds{run};

                tic;
                scLabel = ASMI(dataViews, ind, best_params.k, best_params.m, M);
                elapsedTime = toc;

                metrics = Clustering8Measure(scLabel, label);

                % Record validation results
                result_row = {dataset_name, per, 'Validation', best_params.k, best_params.m, run, metrics, elapsedTime};
                writecell(result_row, excel_filename, 'Sheet', 'AllResults', 'WriteMode', 'append');

                validation_results = [validation_results; metrics, elapsedTime];
                fprintf('Run %d: ACC=%.4f, Time=%.2fs\n', run, metrics(1), elapsedTime);
            end

            % ========== Stage 3: Result Statistics ==========
            fprintf('\n---- Result Statistics Stage ----\n');

            % Get run1 results (from parameter optimization stage)
            run1_idx = find(all_results(:,1)==best_params.k & all_results(:,2)==best_params.m);
            run1_results = all_results(run1_idx, 4:end-1); % Exclude k,m,run and time
            run1_time = all_results(run1_idx, end);

            % Combine all results (run1-run_max)
            all_runs_results = [run1_results; validation_results(:,1:end-1)];
            all_runs_times = [run1_time; validation_results(:,end)];

            % Calculate statistics
            mean_metrics = mean(all_runs_results, 1);
            std_metrics = std(all_runs_results, 0, 1);
            mean_time = mean(all_runs_times);
            std_time = std(all_runs_times);

            % Save summary results
            summary_row = {dataset_name, per, best_params.k, best_params.m, ...
                mean_metrics(1), std_metrics(1), ... % ACC
                mean_metrics(2), std_metrics(2), ... % NMI
                mean_metrics(3), std_metrics(3), ... % Purity
                mean_time, std_time};
            writecell(summary_row, excel_filename, 'Sheet', 'Summary', 'WriteMode', 'append');

            fprintf('Final Results (runs 1-%d):\n', run_max);
            fprintf('ACC: %.4f ± %.4f\n', mean_metrics(1), std_metrics(1));
            fprintf('Time: %.2f ± %.2f seconds\n', mean_time, std_time);

        catch ME
            fprintf('Error processing %s: %s\n', filename, ME.message);
            continue;
        end
    end
end

fprintf('\nAll results saved to: %s\n', excel_filename);

% Adjust Excel column widths
try
    excel = actxserver('Excel.Application');
    workbook = excel.Workbooks.Open(fullfile(pwd, excel_filename));

    sheets = {'AllResults', 'BestParams', 'Summary'};
    for i = 1:length(sheets)
        sheet = workbook.Sheets.Item(sheets{i});
        sheet.Columns.AutoFit;
    end

    workbook.Save;
    workbook.Close;
    excel.Quit;
catch
    fprintf('Failed to auto-adjust column widths, please adjust manually\n');
end
end
