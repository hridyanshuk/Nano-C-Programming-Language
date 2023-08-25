int printStr(char *c);
int printInt(int i);
int readInt(int *eP);

void print_factorial(int a) {
    int n=1;
    int i=0;
    for(i =1 ; i<=a ; i=i+1) {
        n=n*i;
    }
    printStr("The factorial is: ");
    printInt(n);
}

int main () {
    printStr("The factorial of 5\n");
    print_factorial(5);
    printStr("The factorial of 6\n");
    print_factorial(6);
    printStr("The factorial of 7\n");
    print_factorial(7);
    printStr("The factorial of 8\n");
    print_factorial(8);
    printStr("The factorial of 9\n");
    print_factorial(9);
    printStr("\n");
    return 0;
}