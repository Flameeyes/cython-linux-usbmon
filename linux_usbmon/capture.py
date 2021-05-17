#!/usr/bin/env python3
#
# SPDX-FileCopyrightText: © 2020 The cython-linux-usbmon Authors
# SPDX-License-Identifier: Apache-2.0
"""Minimal implementation of usbmon capturing in Python.
"""

import sys
from typing import BinaryIO, Optional

import click
import usbmon.addresses
from usbmon.capture.usbmon_mmap import UsbmonMmapPacket
from usbmon.tools import _utils

import linux_usbmon


@click.command()
@click.option(
    "--device-address",
    help=(
        "Device address (busnum.devnum) of the device to capture."
        " Only packets with source or destination matching this prefix"
        " will be printed out."
    ),
    type=_utils.DeviceAddressType(),
)
@click.argument(
    "usbmon-device",
    type=click.File(mode="rb"),
    required=True,
)
def main(
    *, device_address: Optional[usbmon.addresses.DeviceAddress], usbmon_device: BinaryIO
):
    if sys.version_info < (3, 7):
        raise Exception("Unsupported Python version, please use at least Python 3.7.")

    endianness = ">" if sys.byteorder == "big" else "<"

    for raw_packet, payload in linux_usbmon.monitor(usbmon_device):
        packet = UsbmonMmapPacket(endianness, raw_packet, payload)
        if device_address is None or packet.address.device_address == device_address:
            print(packet)


if __name__ == "__main__":
    main()
