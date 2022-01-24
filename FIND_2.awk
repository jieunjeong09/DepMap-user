BEGIN {
  FS = "\t"
  if (!f) {
    print "define cell line file with -v f=__"
    exit
  }
  if (!c) # column with cell line names
    c = 1
  if (h == "") # number of header lines
    h = 1
  for (i = 1;  i <= h;  i++)
    getline < f
  while (getline < f) {
    Num[$c] = ++s_num
    Nam[s_num] = $c
  }
  close(f)

  # 1st pass for finding names, using column 2
  f = "sample_info.tab"
  while (getline < f)
    if (Num[$2]) {
      Ach[$2] = $1
  }
  close (f)

  for (a in Num)
    if (Num[a] && !Ach[a]) {
      r = toupper(a)
      gsub(/[^0-9A-Z]/,"",r)
      Ori[r] = a
      RNum[r] = Num[a]
    }
      
  # 2st pass for finding names, using column 3 and column 4
  while (getline < f)
    if (RNum[toupper($3)])
      Ach[Ori[toupper($3)]] = $1
  close (f)

  for (i = 1;  i <= s_num;  i++)
    print Ach[Nam[i]], Nam[i]
}
