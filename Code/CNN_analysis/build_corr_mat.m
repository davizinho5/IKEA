
labels = CountLabel(:,1);
corrmat = zeros(size(CountLabel,1));

for j=1:1:size(TTest,1)
    for l=1:1:size(labels,1)
        if (table2array(labels(l,1)) == (TTest(j,1)))
            pos = l;
            break;
        end
    end
    
    if (YTest(i) == TTest(j))
        corrmat(pos,pos) =  corrmat(pos,pos) + 1;    
    else
        for l=1:1:size(labels,1)
            if (table2array(labels(l,1)) == (YTest(j,1)))
                pos1 = l;
                break;
            end
        end
        corrmat(pos,pos1) =  corrmat(pos,pos1) + 1;    
    end
end
% NO SE USA
% sTable = array2table(corrmat,'RowNames',categories(table2array(labels)));

figure, imagesc(corrmat*10)
xticks([1:1:18])
xticklabels(categories(table2array(labels)))
set(gca,'xaxisLocation','top')
yticks([1:1:18])
yticklabels(categories(table2array(labels)))
set(gca,'yaxisLocation','left')
set(gca, 'FontSize', 16)


    