# linux compatibility:
# here we use "gzcat filename" to read from "filename.gz" after decompression
# equivalent command in linux is "zcat filename.gz", CHECK IT
# so line "pf = " has to be changed

# idea for expression data: convert the data file for expression,
# that will eliminate cases in show function, reduce the size of the
# data file.

# in the same direction, CCLE_gene_cn.csv can be re-formatted to
# be much shorter... but this is a code complication.  The benefit
# is a huge decrease in file size, and the size of data files determines
# the time for getting the output.
# 
# options to select data
# -v d=exp == use data on gene expression in CCLE_expression.csv
# -v d=eff == use data on CRISPR effect in Achilles_gene_effect.csv
# -v d=CRI ==  use data on CRISPR effect corrected with CRONOS method
# -v d=RNA ==  use data on RNAi effect
# d not defined == use data on copy number in CCLE_gene_cn.csv

# option to select cell lines to report, MUST BE USED WITH A VALID FILE NAME
# -v samples=__
# this should be a file, 1st column ACH- ids, 2nd column ids we will report
# lines that do not start with ACH are ignored

# option to report single gene 
# -v gene=__ 
# for example, -v gene=EZH2
# this option causes to IGNORE -v genes=__ that is described next

# option to select genes to report, MUST BE USED WITH A VALID FILE NAME
# -v genes=__
# entries in column 1 will be genes to report
# -v genes=all report all genes, use the header line of the data file

# the order of rows/samples and genes is as in the files used to select them
# for genes=all, the order is from the header line of the data file

function show(x) {
  if (x == "" || tolower(x) == "na")
    return "NA"
  if (d == "exp")
    x = exp(x*log(2))-1
  x = sprintf("%9.3f", x)
  gsub(/ /,"",x)
  return x
}
BEGIN {
  FS = "\t"
  if (!samples) {
    print "-v sample=... must be a valid file name"
    exit
  }
  while (getline < samples)
    if ($1 ~ /^ACH/) {
      Num[$1] = ++s_no
      Rep[s_no] = ($2? $2 : $3)
    }
  close(samples)

# if (check) print s_no, "samples", g_no, "genes"
# select the file, set FS
  FS = ","
  if (!d)
    f = "CCLE_gene_cn.csv" 
  else if (d == "exp")
    f = "CCLE_expression.csv" 
  else if (d == "CRI")
    f = "CRISPR_gene_effect.csv"
  else if (d == "RNA")
    f = "D2_transposed.csv"
  pf = "gzcat " f

  # read the header line and find correct column(s)
  pf | getline
  # tables of gene names and columns of those genes
  n = NF
  for (i = 2; i <= n;  i++) {
    g = $i
    sub(/ .*$/,"",g)
    Nam[i-1] = g # used if we report for all genes
    GenCol[g] = i
  }
  # Nam[1..g_no] gene names, C[1..g_no] gene data columns
  if (gene) {
    if (GenCol[gene]) {
      if (GenCol[gene]) {
        g_no = 1
	Nam[1] = gene
      } else {
        print gene, "not found in", f
	exit
      }
    }
  } else if (genes) {
    FS = "" # genes separated by white space, gene names in $1, ^! for comments
    while (getline < genes)
      if ($1 ~ /^!/)
        continue
      else if (GenCol[$1])
	Nam[++g_no] = $1
      else
        print $1, "not found in", f
  } else # we use all genes from f
    g_no = n-1
  for (i = 1;  i <= g_no;  i++)
    C[i] = GenCol[Nam[i]]
   
  # collect the sub-matrix of data
  while (pf | getline) {
    if (!($1 in Num))
      continue
    n = Num[$1]
    for (a = 1;  a <= g_no;  a++)
      Val[n, a] = $C[a]
  }
  # EDIT
  # print header of the sub-matrix
  printf "%s", "cell line"
  for (a = 1;  a <= g_no;  a++)
    printf "\t%s", Nam[a]
  printf "\n"
  # print the data lines of the sub-matrix
  for (n = 1;  n <= s_no;  n++) {
    printf "%-9s", Rep[n]
    for (a = 1;  a <= g_no;  a++)
      printf "\t%s", show(Val[n, a])
    printf "\n"
  }
}
