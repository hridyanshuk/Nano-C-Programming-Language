int printInt(int num);
int printStr(char * c);
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

int main()
{
    int a;
    int *e;
        
    int b = 3;
    e = &b;
    
    printStr("\nEnter an Integer : ");
    b = readInt(e);
    printStr("The factorial : ");
    print_factorial(b);
    printStr("\n");
    

    return 0;
}