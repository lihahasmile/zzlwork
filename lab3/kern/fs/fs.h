#ifndef __KERN_FS_FS_H__
#define __KERN_FS_FS_H__

#include <mmu.h>

#define SECTSIZE            512
//一页需要几个磁盘扇区?
#define PAGE_NSECT          (PGSIZE / SECTSIZE)

#define SWAP_DEV_NO         1

#endif /* !__KERN_FS_FS_H__ */

