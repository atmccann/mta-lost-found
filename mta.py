#!/usr/bin/python2.7

#scrape mta lost and found

import requests
import pprint
import json
import sys
import datetime
import time
import os.path
from bs4 import BeautifulSoup

#make global URL variable so I can use this scraper again
URL = "http://advisory.mtanyct.info/LPUWebServices/CurrentLostProperty.aspx"

#soup the data
def get_data(url):
    #see what time it is, save the time, see if it's been 1 minute
    one_minute = datetime.timedelta(minutes=1)
    #have to use datetime.datetime b/c datetime is also the class in the datetime module
    startime = datetime.datetime.utcnow()
    while (datetime.datetime.utcnow() - startime) < one_minute:
        try:
            response = requests.get(url)
            break
        except requests.exceptions.RequestException as e:
            print >> sys.stderr, e
            #let it sleep for 1 second so it doesnt run a zillion times
            time.sleep(1)
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
    output = "/Users/atmccann/Desktop/mta-lost-found/data/{}.json".format(datetime.date.today())
    #check to see if file exists, if it does already then pass
    if os.path.exists(output):
        sys.exit(0)
    else:
        write_json(parse_data(get_data(URL)), output)

