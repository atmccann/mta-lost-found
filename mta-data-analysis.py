#!/usr/bin/python2.7

#analyze mta lost and found data

import json
import glob
import re
import sqlite3

#loop through the json files, get names of files
def get_filenames(pattern):
	return glob.glob(pattern)

#for each file, get date make a dict of each day
def make_date_dict(filenames):
	#creating a dict with all the json data, haven't specified categories yet
	dates = dict()
	for filename in filenames:
		#putting r in front so its a raw string, dont want python to do \d stuff to it
		date = re.findall(r'\d{4}-\d{2}-\d{2}',filename)[0]
		data = dict()
		with open(filename, 'r') as f:
			categories = json.load(f)
			#getting values from viewvalues, not keys
			for subcategory_dict in categories.viewvalues():
				#merging one dict into another
				data.update(subcategory_dict)
		#assigns date value to data key (dict keys need to be unique)
		dates[date] = data
	return dates

def load_json(filename):
	subcategories = dict()
	subcategories['date'] = re.findall(r'\d{4}-\d{2}-\d{2}',filename)[0]
	with open(filename, 'r') as f:
		categories = json.load(f)
		for subcategory in categories.viewvalues():
			subcategories.update(subcategory)
	return subcategories

#subcategories is dict keyed by subcategory, db is the sql "connection" object
def update_database(subcategories, db):
	#create tuple to get date
	date = (subcategories['date'],)
	#check whether table 'lostfound' exists, if it doesn't create it
	#check whether this date is already in database, if yes exit
	c = db.execute('SELECT * FROM lostfound WHERE date = ?;', date)
	#check for subcategories that aren't in database
	if c.fetchone() is not None:
		return
	#t is a list of rows of the query, which is the column names
	t = db.execute('PRAGMA table_info(lostfound);')
	#check every category against list of columns, insert if doesn't exist
	columns = [c[1] for c in t.fetchall()] 
	#loop over subcategories, for each 
	for subcategory in subcategories:
		#test if subcategory string is in columns, if not create new column
		if subcategory not in columns:
			#alter table or add columns, constrain to integers and 0 if it's null 
			db.execute('ALTER TABLE lostfound ADD COLUMN ? integer NOT NULL DEFAULT 0;', (subcategory, ))
	#all subcategories exist, now add data for all of them




#write an output json function
def write_json(data, output):
	with open(output, 'w') as f:
		json.dump(data, f, sort_keys=True, indent=4)

#for each day, get intial value of each subcategory, make another dict


#save those values

#get difference in days 

#compute change in subcategories for each day

#build new data structure with top 10 categories and delta

#find 10 categories that changed the most

#run it in main, if you give it a filename from command line, save it as such
if __name__ == '__main__':
	conn = sqlite3.connect('lostfound.db')
	for f in get_filenames('data/*.json'): 
		update_database(load_json(f), conn)

