# -*- coding: utf-8 -*-

'''
Configure logger
'''
import logging
from pathlib import Path

Path("/var/log/secdevops").mkdir(parents=True, exist_ok=True)
logging.basicConfig(
    filename="/var/log/secdevops/cloudlab.log",
    level=logging.DEBUG,
    format="[%(asctime)s] [%(filename)s:%(lineno)s - %(funcName)5s() - %(processName)s] %(levelname)s - %(message)s"
)
