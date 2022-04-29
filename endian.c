#include "endian.h"

enum cu_endian_e cu_endian;

static const union {
    uint8_t bytes[4];
    uint32_t value;
} host_order = {
    {0, 1, 2, 3}
};

#define ORDER_LITTLE_ENDIAN     0x03020100
#define ORDER_BIG_ENDIAN        0x00010203

void cu_endian_init()
{
    if (host_order.value == ORDER_LITTLE_ENDIAN)
        cu_endian = LittleEndian;
    else if (host_order.value == ORDER_BIG_ENDIAN)
        cu_endian = BigEndian;
    else cu_endian = MiddleEndian;
}
