clear all
clc
close all

model = 'parallelOR'; % {parallelOR, serialOR, parallelAND, serialAND}

%% Set up possible parameters
sim = model(end-1:end);
switch sim
    case 'ND'
        % AND parameters - Simulations 1 (constrained sum)
        hAc = 45:-5:30; % High Drift in channel A
        hAi = 5:5:20;
        hBc = 42:-5:27; % High Drift in channel B
        hBi = 2:5:17;
        lAc = 40:-5:25; % Low  Drift in channel A
        lAi = 10:5:25;
        lBc = 37:-5:22; % Low  Drift in channel B
        lBi = 7:5:22;
    case 'OR'
        % % OR parameters - Simulation 1 (constrained sum)
        hAc = [40:-5:25]; % High Drift in channel A
        hAi = [10:5:25];
        hBc = [37:-5:22]; % High Drift in channel B
        hBi = [07:5:22];
        lAc = [35:-5:20]; % Low  Drift in channel A
        lAi = [15:5:30];
        lBc = [32:-5:17]; % Low  Drift in channel B
        lBi = [12:5:27];
end

cA = 13; % Criterion A
cB = 13; % Criterion B

%%
nLevels = 4;

switch model
    case 'parallelOR'
        t = 0:.001:1; % Time vector to evaluate
        tModVec = .001:.005:1;
    case 'serialOR'
        t = 0:.001:2; % Time vector to evaluate
        tModVec = .001:.001:2;
    case 'parallelAND'
        t = 0:.001:1;
        tModVec = .001:.005:1;
    case 'serialAND'
        t = 0:.001:2;
        tModVec = .001:.005:2;
end

nPoissonSamples = 1e6;
sicColors = [.6 .6 .6; .4 .4 .4; .2 .2 .2; .1 .1 .1];

tic
for k = 1:nLevels
    drift = [...
        hAc(k), hAi(k), hBc(k), hBi(k);
        hAc(k), hAi(k), lBc(k), lBi(k);
        lAc(k), lAi(k), hBc(k), hBi(k);
        lAc(k), lAi(k), lBc(k), lBi(k)];
    
    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for j = 1:size(drift,1)
        % Use poisson model to get pdf
        Ac = singChan([drift(j,1), cA]', t)'; % PDF channel A
        Ai = singChan([drift(j,2), cA]', t)'; % PDF channel A
        Bc = singChan([drift(j,3), cB]', t)'; % PDF channel B
        Bi = singChan([drift(j,4), cB]', t)'; % PDF channel B
        
        pdfAc = diff([0; Ac]);
        pdfAi = diff([0; Ai]);
        pdfBc = diff([0; Bc]);
        pdfBi = diff([0; Bi]);
        
        % Sample from pdf to get finishing times for each accumulator
        Acrt = datasample(t, nPoissonSamples, 'Replace', true, 'Weights', pdfAc)';
        Airt = datasample(t, nPoissonSamples, 'Replace', true, 'Weights', pdfAi)';
        Bcrt = datasample(t, nPoissonSamples, 'Replace', true, 'Weights', pdfBc)';
        Birt = datasample(t, nPoissonSamples, 'Replace', true, 'Weights', pdfBi)';
        
        % Use parallel self-terminating rules to compute final rt
        switch model
            case 'parallelOR'
                [acc, mod_time, idx] = arrayfun(@(i,j,k,l)pst(i,j,k,l), Acrt, Airt, Bcrt, Birt);
            case 'serialOR'
                [acc, mod_time, idx] = arrayfun(@(i,j,k,l)sst(i,j,k,l), Acrt, Airt, Bcrt, Birt);
            case 'parallelAND'
                 [acc, mod_time, idx] = arrayfun(@(i,j,k,l)pex(i,j,k,l), Acrt, Airt, Bcrt, Birt);
            case 'serialAND'
                [acc, mod_time, idx] = arrayfun(@(i,j,k,l)sex(i,j,k,l), Acrt, Airt, Bcrt, Birt);
   
        end
        
        % Use histogram to bin sampled times from correct trials
        [n, e] = hist(mod_time(acc==1), tModVec);
        pdfs(:,j) = n'./sum(n);
        cdfs(:,j) = cumsum(pdfs(:,j));
        S(:,j) = 1 - cdfs(:,j);
        
        % Summary stats
        meanRT(j,k) = mean(mod_time(acc==1));
        meanAcc(j,k) = mean(acc);
        for m = 1:4
            indexProportions{k}(m,j) = sum(idx == m)./numel(idx);
        end
    end
    
    subplot(4,2,k)
    h = plot(tModVec, cdfs, 'LineWidth', 2); 
    set(h(1), 'Color', 'k', 'LineStyle', '-');
    set(h(2), 'Color', 'k', 'LineStyle', '--');
    set(h(3), 'Color', [.75 .75 .75], 'LineStyle', '-');
    set(h(4), 'Color', [.75 .75 .75], 'LineStyle', '--');
    legend('HH', 'HL', 'LH', 'LL')
    set(gca, 'YLim', [0 1])
    xlabel('t', 'FontSize', 15)
    ylabel('S(t)', 'FontSize', 15)
    title(sprintf('Level %d', k), 'FontSize', 20)
    
    subplot(2,1,2)
    plot(tModVec, S(:,4) - S(:,3) - S(:,2) + S(:,1), 'Color', sicColors(k,:), 'LineWidth', 2); hold on
    xlabel('t', 'FontSize', 15)
    ylabel('SIC(t)', 'FontSize', 15)
    set(gca,'YLim', [-.15, .15])
end
legend('Level 1', 'Level 2', 'Level 3', 'Level 4')
toc
% save(sprintf('Simulation 1 - %s.mat', model))
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% How to sample:
% rt = datasample(t, 1000000, 'Replace', true, 'Weights', pdfAc);

% Check sample
%[n, e] = hist(rt, 0:15:2000);
% bar(e, n./sum(n), 'hist');
% hold on;
% plot(pdfAc*(e(2)-e(1)), 'LineWidth', 2, 'Color', 'r');
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%