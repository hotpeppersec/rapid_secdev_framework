import unittest
from foo.bar import bat

class FooBarTestCase(unittest.TestCase):

    def setUp(self):
        self.my_ip1 = '8.8.8.8'


    def tearDown(self):
        del self.my_ip1


    def test_nmap_scan(self):
        self.assertTrue(next(item for item in self.my_scan if item["ip"] == self.my_ip1))


if __name__ == '__main__':
    unittest.main()


"""
__author__ = "Franklin"
__copyright__ = "Copyright 2020"
__credits__ = [""]
__license__ = "None"
__version__ = "1.0.0"
__maintainer__ = "Franklin"
__email__ = ""
__status__ = "Production"
"""
