from setuptools import setup, find_packages
from version    import Version


setup(
    name='__NAME__',
    version=Version.get(),
    packages=find_packages(),
    install_requires=[],
)
