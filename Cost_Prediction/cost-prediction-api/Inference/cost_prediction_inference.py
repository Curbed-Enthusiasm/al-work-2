import pickle
import numpy as np
import pandas as pd
from datetime import datetime,timedelta, date

def Parse_City_LatLong(LocationKey,LocCity):
    '''
    input:
        LocationKey - Location Key for requested origin or destination expected in the form "city_12345"
        LocCity - the Loc.City staged dataframe
        
    Returns:
    --------
    CityLatLong: Coordinates for use as origin/destination of load
    
    '''   
    CityLocKey = LocationKey
    if CityLocKey.startswith('city_'):
        CityId = float(CityLocKey.split('_')[1])
    else:
        CityId = float('nan')
    
    CityLatLong = LocCity.loc[LocCity["CITYID"] == CityId,['LATITUDE','LONGITUDE']]

    return CityLatLong

def haversine_lon_np(lon1, lat1, miEast):
    """
    Calculate the longitude for a point x miles away
    using great circle distance on the earth 
    assuming same lattitude
    Returns New Longitude
    """
    lat1, lon1 = map(np.radians, [ lat1, lon1])

    d = miEast/3798
    a = np.sin(
        d / 2.0)**2 / (np.cos(lat1)**2)

    c = 2 * np.arcsin(np.sqrt(a))
    m = lon1 + c * np.sign(miEast)
    m = np.degrees(m)
    return m

def haversine_lat_np(lon1, lat1, miNorth):
    """
    Calculate the lattitude for a point x miles away
    using approx 66.29 miles per degree
    Returns New Lattitude
    """
    m = lat1 + miNorth/66.29
    return m

def haversine_np(lon1, lat1, lon2, lat2):
    """
    Calculate the great circle distance between two points
    on the earth (specified in decimal degrees)
    Returns distance in miles
    """
    lon1, lat1, lon2, lat2 = map(np.radians, [lon1, lat1, lon2, lat2])

    dlon = lon2 - lon1
    dlat = lat2 - lat1

    a = np.sin(
        dlat / 2.0)**2 + np.cos(lat1) * np.cos(lat2) * np.sin(dlon / 2.0)**2

    c = 2 * np.arcsin(np.sqrt(a))
    m = 3798 * c
    return m

def Lane_Sim(LMiles,lat_o,long_o,lat_d,long_d,cand_loads,NYNYO,NYNYD):
    '''
    inputs:
        LMiles - the load mileage from the Rate API
        lat_o - the origin latitude
        long_o - the origin longitude
        lat_d - the dest latitude
        long_d - the dest longitude
        cand_loads - candidate "happy path" loads - dataframe
        
    Returns:
    --------
    vlanecost - the "happy path" arrive historical van cost for that location
    
    '''   
    MaxRadius = 250
    MinRadius = 25
    LoadMileageRatio = 0.1
    HalfLife = 25
    
    cand_loads = cand_loads.loc[cand_loads["NYNYFlagO"] == NYNYO,]
    cand_loads = cand_loads.loc[cand_loads["NYNYFlagD"] == NYNYD,]

    start_date = pd.Timestamp.now()
    end_date7 = pd.Timestamp.now() - timedelta(days=7)
    end_date14 = pd.Timestamp.now() - timedelta(days=14)
    end_date30 = pd.Timestamp.now() - timedelta(days=30)
    end_date60 = pd.Timestamp.now() - timedelta(days=60)

    if LMiles * LoadMileageRatio < MinRadius:
        LoadRadius = MinRadius
    elif LMiles * LoadMileageRatio > MaxRadius:
        LoadRadius = MaxRadius
    else:
        LoadRadius = LMiles * LoadMileageRatio

    OMaxLat = haversine_lat_np(long_o,lat_o,LoadRadius)
    OMinLat = haversine_lat_np(long_o,lat_o,-LoadRadius)
    OMaxLong = haversine_lon_np(long_o,lat_o,LoadRadius)
    OMinLong = haversine_lon_np(long_o,lat_o,-LoadRadius)
    DMaxLat = haversine_lat_np(long_d,lat_d,LoadRadius)
    DMinLat = haversine_lat_np(long_d,lat_d,-LoadRadius)
    DMaxLong = haversine_lon_np(long_d,lat_d,LoadRadius)
    DMinLong = haversine_lon_np(long_d,lat_d,-LoadRadius)


    #mask used to find indices that are for the defined lane and that are in the time frame (in this case, the previous 60 days)
    mask60 = ((cand_loads['PICKUPDAY'] <= start_date) & (cand_loads['PICKUPDAY'] > end_date60) & (cand_loads['ORIGLAT'] <= OMaxLat) & (cand_loads['ORIGLAT'] >= OMinLat) & (cand_loads['DESTLAT'] <= DMaxLat) & (cand_loads['DESTLAT'] >= DMinLat) & (cand_loads['ORIGLONG'] <= OMaxLong) & (cand_loads['ORIGLONG'] >= OMinLong) & (cand_loads['DESTLONG'] <= DMaxLong) & (cand_loads['DESTLONG'] >= DMinLong))
        
        #Set distances for widest group of loads
    for x in cand_loads.loc[mask60].LOADNUMBER:
        cand_loads.loc[cand_loads["LOADNUMBER"] == x,"ODistance"] = haversine_np(long_o,lat_o,float(cand_loads.loc[cand_loads["LOADNUMBER"] == x,"ORIGLONG"]),float(cand_loads.loc[cand_loads["LOADNUMBER"] == x,"ORIGLAT"]))
        cand_loads.loc[cand_loads["LOADNUMBER"] == x,"DDistance"] = haversine_np(long_d,lat_d,float(cand_loads.loc[cand_loads["LOADNUMBER"] == x,"DESTLONG"]),float(cand_loads.loc[cand_loads["LOADNUMBER"] == x,"DESTLAT"]))
        delta = (pd.Timestamp.now() - cand_loads.loc[cand_loads["LOADNUMBER"] == x,"PICKUPDAY"].mode()).dt.days
        if float(delta) <= 7:
            TWeight = 1
        elif float(delta) <= 14:
            TWeight = 0.9
        elif float(delta) <= 21:
            TWeight = 0.8
        elif float(delta) <= 28:
            TWeight = 0.7
        elif float(delta) <= 35:
            TWeight = 0.6
        elif float(delta) <= 42:
            TWeight = 0.5
        elif float(delta) <= 49:
            TWeight = 0.4
        elif float(delta) <= 56:
            TWeight = 0.3
        elif float(delta) <= 63:
            TWeight = 0.2
        elif float(delta) <= 70:
            TWeight = 0.1
        else:
            TWeight = 0.0
        cand_loads.loc[cand_loads["LOADNUMBER"] == x,"TotalWeight"] = TWeight * (.5**(cand_loads.loc[cand_loads["LOADNUMBER"] == x,"ODistance"]/HalfLife) + .5**(cand_loads.loc[cand_loads["LOADNUMBER"] == x,"DDistance"]/HalfLife))/2

        # use the mask to get the load count, average miles, and average cost from the time frame
    ma60count = cand_loads.loc[mask60].COSTPERMILE.count()     #ArriveActualLHLCost.count()
    ma60miles = cand_loads.loc[mask60].LOADMILES.mean()
    if ma60count >= 3 and LMiles >= 300 :
        ma60cost = np.average(cand_loads.loc[mask60].COSTPERMILE, weights= cand_loads.loc[mask60].TotalWeight)  #ArriveActualLHLCost.mean()
    elif ma60count >= 3 and LMiles < 300 :
        ma60cost = np.average(cand_loads.loc[mask60].COSTPERMILE * cand_loads.loc[mask60].LOADMILES, weights= cand_loads.loc[mask60].TotalWeight)  #ArriveActualLHLCost.mean()
    else:
        ma60cost = float('nan')

    #  same as above, but for 30 days
    mask30 = ((cand_loads['PICKUPDAY'] <= start_date) & (cand_loads['PICKUPDAY'] > end_date30) & (cand_loads['ORIGLAT'] <= OMaxLat) & (cand_loads['ORIGLAT'] >= OMinLat) & (cand_loads['DESTLAT'] <= DMaxLat) & (cand_loads['DESTLAT'] >= DMinLat) & (cand_loads['ORIGLONG'] <= OMaxLong) & (cand_loads['ORIGLONG'] >= OMinLong) & (cand_loads['DESTLONG'] <= DMaxLong) & (cand_loads['DESTLONG'] >= DMinLong))
    # use the mask to get the load count, average miles, and average cost from the time frame

    ma30count = cand_loads.loc[mask30].COSTPERMILE.count()      #ArriveActualLHLCost.count()
    ma30miles = cand_loads.loc[mask30].LOADMILES.mean()
    if ma30count >= 3  and LMiles >= 300 :
        ma30cost = np.average(cand_loads.loc[mask30].COSTPERMILE, weights= cand_loads.loc[mask30].TotalWeight)  #ArriveActualLHLCost.mean()
    elif ma30count >= 3  and LMiles < 300 :
        ma30cost = np.average(cand_loads.loc[mask30].COSTPERMILE * cand_loads.loc[mask30].LOADMILES, weights= cand_loads.loc[mask30].TotalWeight)  #ArriveActualLHLCost.mean()
    else:
        ma30cost = float('nan')

    #  same as above, but for 7 days
    mask7 = ((cand_loads['PICKUPDAY'] <= start_date) & (cand_loads['PICKUPDAY'] > end_date7) & (cand_loads['ORIGLAT'] <= OMaxLat) & (cand_loads['ORIGLAT'] >= OMinLat) & (cand_loads['DESTLAT'] <= DMaxLat) & (cand_loads['DESTLAT'] >= DMinLat) & (cand_loads['ORIGLONG'] <= OMaxLong) & (cand_loads['ORIGLONG'] >= OMinLong) & (cand_loads['DESTLONG'] <= DMaxLong) & (cand_loads['DESTLONG'] >= DMinLong))
    # use the mask to get the load count, average miles, and average cost from the time frame

    ma7count = cand_loads.loc[mask7].COSTPERMILE.count()      #ArriveActualLHLCost.count()
    ma7miles = cand_loads.loc[mask7].LOADMILES.mean()
    if ma7count >= 3  and LMiles >= 300 :
        ma7cost = np.average(cand_loads.loc[mask7].COSTPERMILE, weights= cand_loads.loc[mask7].TotalWeight)  #ArriveActualLHLCost.mean()
    elif ma7count >= 3  and LMiles < 300 :
        ma7cost = np.average(cand_loads.loc[mask7].COSTPERMILE * cand_loads.loc[mask7].LOADMILES, weights= cand_loads.loc[mask7].TotalWeight)  #ArriveActualLHLCost.mean()
    else:
        ma7cost = float('nan')


    # same as above, but for 14 days
    mask14 = ((cand_loads['PICKUPDAY'] <= start_date) & (cand_loads['PICKUPDAY'] > end_date14) & (cand_loads['ORIGLAT'] <= OMaxLat) & (cand_loads['ORIGLAT'] >= OMinLat) & (cand_loads['DESTLAT'] <= DMaxLat) & (cand_loads['DESTLAT'] >= DMinLat) & (cand_loads['ORIGLONG'] <= OMaxLong) & (cand_loads['ORIGLONG'] >= OMinLong) & (cand_loads['DESTLONG'] <= DMaxLong) & (cand_loads['DESTLONG'] >= DMinLong))
    # use the mask to get the load count, average miles, and average cost from the time frame
    ma14count = cand_loads.loc[mask14].COSTPERMILE.count()     #ArriveActualLHLCost.count()
    ma14miles = cand_loads.loc[mask14].LOADMILES.mean()
    if ma14count >= 3 and LMiles >= 300 :
        ma14cost = np.average(cand_loads.loc[mask14].COSTPERMILE, weights= cand_loads.loc[mask14].TotalWeight)  #ArriveActualLHLCost.mean()
    elif ma14count >= 3  and LMiles < 300 :
        ma14cost = np.average(cand_loads.loc[mask14].COSTPERMILE * cand_loads.loc[mask14].LOADMILES, weights= cand_loads.loc[mask14].TotalWeight)  #ArriveActualLHLCost.mean()
    else:
        ma14cost = float('nan')

    if np.isnan(ma60cost):

        #  Expand radius 2x for 7 days
        O2MaxLat = haversine_lat_np(long_o,lat_o,3*LoadRadius)
        O2MinLat = haversine_lat_np(long_o,lat_o,-3*LoadRadius)
        O2MaxLong = haversine_lon_np(long_o,lat_o,3*LoadRadius)
        O2MinLong = haversine_lon_np(long_o,lat_o,-3*LoadRadius)
        D2MaxLat = haversine_lat_np(long_d,lat_d,3*LoadRadius)
        D2MinLat = haversine_lat_np(long_d,lat_d,-3*LoadRadius)
        D2MaxLong = haversine_lon_np(long_d,lat_d,3*LoadRadius)
        D2MinLong = haversine_lon_np(long_d,lat_d,-3*LoadRadius)

        mask60double = ((cand_loads['PICKUPDAY'] <= start_date) & (cand_loads['PICKUPDAY'] > end_date60) & (cand_loads['ORIGLAT'] <= O2MaxLat) & (cand_loads['ORIGLAT'] >= O2MinLat) & (cand_loads['DESTLAT'] <= D2MaxLat) & (cand_loads['DESTLAT'] >= D2MinLat) & (cand_loads['ORIGLONG'] <= O2MaxLong) & (cand_loads['ORIGLONG'] >= O2MinLong) & (cand_loads['DESTLONG'] <= D2MaxLong) & (cand_loads['DESTLONG'] >= D2MinLong))
            
            #Set distances for widest group of loads
        for x in cand_loads.loc[mask60double].LOADNUMBER:
            cand_loads.loc[cand_loads["LOADNUMBER"] == x,"ODistance"] = haversine_np(long_o,lat_o,float(cand_loads.loc[cand_loads["LOADNUMBER"] == x,"ORIGLONG"]),float(cand_loads.loc[cand_loads["LOADNUMBER"] == x,"ORIGLAT"]))
            cand_loads.loc[cand_loads["LOADNUMBER"] == x,"DDistance"] = haversine_np(long_d,lat_d,float(cand_loads.loc[cand_loads["LOADNUMBER"] == x,"DESTLONG"]),float(cand_loads.loc[cand_loads["LOADNUMBER"] == x,"DESTLAT"]))
            delta = (pd.Timestamp.now() - cand_loads.loc[cand_loads["LOADNUMBER"] == x,"PICKUPDAY"].mode()).dt.days
            if float(delta) <= 7:
                TWeight = 1
            elif float(delta) <= 14:
                TWeight = 0.9
            elif float(delta) <= 21:
                TWeight = 0.8
            elif float(delta) <= 28:
                TWeight = 0.7
            elif float(delta) <= 35:
                TWeight = 0.6
            elif float(delta) <= 42:
                TWeight = 0.5
            elif float(delta) <= 49:
                TWeight = 0.4
            elif float(delta) <= 56:
                TWeight = 0.3
            elif float(delta) <= 63:
                TWeight = 0.2
            elif float(delta) <= 70:
                TWeight = 0.1
            else:
                TWeight = 0.0
            cand_loads.loc[cand_loads["LOADNUMBER"] == x,"TotalWeight"] = TWeight * (.5**(cand_loads.loc[cand_loads["LOADNUMBER"] == x,"ODistance"]/HalfLife) + .5**(cand_loads.loc[cand_loads["LOADNUMBER"] == x,"DDistance"]/HalfLife))/2

        ma60doublecount = cand_loads.loc[mask60double].COSTPERMILE.count()     #ArriveActualLHLCost.count()
        ma60doublemiles = cand_loads.loc[mask60double].LOADMILES.mean()
        if ma60doublecount >= 3 and LMiles >= 300:
            ma60doublecost = np.average(cand_loads.loc[mask60double].COSTPERMILE, weights= cand_loads.loc[mask60double].TotalWeight)  
        elif ma60doublecount >= 3  and LMiles < 300 :
            ma60doublecost = np.average(cand_loads.loc[mask60double].COSTPERMILE * cand_loads.loc[mask60double].LOADMILES, weights= cand_loads.loc[mask60double].TotalWeight)  
        else:
            ma60doublecost = float('nan')

    else:
        ma60doublecost = float('nan')
        ma60doublecount = float('nan')
        ma60doublemiles = float('nan')

    if ~np.isnan(ma7cost):
        vlanecost = ma7cost
        Expansion = 1
    elif ~np.isnan(ma14cost):
        vlanecost = ma14cost 
        Expansion = 2
    elif ~np.isnan(ma30cost):
        vlanecost = ma30cost 
        Expansion = 3
    elif ~np.isnan(ma60cost):
        vlanecost = ma60cost 
        Expansion = 4
    elif ~np.isnan(ma60doublecost):
        vlanecost = ma60doublecost 
        Expansion = 5
    else:
        vlanecost = float('nan')
        Expansion = float('nan')

    return vlanecost, Expansion


def getSONAR(APIData,LocCity,airport_to_market,cp_sonar_data):
    oCityLocKey = APIData.OriginLocationKey[0].lower()
    dCityLocKey = APIData.DestinationLocationKey[0].lower()
    if oCityLocKey.startswith('city_'):
        oCityId = float(oCityLocKey.split('_')[1])
    else:
        oCityId = float('nan')

    if dCityLocKey.startswith('city_'):
        dCityId = float(dCityLocKey.split('_')[1])
    else:
        dCityId = float('nan')    
    oMarket = LocCity.loc[LocCity["CITYID"] == oCityId,'MARKETAREAID'].values[0]
    dMarket = LocCity.loc[LocCity["CITYID"] == dCityId,'MARKETAREAID'].values[0]

    oAirport = airport_to_market.loc[airport_to_market["MARKETAREAID"]==oMarket,'AIRPORTCODE'].values[0]
    dAirport = airport_to_market.loc[airport_to_market["MARKETAREAID"]==dMarket,'AIRPORTCODE'].values[0]

    if APIData.LoadTypeId[0] == 1:
        oOTRI = cp_sonar_data.loc[cp_sonar_data["AIRPORTCODE"]==oAirport,'VOTRI']
        dOTRI = cp_sonar_data.loc[cp_sonar_data["AIRPORTCODE"]==dAirport,'VOTRI']
    else:
        oOTRI = cp_sonar_data.loc[cp_sonar_data["AIRPORTCODE"]==oAirport,'ROTRI'].combine_first(cp_sonar_data.loc[cp_sonar_data["AIRPORTCODE"]==oAirport,'VOTRI'])
        dOTRI = cp_sonar_data.loc[cp_sonar_data["AIRPORTCODE"]==dAirport,'ROTRI'].combine_first(cp_sonar_data.loc[cp_sonar_data["AIRPORTCODE"]==dAirport,'VOTRI'])

    return oOTRI, dOTRI


def NYNYFromCity (ctyid,LocCity):
    CityLocKey = ctyid
    if CityLocKey.startswith('city_'):
        CityId = float(CityLocKey.split('_')[1])
    else:
        CityId = float('nan')

    Market = LocCity.loc[LocCity["CITYID"] == CityId,'MARKETAREAID'].values[0]
    if Market is not None:
        if Market.lower() == 'ny_brn':
            rtrn = 1
        else:
            rtrn = 0
    else:
        rtrn = 0
    return rtrn


def ControlFunc(InputData,LocCity,airport_to_market,cp_sonar_data,load_cost_per_mile,model,DATData):
    OrigLocKey = InputData.OriginLocationKey[0].lower()
    DestLocKey =InputData.DestinationLocationKey[0].lower()
    LdMileage = InputData.Miles[0]
    LdType = InputData.LoadTypeCode[0]

    TestDATData = DATData['TRUCKTYPE']
    TestLoadDate = InputData['LoadDate']

    OLoc = Parse_City_LatLong(OrigLocKey,LocCity)
    DLoc = Parse_City_LatLong(DestLocKey,LocCity)
    OLat = float(OLoc['LATITUDE'])
    OLong = float(OLoc['LONGITUDE'])
    DLat = float(DLoc['LATITUDE'])
    DLong = float(DLoc['LONGITUDE'])
    load_cost_per_mile['NYNYFlagO'] = np.where(load_cost_per_mile['ORIGINMARKET'].str.lower() == 'brooklyn', 1, 0)
    load_cost_per_mile['NYNYFlagD'] = np.where(load_cost_per_mile['DESTINATIONMARKET'].str.lower() == 'brooklyn', 1, 0)
    LoadFromNYNY = NYNYFromCity(OrigLocKey, LocCity) 
    LoadToNYNY = NYNYFromCity(DestLocKey, LocCity) 
    if LdType == 'R':
        ReeferFlag = 1
        SpotFuelSurcharge = 0.68
    else:
        ReeferFlag = 0
        SpotFuelSurcharge = 0.64
    ExpansionResults = Lane_Sim(LdMileage,OLat,OLong,DLat,DLong,load_cost_per_mile, LoadFromNYNY, LoadToNYNY)
    HappyPathCost = ExpansionResults[0]
    MAExpansion = ExpansionResults[1]


    #SONAR = getSONAR(InputData,LocCity,airport_to_market,cp_sonar_data)

    d = {'IsReefer':[ReeferFlag],'Expansion':[MAExpansion],'IsWeekend':[0]}
    inf = pd.DataFrame(data=d)

    if  ~np.isnan(HappyPathCost):
        PredictedCosts = model.predict(inf)
    else:
        PredictedCosts = float('nan')

    if LdMileage < 300 and LdMileage > 0 and PredictedCosts > 0:

        LinehaulTotal = PredictedCosts * HappyPathCost
        LinehaulPerMile = PredictedCosts * HappyPathCost/LdMileage
        FSCTotal = SpotFuelSurcharge * LdMileage
        FSCPerMile = SpotFuelSurcharge
        TestConfidenceLevel = 'Very High'
        rdict = {'LinehaulTotal':[LinehaulTotal[0]],'LinehaulPerMile':[LinehaulPerMile[0]],'FSCTotal':[FSCTotal],'FSCPerMile':[FSCPerMile],'ConfidenceLevel':TestConfidenceLevel}
        rdf = pd.DataFrame(data = rdict)
    elif LdMileage >= 300 and PredictedCosts > 0:

        LinehaulTotal = PredictedCosts * HappyPathCost * LdMileage
        LinehaulPerMile = PredictedCosts * HappyPathCost
        FSCTotal = SpotFuelSurcharge * LdMileage
        FSCPerMile = SpotFuelSurcharge
        TestConfidenceLevel = 'Very High'
        rdict = {'LinehaulTotal':[LinehaulTotal[0]],'LinehaulPerMile':[LinehaulPerMile[0]],'FSCTotal':[FSCTotal],'FSCPerMile':[FSCPerMile],'ConfidenceLevel':TestConfidenceLevel}
        rdf = pd.DataFrame(data = rdict)
    else:
        rdf = pd.DataFrame(data = {'LinehaulTotal':[None],'LinehaulPerMile':[None],'FSCTotal':[None],'FSCPerMile':[None],'ConfidenceLevel':[None]})

    
    return rdf