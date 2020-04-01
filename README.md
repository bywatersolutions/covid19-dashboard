# covid19-dashboard
A simple dashboard to see all COVID19 related tickets from RT by Requestor Group

## Usaage
* Create a CSV of Requestor Groups with columns Id, Name, Description, and Status
    * Status should be Enabled if group is active, Disabled if not
* Run covid-data.pl to generate a YAML file of data ( covid.yml )
* Run covid-web.pl to generate a static html dashbaord page
* Place the html page in a web accessable directory
* Browse to the correct URL and view your dashboard!
