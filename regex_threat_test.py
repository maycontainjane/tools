#!/usr/bin/python3

# script that takes in a csv of threat type, location, and threat string and runs a request against a Kong endpoint using that string in a given location
# output should include:
#   - Threat type, location, and threat string for each case
#   - Status of response and message if it exists
#   - (if debug=true) full response output
#   - (if debug=true) full request for debugging
#   - Whether response and message match expected 400 Bad Request

import requests
import argparse
import csv
import pandas
import urllib.parse as urllib


def parse_args():
    parser = argparse.ArgumentParser(description='Run a request against a Kong endpoint using a threat string in a given location')
    subparsers = parser.add_subparsers(dest='subcommand')

    # add subcommands for csv and single threat string
    threat_parser = subparsers.add_parser('threat', help='Run a single threat string against endpoint')
    threat_parser.add_argument('--type', type=str, required=True, choices=['sql', 'server_side', 'xpath_abbreviated', 'xpath_extended', 'java_exception', 'js'], help='Threat type to run against endpoint. One of: sql, server_side, xpath_abbreviated, xpath_extended, java_exception, js')
    threat_parser.add_argument('--location', type=str, required=True, choices=['header', 'path_and_query', 'body'], help='Location to run threat string against endpoint. One of: headers, path_and_query, body')
    threat_parser.add_argument('--threat_string', required=True, type=str, help='Threat string to run against endpoint')

    csv_parser = subparsers.add_parser('csv', help='Run a csv of threat strings against endpoint')
    csv_parser.add_argument('--file', required=True, type=str, help='Path to csv file of threat strings to run against endpoint. Column order must be "threat_type","location","threat_string"')
    csv_parser.add_argument('--type', type=str, default='all', choices=['sql', 'server_side', 'xpath_abbreviated', 'xpath_extended', 'java_exception', 'js'], help='Threat type to run against endpoint with all others excluded. One of: sql, server_side, xpath_abbreviated, xpath_extended, java_exception, js')
    csv_parser.add_argument('--location', type=str, default='all', choices=['header', 'path_and_query', 'body'], help='Location to run threat string against endpoint with all others excluded. One of: headers, path_and_query, body')

    parser.add_argument('--output', type=str, help='output file to write results to. If not specified, output will be written to stdout')
    parser.add_argument('--url', type=str, default="http://localhost:8000/threats", help='URL of Kong endpoint to run request against')
    parser.add_argument('--expected_status', type=int, default=400, help='Expected status of response. Default is 400')
    parser.add_argument('--debug', action='store_true', default=False, help='Debug output on or off')
    args = parser.parse_args()
    return args

def make_request(url, location, threat_string, debug):
    headers = {
        "Accept": "",
        "User-Agent": "",
        "Content-Type": ""
    }
    data = {}
    if location == 'header':
        headers['Test-Header'] = threat_string
    elif location == 'body':
        data = {
            "test_body": threat_string
        }
    elif location == 'path_and_query':
        # make querystring URL-encoded
        threat_string = urllib.quote_plus(threat_string)
        url = url + "?test_query=" + threat_string

    if debug:
        print("Request URL: " + url)
        print("Request Headers: " + str(headers))
        print("Request Body: " + str(data))
    response = requests.post(url, headers=headers, json=data)
    return response

def run_threat(url, threat_type, location, threat_string, debug, expected_status):
    # run a request against the endpoint using the given threat string in the given location
    # return the response and message
    if (debug):
        print("Running test for " + threat_type + " injection using string " + threat_string + " in " + location + " of request")
    response = make_request(url, location, threat_string, debug)
    if (debug):
        print("Response status: " + str(response.status_code))
        print("Response message: " + str(response.text))
    result_row = {"THREAT TYPE": threat_type, "LOCATION": location, "THREAT STRING": threat_string, "STATUS": response.status_code, "MESSAGE": response.text}
    if response.status_code == expected_status:
        result_row["RESULT"] = "PASS"
    else:
        result_row["RESULT"] = "FAIL"
    return result_row

def output_results(results, output_file=None):
    pandas.set_option('display.max_rows', None)
    if output_file:
        # output results as csv
        with open(output_file, 'w') as f:
            writer = csv.DictWriter(f, fieldnames=results[0].keys())
            writer.writeheader()
            writer.writerows(results)
    else:
        # output results as table to stdout
        print(pandas.json_normalize(results))
        
    
def run_csv(url, file, debug, expected_status, threat_type, location):
    # get csv contents as an object
    # run each threat string in the csv against the endpoint
    # return the response and message for each threat string
    file_contents = open(file, 'r')
    csv_file = csv.reader(file_contents) 
    # create object to store output
    results = []
    for row in csv_file:
        if debug:
            print(row)
        if threat_type != 'all' and row[0] != threat_type:
            if debug:
                print("Skipping " + row[0] + " injection")
            continue
        if location != 'all' and row[1] != location:
            if debug:
                print("Skipping " + row[1] + " location")
            continue
        result = run_threat(url, row[0], row[1], row[2], debug, expected_status)
        results.append(result)  
    return results
        

if __name__ == "__main__":
    args = parse_args()
    # results is list of objects in this format: 
    # [{"threat_type": "sql", "location": "header", "threat_string": "test", "status": 400, "message": "Bad Request"}]
    results = [] 
    if(args.debug):
        print(args)
    if(args.subcommand == 'threat'):
        results = [run_threat(args.url, args.type, args.location, args.threat_string, args.debug, args.expected_status)]
    if(args.subcommand == 'csv'):
        results = run_csv(args.url, args.file, args.debug, args.expected_status, args.type, args.location)

    output_results(results, args.output)
