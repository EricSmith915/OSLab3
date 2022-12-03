#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "kernel/fs.h"

int main(int argc, char *argv[])
{
    if(argc < 2){
        fprintf(2, "Too few args\n");
        exit(1);
    }

    int fd = open(argv[1], 0x000);

    struct stat *sta = {0};
    
    fstat(fd, sta);

    printf("Type: %d\nSize: %d\nInode Number: %d\nLinks: %d\n", sta->type, sta->size, sta->ino, sta->nlink);

    exit(0);
}