# -*- coding: utf-8 -*-

import logging
from pathlib import Path



def check_docker():
    '''
    Decide if we are running in a Docker Container
    '''
    if not "/.dockerenv":
        print('NOT RUNNING IN DOCKER CONTAINER')
        logging.debug('NOT RUNNING IN DOCKER CONTAINER')
        print('There may be issues with functionality.')
        return False
    else:
        logging.debug('We are running in docker container')
        print('We are running in docker container')
        return True

