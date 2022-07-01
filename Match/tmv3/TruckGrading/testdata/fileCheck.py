# from pip import _internal
# _internal.main(['list'])

import pandas as pd
import numpy as np
import json
import pathlib
import os

cmd = 'ls /home/vsts/work/1/s/tmv3/TruckGrading'
os.system(cmd)
try:
    print("starting file 1")
    c_lh = pd.read_csv(pathlib.Path(__file__).parent.parent.parent / "carrier_lane_history/carrier_lane_history.csv", escapechar='\\')
    print("starting file 2")
    cl = pd.read_csv(pathlib.Path(__file__).parent.parent.parent / "carrier_locations/carrier_locations.csv", escapechar='\\')
    print("starting file 3")
    c = pd.read_csv(pathlib.Path(__file__).parent.parent.parent / "carrier_matching/carrier_matching.csv", escapechar='\\')
    print("starting file 4")
    ci = pd.read_csv(pathlib.Path(__file__).parent.parent.parent / "proper_city/proper_city.csv", escapechar='\\')
    print("starting file 5")
    sd_1 = pd.read_csv(pathlib.Path(__file__).parent.parent.parent / "sonar_data_1/sonar_data_1.csv", escapechar='\\')
    print("starting file 6")
    sd_2 = pd.read_csv(pathlib.Path(__file__).parent.parent.parent / "sonar_data_2/sonar_data_2.csv", escapechar='\\')
    print("starting file 7")
    sd_3 = pd.read_csv(pathlib.Path(__file__).parent / "sonar_data_3.csv")
    print("starting file 8")
    t = pd.read_csv(pathlib.Path(__file__).parent.parent.parent / "transcore_market_zone/transcore_market_zone.csv", escapechar='\\')
    print(" (งツ)ว files loaded without error (งツ)ว ")
except Exception as err:
    print("One of the files won't load D: ")
    print(str(err))