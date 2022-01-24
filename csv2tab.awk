# csv has fields of the form "  ,   , " that confuse awk
# we will remove "" and separate with tabs, assuming no tab inside fields
{
  a = split($0,A,"") # A[1..a] becomes an array of characters of $0
  out = 1    # in for loop, out==1 when A[i] is outside quotes, 0 if inside
  for (i = 1;  i <= a;  i++)
    if (A[i] == "\"")
      out = 1-out  # toggle inside/outside quotes and DO NOT print the quote
    else if (A[i] == "," && out)  # comma outside separates fields
      printf "\t"
    else
      printf "%s", A[i]
  printf "\n"
}
