# options restricting the set of mutations we consider
 
# -v samples=
# if samples == "all", we consider all cell lines, otherwise
# samples is a file name, and in this file we read lines that have
# 1st column with ACH-___ entry, cell line id used by CCLE
# 2nd column with cell line ID we use in tables and reports
# other lines are ignored

# -v genes=
# if genes == "all", we consider all genes, otherwise
# genes is a files name, and we consider genes in its 1st column.

# options that regulate the output

# -v verb=1
# we compute a name of the second output file 
# MutFile = "Mutations_" genes "_" samples ".txt"
# for each mutation we consider we print a short desciption
# into MutFile, the first line in the description starts with "Mutation"
# the details of this description are in function report_mutation()
    
# -v byGene
# print the table with a row for each gene, columns for cell lines
# the default is a row for each cell line, column for every gene
function report_mutation() {
  head = "Mutation " Rep [s] " " Gene[g] " "
  head = head "Chr" $4 ":" $5 "-" $6 $7
  print head > MutFile
  print ($20 == "True"? "Is" : "Not") "Deleterious" > MutFile
  print "Classification", $8 > MutFile
  print "Type", $9 > MutFile
  print "Annotation", $26 > MutFile
  print "Codon change", $18 > MutFile
  print "Protein change", $19 > MutFile
}
BEGIN {
# DataDir = "/Depmap/"
  if (!samples)
    samples = "Sixteen_workout"
  MutFile = "Mutations_" genes "_" samples ".txt"
if (check) print MutFile
  FS="\t"
  if (samples != "all")
    while (getline < samples)
      if ($1 ~ /^ACH/) {
        SNum[$1] = ++s_no
        Sam[s_no] = $1
        Rep[s_no] = $2? $2 : $3
      }
  close(samples)
if (check) print s_no, samples
  if (genes != "all")
    while (getline < genes) {
      if ($1 ~ /^!/) continue
      GNum[$1] = ++g_no
      Gene[g_no] = $1
    }
if (check) print g_no, genes

  FS = ","
  f = DataDir "CCLE_mutations.csv" 
  pf = "gzcat " f
  pf | getline
if (check) print substr($0,1,130)
  while (pf | getline) {
    if (!($1 in GNum)) {
if (check && ++n%10000 == 0) print "A", n/10000 

      if (genes == "all") {
        GNum[$1] = ++g_no
        Gene[g_no] = $1
      } else
        continue
    }
    if (!($16 in SNum)) {
      if (samples == "all") {
        SNum[$1] = ++s_no
        Rep[s_no] = Sam[s_no] = $1
      } else
        continue
    }
    if ($8 == "Silent")
      continue
    s = SNum[$16]
    g = GNum[$1]
    d = $20 == "True" || $26 == "damaging"? 2 : 1
    C[s, g, d]++
    if (verb)
      report_mutation()
  }
  if (byGene) {
    printf "Gene"
    for (s = 1;  s <= s_no;  s++)
      printf "\t%s", Rep[s]
    printf "\n"
    for (g = 1;  g <= g_no;  g++) {
    # add steps to compute p-value
      printf "%s", Gene[g]
      for (s = 1;  s <= s_no;  s++)
        printf "\t%d_%d", C[s, g, 1], C[s, g, 2]
      printf "\n"
    }
    exit 
  }
  printf "Cell_line"
  for (g = 1;  g <= g_no;  g++)
    printf "\t%s", Gene[g]
  printf "\n"
  for (s = 1;  s <= s_no;  s++) {
    printf "%-9s", Rep[s]
    for (g = 1;  g <= g_no;  g++)
      printf "\t%d_%d", C[s, g, 1], C[s, g, 2]
    printf "\n"
  }
}
