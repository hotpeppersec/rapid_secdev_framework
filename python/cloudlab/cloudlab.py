# -*- coding: utf-8 -*-

import logging
from pathlib import Path

try:
  from lib.helper_functions import *
except ImportError:
  DEBUG = True


def main():
    '''
    Cloud Lab tester
    '''
    logging.debug('Cloud Lab Test App starting up...')

    ''' see if we are running in docker'''
    check_docker()

    logging.info('Finished execution')
    print('success')


if __name__ =="__main__":
    main()
