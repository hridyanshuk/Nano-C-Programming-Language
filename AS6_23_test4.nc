int printStr(char *c);
int printInt(int i);
int readInt(int *eP);

// Add two numbers from input
int main() {
  int x;
  int y;
  int z;
  int *xaddr;
  xaddr = &x;
  x = readInt(xaddr);
  int *yaddr;
  yaddr = &y;
  y = readInt(yaddr);
  z = x + y;
  printInt(x);
  printStr("+");
  printInt(y);
  printStr(" = ");
  printInt(z);
    printStr("\n");
  return 0;
}