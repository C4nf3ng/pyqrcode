from setuptools import setup, find_packages
from distutils.extension import Extension
with open("README.md", "r", encoding="utf-8") as fh:
    long_description = fh.read()

setup(
ext_modules = [
    Extension(name="pyqrcode",
              sources=["wrapper.pyx",
                       "qrcode.c",
                       ],
              language="c",
              extra_compile_args=["-Wall", "-I/usr/local/include"],
              extra_link_args=["-L/usr/local/lib"],
              )
    ],
name="pyqrcode",
install_requires=['cython'],
version='0.0.1',
packages=find_packages(),
author='C4nf3ng',
license='GNU General Public License v3.0',
description='A python binding for https://github.com/ricmoo/QRCode with some modification',
url = 'https://github.com/C4nf3ng/pyqrcode',
long_description=long_description,
long_description_content_type="text/markdown",

)