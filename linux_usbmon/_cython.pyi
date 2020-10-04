# SPDX-FileCopyrightText: © 2020 The cython-linux-usbmon Authors
# SPDX-License-Identifier: Apache-2.0

from typing import BinaryIO, Generator, Tuple

def get_ring_size(fid: BinaryIO) -> int: ...

def monitor(fid: BinaryIO) -> Generator[Tuple[bytes, bytes], None, None]: ...
