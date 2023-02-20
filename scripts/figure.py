import pandas as pd
import sys
from matplotlib import pyplot as plt

data = pd.read_csv('{}'.format(sys.argv[1]), sep = '\t')
gene_list = pd.unique(data['Segment'])

for gene_id in gene_list:
    gene = data.loc[(data['Segment'] == gene_id)]
    all_for_bp = {k: 0 for k in range(1,2400)}
    all_rev_bp = {k: 0 for k in range(1,2400)}
    for index, row in gene.iterrows():
        start = row["Start"]
        stop = row["Stop"]
        for i in range(start,stop):
            all_for_bp[i] += row["Forward_support"]
            all_rev_bp[i] += row["Reverse_support"]
    
    fig, (ax1, ax2) = plt.subplots(1, 2)
    fig.suptitle('Defective interfering particles segment: {}'.format(gene_id))

    ax1.bar(list(all_for_bp.keys()), all_for_bp.values(), color='blue')
    ax1.set(xlabel='bp', ylabel='read coverage')
    ax1.set_title('Forward support')
    ax1.set_ylim(0, max(max(all_for_bp.values()),max(all_rev_bp.values()))+20)
    
    ax2.bar(list(all_rev_bp.keys()), all_rev_bp.values(), color='red')
    ax2.set(xlabel='bp')
    ax2.set_title('Reverse support')
    ax2.set_ylim(0, max(max(all_for_bp.values()),max(all_rev_bp.values()))+20)
    fig.savefig("{}.pdf".format(gene_id), format="pdf", bbox_inches="tight")

