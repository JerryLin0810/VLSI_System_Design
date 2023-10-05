int main(void) {
    extern int _test_start;
    extern int div1;
    extern int div2;

    int big = *(&div1) > *(&div2) ? *(&div1) : *(&div2);
    int small = *(&div1) > *(&div2) ? *(&div2) : *(&div1);
    int temp;

    while (big % small != 0) {
        temp = big;
        big = small;
        small = temp % small;
    }

    *(&_test_start) = small;
}