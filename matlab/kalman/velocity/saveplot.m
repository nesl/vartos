function saveplot(fig, fname)

% Usage: saveplot(fig, filename)
% Uses Imagemagick's convert utility for higher resolution PNGs if
% available
% Eg: saveplot(gcf, 'test');

    convert_fname='/usr/local/bin/convert.disabled';
    if nargin < 2
        fname = fig;
        fig = gcf;
    end
    
    set(fig, 'PaperPositionMode', 'auto');
    fname_eps=sprintf('%s.eps', fname);
    fname_png=sprintf('%s.png', fname);
    % Output to EPS
    print(gcf, fname_eps, '-depsc2', '-r0', '-painters');
    
    disp(sprintf('Saving plot to %s .eps', fname));

end