BEGIN {
  FS = ","
  f = "sample_info.csv"
  while (getline < f)
    ACH[$4] = $1 # cell line identifier in D2 -> ACH identifier
  close(f)

  f = "D2_combined_gene_dep_scores.csv"
  getline < f
  for (i = 2;  i <= NF;  i++) {
    a = $i
    gsub(/"/,"",a)
    A[i-1] = ACH[a]
  }
   
  while (getline < f) {
    g++
    B[g] = $1 # gene with ID number, like in other tables
    for (i = 2;  i <= NF;  i++)
      V[i-1, g] = substr($i,1,7)
  }
  close(f)

  # head line with genes
  for (i = 1;  i <= g;  i++)
    printf ",%s", B[i]
  printf "\n"
  # lines with data
  for (i = 1;  i <= NF;  i++) {
    printf "%s", A[i]
    for (j = 1;  j <= g;  j++)
      printf ",%s", V[i, j]
    printf "\n"
  }
}
