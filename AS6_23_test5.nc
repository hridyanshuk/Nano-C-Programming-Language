int printStr(char *c);
int printInt(int i);
int readInt(int *eP);
// Find max of n numbers using array
int main() {
  int n;
  int a[10];
  int m;
  int i;
  i = 0;
  int *naddr;
  naddr = &n;
  printStr("Enter n : ");
  n = readInt(naddr);
  int *maddr;
  printStr("Running loop ");
  printInt(n);
  printStr(" times\n");

  for(i=0 ; i<n ; i=i+1) {
    printInt(i);
    printStr("th iteration\n");
  }
    printStr("\n");

  return 0;
}