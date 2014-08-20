#!/usr/bin/python2.7

#scrape mta lost and found

import requests
import pprint
import json
import sys
import datetime
from bs4 import BeautifulSoup

#make global URL variable so I can use this scraper again
URL = "http://advisory.mtanyct.info/LPUWebServices/CurrentLostProperty.aspx"

#soup the data
def get_data(url):
    response = requests.get(url)
    data = BeautifulSoup(response.text, "xml")
    return data

#set up data structure, get categories and create dict of subcategories
def parse_data(souped_data):

    #make the subcategories dictionary
    def make_dict(souped_category):
        #little bit weird but want a dict of dicts
        subcategories = souped_category.find_all("SubCategory")
        return {subcategory["SubCategory"]: int(subcategory["count"]) for subcategory in subcategories}

    return {category["Category"]: make_dict(category) for category in souped_data("Category")}

#write an output json function
def write_json(data, output):
	with open(output, 'w') as f:
		json.dump(data, f, sort_keys=True, indent=4)

#run it in main, if you give it a filename from command line, save it as such
if __name__ == '__main__':
   	write_json(parse_data(get_data(URL)), "/Users/atmccann/Desktop/mta-lost-found/data/{}.json".format(datetime.date.today()))

