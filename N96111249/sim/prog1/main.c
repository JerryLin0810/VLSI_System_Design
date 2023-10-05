int main(void) {
    extern int _test_start;
    extern int array_addr;
    extern int array_size;

    int i, j, k;
    int temp;

    for (k = 0; k < 32; k++) {
        *(&_test_start + k) = *(&array_addr + k);
    }

    for (i = 0; i < *(&array_size) - 1; i++) {
        for (j = 0; j < *(&array_size) - 1 - i; j++) {
            int* current = &(_test_start) + j;
            int* next = &(_test_start) + j + 1;

            if (*current > *next) {
                temp = *current;
                *current = *next;
                *next = temp;
            }
        }
    }

    return 0;
}
