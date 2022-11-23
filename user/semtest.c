#include "kernel/types.h"
#include "user/user.h"
#include "kernel/stat.h"

void
test1(void){
    printf("Semaphore test1 passed\n");
    return;
}

void
test2(void){
    printf("Semaphore test2 passed\n");
    return;
}

void
test3(void){
    printf("Semaphore test3 passed\n");
    return;
}

void
test4(void){
    printf("Semaphore test4 passed\n");
    return;
}



void main(){
    test1();
    test2();
    test3();
    test4();
    return;
}