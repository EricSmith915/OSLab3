  
  //Add after pid = np -> p;
  
  // Copy mmr table from parent to child
  memmove((char*)np->mmr, (char *)p->mmr, MAX_MMR*sizeof(struct mmr));
  // For each valid mmr, copy memory from parent to child, allocating new memory for
  // private regions but not for shared regions, and add child to family for shared regions.
  for (int i = 0; i < MAX_MMR; i++) {
    if(p->mmr[i].valid == 1) {
      if(p->mmr[i].flags & MAP_PRIVATE) {
        for (uint64 addr = p->mmr[i].addr; addr < p->mmr[i].addr+p->mmr[i].length; addr += PGSIZE)
          if(walkaddr(p->pagetable, addr))
            if(uvmcopy(p->pagetable, np->pagetable, addr, addr+PGSIZE) < 0) {
              freeproc(np);
              release(&np->lock);
              return -1;
            }
          np->mmr[i].mmr_family.proc = np;
          np->mmr[i].mmr_family.listid = -1;
          np->mmr[i].mmr_family.next = &(np->mmr[i].mmr_family);
          np->mmr[i].mmr_family.prev = &(np->mmr[i].mmr_family);
      } else { // MAP_SHARED
        for (uint64 addr = p->mmr[i].addr; addr < p->mmr[i].addr+p->mmr[i].length; addr += PGSIZE)
          if(walkaddr(p->pagetable, addr))
            if(uvmcopyshared(p->pagetable, np->pagetable, addr, addr+PGSIZE) < 0) {
              freeproc(np);
              release(&np->lock);
              return -1;
            }
        // add child process np to family for this mapped memory region
        np->mmr[i].mmr_family.proc = np;
        np->mmr[i].mmr_family.listid = p->mmr[i].mmr_family.listid;
        acquire(&mmr_list[p->mmr[i].mmr_family.listid].lock);
        np->mmr[i].mmr_family.next = p->mmr[i].mmr_family.next;
        p->mmr[i].mmr_family.next = &(np->mmr[i].mmr_family);
        np->mmr[i].mmr_family.prev = &(p->mmr[i].mmr_family);
        if (p->mmr[i].mmr_family.prev == &(p->mmr[i].mmr_family))
          p->mmr[i].mmr_family.prev = &(np->mmr[i].mmr_family);
        release(&mmr_list[p->mmr[i].mmr_family.listid].lock);
      }
    }