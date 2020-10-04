<!--
SPDX-FileCopyrightText: 2019 The cython-linux-usbmon Authors

SPDX-License-Identifier: Apache-2.0
-->

# Linux usbmon in Cython

This repository contains a Cython module and some command line tools
implementing the
[usbmon](https://www.kernel.org/doc/Documentation/usb/usbmon.txt) capture
interface of Linux, through the binary capture API.

## Development

To set up a development environment, you can use the following commands:

```shell
$ git clone https://github.com/Flameeyes/cython-linux-usbmon
$ cd usbmon-tools
$ python3 -m venv venv
$ . venv/bin/activate
$ pip install -e .[dev]  # editable installation
$ pre-commit install
```
