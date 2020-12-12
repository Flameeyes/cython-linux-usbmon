# SPDX-FileCopyrightText: © 2020 The cython-linux-usbmon Authors
# SPDX-License-Identifier: Apache-2.0

from typing import BinaryIO, Generator, List, Tuple


def get_ring_size(fid: BinaryIO) -> int: ...


def monitor(fid: BinaryIO) -> Generator[Tuple[UsbmonPkt, bytes], None, None]: ...


class UsbmonPkt:

    def __repr__(self) -> str: ...

    def __str__(self) -> str: ...

    # Extension class properties
    @property
    def id(self) -> int:
        """u64 id; /*  0: URB ID - from submission to callback */"""
        ...

    @property
    def type(self) -> int:
        """unsigned char type; /*  8: Same as text; extensible. */"""
        ...

    @property
    def xfer_type(self) -> int:
        """unsigned char xfer_type; /*    ISO (0), Intr, Control, Bulk (3) */"""
        ...

    @property
    def epnum(self) -> int:  # uint8_t
        """unsigned char epnum; /*     Endpoint number and transfer direction */"""
        ...

    @property
    def devnum(self) -> int:  # uint8_t
        """unsigned char devnum; /*     Device address */"""
        ...

    @property
    def busnum(self) -> int:
        """u16 busnum; /* 12: Bus number */"""
        ...

    @property
    def flag_steu(self) -> int:
        """char flag_setup; /* 14: Same as text */"""
        ...

    @property
    def flag_data(self) -> int:
        """char flag_data; /* 15: Same as text; Binary zero is OK. */"""
        ...

    @property
    def ts_sec(self) -> int:
        """s64 ts_sec; /* 16: gettimeofday */"""
        ...

    @property
    def ts_usec(self) -> int:
        """s32 ts_usec; /* 24: gettimeofday */"""
        ...

    @property
    def status(self) -> int:
        """int status; /* 28: */"""
        ...

    @property
    def length(self) -> int:
        """unsigned int length; /* 32: Length of data (submitted or actual) */"""
        ...

    @property
    def len_cap(self) -> int:
        """unsigned int len_cap; /* 36: Delivered length */"""
        ...

    @property
    def setup(self) -> List[int]:
        """union { /* 40: */
            unsigned char setup[SETUP_LEN]; /* Only for Control S-type */
            struct iso_rec { /* Only for ISO */
                int error_count;
                int numdesc;
            } iso;
        } s;"""
        ...

    @property
    def interval(self) -> int:
        """int interval; /* 48: Only for Interrupt and ISO */"""
        ...

    @property
    def start_frame(self) -> int:
        """int start_frame; /* 52: For ISO */"""
        ...

    @property
    def xfer_flags(self) -> int:
        """unsigned int xfer_flags; /* 56: copy of URB's transfer_flags */"""
        ...

    @property
    def ndesc(self) -> int:
        """unsigned int ndesc; /* 60: Actual number of ISO descriptors */"""
        ...

    @property
    def address(self) -> str:
        """USB address as a string"""
        ...
