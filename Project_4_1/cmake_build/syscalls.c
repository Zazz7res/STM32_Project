#include <stdint.h>
#include <sys/stat.h>
#include <errno.h>
extern uint32_t __HeapLimit;
extern uint32_t _estack;
caddr_t _sbrk(int incr) {
    static uint32_t heap_ptr = 0;
    uint32_t prev_heap_ptr;
    if (heap_ptr == 0) heap_ptr = (uint32_t)&__HeapLimit;
    prev_heap_ptr = heap_ptr;
    if (heap_ptr + incr > (uint32_t)&_estack) {
        errno = ENOMEM;
        return (caddr_t)-1;
    }
    heap_ptr += incr;
    return (caddr_t)prev_heap_ptr;
}
int _close(int file) { return -1; }
int _fstat(int file, struct stat *st) { st->st_mode = S_IFCHR; return 0; }
int _isatty(int file) { return 1; }
int _lseek(int file, int ptr, int dir) { return 0; }
int _read(int file, char *ptr, int len) { return 0; }
int _write(int file, char *ptr, int len) { return len; }
void _exit(int status) { while(1); }
