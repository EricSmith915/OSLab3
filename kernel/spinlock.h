#define NSEM_S 100

// Mutual exclusion lock.
struct spinlock {
  uint locked;       // Is the lock held?

  // For debugging:
  char *name;        // Name of lock.
  struct cpu *cpu;   // The cpu holding the lock.
};

struct semaphore {
  struct spinlock lock;
  int count;
  int valid;
};

struct semtab {
  struct spinlock lock;
  struct semaphore sem[NSEM_S];
};

extern struct semtab semtable;



