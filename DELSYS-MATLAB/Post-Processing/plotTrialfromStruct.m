function plotTrialfromStruct(struct,setting)
%UNTITLED15 Summary of this function goes here
%   Detailed explanation goes here
tr_idx = setting.tr_idx;
ch_num = size(struct.channel,2);
colors = setting.color;
transp = setting.transp;
ch_pos = setting.ch_pos;
sen_num = setting.sen_num;
legend_flag = setting.legend_flag;
if isfield(setting,'legend')
    legend_name = setting.legend;
else
    legend_name = struct.trial(tr_idx);
end
if isfield(setting,'titles')
    plot_title = setting.titles;
else
    for ch = 1:ch_num/2
        plot_title{ch} = strrep(struct.channel(i).muscle,'_',' ');
             if sen_num == 2
                 plot_title{ch} = strrep(plot_title{ch}, ' L', ' 1');
                 plot_title{ch} = strrep(plot_title{ch}, ' R', ' 2');
                 plot_title{ch} = strrep(plot_title{ch}, '2F', 'RF');
             end
    end
end
f = figure;
if strcmp(setting.type,'avg')
    j = 0;
    
        j = j +1;
        avg_dataL = squeeze(mean(struct.interpL.data,2));
        std_dataL = squeeze(std(struct.interpL.data,0,2));
        for ch = 1:ch_num/2
             ax = subplot(1,ch_num,ch_pos(ch));
             t= (0:size(avg_dataL(ch,:),2)-1)/size(avg_dataL(ch,:),2);
             plt(j) = plot(t,avg_dataL(ch,:),'Color',colors{j},'LineWidth',2);
             hold on
             xline(0.40)
             inBetween = [avg_dataL(ch,:) + std_dataL(ch,:),fliplr(avg_dataL(ch,:) - std_dataL(ch,:))];
             x_fill = [t,fliplr(t)];
             fill(x_fill, inBetween, colors{j}, 'FaceAlpha', transp, 'EdgeColor','none', 'HandleVisibility','off'); 
             hold on; 
             h = title(plot_title{ch});
             xticklabels({'0\%','50\%','100\%'})
            ax.Title.FontSize=15;
            ax.XAxis.FontSize = 12;
            ax.YAxis.FontSize = 12;
        end
        avg_dataR = squeeze(mean(struct.interpR.data,2));
        std_dataR = squeeze(std(struct.interpR.data,0,2));
        for ch = 1:ch_num/2
            ch1 = ch+ch_num/2;
             ax = subplot(1,ch_num,ch_pos(ch1));
             t= (0:size(avg_dataR(ch,:),2)-1)/size(avg_dataR(ch,:),2);
             plt(j) = plot(t,avg_dataR(ch,:),'Color',colors{j},'LineWidth',2);
             hold on
             xline(0.40)
             inBetween = [avg_dataR(ch,:) + std_dataR(ch,:),fliplr(avg_dataR(ch,:) - std_dataR(ch,:))];
             x_fill = [t,fliplr(t)];
             fill(x_fill, inBetween, colors{j}, 'FaceAlpha', transp, 'EdgeColor','none', 'HandleVisibility','off'); 
             hold on; 
             h = title(plot_title{ch1});
             xticklabels({'0\%','50\%','100\%'})
            ax.Title.FontSize=15;
            ax.XAxis.FontSize = 12;
            ax.YAxis.FontSize = 12;
        end
end
%latexify
hold off
if legend_flag
    lg = legend(plt,legend_name,'Location','eastoutside','NumColumns',1,'FontSize',8);
    lg.Position =  [0.7996    0.5491    0.1023    0.2283];
    legend('boxoff');
end
f.Position = [50 250 1400 400];
if setting.save
    fold = setting.fold;
    if ~exist(fold,'dir')
        mkdir(fold);
    end
    if ~isempty(setting.fname)
        name = setting.fname;
    else
        name = strrep([struct.trial{tr_idx} 'step.eps'],' ','_');
    end
    saveas(gcf,fullfile(fold,string(name))); %,'epsc'
end
