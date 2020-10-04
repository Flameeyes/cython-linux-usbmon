# -*- coding: utf-8 -*-
#
# SPDX-FileCopyrightText: © 2019 The cython-linux-usbmon Authors
# SPDX-License-Identifier: Apache-2.0

from setuptools import Extension, setup

# Ensure it's present.
import setuptools_scm  # noqa: F401
from Cython.Build import cythonize

setup(
    ext_modules=cythonize(
        [Extension("linux_usbmon._cython", ["src/linux_usbmon.pyx"])]
    ),
)
