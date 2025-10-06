function rejectedComponents = inspect_ica_components(data_comp, elec, lay, cSubject)

% GUI to inspect ICA components and select those to reject


% Inputs:
%   - data_comp: FieldTrip ICA component data
%   - elec: electrode structure (from ft_read_sens)
%   - lay: layout structure
%   - cSubject: subject ID for labeling
%
% Output:
%   - rejectedComponents: vector of selected components for rejection

nComp = size(data_comp.trial{1}, 1);  % total components
compsPerFigure = 10;
nFigures = ceil(nComp / compsPerFigure);
allPowers = zeros(nComp, 1);

% 1. Compute power spectrum for all components
for comp = 1:nComp
    pspctrm = 0;
    for tr = 1:numel(data_comp.trial)
        signal = data_comp.trial{tr}(comp, :);
        N = length(signal);
        fourierCoefsF = fft(signal) / N;
        pspctrm = pspctrm + abs(fourierCoefsF(1:floor(N/2)+1)) * 2;
    end
    pspctrm = pspctrm / numel(data_comp.trial);
    allPowers(comp) = mean(pspctrm);
end

% 2. Auto flag suspicious components
powerThreshold = mean(allPowers) + 2 * std(allPowers);
suggestedBadComps = find(allPowers > powerThreshold);

% 3. Plot in batches of 10 and store figure handles
figHandles = gobjects(nFigures, 1); 
for f = 1:nFigures
    compStart = (f - 1) * compsPerFigure + 1;
    compEnd = min(f * compsPerFigure, nComp);
    comps = compStart:compEnd;

    figHandles(f) = figure('Name', sprintf('ICA Components %d–%d - %s', compStart, compEnd, cSubject), ...
           'NumberTitle', 'off');
    ax_ = nan(length(comps), 1);

    for j = 1:length(comps)
        comp = comps(j);
        pspctrm = 0;

        for tr = 1:numel(data_comp.trial)
            signal = data_comp.trial{tr}(comp, :);
            N = length(signal);
            nyquist = data_comp.fsample / 2;
            frequencies = linspace(0, nyquist, floor(N/2)+1);
            fourierCoefsF = fft(signal) / N;
            pspctrm = pspctrm + abs(fourierCoefsF(1:length(frequencies))) * 2;
        end

        pspctrm = pspctrm / numel(data_comp.trial);
        isSuspect = mean(pspctrm) > powerThreshold;

        subplot(5, 4, 2*j - 1); hold on
        cfg = [];
        cfg.component = comp;
        cfg.elec = elec;
        cfg.comment = 'no';
        cfg.layout = lay;
        ft_topoplotIC(cfg, data_comp);

        ax_(j) = subplot(5, 4, 2*j); hold on;
        plot(frequencies, pspctrm, 'Color', isSuspect * [1 0 0] + ~isSuspect * [0 0 0]);
        title(sprintf('Component %d%s', comp, ternary(isSuspect, ' ⚠️', '')));
        set(ax_(j), 'xlim', [0 60]);
    end

    % Frequency zoom slider
    hax = @(src, ax_) set(ax_, 'xlim', [0 get(src, 'Value')]);
    uicontrol('Style', 'slider', ...
              'Units', 'normalized', ...
              'Min', 20, 'Max', 300, 'Value', 60, ...
              'Position', [0 0 1 0.05], ...
              'Callback', @(src, evt) hax(src, ax_));
end

% 4. Manual selection GUI
componentList = arrayfun(@(x) sprintf('Component %d', x), 1:nComp, 'UniformOutput', false);
fGui = figure('Name', sprintf('Select Components to Reject - %s', cSubject), ...
           'Position', [500 400 400 300]);
uicontrol('Style', 'text', 'Position', [50 260 300 20], ...
          'String', 'Select components to reject and click OK');
lb = uicontrol('Style', 'listbox', ...
               'Position', [50 70 300 180], ...
               'String', componentList, ...
               'Max', 2, 'Min', 0, ...
               'Value', suggestedBadComps);  % pre-select flagged comps

uicontrol('Style', 'pushbutton', 'String', 'OK', ...
          'Position', [150 20 100 30], ...
          'Callback', @(src, event) uiresume(fGui));

uiwait(fGui); 
rejectedComponents = lb.Value;
close(fGui);

% NEW: Close all ICA figure windows
for k = 1:numel(figHandles)
    if ishandle(figHandles(k))
        close(figHandles(k));
    end
end

fprintf('✅ Components selected for rejection in %s: %s\n', cSubject, mat2str(rejectedComponents));

end

% Inline ternary for titles
function out = ternary(cond, a, b)
    if cond
        out = a;
    else
        out = b;
    end
end
