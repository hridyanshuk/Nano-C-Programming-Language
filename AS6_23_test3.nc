
int printStr(char *c);
int printInt(int i);
int readInt(int *eP);
int a;
int b = 1;
int greaterThan10 (int b) {
  int ans;
  int c = 2;
  int d;
  int arr[10];
  int*p;
  ans = b;
  d = 2;
  int rem;
  
  if (b>10) {
    printStr("Yes");
    return ans;
  }
  else {
    printStr("No");
  }
  return ans;
}
int main () {
  int c = 2;
  int d;
  int arr[10];
  int *p;
  int x;
  int y;
  int z;
  int eP;
  printStr("Enter number  : ");
  p = &eP;
  x = readInt(p);
  printStr("Greater than 10?\n");
  z = greaterThan10(x);
    printStr("\n");
  
  return c;
}
