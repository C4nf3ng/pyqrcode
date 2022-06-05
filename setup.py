from setuptools import setup, find_packages
from distutils.extension import Extension
from Cython.Distutils import build_ext

setup(
cmdclass = {'build_ext': build_ext},
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
description='A python binding for https://github.com/ricmoo/QRCode with some modification',
)