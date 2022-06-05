from libc.stdlib cimport malloc, free
from libc.stdint cimport uint8_t, uint16_t, int8_t
from cpython.bytes cimport PyBytes_FromStringAndSize

cdef extern from "qrcode.h":
    ctypedef struct QRCode:
        uint8_t version
        uint8_t size
        uint8_t ecc
        uint8_t mode
        uint8_t mask
        uint8_t*modules

    uint16_t qrcode_getBufferSize(uint8_t version)
    int8_t qrcode_initBytes(QRCode *qrcode, uint8_t *modules, uint8_t version, uint8_t ecc, uint8_t *data,
                            uint16_t length)
    bint qrcode_getModule(uint8_t*qrcode_modules, uint8_t qrcode_size, uint8_t x, uint8_t y)
    uint8_t *qrcode_uncompressModule(uint8_t*qrcode_modules, uint8_t qrcode_size)

class VerionError(Exception):
    pass


def getBufferSize(version: int) -> int:
    if version > 40 or version < 1:
        raise VerionError("version should in range 1~40")
    return qrcode_getBufferSize(version)

def getModule(modules, size: int, x: int, y: int) -> int:
    return qrcode_getModule(<uint8_t*> modules, size, x, y)

def uncompressModule(modules, size: uint8_t) -> int:
    uncompressBytes = qrcode_uncompressModule(<uint8_t*> modules, size)
    ret =  PyBytes_FromStringAndSize(<char*> uncompressBytes, size * size)
    free(uncompressBytes)
    return ret

def initBytes(data: bytes, ecc: int = 1):
    # use ECC_MEDIUM by default
    cdef QRCode *qrcode
    cdef uint8_t*qrcodeBytes
    version = 0
    length = len(data)
    table = {
        0: [17, 32, 53, 78, 106, 134, 154, 192, 230, 271, 321, 367, 425, 458, 520, 586, 644, 718, 792, 858, 929, 1003,
            1091, 1171, 1273, 1367, 1465, 1528, 1628, 1732, 1840, 1952, 2068, 2188, 2303, 2431, 2563, 2699, 2809, 2953],
        1: [14, 26, 42, 62, 84, 106, 122, 152, 180, 213, 251, 287, 331, 362, 412, 450, 504, 560, 624, 666, 711, 779,
            857, 911, 997, 1059, 1125, 1190, 1264, 1370, 1452, 1538, 1628, 1722, 1809, 1911, 1989, 2099, 2213, 2331],
        2: [11, 20, 32, 46, 60, 74, 86, 108, 130, 151, 177, 203, 241, 258, 292, 322, 364, 394, 442, 482, 509, 565, 611,
            661, 715, 751, 805, 868, 908, 982, 1030, 1112, 1168, 1228, 1283, 1351, 1423, 1499, 1579, 1663],
        3: [7, 14, 24, 34, 44, 58, 64, 84, 98, 119, 137, 155, 177, 194, 220, 250, 280, 310, 338, 382, 403, 439, 461,
            511, 535, 593, 625, 658, 698, 742, 790, 842, 898, 958, 983, 1051, 1093, 1139, 1219, 1273]}
    for idx, cap in enumerate(table[ecc]):
        if cap > length:
            version = idx + 1
            break
    if version == 0:
        raise VerionError("no version fits current data capacity")
    qrcode = <QRCode*> malloc(sizeof(QRCode))
    qrcodeBytes = <uint8_t *> malloc(qrcode_getBufferSize(version))
    qrcode_initBytes(qrcode, qrcodeBytes, version, ecc, data, length)


    modules = PyBytes_FromStringAndSize(<char*> qrcodeBytes, qrcode_getBufferSize(version))
    ret = {'version': version, 'size': qrcode.size, 'ecc': ecc,
           'mode': qrcode.mode, 'mask': qrcode.mask, 'modules': modules}
    free(qrcodeBytes)
    free(qrcode)
    return ret
