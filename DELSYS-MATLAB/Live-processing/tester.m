NUM_SENSORS = 6;
Muscle =["Left TA", "Left GAS", "Left SOL","Right TA","Right GAS","Right SOL"];
figureHandleGaits = figure('Name', 'Averaged Gait Cycles', 'Numbertitle', 'off');%, 'CloseRequestFcn', {@localCloseFigure, interfaceObjectEMG, interfaceObjectACC, commObject, t});
    set(figureHandleGaits,'position', [200 150 1200 550]);
    for i = 1:NUM_SENSORS
        axesHandlesGaits(i) = subplot(1,6,i);
        plotHandlesGaits(i) = plot(axesHandlesGaits(i),0, Color=[0.8500 0.3250 0.0980],LineWidth=2);
        set(axesHandlesGaits(i),'YGrid','on');
        set(axesHandlesGaits(i),'XGrid','on');
        set(axesHandlesGaits(i),'Color',[.15 .15 .15]);
        set(axesHandlesGaits(i),'YLim', [-5 5]);
        set(axesHandlesGaits(i),'YLimMode', 'auto');
        set(axesHandlesGaits(i),'XLim', [0 100]);
        set(axesHandlesGaits(i),'XLimMode', 'manual');
        ax = gca;
        ax.GridColor = [0.9,0.9,0.9];
        if(mod(i, 3) == 1)
            ylabel(axesHandlesGaits(i),'Muscle Activity (V)');
        else
            set(axesHandlesGaits(i), 'YTickLabel', '')
        end
        
        if(i >12)
            xlabel(axesHandlesGaits(i),'Samples');
        end
        title(sprintf(Muscle(i), i))
    end
sizeavg_dataL=randi([1800,2000],6,1);
sizeavg_dataR=randi([1800,2000],6,1);

ch_num = 6;
            for ch = 1:ch_num/2
                    leftT = linspace(0,100,sizeavg_dataL(ch));
                    avg_dataL = sind(leftT);                    
                    set(plotHandlesGaits(ch), 'Ydata', avg_dataL);
                    set(plotHandlesGaits(ch), 'Xdata', leftT);
            end
            for ch = 1:ch_num/2
                ch2 = ch + ch_num/2;
                    rightT = linspace(0,100,sizeavg_dataR(ch));
                    avg_dataR = cosd(rightT);
                    set(plotHandlesGaits(ch2), 'Ydata', avg_dataR);
                    set(plotHandlesGaits(ch2), 'Xdata', rightT);
            end