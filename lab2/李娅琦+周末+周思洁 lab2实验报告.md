<h1 align = "center">操作系统实验报告</h1>

<h3 align = "center">实验名称：物理内存和页表    </h3>

<h4 align = "center"> 小组成员：李娅琦  周思洁  周末</h4>

## 一、实验目的
- 理解页表的建立和使用方法
- 理解物理内存的管理方法
- 理解页面分配算法
  
## 二、实验内容
### 练习1：理解first-fit 连续物理内存分配算法（思考题）

**first-fit 连续物理内存分配算法作为物理内存分配一个很基础的方法，需要同学们理解它的实现过程。请大家仔细阅读实验手册的教程并结合kern/mm/default_pmm.c中的相关代码，认真分析default_init，default_init_memmap，default_alloc_pages， default_free_pages等相关函数，并描述程序在进行物理内存分配的过程以及各个函数的作用。** 

###### (1)函数default_init：
- 初始化空闲页面链表free_list。
- 将记录空闲页面数量的变量nr_free设置为0。
###### (2)函数default_init_memmap：
- 初始化物理内存映射。
- 参数base是物理页面基址，n是页面数量。
- 遍历所有页面，将它们标记为非保留，并初始化页面属性。
- 将第一个页面的property字段设置为页面总数n，并设置页面属性。
- 增加空闲页面数量nr_free。
- 将空闲页面链入空闲链表，按照地址顺序插入。
###### (3)函数default_alloc_pages：
- 从空闲链表中分配n个连续的物理页面。
- 如果空闲页面不足以满足请求，返回NULL。
- 遍历空闲链表，找到第一个足够大的空闲块。
- 从链表中删除找到的页面块，并根据需要将其拆分。
- 减少空闲页面数量nr_free。
- 返回分配的页面基址。
###### (4)函数default_free_pages：
- 释放n个连续的物理页面。
- 参数base是物理页面基址，n是页面数量。
- 初始化释放的页面，并将它们标记为非保留。
- 增加空闲页面数量nr_free。
- 将释放的页面链入空闲链表，并尝试与相邻的空闲页面合并。

**你的first fit算法是否有进一步的改进空间？**

**答：** first fit算法确实有进一步优化的空间。以下是一些可能的改进点：
- 错误处理和断言：
在default_alloc_pages函数中，如果n > nr_free，函数直接返回NULL。可能需要添加更多的日志信息或者错误处理机制，以便于调试和跟踪内存分配失败的原因。
- 合并逻辑优化：
在default_free_pages函数中，合并逻辑可以进一步优化，以减少链表遍历的次数。例如，可以在删除节点后立即检查相邻节点是否可以合并，而不是在插入新节点后再次遍历。
- 代码重复：
在default_init_memmap和default_free_pages中，都有插入新节点到空闲链表的逻辑，这部分代码可以抽象成一个单独的函数来减少重复。
- 内存对齐：
在分配和释放页面时，可能需要考虑内存对齐的要求，以确保分配的内存块满足特定的对齐约束。
- 性能优化：
在遍历空闲链表时，可以考虑使用更高效的数据结构，如平衡二叉树或者跳表，以减少查找和插入操作的时间复杂度。

### 练习2：实现 Best-Fit 连续物理内存分配算法（需要编程）
**在完成练习一后，参考kern/mm/default_pmm.c对First Fit算法的实现，编程实现Best Fit页面分配算法，算法的时空复杂度不做要求，能通过测试即可。**

在best_fit_pmm.c中总共修改了三部分的代码：

###### 1.best_fit_init_memmap函数
这部分函数主要是使用best-fit算法以完成内存映射的初始化。

**第一部分：初始化每个页框**
- 初始化时需要分配一个包括n个页的页块；
- 对于连续n个页组成的空闲页块，只需把**第一个页**设置`property=n`且设置property标志位；
- 对于后续所有页，只需**清空当前页框的标志和属性信息并将页框的引用计数设置为0**

**第二部分：将base插入free_list链表适当位置**
- 初始化之后下面需要将其插入free_list 链表；
- 如果是空链表直接插入即可；
- 否则找到第一个地址大于 base 的页框（free_list链表是按照地址排序的），然后将 base 插入到这个页框之前；
- 如果遍历到链表的末尾还没有找到合适的位置（即 list_next(le) == &free_list），则将 base 添加到链表的末尾。

```c
best_fit_init_memmap(struct Page *base, size_t n) {
    assert(n > 0);
    struct Page *p = base;
    for (; p != base + n; p ++) {
        assert(PageReserved(p));

        /*LAB2 EXERCISE 2: 2211349*/ 
        // 清空当前页框的标志和属性信息，并将页框的引用计数设置为0
        p->flags = p->property = 0;
        set_page_ref(p, 0);
    }
    base->property = n;
    SetPageProperty(base);
    nr_free += n;
    if (list_empty(&free_list)) {
        list_add(&free_list, &(base->page_link));
    } else {
        list_entry_t* le = &free_list;
        while ((le = list_next(le)) != &free_list) {
            struct Page* page = le2page(le, page_link);
             /*LAB2 EXERCISE 2: 2211349*/ 
            // 编写代码
            // 1、当base < page时，找到第一个大于base的页，将base插入到它前面，并退出循环
            // 2、当list_next(le) == &free_list时，若已经到达链表结尾，将base插入到链表尾部
            if (base < page) {
                list_add_before(le, &(base->page_link));
                break;
            } else if (list_next(le) == &free_list) {
                list_add(le, &(base->page_link));
            }
        }
    }
}
```
##### 2.
- 原本代码实现的是First-fit，只需找到**第一个**满足大小的空闲块则立即退出循环
- 而需要实现的best-fit，则是找到满足大小的**最小的**空闲块。
因此，在原来代码基础上，
- 使用`min_size`来记录满足要求的最小property值
- 依次遍历**所有**在free_list链表上的空闲块以找到满足要求的空闲块。
基于此代码修改如下：
```c
best_fit_alloc_pages(size_t n) {
    assert(n > 0);
    if (n > nr_free) {
        return NULL;
    }
    struct Page *page = NULL;
    list_entry_t *le = &free_list;
    size_t min_size = nr_free + 1;
     /*LAB2 EXERCISE 2: 2213603*/ 
    // 下面的代码是first-fit的部分代码，请修改下面的代码改为best-fit
    // 遍历空闲链表，查找满足需求的空闲页框
    // 如果找到满足需求的页面，记录该页面以及当前找到的最小连续空闲页框数量
    while ((le = list_next(le)) != &free_list) {
        struct Page *p = le2page(le, page_link);
        if (p->property >= n&&p->property<min_size) {
            min_size=p->property;
            page = p;
        }
    }

    if (page != NULL) {
        list_entry_t* prev = list_prev(&(page->page_link));
        list_del(&(page->page_link));
        if (page->property > n) {
            struct Page *p = page + n;
            p->property = page->property - n;
            SetPageProperty(p);
            list_add(prev, &(p->page_link));
        }
        nr_free -= n;
        ClearPageProperty(page);
    }
    return page;
}
```
##### 3.default_free_pages函数

**补充的第一部分代码**
- `base->property = n;`：设置当前页块的大小为n，表示这个页块现在是一个空闲的页块，包含n个连续的页面。
- `SetPageProperty(base);`：对于重新变为空闲状态的块，需要将其块内第一个页的PG_property属性置位，即`SetPageProperty(base)`
- `nr_free += n;`：增加全局空闲页面计数nr_free，表示系统中现在有更多的空闲页面可用。
  
**补充的第二部分代码**
- `if ((unsigned int)(base - p) == p->property)`：检查当前页块是否紧跟在前一个页块之后。如果是，这意味着两个页块是连续的，可以合并。
- `p->property += base->property;`：更新前一个页块的大小，加上当前页块的大小。
- `ClearPageProperty(base);`：清除当前页块的属性标记，因为它已经被合并到前一个页块中。
- `list_del(&(base->page_link));`：从链表中删除当前页块的节点。
- `base = p`;：更新base指针，指向合并后的页块。
```c
best_fit_free_pages(struct Page *base, size_t n) {
    assert(n > 0);
    struct Page *p = base;
    for (; p != base + n; p ++) {
        assert(!PageReserved(p) && !PageProperty(p));
        p->flags = 0;
        set_page_ref(p, 0);
    }
    /*LAB2 EXERCISE 2: 2212126*/ 
    // 编写代码
    // 具体来说就是设置当前页块的属性为释放的页块数、并将当前页块标记为已分配状态、最后增加nr_free的值
    base->property = n;
    SetPageProperty(base);
    nr_free += n;

    if (list_empty(&free_list)) {
        list_add(&free_list, &(base->page_link));
    } else {
        list_entry_t* le = &free_list;
        while ((le = list_next(le)) != &free_list) {
            struct Page* page = le2page(le, page_link);
            if (base < page) {
                list_add_before(le, &(base->page_link));
                break;
            } else if (list_next(le) == &free_list) {
                list_add(le, &(base->page_link));
            }
        }
    }

    list_entry_t* le = list_prev(&(base->page_link));
    if (le != &free_list) {
        p = le2page(le, page_link);
        /*LAB2 EXERCISE 2: 2212126*/ 
         // 编写代码
        // 1、判断前面的空闲页块是否与当前页块是连续的，如果是连续的，则将当前页块合并到前面的空闲页块中
        // 2、首先更新前一个空闲页块的大小，加上当前页块的大小
        // 3、清除当前页块的属性标记，表示不再是空闲页块
        // 4、从链表中删除当前页块
        // 5、将指针指向前一个空闲页块，以便继续检查合并后的连续空闲页块
         if ((unsigned int)(base - p) == p->property) {
            p->property += base->property;
            ClearPageProperty(base);
            list_del(&(base->page_link));
            base = p;
        }
    }

    le = list_next(&(base->page_link));
    if (le != &free_list) {
        p = le2page(le, page_link);
        if (base + base->property == p) {
            base->property += p->property;
            ClearPageProperty(p);
            list_del(&(p->page_link));
        }
    }
}
```

#### 4.你的 Best-Fit 算法是否有进一步的改进空间？
**答：** 仍有改进空间
- 内存分配粒度：
多粒度分配：结合不同大小的内存块，如使用固定大小的分配器处理小内存请求，而Best-Fit用于大内存请求。
伙伴系统：使用伙伴系统来管理内存块，可以更有效地处理不同大小的分配请求。
- 预测和适应性：
基于历史数据的预测：分析历史分配模式，预测未来的内存需求，并据此调整分配策略。
自适应算法：根据当前的内存使用情况自动调整分配策略，以优化性能和碎片管理。
内存回收：
- 延迟合并：当内存被释放时，不是立即合并相邻的空闲块，而是延迟合并，以减少合并操作的开销。
并行处理：
- 并行搜索：在多核系统中，可以并行搜索空闲块列表，以加快分配速度。
虚拟内存集成：
- 虚拟内存管理：结合虚拟内存管理，通过分页或分段机制，减少物理内存分配的压力。
- 利用硬件特性：
NUMA-aware分配：在非一致性内存访问（NUMA）系统中，优化内存分配以考虑内存访问延迟。

### 扩展练习Challenge1：buddy system（伙伴系统）分配算法（需要编程）

#### 代码实现

##### 内存初始化
为了管理不同大小的内存块，维护了一组空闲链表，每个链表存储特定大小的空闲内存块。系统启动时，所有链表为空，需要初始化它们，同时初始化物理内存，将页面标记为可用并加入适当的链表中。
```c
static void
buddy_system_init(void) {
    for(int i = 0; i < MAX_ORDER; i++) {
        list_init(&(free_area[i].free_list));
        free_area[i].nr_free = 0;
    }
    
}
```
```c
static void
buddy_system_init_memmap(struct Page *base, size_t n) {
    assert(n > 0);
    struct Page *p = base;
    for (; p != base + n; p ++) {
        assert(PageReserved(p));
        p->flags = p->property = 0;
        set_page_ref(p, 0);
    }
    size_t curr_size = n;
    uint32_t order = MAX_ORDER - 1;
    uint32_t order_size = 1 << order;
    p = base;
    while (curr_size != 0) {
        p->property = order_size;
        SetPageProperty(p);
        nr_free(order) += 1;
        list_add_before(&(free_list(order)), &(p->page_link));
        curr_size -= order_size;
        while(order > 0 && curr_size < order_size) {
            order_size >>= 1;
            order -= 1;
        }
        p += order_size;
    }
}
```

#### 内存分配
根据请求的大小，快速分配一个合适的内存块，并将其从空闲链表中移除。 

1. 选择合适大小的内存块：首先需要确定哪个链表中包含适合当前请求的内存块。buddy系统按二的幂次划分内存，因此通过二进制位运算可以快速找到合适的块。但其中可能存在我们需要的最合适的块大小在链表中不存在，需要分裂一个更大的块；
```c
static struct Page *
buddy_system_alloc_pages(size_t n) {
    assert(n > 0);
    if (n > (1 << (MAX_ORDER - 1))) {
        return NULL;
    }
    struct Page *page = NULL;
    uint32_t order = MAX_ORDER - 1;
    while (n < (1 << order)) {
        order -= 1;
    }
    order += 1;
    uint32_t flag = 0;
    for (int i = order; i < MAX_ORDER; i++) flag += nr_free(i);
    if(flag == 0) return NULL;
    if(list_empty(&(free_list(order)))) {
        split_page(order + 1);
    }
    if(list_empty(&(free_list(order)))) return NULL;
    list_entry_t *le = list_next(&(free_list(order)));
    page = le2page(le, page_link);
    list_del(&(page->page_link));
    ClearPageProperty(page);
    return page;
}
```
2. 分裂较大的块：如果当前链表中没有合适大小的块，程序会从更大的块中分裂出两个较小的块，并将其放入较低级别的链表中，以满足请求。
```c
static void split_page(int order) {
    if(list_empty(&(free_list(order)))) {
        split_page(order + 1);
    }
    list_entry_t* le = list_next(&(free_list(order)));
    struct Page *page = le2page(le, page_link);
    list_del(&(page->page_link));
    nr_free(order) -= 1;
    uint32_t n = 1 << (order - 1);
    struct Page *p = page + n;
    page->property = n;
    p->property = n;
    SetPageProperty(p);
    list_add(&(free_list(order-1)),&(page->page_link));
    list_add(&(page->page_link),&(p->page_link));
    nr_free(order-1) += 2;
    return;
}
```
#### 内存释放与合并
当内存不再使用时，将其返回系统的空闲链表中。为减少内存碎片，程序会尝试合并相邻的空闲块，形成更大的块。

1. 释放内存：将内存块标记为空闲，并按照其大小放入对应的空闲链表中。
```c
static void
buddy_system_free_pages(struct Page *base, size_t n) {
    assert(n > 0);
    assert(IS_POWER_OF_2(n));
    assert(n < (1 << (MAX_ORDER - 1)));
    struct Page *p = base;
    for (; p != base + n; p ++) {
        assert(!PageReserved(p) && !PageProperty(p));//确保页面没有被保留且没有属性标志
        p->flags = 0;
        set_page_ref(p, 0);
    }
    base->property = n;
    SetPageProperty(base);

    uint32_t order = 0;
    size_t temp = n;
    while (temp != 1) {//找到能将此内存块放入的链表序号，根据幂次方的大小对序号进行加法运算，直到确定序号
        temp >>= 1;
        order++;
    }
    add_page(order,base);
    merge_page(order,base);
}
```
2. 合并相邻的空闲块：程序会检查释放的块是否与相邻的块连续，如果是，则将它们合并为一个更大的块，重复这一过程，直到无法再合并。
```c
static void merge_page(uint32_t order, struct Page* base) {
    if (order == MAX_ORDER - 1) {//没有更大的内存块了，升不了级了
        return;
    }
    
    list_entry_t* le = list_prev(&(base->page_link));
    if (le != &(free_list(order))) {
        struct Page *p = le2page(le, page_link);
        if (p + p->property == base) {//若是连续内存
            p->property += base->property;
            ClearPageProperty(base);
            list_del(&(base->page_link));
            base = p;
            if(order != MAX_ORDER - 1) {
                list_del(&(base->page_link));
                add_page(order+1,base);
            }
        }
    }

    le = list_next(&(base->page_link));
    if (le != &(free_list(order))) {
        struct Page *p = le2page(le, page_link);
        if (base + base->property == p) {
            base->property += p->property;
            ClearPageProperty(p);
            list_del(&(p->page_link));
            if(order != MAX_ORDER - 1) {
                list_del(&(base->page_link));
                add_page(order+1,base);
            }
        }
    }
    merge_page(order+1,base);
    return;
}
```

#### 空闲块管理  
为了高效管理不同大小的内存块，系统需要维护一个空闲块链表，该模块负责将空闲块正确添加到链表中，并确保链表中的块按地址顺序排列。
 
1. 按地址顺序插入：为了方便合并空闲块，链表中的块需要按内存地址升序排列。当释放内存块时，系统会将其按照地址顺序插入到链表中。
```c
static void add_page(uint32_t order, struct Page* base) {
    if (list_empty(&(free_list(order)))) {
        list_add(&(free_list(order)), &(base->page_link));
    } else {
        list_entry_t* le = &(free_list(order));
        while ((le = list_next(le)) != &(free_list(order))) {
            struct Page* page = le2page(le, page_link);
            if (base < page) {
                list_add_before(le, &(base->page_link));
                break;
            } else if (list_next(le) == &(free_list(order))) {
                list_add(le, &(base->page_link));
            }
        }
    }
}
```
2. 维护空闲块计数：每次插入或删除块时，系统需要更新当前链表中空闲块的数量，以便快速知道是否有足够的内存块可用。
```c
static size_t
buddy_system_nr_free_pages(void) {//计算空闲页面的数量，空闲块*块大小（与链表序号有关）
    size_t num = 0;
    for(int i = 0; i < MAX_ORDER; i++) {
        num += nr_free(i) << i;
    }
    return num;
}
```
#### 测试验证
测试函数如下
```
static void buddy_system_check(void)
{
    struct Page *p0, *p1, *p2, *p3;

    //检验合并是否成功
     cprintf("%d",nr_free(1));//0
     p0 = buddy_system_alloc_pages(2);
     assert(nr_free(1)==1);
     p3 = buddy_system_alloc_pages(2);
     assert(nr_free(1)==0);
     p2 = buddy_system_alloc_pages(4);
     assert(nr_free(1) ==0&&nr_free(2)==0 );
    buddy_system_free_pages(p3, 2);
    assert(nr_free(1)==1);
    buddy_system_free_pages(p2, 4);
    buddy_system_free_pages(p0, 2);
    assert(nr_free(1)==0);

    // 测试 2 页的分配和释放
  
    p0 = buddy_system_alloc_pages(2);
    assert(p0 != NULL);
    buddy_system_free_pages(p0, 2);
    
    
    //非二次幂分配
    p0 = buddy_system_alloc_pages(3);
    assert(p0 != NULL);
    buddy_system_free_pages(p0, 4);

    // // 测试 8 页分配
    p3 = buddy_system_alloc_pages(8);
    assert(p3 != NULL);
    buddy_system_free_pages(p3, 8);


    cprintf("buddy system tests passed.\n");
}

```
结果如下
```c
Special kernel symbols:
  entry  0xffffffffc0200032 (virtual)
  etext  0xffffffffc02014b0 (virtual)
  edata  0xffffffffc0206010 (virtual)
  end    0xffffffffc0206560 (virtual)
Kernel executable memory footprint: 26KB
memory management: buddy_pmm_manager
physcial memory map:
  memory: 0x0000000007e00000, [0x0000000080200000, 0x0000000087ffffff].
buddy system tests passed.
check_alloc_page() succeeded!
satp virtual address: 0xffffffffc0205000
satp physical address: 0x0000000080205000
```

### 扩展练习Challenge3：可用物理内存获取
- 内存管理单元（MMU）：操作系统可以通过查询 MMU 或硬件特性（例如我们实验中的openSBI）来确定可用内存的物理地址范围。某些处理器提供寄存器或特性，用于报告可用内存信息。
- BIOS/UEFI 提供内存映射信息，列出可用内存区域和保留内存区域
- 设置内存访问权限。如果访问超出分配范围的内存，则返回零。
