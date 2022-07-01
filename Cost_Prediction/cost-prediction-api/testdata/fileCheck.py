# from pip import _internal
# _internal.main(['list'])

import pandas as pd
import numpy as np
import json
import pathlib
import os

cmd = f"ls {pathlib.Path(__file__).parent.parent}"
os.system(cmd)
try:
    print("starting file 1")
    a2m = pd.read_csv(pathlib.Path(__file__).parent.parent  / "inference-data/airport_to_market/airport_to_market.csv", escapechar='\\')
    print("starting file 2")
    cpsd = pd.read_csv(pathlib.Path(__file__).parent.parent  / "inference-data/cp_sonar_data/cp_sonar_data.csv", escapechar='\\')
    print("starting file 3")
    lcpm = pd.read_csv(pathlib.Path(__file__).parent.parent  / "inference-data/load_cost_per_mile/load_cost_per_mile.csv", escapechar='\\')
    print("starting file 4")
    cd = pd.read_csv(pathlib.Path(__file__).parent.parent  / "inference-data/city_data/loc_city.csv", escapechar='\\')
    print("starting file 5")
    md = pd.read_csv(pathlib.Path(__file__).parent.parent  / "inference-data/market_data/market_data.csv", escapechar='\\')
    print("----------------------------------------")
    print(" (งツ)ว files loaded without error (งツ)ว ")
except Exception as err:
    print("One of the files won't load D: ")
    print(str(err))
    raise err