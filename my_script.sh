#!/bin/bash

apiKey="apikey"
recipientEmail="email"

# Get device's location based on IP address using ipinfo.io
locationData=$(curl -s https://ipinfo.io/json)
city=$(echo "$locationData" | jq -r '.city')
ip=$(echo "$locationData" | jq -r '.ip')

# Fetch weather data from OpenWeatherMap API based on detected city
data=$(curl -s "http://api.openweathermap.org/data/2.5/weather?q=$city&units=metric&appid=$apiKey")

# Check the HTTP response code
httpStatusCode=$(echo "$data" | jq -r '.cod')

if [ "$httpStatusCode" != "200" ]; then
    errorMessage=$(echo "$data" | jq -r '.message')
    echo "Error: Failed to fetch weather data. HTTP Status Code: $httpStatusCode. Message: $errorMessage"
    exit 1
fi

# Extract information from API response using jq
temp=$(echo "$data" | jq '.main.temp')
description=$(echo "$data" | jq -r '.weather[0].description')

# Generate HTML content

html_content="
<!DOCTYPE html>
<html>
<head>
    <title>Weather Report</title>
</head>
<body>
    <h1>Weather in $city</h1>
    <p><strong>Temperature:</strong> $temp &deg;C</p>
    <p><strong>Description:</strong> $description</p>
</body>
</html>
"

# Save HTML content to weather_report.html
echo "$html_content" > weather_report.html
echo "Weather report generated: weather_report.html"

# Generate email content
email_subject="Weather Report for $city"
email_content="Temperature in $city: $temp °C\nDescription: $description"

# Send email with weather report
echo "$email_content" | mail -s "Weather Report" "$recipientEmail"
echo "Email sent to $recipientEmail"

# Open the generated HTML file
xdg-open weather_report.html

