#!/usr/bin/env python3
import argparse

def collectArgs():
    """
    collect arguments passed to this script.
    :return: arguments - filename, pdb directory, separated directory and outfilename
    """
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter,
                                     epilog='Enjoy the program! :)')
    parser.add_argument("-i", "--input", type=str, required=True,
                        help="The file containing all the frames per cluster")
    parser.add_argument("-o", "--output", type=str, required=True,
                        help="The filename to write the list of representatives of each cluster sequentially separated by comma")

    args = parser.parse_args()
    return args


args = collectArgs()
data = open(args.input).read().split('\n')
cluster_rep = []

# Get all cluster representatives from input file 
for line in data:
    if not line.startswith('cluster'):
        continue
    line = line.split('=>')[1].split()[0]
    cluster_rep.append(line)

# write all cluster representatives in output file
with open(args.output, 'w') as f:
    f.write(','.join(cluster_rep))

