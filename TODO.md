Day | Region | Package UUID

* Keep: package_uuid, status, region, date, request_count


* drop client_type, request_addrs, cache_misses, body_bytes_sent, request_time

keep 404s


-----30NOV Adrian's feedback---
1) push unzip to try catch failing            Y
2) use unix time stamp for date              Y
3) writing model object should be inside if ...because object should not be created if not unused       Y
4) save should be create_or_update....     Y
5) more indexes region/package_uuid (date with can't use because no start and end) Y


# Pkg App TODO

1) Text field should have client and server side validations
2) See if you can put tag with comma in quasar for Text field
3) Add a button (on button click so something)
4) Plot should have matching day - request_count
5) Fix re-inserting bug backend
6) Make the Search Button DISABLED by default if searchtext is empty
7) Disable all the dates in calendar if not present in database

### Advance TODO

1) Style it | Branding (CSS)
2) Try Julia version also. Insert to table [see how you can figure that out] or talk to Stefan


# know issues

1) Append to DB instead of insertion :TODO
2) Update on Button Click   [X] FIXED
3) Doesn't take mulitiple package names [X] FIXED
4) Pick same date | Pick wrong (that don't exist in DB) - check for behaviour
5) Click on search with empty search text - no results


# Finish all TODO Cleanup from CODE



# Interation 2 mapbox integration maybe. Talk to Adrian. Maps :() are fun


# TODO adrian
1) Unique index on UUID, region and date [X]
2) add index to date


3) Read row...get the new date

4) show all regions in dropdown
5) change the algorithm

6) append CSV 
https://docs.juliahub.com/CSV/HHBkp/0.9.11/reading.html#CSV.Rows

https://v1.quasar.dev/vue-components/select#qselect-api


for all

use display value property 

selection > display 


Disable button
----
if search has changed && previous operation has finished



remaining 
1) stop user from spamming visualization
2) css to add margin left
3) make the calender icon big
4) Check if stats exists then only get max of table otherwise just insert

backlog
- add date as ID. But it will take lot of time. it would block my work. So I kept it for one of the nigh task
  Like I'll drop the db and re-run migration


  # remove format 
  # union of ismissing or date
## put it in return type of the function 