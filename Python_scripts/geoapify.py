# This script uses Geoapify.com to send Geocoding API requests.
# Limit is 3000 requests/day for free

import os
import pandas as pd
import re
import requests
from requests.structures import CaseInsensitiveDict
from openpyxl import load_workbook


key = open('C:\\Users\\Weihan\\PersonalProjects\\FastFoodChains\\Python_scripts\\geoapify_key.txt').read()

class api_construct:
    def __init__(self, apikey):
        self.apikey = apikey

    def subway_coord_old(self, start, stop):
        if os.path.exists('C:\\Users\\Weihan\\PersonalProjects\\FastFoodChains\\Datasets\\Raw\\locations\\subwayCA.xlsx'):
            df = pd.read_excel('C:\\Users\\Weihan\\PersonalProjects\\FastFoodChains\\Datasets\\Raw\\locations\\subwayCA.xlsx', sheet_name='full_address', header=None)
        else:
            print('The excel file specified does not exist in the path')
            return
        
        lat, long = [], []

        for i in range(start, stop):
            address = df[0][i]
            text = re.sub(' ', '%20', address)
            text = re.sub(',', '%2C', text)
            text = re.sub('#', '%23', text)
            text = re.sub('\'', '%27', text)
            text = re.sub('-', '%2D', text)
            text = re.sub('\.', '%2E', text)
            text = re.sub('\(', '%28', text)
            text = re.sub('\)', '%29', text)
            text = re.sub('&', '%26', text)

            url = "https://api.geoapify.com/v1/geocode/search?text=" + text + "&filter=countrycode:ca&limit=1&format=json&apiKey=" + self.apikey

            headers = CaseInsensitiveDict()
            headers["Accept"] = "application/json"

            r = requests.get(url, headers=headers)

            data = r.json()

            try: 
                lat.append(data["results"][0]["lat"])
                long.append(data["results"][0]["lon"])
            except IndexError:
                lat.append(0)
                long.append(0)
            
            print(i)
            print(data["results"][0]["lat"])

        df_lat = pd.DataFrame({'latitude': lat})
        df_long = pd.DataFrame({'longitude': long})

        df_main = pd.read_excel('C:\\Users\\Weihan\\PersonalProjects\\FastFoodChains\\Datasets\\Raw\\locations\\subwayCA.xlsx')

        if pd.isna(df_main['latitude'].idxmax()):
            startrow = 1    # Plus one to account for header
        else:
            startrow = df_main['latitude'].idxmax() + 2    # Plus two (+1 for the next position and +1 to account for header)

        startcol_lat = df_main.columns.get_loc('latitude')
        startcol_long = df_main.columns.get_loc('longitude')

        try:
            existing_data = load_workbook('C:\\Users\\Weihan\\PersonalProjects\\FastFoodChains\\Datasets\\Raw\\locations\\subwayCA.xlsx')
            writer = pd.ExcelWriter('C:\\Users\\Weihan\\PersonalProjects\\FastFoodChains\\Datasets\\Raw\\locations\\subwayCA.xlsx', mode='a', engine="openpyxl", if_sheet_exists='overlay')
            df_lat.to_excel(writer, sheet_name='Sheet1', startcol=startcol_lat, startrow=startrow, header=None, index=False)
            df_long.to_excel(writer, sheet_name='Sheet1', startcol=startcol_long, startrow=startrow, header=None, index=False)
            writer.close()
        except Exception as ex:
            print(ex)

    
    def subway_coord(self, start, stop):
        if os.path.exists('C:\\Users\\Weihan\\PersonalProjects\\FastFoodChains\\Datasets\\Raw\\locations\\subwayCA.xlsx'):
            df = pd.read_excel('C:\\Users\\Weihan\\PersonalProjects\\FastFoodChains\\Datasets\\Raw\\locations\\subwayCA.xlsx', sheet_name='full_address', header=None)
        else:
            print('The excel file specified does not exist in the path')
            return
        
        lat, long = [], []

        for i in range(start, stop):
            address = df[0][i]
            text = re.sub(' ', '%20', address)
            text = re.sub(',', '%2C', text)
            text = re.sub('#', '%23', text)
            text = re.sub('\'', '%27', text)
            text = re.sub('-', '%2D', text)
            text = re.sub('\.', '%2E', text)
            text = re.sub('\(', '%28', text)
            text = re.sub('\)', '%29', text)
            text = re.sub('&', '%26', text)
            print(text)
            url = "https://api.geoapify.com/v1/geocode/search?text=" + text + "&filter=countrycode:ca&limit=1&format=json&apiKey=" + self.apikey

            headers = CaseInsensitiveDict()
            headers["Accept"] = "application/json"

            r = requests.get(url, headers=headers)

            data = r.json()

            try: 
                lat.append(data["results"][0]["lat"])
                long.append(data["results"][0]["lon"])
            except IndexError:
                lat.append(0)
                long.append(0)
            
            print(i)

        df_lat = pd.DataFrame({'latitude': lat})
        df_long = pd.DataFrame({'longitude': long})

        try:
            df_lat.to_excel('C:\\Users\\Weihan\\PersonalProjects\\FastFoodChains\\Datasets\\Raw\\locations\\geo_lat.xlsx', index=False)
            df_long.to_excel('C:\\Users\\Weihan\\PersonalProjects\\FastFoodChains\\Datasets\\Raw\\locations\\geo_long.xlsx', index=False)
        except Exception as ex:
            print(ex)


    def kfcCA_coord(self, start, stop):
        if os.path.exists('C:\\Users\\Weihan\\PersonalProjects\\FastFoodChains\\Datasets\\Raw\\locations\\kfcCA.xlsx'):
            df = pd.read_excel('C:\\Users\\Weihan\\PersonalProjects\\FastFoodChains\\Datasets\\Raw\\locations\\kfcCA.xlsx')
        else:
            print('The excel file specified does not exist in the path')
            return
        
        lat, long = [], []

        for i in range(start, stop):
            address = df['full_address'][i]
            text = re.sub(' ', '%20', address)
            text = re.sub(',', '%2C', text)
            text = re.sub('#', '%23', text)
            text = re.sub('\'', '%27', text)
            text = re.sub('-', '%2D', text)
            text = re.sub('\.', '%2E', text)
            text = re.sub('\(', '%28', text)
            text = re.sub('\)', '%29', text)
            text = re.sub('&', '%26', text)

            url = "https://api.geoapify.com/v1/geocode/search?text=" + text + "&filter=countrycode:ca&limit=1&format=json&apiKey=" + self.apikey

            headers = CaseInsensitiveDict()
            headers["Accept"] = "application/json"

            r = requests.get(url, headers=headers)

            data = r.json()

            try: 
                lat.append(data["results"][0]["lat"])
                long.append(data["results"][0]["lon"])
            except IndexError:
                lat.append(0)
                long.append(0)
            
            print(i)

        df_lat = pd.DataFrame({'latitude': lat})
        df_long = pd.DataFrame({'longitude': long})

        try:
            df_lat.to_excel('C:\\Users\\Weihan\\PersonalProjects\\FastFoodChains\\Datasets\\Raw\\locations\\geo_lat.xlsx', index=False)
            df_long.to_excel('C:\\Users\\Weihan\\PersonalProjects\\FastFoodChains\\Datasets\\Raw\\locations\\geo_long.xlsx', index=False)
        except Exception as ex:
            print(ex)
     

    def kfcUS_coord(self, start, stop):
        if os.path.exists('C:\\Users\\Weihan\\PersonalProjects\\FastFoodChains\\Datasets\\Raw\\locations\\kfcUS.xlsx'):
            df = pd.read_excel('C:\\Users\\Weihan\\PersonalProjects\\FastFoodChains\\Datasets\\Raw\\locations\\kfcUS.xlsx', sheet_name='full_address', header=None)
        else:
            print('The excel file specified does not exist in the path')
            return
        
        lat, long = [], []

        for i in range(start, stop):
            address = df[0][i]
            text = re.sub(' ', '%20', address)
            text = re.sub(',', '%2C', text)
            text = re.sub('#', '%23', text)
            text = re.sub('\'', '%27', text)
            text = re.sub('-', '%2D', text)
            text = re.sub('\.', '%2E', text)
            text = re.sub('\(', '%28', text)
            text = re.sub('\)', '%29', text)
            text = re.sub('&', '%26', text)

            url = "https://api.geoapify.com/v1/geocode/search?text=" + text + "&filter=countrycode:us&limit=1&format=json&apiKey=" + self.apikey

            headers = CaseInsensitiveDict()
            headers["Accept"] = "application/json"

            r = requests.get(url, headers=headers)

            data = r.json()

            try: 
                lat.append(data["results"][0]["lat"])
                long.append(data["results"][0]["lon"])
            except IndexError:
                lat.append(0)
                long.append(0)
            
            print(i)

        df_lat = pd.DataFrame({'latitude': lat})
        df_long = pd.DataFrame({'longitude': long})

        try:
            df_lat.to_excel('C:\\Users\\Weihan\\PersonalProjects\\FastFoodChains\\Datasets\\Raw\\locations\\geo_lat.xlsx', index=False)
            df_long.to_excel('C:\\Users\\Weihan\\PersonalProjects\\FastFoodChains\\Datasets\\Raw\\locations\\geo_long.xlsx', index=False)
        except Exception as ex:
            print(ex)

    
    def timhortonsCA_coord(self, start, stop):
        if os.path.exists('C:\\Users\\Weihan\\PersonalProjects\\FastFoodChains\\Datasets\\Raw\\locations\\timhortonsCA.xlsx'):
            df = pd.read_excel('C:\\Users\\Weihan\\PersonalProjects\\FastFoodChains\\Datasets\\Raw\\locations\\timhortonsCA.xlsx', sheet_name='full_address', header=None)
        else:
            print('The excel file specified does not exist in the path')
            return
        
        lat, long = [], []

        for i in range(start, stop):
            address = df[0][i]
            text = re.sub(' ', '%20', address)
            text = re.sub(',', '%2C', text)
            text = re.sub('#', '%23', text)
            text = re.sub('\'', '%27', text)
            text = re.sub('-', '%2D', text)
            text = re.sub('\.', '%2E', text)
            text = re.sub('\(', '%28', text)
            text = re.sub('\)', '%29', text)
            text = re.sub('&', '%26', text)

            url = "https://api.geoapify.com/v1/geocode/search?text=" + text + "&filter=countrycode:ca&limit=1&format=json&apiKey=" + self.apikey

            headers = CaseInsensitiveDict()
            headers["Accept"] = "application/json"

            r = requests.get(url, headers=headers)

            data = r.json()

            try: 
                lat.append(data["results"][0]["lat"])
                long.append(data["results"][0]["lon"])
            except IndexError:
                lat.append(0)
                long.append(0)
            
            print(i)

        df_lat = pd.DataFrame({'latitude': lat})
        df_long = pd.DataFrame({'longitude': long})

        try:
            df_lat.to_excel('C:\\Users\\Weihan\\PersonalProjects\\FastFoodChains\\Datasets\\Raw\\locations\\geo_lat.xlsx', index=False)
            df_long.to_excel('C:\\Users\\Weihan\\PersonalProjects\\FastFoodChains\\Datasets\\Raw\\locations\\geo_long.xlsx', index=False)
        except Exception as ex:
            print(ex)

    
    def timhortonsUS_coord(self, start, stop):
        if os.path.exists('C:\\Users\\Weihan\\PersonalProjects\\FastFoodChains\\Datasets\\Raw\\locations\\timhortonsUS.xlsx'):
            df = pd.read_excel('C:\\Users\\Weihan\\PersonalProjects\\FastFoodChains\\Datasets\\Raw\\locations\\timhortonsUS.xlsx', sheet_name='full_address', header=None)
        else:
            print('The excel file specified does not exist in the path')
            return
        
        lat, long = [], []

        for i in range(start, stop):
            address = df[0][i]
            text = re.sub(' ', '%20', address)
            text = re.sub(',', '%2C', text)
            text = re.sub('#', '%23', text)
            text = re.sub('\'', '%27', text)
            text = re.sub('-', '%2D', text)
            text = re.sub('\.', '%2E', text)
            text = re.sub('\(', '%28', text)
            text = re.sub('\)', '%29', text)
            text = re.sub('&', '%26', text)

            url = "https://api.geoapify.com/v1/geocode/search?text=" + text + "&filter=countrycode:us&limit=1&format=json&apiKey=" + self.apikey

            headers = CaseInsensitiveDict()
            headers["Accept"] = "application/json"

            r = requests.get(url, headers=headers)

            data = r.json()

            try: 
                lat.append(data["results"][0]["lat"])
                long.append(data["results"][0]["lon"])
            except IndexError:
                lat.append(0)
                long.append(0)
            
            print(i)

        df_lat = pd.DataFrame({'latitude': lat})
        df_long = pd.DataFrame({'longitude': long})

        try:
            df_lat.to_excel('C:\\Users\\Weihan\\PersonalProjects\\FastFoodChains\\Datasets\\Raw\\locations\\geo_lat.xlsx', index=False)
            df_long.to_excel('C:\\Users\\Weihan\\PersonalProjects\\FastFoodChains\\Datasets\\Raw\\locations\\geo_long.xlsx', index=False)
        except Exception as ex:
            print(ex)


# geoapify is not the most accurate online converter, but it gives us the most volume. 
# For the locations that their API cannot return properly, we will give those a value of "0" for both latitude and longitude. Then manually find those.

# test.subway_coord_old(839, 900)
# For some reason, our excel is just not saving, but there is nothing wrong with it. In fact it HAS WORKED FOR SOME ROWS
# We are going to just save the coordinates to a new Excel file instead of trying to append.

# test = api_construct(key)
# test.subway_coord(831, 839)
