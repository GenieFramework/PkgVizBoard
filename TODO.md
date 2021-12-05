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


### Advance TODO

1) Style it | Branding (CSS)
2) Try Julia version also. Insert to table [see how you can figure that out] or talk to Stefan



# know issues

1) Append to DB instead of insertion
2) Update on Button Click
3) Doesn't take mulitiple package names