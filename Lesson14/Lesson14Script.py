#TheScriptLadies Nadine Drigo and Amy Gex
#26 Jan 2017

#Import modules
from twython import TwythonStreamer
import string, json, pprint
import urllib
from datetime import datetime
from datetime import date
from time import *
import string, os, sys, subprocess, time
import psycopg2
import time

##codes to access twitter API. Feel free to enter own 
APP_KEY =  '2Pm7q86eU9m5wcS0BKQufnxoR'
APP_SECRET =  'fpmnLiXbGoc4iTJZEDzXkslHzLVOKRKUwibZ4u3IpGYVwmtMoC'
OAUTH_TOKEN = '824523359622991873-aSTORLzNlpPW8BBA2z9xQ0xicYLrw5z'
OAUTH_TOKEN_SECRET = '4RliS8yQyuXggPMQcBufZO9zMIRXwIqFdHnjNtVMfqz48'

##initiating Twython object. Put own path here
output_file = '/home/user/GeoScripting/TwitterLesson_'+datetime.now().strftime('%Y%m%d-%H%M%S')+'.csv' 

##Connection to database. 
## NOTE: We Connected to pgAdminIII on the virtual box 
##and made a database table BEFOREHAND in order to connect
try:
    con = psycopg2.connect("dbname=lesson14 user=user password=user" )
    cur = con.cursor()
    print "Connected to database"
except:
    print "Oops error, failed to connect"             
       
##Class to process JSON data comming from the twitter stream API. Extract relevant fields
class MyStreamer(TwythonStreamer):
    def on_success(self, data):
        tweet_lat = 0.0
        tweet_lon = 0.0
        tweet_name = ""

        if 'id' in data:
            tweet_id = data['id']
        else:
            tweet_id = 9999999999
            
        if 'text' in data:
            tweet_text = data['text'].encode('utf-8').replace("'", '')
        else:
            tweet_text = "NaN"
            
        if 'coordinates' in data:    
            geo = data['coordinates']
        else:
            geo = None
 
        if not geo is None:
            latlon = geo['coordinates']
            tweet_lon = latlon[0]
            tweet_lat= latlon[1]
        else:
            tweet_lon = 0
            tweet_lat = 0
            
        if 'user' in data:
            users = data['user']
            tweet_name = users['screen_name']
            tweet_lang = users['lang']
            
        if 'created_at' in data:
            dt = data['created_at']
            tweet_datetime = datetime.strptime(dt, '%a %b %d %H:%M:%S +0000 %Y')
        
        #print string_to_write
        tweet_text.replace("'", '')
        
       
       ##Insert tweets into database table named tweets with the row headings defined below
        if tweet_lat != 0:
            insert_query = r"""
                INSERT INTO public.tweets VALUES(
                {id}, '{name}', '{time}', '{latitude}', '{longitude}','{text}','{language}')
                """.format( id = str(tweet_id),
                            name = str(tweet_name),
                            time = str(tweet_datetime),
                            latitude = str(tweet_lat),
                            longitude = str(tweet_lon),
                            text = str(tweet_text),
                            language = str(tweet_lang))     
            cur.execute(insert_query)
            con.commit()
            print "success"
        
            #some elementary output to console    
            string_to_write = str(tweet_datetime)+", "+str(tweet_lat)+", "+str(tweet_lon)+": "+str(tweet_text)
            print string_to_write
            write_tweet(string_to_write)
       
#to write data to file
def write_tweet(t):
    target = open(output_file, 'a')
    target.write(t)
    target.write('\n')
    target.close()
    
def main():
    try:
        stream = MyStreamer(APP_KEY, APP_SECRET,OAUTH_TOKEN, OAUTH_TOKEN_SECRET)
        print 'Connecting to twitter: will take a minute'
    except ValueError:
        print 'OOPS! that hurts, something went wrong while making connection with Twitter: '+str(ValueError)
    
    
    
    # Filter based on near real time tweets on holidays
    try:
        stream.statuses.filter(track='holiday')
        
    except ValueError:
        print 'OOPS! that hurts, something went wrong while getting the stream from Twitter: '+str(ValueError)


                
if __name__ == '__main__':
    main()





