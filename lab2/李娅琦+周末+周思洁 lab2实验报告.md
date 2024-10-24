<h1 align = "center">操作系统实验报告</h1>

<h3 align = "center">实验名称：物理内存和页表    </h3>

<h4 align = "center"> 小组成员：李娅琦  周思洁  周末</h4>

## 一、实验目的
- 理解页表的建立和使用方法
- 理解物理内存的管理方法
- 理解页面分配算法
  
## 二、实验内容
#### 练习1：理解first-fit 连续物理内存分配算法（思考题）

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

#### 练习2：实现 Best-Fit 连续物理内存分配算法（需要编程）
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

##### 4.你的 Best-Fit 算法是否有进一步的改进空间？
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