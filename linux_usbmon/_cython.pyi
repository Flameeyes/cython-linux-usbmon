# SPDX-FileCopyrightText: © 2020 The cython-linux-usbmon Authors
# SPDX-License-Identifier: Apache-2.0

from typing import BinaryIO, Iterator, Tuple

def get_ring_size(fid: BinaryIO) -> int: ...
def monitor(fid: BinaryIO) -> Iterator[Tuple[bytes, bytes]]: ...
