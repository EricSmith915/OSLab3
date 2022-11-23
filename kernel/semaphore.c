#include "types.h"
#include "riscv.h"
#include "param.h"
#include "defs.h"
#include "spinlock.h"

struct semtab semtable;

void 
seminit(void)
{
    initlock(&semtable.lock, "semtable");
    for(int i = 0; i < NSEM; i++){
        initlock(&semtable.sem[i].lock, "sem");
    }
}

void
semdestroy(struct semaphore *s)
{
    return;
}

void
semwait(struct semaphore *s)
{
    acquire(&s->lock);
    while(s->count == 0){
        sleep(s, &s->lock);
    }
    s->count -= 1;
    release(&s->lock);
}

void 
sempost(struct semaphore *s)
{
    acquire(&s->lock);
    s->count += 1;
    wakeup(s);
    release(&s->lock);
}