# cython: language_level=3

# SPDX-FileCopyrightText: © 2020 The cython-linux-usbmon Authors
# SPDX-License-Identifier: Apache-2.0

from libc.stdint cimport int8_t, int32_t, int64_t, uint8_t, uint16_t, uint32_t, uint64_t

ctypedef struct mon_fetch_arg:
    uint32_t *offvec
    uint32_t nfetch
    uint32_t nflush

ctypedef struct usbmon_packet:
    uint64_t id
    uint8_t type
    uint8_t xfer_type
    uint8_t epnum
    uint8_t devnum
    uint16_t busnum
    int8_t flag_steu
    int8_t flag_data
    int64_t ts_sec
    int32_t ts_usec
    int32_t status
    uint32_t length
    uint32_t len_cap
    uint8_t setup[8]
    int32_t interval
    int32_t start_frame
    int32_t xfer_flags
    int32_t ndesc
