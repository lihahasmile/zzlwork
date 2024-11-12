#include <defs.h>
#include <riscv.h>
#include <stdio.h>
#include <string.h>
#include <swap.h>
#include <swap_lru.h>
#include <memlayout.h>
#include <list.h>

/* LRU (最近最少使用) 页面替换算法 */

list_entry_t pra_list_head, *curr_ptr;

/*
 * (1) _lru_init_mm: 初始化LRU页面替换结构
 */
static int
_lru_init_mm(struct mm_struct *mm) {
    list_init(&pra_list_head);  // 初始化LRU链表头
    curr_ptr = &pra_list_head;  // curr_ptr跟踪当前页面替换位置
    mm->sm_priv = &pra_list_head;  // 将mm的私有字段指向LRU链表头
    cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
    return 0;
}

/*
 * (2) _lru_map_swappable: 将最近访问的页面添加到LRU队列的前端
 */
static int
_lru_map_swappable(struct mm_struct *mm, uintptr_t addr, struct Page *page, int swap_in) {
    list_entry_t *entry = &(page->pra_page_link);
    assert(entry != NULL && curr_ptr != NULL);

    list_entry_t *head = (list_entry_t*) mm->sm_priv;
    
    list_entry_t *temp = head->next;
    while(temp != head)
    {
        if(entry == temp)
        {
            list_del(temp);
            break;
        }
        temp = temp->next;
    }
    list_add(head, entry);  // 将页面插入到链表的前端

    return 0;
}

/*
 * (3) _lru_swap_out_victim: 选择最久未访问的页面进行替换
 */
static int
_lru_swap_out_victim(struct mm_struct *mm, struct Page **ptr_page, int in_tick) {
    list_entry_t *head = (list_entry_t*) mm->sm_priv;
    assert(head != NULL);
    assert(in_tick == 0);

    // 遍历LRU链表，找到最久未被访问的页面（位于链表尾部）
    list_entry_t *victim_entry = list_prev(head);  // 最久未访问的页面在链表尾部
    cprintf("curr_ptr %p\n", victim_entry);
    // 获取页面对应的结构体
    struct Page *victim_page = le2page(victim_entry, pra_page_link);

    // 将该页面从链表中删除
    list_del(victim_entry);

    // 将该页面指针赋给 ptr_page，表示该页面被淘汰
    *ptr_page = victim_page;

    return 0;
}

/*
 * (4) _lru_check_swap: 检查页面交换情况（用于测试）
 */
static int
_lru_check_swap(void) {
#ifdef ucore_test
    int score = 0, totalscore = 5;
    cprintf("%d\n", &score);
    ++score; cprintf("grading %d/%d points", score, totalscore);
    *(unsigned char *)0x3000 = 0x0c;
    assert(pgfault_num == 4);
    *(unsigned char *)0x1000 = 0x0a;
    assert(pgfault_num == 4);
    *(unsigned char *)0x4000 = 0x0d;
    assert(pgfault_num == 4);
    *(unsigned char *)0x2000 = 0x0b;
    assert(pgfault_num == 4);
    *(unsigned char *)0x5000 = 0x0e;
    assert(pgfault_num == 5);
    *(unsigned char *)0x2000 = 0x0b;
    assert(pgfault_num == 5);
    *(unsigned char *)0x1000 = 0x0a;
    assert(pgfault_num == 5);
    *(unsigned char *)0x2000 = 0x0b;
    assert(pgfault_num == 5);
    *(unsigned char *)0x3000 = 0x0c;
    assert(pgfault_num == 5);
    *(unsigned char *)0x4000 = 0x0d;
    assert(pgfault_num == 5);
    *(unsigned char *)0x5000 = 0x0e;
    assert(pgfault_num == 5);
    assert(*(unsigned char *)0x1000 == 0x0a);
    *(unsigned char *)0x1000 = 0x0a;
    assert(pgfault_num == 6);
#else
    *(unsigned char *)0x3000 = 0x0c;
    assert(pgfault_num == 4);
    *(unsigned char *)0x1000 = 0x0a;
    assert(pgfault_num == 4);
    *(unsigned char *)0x4000 = 0x0d;
    assert(pgfault_num == 4);
    *(unsigned char *)0x2000 = 0x0b;
    assert(pgfault_num == 4);
    *(unsigned char *)0x5000 = 0x0e;
    assert(pgfault_num == 5);
    *(unsigned char *)0x2000 = 0x0b;
    assert(pgfault_num == 5);
    *(unsigned char *)0x1000 = 0x0a;
    assert(pgfault_num == 5);
    *(unsigned char *)0x2000 = 0x0b;
    assert(pgfault_num == 5);
    *(unsigned char *)0x3000 = 0x0c;
    assert(pgfault_num == 5);
    *(unsigned char *)0x4000 = 0x0d;
    assert(pgfault_num == 5);
    *(unsigned char *)0x5000 = 0x0e;
    assert(pgfault_num == 5);
    assert(*(unsigned char *)0x1000 == 0x0a);
    *(unsigned char *)0x1000 = 0x0a;
    assert(pgfault_num == 6);
#endif
    return 0;
}

/*
 * (5) _lru_init: 初始化LRU算法结构（可选）
 */
static int
_lru_init(void) {
    return 0;
}

/*
 * (6) _lru_set_unswappable: 将页面设置为不可交换
 */
static int
_lru_set_unswappable(struct mm_struct *mm, uintptr_t addr) {
    return 0;
}

/*
 * (7) _lru_tick_event: 处理周期性事件（可选）
 */
static int
_lru_tick_event(struct mm_struct *mm) {
    return 0;
}

/*
 * 定义LRU算法的swap管理器
 */
struct swap_manager swap_manager_lru = {
    .name = "LRU swap manager",
    .init = &_lru_init,
    .init_mm = &_lru_init_mm,
    .tick_event = &_lru_tick_event,
    .map_swappable = &_lru_map_swappable,
    .set_unswappable = &_lru_set_unswappable,
    .swap_out_victim = &_lru_swap_out_victim,
    .check_swap = &_lru_check_swap,
};