### This file builds all the restaurant scrapers ##################################################################################################################

from bs4 import BeautifulSoup as bs
import re
from selenium import webdriver
from selenium.common.exceptions import TimeoutException
from selenium.common.exceptions import NoSuchElementException
from selenium.common.exceptions import ElementNotInteractableException
from selenium.common.exceptions import ElementClickInterceptedException
from selenium.webdriver.common.action_chains import ActionChains
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
import time
import random


class scrape_construct:
    def __init__(self, service, chrome_options):
        self.service = service
        self.chrome_options = chrome_options

    
    def subway_CA(self):
        ### Request the webpage ##############################################################################################################
        url = "https://restaurants.subway.com/canada"
        browser = webdriver.Chrome(service=self.service, options=self.chrome_options)
        browser.execute_script("Object.defineProperty(navigator, 'webdriver', {get: () => undefined})") 
        browser.get(url)

        # Get the original window handle as we will need to go back to this page multiple times
        window_province = browser.current_window_handle

        # Set up empty lists to store the data that we will scrape
        raw_text = []
        province = []
        city = []
        address = []
        postcode = []
        row_index = 0

        # Set up a function to check the lengths of our lists and make sure they are equal upon return. This way we can ensure our pd.DataFrame is the same length
        def equal_list():
            # Since province is the first to get a value, the others can't possily have longer length. So don't bother checking if already the same.
            if len(province) > 0 and (len(province) != len(postcode)): 
                if len(province) != len(postcode):
                    province.pop()
                if len(city) != len(postcode):
                    city.pop()
                if len(raw_text) != len(postcode):
                    raw_text.pop()
                if len(raw_text) != len(postcode):
                    address.pop()

        ### Starting in the province/territories page, scrape data for each entry one by one #################################################
        directory_xpath = '//ul[@class="Directory-listLinks"]'
        list_position = 1
        while True:
            # Set up a flag to break all the way to this outermost loop
            break_outer = False
            try:
                list_xpath = directory_xpath + '/li[position()=' + str(list_position) + ']/a'
                list_element = browser.find_element(By.XPATH, list_xpath)

                # Get and store the province or territory name
                province.append(list_element.get_attribute('innerText').strip())
                
                # Hold ctrl when clicking province/territory to open it in a new tab
                ActionChains(browser).key_down(Keys.CONTROL).click(list_element).key_up(Keys.CONTROL).perform()

                # Get the handle of the new tab and switch to it
                time.sleep(round(random.uniform(0.50, 1.00),2)) 
                window_city = browser.window_handles[1]
                browser.switch_to.window(window_city)
                time.sleep(round(random.uniform(0.50, 1.00),2))

                list_position += 1
            except NoSuchElementException as ex:
                print("Exception thrown within Loop 1 - Try 1", ex)
                browser.quit()
                break
            except ElementNotInteractableException as ex:
                print("Exception thrown within Loop 1 - Try 1", ex)
                browser.quit() 
                break
            except Exception as ex:
                print("Exception thrown within Loop 1 - Try 1", type(ex).__name__, ex)
                browser.quit()
                break   # we use break for our outermost while loop
            
            ### A province or territory may have one or multiple cities listed. Each scenario will give us a different page layout ###########
            # city index position should always be reset for each new province/territory
            city_position = 1
            while True:
                # Check break flag here and if = True, go back to province selection outermost loop
                if break_outer:
                    break
                # content index position should always be reset for each new city
                content_position = 1
                ### multiple cities ##########################################################################################################
                try:
                    city_xpath = directory_xpath + '/li[position()=' + str(city_position) + ']/a'
                    city_element = browser.find_element(By.XPATH, city_xpath)

                    # Append a duplicate province value if this is not the 1st loop count for city
                    if len(province) == len(city):
                        province.append(province[row_index - 1])

                    # Get and store the city name
                    city.append(city_element.get_attribute('innerText').strip())

                    ActionChains(browser).key_down(Keys.CONTROL).click(city_element).key_up(Keys.CONTROL).perform()
                    time.sleep(round(random.uniform(0.50, 1.00),2))
                    window_store = browser.window_handles[2]
                    browser.switch_to.window(window_store)
                    time.sleep(round(random.uniform(0.50, 1.00),2))
                    city_position += 1

                    ### multiple cities + multiple stores ####################################################################################
                    while True:
                        try:
                            content_xpath = '//ul[@class="Directory-listTeasers Directory-row"]/li[position()=' + str(content_position) + ']//div/div/address'
                            content_element = browser.find_element(By.XPATH, content_xpath)
                            content_position += 1
                            start = content_element.get_attribute('innerHTML')
                            soup = bs(start, features='lxml')
                            raw = soup.get_text().strip()

                            # Append the same province and city value to their respective list if they are the same size as address
                            # Basically creating our "next row"
                            if len(province) == len(address):
                                province.append(province[row_index - 1])
                                city.append(city[row_index - 1])

                            # strip away the CA abbreviation at the end 
                            raw_text.append(raw[:-2].strip())

                            # Get the address -> Get everything up to the last comma which should take out the province and postal code. Then sub out the city
                            comma_pos = len(raw_text[row_index]) - raw_text[row_index][::-1].find(",")
                            x = raw_text[row_index][:comma_pos-1]
                            address.append(re.sub(city[row_index], "", x).strip())

                            # Get the postal code by taking the last 7 characters
                            postcode.append(raw_text[row_index][-7:])

                            # Increase the row_index
                            row_index += 1

                        except NoSuchElementException as ex: # This will trigger for single store scenario or when multiple stores exceed index
                            ### multiple cities + Single store ################################################################################
                            try:
                                address_xpath = '//address[@id="address"]'
                                address_element = browser.find_element(By.XPATH, address_xpath)
                                start = address_element.get_attribute('innerHTML')
                                soup = bs(start, features='lxml')
                                raw = soup.get_text().strip()    

                                raw_text.append(raw[:-2].strip())           

                                # Get the address
                                comma_pos = len(raw_text[row_index]) - raw_text[row_index][::-1].find(",")
                                x = raw_text[row_index][:comma_pos-1]
                                address.append(re.sub(city[row_index], "", x).strip())

                                # Get the postal code
                                postcode.append(raw_text[row_index][-7:])

                                # Increase the row_index
                                row_index += 1

                                # Since it is single store, this city is done with so we need to break back into city selection loop and tab
                                browser.close()
                                browser.switch_to.window(window_city)
                                break

                            except NoSuchElementException as ex: # This will trigger when multiple stores exceed index
                                # break out of the content loop and back into the city selection loop
                                browser.close()
                                browser.switch_to.window(window_city)
                                break
                            except Exception as ex:
                                print("Exception thrown within Loop 3 - Try 2", type(ex).__name__, ex)
                                browser.quit()
                                equal_list()
                                return raw_text, province, city, address, postcode
                            
                        except Exception as ex:
                            print("Exception thrown within Loop 3 - Try 1", type(ex).__name__, ex)
                            browser.quit()
                            equal_list()
                            return raw_text, province, city, address, postcode

                except NoSuchElementException as ex: # This will trigger for single city scenario or when multiple cities exceed index
                    ### Single city #########################################################################################################
                    while True:
                        try:
                            content_xpath = '//ul[@class="Directory-listTeasers Directory-row"]/li[position()=' + str(content_position) + ']//div/div/address'
                            content_element = browser.find_element(By.XPATH, content_xpath)
                            content_position += 1
                            start = content_element.get_attribute('innerHTML')
                            soup = bs(start, features='lxml')
                            raw = soup.get_text().strip()

                            raw_text.append(raw[:-2].strip())
                            
                            # Append a province value if this is NOT the first loop count
                            if len(province) == len(address):
                                province.append(province[row_index - 1])
                            
                            # Get the city
                            title_xpath = '//h1[@class="Directory-bannerTitle"]'
                            title_element = browser.find_element(By.XPATH, title_xpath)
                            x = title_element.get_attribute('innerText').strip()
                            city.append(re.split("Locations in", x)[1].strip())

                            # Get the address
                            comma_pos = len(raw_text[row_index]) - raw_text[row_index][::-1].find(",")
                            x = raw_text[row_index][:comma_pos-1]
                            address.append(re.sub(city[row_index], "", x).strip())

                            # Get the postal code
                            postcode.append(raw_text[row_index][-7:])

                            # Increase the row_index
                            row_index += 1
                        
                        except NoSuchElementException as ex: # Triggers when single city or multiple cities exceed index
                            # break back into province/territory selection loop by raising "break_outer" flag so we break immediately in Loop 2 
                            browser.close()
                            browser.switch_to.window(window_province)
                            break_outer = True
                            break
                        except Exception as ex:
                            print("Exception thrown within Loop 4 - Try 1", type(ex).__name__, ex)
                            browser.quit()
                            equal_list()
                            return raw_text, province, city, address, postcode

                except Exception as ex:
                    print("Exception thrown within Loop 2 - Try 1", type(ex).__name__, ex)
                    browser.quit()
                    equal_list()
                    return raw_text, province, city, address, postcode

        equal_list()
        return raw_text, province, city, address, postcode
    

    def kfc_CA(self):
        ### Request the webpage ##############################################################################################################
        url = "https://www.kfc.ca/sitemap"
        browser = webdriver.Chrome(service=self.service, options=self.chrome_options)
        browser.execute_script("Object.defineProperty(navigator, 'webdriver', {get: () => undefined})") 
        browser.get(url)

        raw_text = []

        list_xpath = '//h4[@data-testid="Store"]/following-sibling::div'
        list_position = 1
        while True:
            print(list_position)
            try:
                store_xpath = list_xpath + '/div[position()=' + str(list_position) + ']/a'
                store_element = WebDriverWait(browser, 5).until(EC.presence_of_element_located((By.XPATH, store_xpath)))

                # We are getting Error: element click intercepted. Other element would receive click due to the ACCEPT COOKIES POPUP. 
                # Try scrolling until the element is at the bottom of the page. Then scroll down by the height of the cookie popup x 2 for good measure
                try:
                    store_element.click()
                except ElementClickInterceptedException:
                    ActionChains(browser).scroll_to_element(store_element).perform()   
                    cookie_xpath = '//div[@id="onetrust-group-container"]' 
                    cookie_element = browser.find_element(By.XPATH, cookie_xpath)
                    delta_y = int(cookie_element.rect['height'])
                    ActionChains(browser).scroll_by_amount(0, 2*delta_y).perform()
                    store_element.click()

                list_position += 1

                # Some pages have a 404 error. Maybe the store closed down or something
                try:
                    WebDriverWait(browser, 5).until(EC.presence_of_element_located((By.XPATH, '//div[@class="not-found-container"]')))
                    # If exists, go back to the previous page and continue scraping
                    browser.back()
                    continue
                except:
                    # pass if the 404 error does not exist
                    pass

                content_xpath = '//div[@class="store-address"]'
                content_element = WebDriverWait(browser, 5).until(EC.presence_of_element_located((By.XPATH, content_xpath)))
                raw_text.append(content_element.get_attribute('innerText').strip())

                browser.back()
            except Exception as ex:
                print(ex)
                return raw_text
            
    
    def kfc_US(self):
        ### Request the webpage ##############################################################################################################
        url = "https://locations.kfc.com/"
        browser = webdriver.Chrome(service=self.service, options=self.chrome_options)
        browser.execute_script("Object.defineProperty(navigator, 'webdriver', {get: () => undefined})") 
        browser.get(url)

        # Going to click "Accept" for the cookie popup
        cookie_xpath = '//button[@id="onetrust-accept-btn-handler"]'
        cookie_element = WebDriverWait(browser, 5).until(EC.presence_of_element_located((By.XPATH, cookie_xpath)))
        cookie_element.click()
        time.sleep(round(random.uniform(0.50, 1.00),2)) 

        # Get the original window handle as we will need to go back to this page multiple times
        window_state = browser.current_window_handle

        raw_text = []
        state = []
        city = []
        address = []
        postcode = []
        row_index = 0

        # Set up a function to check the lengths of our lists and make sure they are equal upon return. This way we can ensure our pd.DataFrame is the same length
        def equal_list():
            # Since state is the first to get a value, the others can't possily have longer length. So don't bother checking if already the same.
            if len(state) > 0 and (len(state) != len(postcode)): 
                if len(state) != len(postcode):
                    state.pop()
                if len(city) != len(postcode):
                    city.pop()
                if len(raw_text) != len(postcode):
                    raw_text.pop()
                if len(raw_text) != len(postcode):
                    address.pop()

        list_xpath = '//ul[@class="Directory-listLinks"]'
        list_position = 1
        while True:
            # Set up a flag to break all the way to this outermost loop
            break_outer = False
            try:
                state_xpath = list_xpath + '/li[position()=' + str(list_position) + ']/a'
                state_element = browser.find_element(By.XPATH, state_xpath)

                state.append(state_element.get_attribute('innerText').strip())

                ActionChains(browser).key_down(Keys.CONTROL).click(state_element).key_up(Keys.CONTROL).perform()
                time.sleep(round(random.uniform(0.50, 1.00),2)) 
                window_city = browser.window_handles[1]
                browser.switch_to.window(window_city)
                time.sleep(round(random.uniform(0.50, 1.00),2)) 

                list_position += 1
            except Exception as ex:
                print("Exception thrown within Loop 1 - Try 1", type(ex).__name__, ex)
                # browser.quit()
                break
            
            # A state may have one or multiple cities listed. Each scenario will give us a different page layout #############################
            city_position = 1
            while True:
                if break_outer:
                    break
                content_position = 1
                ### multiple cities ##########################################################################################################
                try:
                    city_xpath = list_xpath + '/li[position()=' + str(city_position) + ']/a'
                    city_element = browser.find_element(By.XPATH, city_xpath)

                    if len(state) == len(city):
                        state.append(state[row_index - 1])
                    
                    city.append(city_element.get_attribute('innerText').strip())

                    ActionChains(browser).key_down(Keys.CONTROL).click(city_element).key_up(Keys.CONTROL).perform()
                    time.sleep(round(random.uniform(0.50, 1.00),2)) 
                    window_store = browser.window_handles[2]
                    browser.switch_to.window(window_store)
                    time.sleep(round(random.uniform(0.50, 1.00),2)) 
   
                    city_position += 1
                    ### multiple cities + multiple store #####################################################################################
                    while True:
                        try:
                            content_xpath = '//ul[@class="Directory-listTeasers Directory-row"]/li[position()=' + str(content_position) + ']//div/following-sibling::div/address'
                            content_element = browser.find_element(By.XPATH, content_xpath)
                            content_position += 1
                            start = content_element.get_attribute('innerHTML')
                            soup = bs(start, features='lxml')
                            raw = soup.get_text().strip()

                            if len(state) == len(postcode):
                                state.append(state[row_index - 1])
                                city.append(city[row_index - 1])

                            # strip away the US abbreviation at the end
                            raw_text.append(raw[:-2].strip())

                            # Get the address
                            comma_pos = len(raw_text[row_index]) - raw_text[row_index][::-1].find(",")
                            x = raw_text[row_index][:comma_pos-1]
                            address.append(re.sub(city[row_index], "", x).strip())

                            # Zipcode might not be 5 numbers. Use the last comma. Remove state and take everything after
                            postcode.append(raw_text[row_index][comma_pos+3:].strip())

                            row_index += 1
                        except NoSuchElementException as ex:
                            ### multiple cities + Single store ################################################################################
                            try:
                                address_xpath = '//address[@id="address"]'
                                address_element = browser.find_element(By.XPATH, address_xpath)
                                start = address_element.get_attribute('innerHTML')
                                soup = bs(start, features='lxml')
                                raw = soup.get_text().strip()    

                                raw_text.append(raw[:-2].strip())

                                comma_pos = len(raw_text[row_index]) - raw_text[row_index][::-1].find(",")
                                x = raw_text[row_index][:comma_pos-1]
                                address.append(re.sub(city[row_index], "", x).strip())

                                postcode.append(raw_text[row_index][comma_pos+3:].strip())

                                row_index += 1

                                browser.close()
                                browser.switch_to.window(window_city)
                                break
                            except NoSuchElementException as ex:
                                browser.close()
                                browser.switch_to.window(window_city)
                                break
                            except Exception as ex:
                                print("Exception thrown within Loop 3 - Try 2", type(ex).__name__, ex)
                                browser.quit()
                                equal_list()
                                return raw_text, state, city, address, postcode
                        
                        except Exception as ex:
                            print("Exception thrown within Loop 3 - Try 1", type(ex).__name__, ex)
                            browser.quit()
                            equal_list()
                            return raw_text, state, city, address, postcode
                            
                except NoSuchElementException as ex:
                    ### Single City ###########################################################################################################
                    while True:
                        try:
                            content_xpath = '//ul[@class="Directory-listTeasers Directory-row"]/li[position()=' + str(content_position) + ']//div/following-sibling::div/address'
                            content_element = browser.find_element(By.XPATH, content_xpath)
                            content_position += 1
                            start = content_element.get_attribute('innerHTML')
                            soup = bs(start, features='lxml')
                            raw = soup.get_text().strip()

                            raw_text.append(raw[:-2].strip())

                            # Append a province value if this is NOT the first loop count
                            if len(state) == len(postcode):
                                state.append(state[row_index - 1])

                            # Get the city
                            title_xpath = '//h1[@class="DirHero-subTitle"]'
                            title_element = browser.find_element(By.XPATH, title_xpath)
                            x = title_element.get_attribute('innerText').strip()
                            city.append(re.split("Locations in", x)[1].strip())

                            # Get the address
                            comma_pos = len(raw_text[row_index]) - raw_text[row_index][::-1].find(",")
                            x = raw_text[row_index][:comma_pos-1]
                            address.append(re.sub(city[row_index], "", x).strip())

                            # Get the zipcode
                            postcode.append(raw_text[row_index][comma_pos+3:].strip())

                            # Increase the row index
                            row_index += 1
                        except NoSuchElementException as ex:
                            # break back into state selection loop by raising 'break_outer' flag to break twice
                            browser.close()
                            browser.switch_to.window(window_state)
                            break_outer = True
                            break
                        except Exception as ex:
                            print("Exception thrown within Loop 4 - Try 1", type(ex).__name__, ex)
                            browser.quit()
                            equal_list()
                            return raw_text, state, city, address, postcode
                        
                except Exception as ex:
                    print("Exception thrown within Loop 2 - Try 1", type(ex).__name__, ex)
                    browser.quit()
                    equal_list()
                    return raw_text, state, city, address, postcode

        equal_list()
        return raw_text, state, city, address, postcode


    def timhortons_CA(self):
        url = "https://locations.timhortons.ca/en/"
        browser = webdriver.Chrome(service=self.service, options=self.chrome_options)
        browser.execute_script("Object.defineProperty(navigator, 'webdriver', {get: () => undefined})") 
        browser.get(url)

        # Close the cookie popup if exists
        time.sleep(round(random.uniform(0.50, 1.00),2)) 
        try:
            cookie = browser.find_element(By.XPATH, '//div[@id="onetrust-close-btn-container"]/button')
            cookie.click()
            # Give the page time to process that there is no longer a cookie popup.
            time.sleep(round(random.uniform(0.50, 1.00),2)) 
        except:
            pass
        
        window_province = browser.current_window_handle

        raw_text = []
        province = []
        city = []
        address = []
        postcode = []
        row_index = 0
        
        def equal_list():
            # Since province is the first to get a value, the others can't possily have longer length. So don't bother checking if already the same.
            if len(province) > 0 and (len(province) != len(postcode)): 
                if len(province) != len(postcode):
                    province.pop()
                if len(city) != len(postcode):
                    city.pop()
                if len(raw_text) != len(postcode):
                    raw_text.pop()
                if len(raw_text) != len(postcode):
                    address.pop()
        
        directory_xpath = '//ul[@class="sb-directory-list sb-directory-list-states"]'
        list_position = 1
        while True:
            try:
                province_xpath = directory_xpath + '/li[position()=' + str(list_position) + ']/a'
                province_element = browser.find_element(By.XPATH, province_xpath)
                province.append(province_element.get_attribute('innerText').strip())

                ActionChains(browser).key_down(Keys.CONTROL).click(province_element).key_up(Keys.CONTROL).perform()
                time.sleep(round(random.uniform(0.50, 1.00),2))
                window_city = browser.window_handles[1]
                browser.switch_to.window(window_city)
                time.sleep(round(random.uniform(0.50, 1.00),2))
                list_position += 1
            except Exception as ex:
                print("Exception thrown within Loop 1 - Try 1", ex)
                browser.quit()
                break

            city_position = 1
            while True:
                content_position = 1
                ### multiple cities or single city ###########################################################################################################
                try:
                    city_xpath = directory_xpath + '/li[position()=' + str(city_position) + ']/a'
                    city_element = browser.find_element(By.XPATH, city_xpath)

                    ActionChains(browser).key_down(Keys.CONTROL).click(city_element).key_up(Keys.CONTROL).perform()
                    time.sleep(round(random.uniform(0.50, 1.00),2))
                    window_store = browser.window_handles[2]
                    browser.switch_to.window(window_store)
                    time.sleep(round(random.uniform(0.50, 1.00),2))
                    city_position += 1
                
                    ### multiple cities + multiple stores or single store ####################################################################################
                    while True:
                        # Some stores have numbers in place of the city name, sometimes because it really is in the middle of nowhere. 
                        # However, the browser TITLE sometimes will give the city name, so we can use that.
                        try:
                            content_xpath = '//ul[@class="sb-directory-list sb-directory-list-sites"]' + '/li[position()=' + str(content_position) + ']'
                            content_element = browser.find_element(By.XPATH, content_xpath)
                            content_position += 1
                            start = content_element.get_attribute('innerHTML')
                            soup = bs(start, features='lxml')
                            raw = soup.get_text().strip()
   
                            raw_text.append(re.sub("\n", "", raw))
                            raw_text[row_index] = re.sub("Tim Hortons *-", "", raw_text[row_index]).strip()

                            # Append a province value if this is NOT the first loop count
                            if len(province) == len(postcode):
                                province.append(province[row_index - 1])

                            # Get the city
                            title_xpath = '//h1[@class="store-directory-header"]'
                            title_element = browser.find_element(By.XPATH, title_xpath)
                            x = title_element.get_attribute('innerText').strip()
                            y = re.split('CA in', x)
                            z = re.sub(f', {province[row_index]}', '', y[1]).strip()

                            # Check if the city has been replaced by that weird number pattern
                            if re.search("[0-9]+\|[0-9]+", z):
                                store_link_xpath = content_xpath + '/a'
                                store_link_element = browser.find_element(By.XPATH, store_link_xpath)

                                ActionChains(browser).key_down(Keys.CONTROL).click(store_link_element).key_up(Keys.CONTROL).perform()
                                time.sleep(round(random.uniform(0.50, 1.00),2))
                                window_store_link = browser.window_handles[3]
                                browser.switch_to.window(window_store_link)
                                time.sleep(round(random.uniform(0.50, 1.00),2))

                                possible_city = browser.find_element(By.XPATH, '//head/title').get_attribute('innerText').strip()
                                # Check if possible_city starts with tim hortons. If so, it has no city name
                                if possible_city[:10] == 'Tim Horton':
                                    city.append(z)
                                    browser.close()
                                    browser._switch_to.window(window_store)
                                else:
                                    city.append(re.split(",", possible_city)[0].strip())
                                    browser.close()
                                    browser._switch_to.window(window_store)
                            else:
                                city.append(z)

                            # Get the address
                            comma_pos = len(raw_text[row_index]) - raw_text[row_index][::-1].find(",")
                            x = raw_text[row_index][:comma_pos-1]
                            address.append(re.sub(city[row_index], "", x).strip())

                            # Get the postal code
                            postcode.append(raw_text[row_index][-7:])

                            # We want to replace the numbered cities by their actual cities if applicable.
                            if re.search("[0-9]+\|[0-9]+", raw_text[row_index]):
                                raw_text[row_index] = re.sub("[0-9]+\|[0-9]+", city[row_index], raw_text[row_index])

                            # Increase the row_index
                            row_index += 1

                        except NoSuchElementException as ex: # This will trigger when the loop runs out of stores
                            browser.close()
                            browser.switch_to.window(window_city)
                            break
                        except Exception as ex:
                            print("Exception thrown within Loop 3 - Try 1", type(ex).__name__, ex)
                            browser.quit()
                            equal_list()
                            return raw_text, province, city, address, postcode

                except NoSuchElementException as ex: # When we run out of cities and need to break back into province selection
                    browser.close()
                    browser.switch_to.window(window_province)
                    break
                except Exception as ex:
                    print("Exception thrown within Loop 2 - Try 1", type(ex).__name__, ex)
                    browser.quit()
                    equal_list()
                    return raw_text, province, city, address, postcode
            
        equal_list()
        return raw_text, province, city, address, postcode


    def timhortons_US(self):
        url = "https://locations.timhortons.com/en/"
        browser = webdriver.Chrome(service=self.service, options=self.chrome_options)
        browser.execute_script("Object.defineProperty(navigator, 'webdriver', {get: () => undefined})") 
        browser.get(url)

        # Close the cookie popup if exists
        time.sleep(round(random.uniform(0.50, 1.00),2)) 
        try:
            cookie = browser.find_element(By.XPATH, '//div[@id="onetrust-close-btn-container"]/button')
            cookie.click()
            # Give the page time to process that there is no longer a cookie popup.
            time.sleep(round(random.uniform(0.50, 1.00),2)) 
        except:
            pass
        
        window_state = browser.current_window_handle

        raw_text = []
        state = []
        city = []
        address = []
        postcode = []
        row_index = 0
        
        def equal_list():
            # Since state is the first to get a value, the others can't possily have longer length. So don't bother checking if already the same.
            if len(state) > 0 and (len(state) != len(postcode)): 
                if len(state) != len(postcode):
                    state.pop()
                if len(city) != len(postcode):
                    city.pop()
                if len(raw_text) != len(postcode):
                    raw_text.pop()
                if len(raw_text) != len(postcode):
                    address.pop()
        
        directory_xpath = '//ul[@class="sb-directory-list sb-directory-list-states"]'
        list_position = 1
        while True:
            try:
                state_xpath = directory_xpath + '/li[position()=' + str(list_position) + ']/a'
                state_element = browser.find_element(By.XPATH, state_xpath)
                state.append(state_element.get_attribute('innerText').strip())

                ActionChains(browser).key_down(Keys.CONTROL).click(state_element).key_up(Keys.CONTROL).perform()
                time.sleep(round(random.uniform(0.50, 1.00),2))
                window_city = browser.window_handles[1]
                browser.switch_to.window(window_city)
                time.sleep(round(random.uniform(0.50, 1.00),2))
                list_position += 1
            except Exception as ex:
                print("Exception thrown within Loop 1 - Try 1", ex)
                browser.quit()
                break

            city_position = 1
            while True:
                content_position = 1
                ### multiple cities or single city ###########################################################################################################
                try:
                    city_xpath = directory_xpath + '/li[position()=' + str(city_position) + ']/a'
                    city_element = browser.find_element(By.XPATH, city_xpath)

                    ActionChains(browser).key_down(Keys.CONTROL).click(city_element).key_up(Keys.CONTROL).perform()
                    time.sleep(round(random.uniform(0.50, 1.00),2))
                    window_store = browser.window_handles[2]
                    browser.switch_to.window(window_store)
                    time.sleep(round(random.uniform(0.50, 1.00),2))
                    city_position += 1
                
                    ### multiple cities + multiple stores or single store ####################################################################################
                    while True:
                        # The US stores are displayed nicely. There are no numbers replacing cities as far as I can tell
                        try:
                            content_xpath = '//ul[@class="sb-directory-list sb-directory-list-sites"]' + '/li[position()=' + str(content_position) + ']'
                            content_element = browser.find_element(By.XPATH, content_xpath)
                            content_position += 1
                            start = content_element.get_attribute('innerHTML')
                            soup = bs(start, features='lxml')
                            raw = soup.get_text().strip()
   
                            raw_text.append(re.sub("\n", "", raw))
                            raw_text[row_index] = re.sub("Tim Hortons *-", "", raw_text[row_index]).strip()

                            # Append a state value if this is NOT the first loop count
                            if len(state) == len(postcode):
                                state.append(state[row_index - 1])

                            # Get the city
                            title_xpath = '//h1[@class="store-directory-header"]'
                            title_element = browser.find_element(By.XPATH, title_xpath)
                            x = title_element.get_attribute('innerText').strip()
                            y = re.split('Hortons in', x)
                            city.append(re.sub(f', {state[row_index]}', '', y[1]).strip())

                            # Get the address
                            comma_pos = len(raw_text[row_index]) - raw_text[row_index][::-1].find(",")
                            x = raw_text[row_index][:comma_pos-1]
                            address.append(re.sub(city[row_index], "", x).strip())

                            # Zipcode might not be 5 numbers. Find the position of the city. Then move by the length of the city + 2 letters for the state to get the Zipcode
                            city_pos_last = raw_text[row_index].find(city[row_index]) + len(city[row_index])
                            postcode.append(raw_text[row_index][city_pos_last+4:])

                            # Increase the row_index
                            row_index += 1

                        except NoSuchElementException as ex: # This will trigger when the loop runs out of stores
                            browser.close()
                            browser.switch_to.window(window_city)
                            break
                        except Exception as ex:
                            print("Exception thrown within Loop 3 - Try 1", type(ex).__name__, ex)
                            browser.quit()
                            equal_list()
                            return raw_text, state, city, address, postcode

                except NoSuchElementException as ex: # When we run out of cities and need to break back into state selection
                    browser.close()
                    browser.switch_to.window(window_state)
                    break
                except Exception as ex:
                    print("Exception thrown within Loop 2 - Try 1", type(ex).__name__, ex)
                    browser.quit()
                    equal_list()
                    return raw_text, state, city, address, postcode
            
        equal_list()
        return raw_text, state, city, address, postcode
    



