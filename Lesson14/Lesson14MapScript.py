##TheScriptLadies Nadine Drigo and Amy Gex
## 26 Jan 2017

##Import modules
from twython import TwythonStreamer
import string, json, pprint
import urllib
from datetime import datetime
from datetime import date
from time import *
import string, os, sys, subprocess, time
import psycopg2
import time
import folium
import pprint

##Connect to database table created from main script "Lesson14Script" and retrieve data
try:
    con = psycopg2.connect("dbname=lesson14 user=user password=user" )
    cur = con.cursor()
    print "Connected to database"
except:
    print "oops error"    

cur = con.cursor()
cur.execute("""SELECT * from tweets""")
values = cur.fetchall()


## Function to retrieve the latitude, longitude, and tweet text from the database table 
def map_list(l):
    info = []
    for row in l:
        lat = float(row[3])
        lon = float(row[4])
        text = row[5]
        info += [[lat, lon, text]]
    return (info)
    
mapCoord = map_list(values)  
   
   
##Create a map using data pulled from above function  
map_tweet = folium.Map(location=[45.372, -121.6972], zoom_start=2,
                   tiles='Stamen Terrain')
map_tweet.create_map(path='Holiday_tweets.html')

for i in range(len(mapCoord)):
    map_tweet.simple_marker([mapCoord[i][0],mapCoord[i][1]], popup=mapCoord[i][2])
map_tweet.create_map(path='Holiday_tweets.html')
    

