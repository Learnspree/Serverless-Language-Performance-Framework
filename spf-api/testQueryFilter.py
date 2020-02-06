import unittest
from decimal import *
from getruntime import queryfilter

class TestGetMemoryFromQueryFilter(unittest.TestCase):
    expectedMemoryDefault = Decimal(128)
    expectedMemory = Decimal(512)

    testQueryStringNoMemory = {'state': 'cold'}
    testQueryStringWithMemory = {'memory': '512'}

    def testQueryStringWithNoMemoryKey(self):
        returnedMemory = queryfilter.getMemoryFromQueryString(self.testQueryStringNoMemory)
        self.assertEqual(self.expectedMemoryDefault, returnedMemory)

    def testQueryStringWithMemoryKey(self):
        returnedMemory = queryfilter.getMemoryFromQueryString(self.testQueryStringWithMemory)
        self.assertEqual(self.expectedMemory, returnedMemory)        

if __name__ == '__main__':
    unittest.main()