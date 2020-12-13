# cython: language_level=3

# SPDX-FileCopyrightText: © 2020 The cython-linux-usbmon Authors
# SPDX-License-Identifier: Apache-2.0

from libc.errno cimport errno
from libc.stdint cimport uint8_t, uint32_t
from libc.stdlib cimport free, malloc
from posix.ioctl cimport ioctl
from posix.mman cimport mmap, munmap, MAP_FAILED, MAP_PRIVATE, PROT_READ

cimport linux_usbmon_packet  # noqa: F401
from linux_usbmon_packet cimport mon_fetch_arg, usbmon_packet
# These are calculated from the definition provided by the Linux kernel source code, and
# necessary to perform syscalls.
#
# Note that since ioctl(3p) uses `int` rather than `unsigned long`, we use the negative
# value for MFETCH.
#
# Replace these with an include of linux/usb/mon.h once the UAPI header is widely
# available.
MON_IOCQ_RING_SIZE = 37381
MON_IOCX_MFETCH = -1072655865

USBMON_PACKET_FIELDS_NAMES = (
  'id',
  'type',
  'xfer_type',
  'epnum',
  'devnum',
  'busnum',
  'flag_steu',
  'flag_data',
  'ts_sec',
  'ts_usec',
  'status',
  'length',
  'len_cap',
  'setup',
  'interval',
  'start_frame',
  'xfer_flags',
  'ndesc',
)


cdef class UsbmonPkt:
    cdef usbmon_packet *_ptr
    cdef bint ptr_owner

    def __cinit__(self):
        self.ptr_owner = False

    def __dealloc__(self):
        if self._ptr is not NULL and self.ptr_owner is True:
            free(self._ptr)
            self._ptr = NULL

    def __str__(self):
        """Short info"""
        return f"<usbmon a:{self.address} id:{self.id:08x} p:{self.length}B at {hex(id(self))}>"

    def __repr__(self):
        """Repr alike in dataclasses, but with positional"""
        args = [f'{str(getattr(self, name))}' for name in USBMON_PACKET_FIELDS_NAMES]
        return f"{self.__class__.__name__}({', '.join(args)})"

    def yaml_info(self) -> str:
        try:
            import yaml
            own_dict = {
                self.__class__.__name__: {name: getattr(self, name) for name in USBMON_PACKET_FIELDS_NAMES},
                'payload': b'no payload',
            }
            return yaml.dump(own_dict, Dumper=yaml.Dumper)

        except ImportError:
            return '# no yaml installed'

    @staticmethod
    cdef UsbmonPkt from_ptr(usbmon_packet *_ptr, bint owner=False):
        """Factory function to create UsbmonPkt objects from
        given usbmon_packet pointer.

        Setting ``owner`` flag to ``True`` causes
        the extension type to ``free`` the structure pointed to by ``_ptr``
        when the wrapper object is deallocated."""
        # Call to __new__ bypasses __init__ constructor
        cdef UsbmonPkt wrapper = UsbmonPkt.__new__(UsbmonPkt)
        wrapper._ptr = _ptr
        wrapper.ptr_owner = owner
        return wrapper

    @staticmethod
    cdef UsbmonPkt new_struct():
        """Factory function to create UsbmonPkt objects with
        newly allocated usbmon_packet"""
        cdef usbmon_packet *_ptr = <usbmon_packet *> malloc(sizeof(usbmon_packet))
        if _ptr is NULL:
            raise MemoryError

        _ptr.id = 0
        _ptr.type = 0
        _ptr.xfer_type = 0
        _ptr.epnum = 0
        _ptr.devnum = 0
        _ptr.busnum = 0
        _ptr.flag_steu = 0
        _ptr.flag_data = 0
        _ptr.ts_sec = 0
        _ptr.ts_usec = 0
        _ptr.status = 0
        _ptr.length = 0
        _ptr.len_cap = 0
        _ptr.setup = [0] * 8 # TODO: check if it's correct
        _ptr.interval = 0
        _ptr.start_frame = 0
        _ptr.xfer_flags = 0
        _ptr.ndesc = 0

        return UsbmonPkt.from_ptr(_ptr, owner=True)


    # Extension class properties
    @property
    def id(self) -> int:
        return self._ptr.id if self._ptr is not NULL else None

    @property
    def type(self) -> int:  # uint8_t
        return self._ptr.type if self._ptr is not NULL else None

    @property
    def xfer_type(self) -> int:  # uint8_t
        return self._ptr.xfer_type if self._ptr is not NULL else None

    @property
    def epnum(self) -> int:  # uint8_t
        return self._ptr.epnum if self._ptr is not NULL else None

    @property
    def devnum(self) -> int:  # uint8_t
        return self._ptr.devnum if self._ptr is not NULL else None

    @property
    def busnum(self) -> int:  # uint16_t
        return self._ptr.busnum if self._ptr is not NULL else None

    @property
    def flag_steu(self) -> int:  # int8_t
        return self._ptr.flag_steu if self._ptr is not NULL else None

    @property
    def flag_data(self) -> int:  # int8_t
        return self._ptr.flag_data if self._ptr is not NULL else None

    @property
    def ts_sec(self) -> int:  # int64_t
        return self._ptr.ts_sec if self._ptr is not NULL else None

    @property
    def ts_usec(self) -> int:  # int32_t
        return self._ptr.ts_usec if self._ptr is not NULL else None

    @property
    def status(self) -> int:  # int32_t
        return self._ptr.status if self._ptr is not NULL else None

    @property
    def length(self) -> int:  # uint32_t
        return self._ptr.length if self._ptr is not NULL else None

    @property
    def len_cap(self) -> int:  # uint32_t
        return self._ptr.len_cap if self._ptr is not NULL else None

    @property
    def setup(self) -> str:  # uint8_t
        # FIXME
        return str(self._ptr.setup) if self._ptr is not NULL else None

    @property
    def interval(self) -> int:  # int32_t
        return self._ptr.interval if self._ptr is not NULL else None

    @property
    def start_frame(self) -> int:  # int32_t
        return self._ptr.start_frame if self._ptr is not NULL else None

    @property
    def xfer_flags(self) -> int:  # int32_t
        return self._ptr.xfer_flags if self._ptr is not NULL else None

    @property
    def ndesc(self) -> int:  # int32_t
        return self._ptr.ndesc if self._ptr is not NULL else None

    # computed properties
    @property
    def address(self) -> str:
        return f'{self.busnum}.{self.devnum}.{self.epnum}'


def get_ring_size(fid):
    """Retrieve the usbmon ring buffer size."""

    result = ioctl(fid.fileno(), MON_IOCQ_RING_SIZE)
    if result < 0:
        raise OSError(errno, 'ioctl (MON_IOCQ_RING_SIZE) failed')

    return result

def monitor(fid):
    """Monitor the provided USB controller.

    Args:
      fid: The file object (open for read) for usbmon.

    Yields:
      Pairs of (usbmon_packet, packet_data) as bytes.
    """
    cdef uint32_t nflush = 0
    cdef uint32_t offvec[64]
    cdef mon_fetch_arg fetch
    cdef usbmon_packet *pkt
    cdef UsbmonPkt pypacket

    map_size = get_ring_size(fid)

    cdef uint8_t *usbmon = <uint8_t*>mmap(
        NULL, map_size, PROT_READ, MAP_PRIVATE, fid.fileno(), 0)
    if usbmon == MAP_FAILED:
        raise OSError(errno, 'mmap failed')

    print('\n'.join([
        # logo source: http://patorjk.com/software/taag/#p=display&f=Rectangles&t=cython%20linux%20usbmon%20monitor
        "",
        "             _   _              _ _                        _                                  _ _           ",
        "     ___ _ _| |_| |_ ___ ___   | |_|___ _ _ _ _    _ _ ___| |_ _____ ___ ___    _____ ___ ___|_| |_ ___ ___ ",
        "    |  _| | |  _|   | . |   |  | | |   | | |_'_|  | | |_ -| . |     | . |   |  |     | . |   | |  _| . |  _|",
        "    |___|_  |_| |_|_|___|_|_|  |_|_|_|_|___|_,_|  |___|___|___|_|_|_|___|_|_|  |_|_|_|___|_|_|_|_| |___|_|  ",
        "        |___|                                                                                               ",
        "",
        "    Example USB monitor implemented with cython-linux-usbmon",
        "",
    ]))

    try:
        while True:
            # This should be optimized, just assume it's a decent value for now.
            fetch.offvec = offvec
            fetch.nfetch = 64
            fetch.nflush = nflush

            res = ioctl(fid.fileno(), MON_IOCX_MFETCH, &fetch)
            if res < 0:
                raise OSError(errno, 'ioctl (MON_IOCX_MFETCH) failed')
            nflush = fetch.nfetch
            for i in range(nflush):
                pkt_offset = offvec[i]
                pkt = <usbmon_packet*>&usbmon[pkt_offset]
                if pkt.type == ord('@'):
                    continue
                data_length = pkt.len_cap
                if data_length > 0:
                    data_start = pkt_offset + 64
                    data_end = pkt_offset + 64 + data_length
                    data = bytes(usbmon[data_start:data_end])
                else:
                    data = None

                pypacket = UsbmonPkt.from_ptr(pkt)
                yield pypacket, data

    except KeyboardInterrupt:
        pass
    finally:
        munmap(usbmon, map_size)
