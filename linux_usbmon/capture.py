#!/usr/bin/env python3
#
# SPDX-FileCopyrightText: © 2020 The cython-linux-usbmon Authors
# SPDX-License-Identifier: Apache-2.0
"""Minimal implementation of usbmon capturing in Python.
"""

import sys
from binascii import hexlify
from typing import BinaryIO

import click
import linux_usbmon


@click.command()
@click.option(
    "--address-prefix",
    "-a",
    help=(
        "Prefix match applied to the device address in text format. "
        "Only packets with source or destination matching this prefix "
        "will be printed out."
    ),
    default="",
)
@click.argument(
    "usbmon-device",
    type=click.File(mode="rb"),
    required=True,
)
def main(*, address_prefix: str, usbmon_device: BinaryIO):
    if sys.version_info < (3, 7):
        raise Exception("Unsupported Python version, please use at least Python 3.7.")

    for packet, payload in linux_usbmon.monitor(usbmon_device):
        if packet.address.startswith(address_prefix):
            print(
                packet, repr(packet), hexlify(payload) if payload else "# <no payload>"
            )


if __name__ == "__main__":
    main()
