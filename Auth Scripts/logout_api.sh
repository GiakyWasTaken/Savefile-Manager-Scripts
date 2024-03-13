#!/bin/bash

# API logout endpoint
logout_url="http://localhost:8000/api/logout"

# API token
token="eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJhdWQiOiIxIiwianRpIjoiYmE0NGQwMTM1YTUzMzZmZDZmN2Q4MmIyOTU4NDg3N2E1ZTc4NDYxNjc4NDEwOTFjNDRmNzdiMTAwZTc0NzU4NmY5NzUyZmFjNjdkZDZkMjgiLCJpYXQiOjE3MTAzMjIzMzkuMjg3ODMyLCJuYmYiOjE3MTAzMjIzMzkuMjg3ODQxLCJleHAiOjE3NDE4NTgzMzkuMjc5NzM4LCJzdWIiOiIxIiwic2NvcGVzIjpbXX0.Z-ZoOKEUQKdwdNI4RgAqtgH31O8GBMBfy6wlcmDWNdpY2wBIE-iBs-P5vesKdABoAZmt20rRqWAiPifvfvZTkjEKg4iHA_DqUO2f09p91bv4QbEb0Guz9U2Z46D0lCTGnC1w_vBbnevichbe4FdPHozLUXcygaYjE-hoB9xMFGBe0ZjH3M7OWLrbu54TX1ehAVTAFEQCACc81oZXVX7kuYkZBwsOyMukqh8X_eVnLWbb-0fmSB5VRufKN21cGweLHaPIqdjTvk06Q44cX77p7J1jm4GOZPFw_l7V7x_REto1z1LMZWIKCli32m5v9pNzxfKCDQgqrnA-85B-NdHRC_AFwmGBkIzM7Z_V6jtzoFeRptgpZ1PqtVXx9BXlCJxzXyK7PfIjZNLmPPf-XHdwjL988b9ATEFnCOVIk-cu8gulmH8qXqHpEcQWNacsy0mHXWTHXOZMqNkJ2dYWfEKRyZfWtXQ845ZUZtceg4sAyTqx9H-9dvNarMaXnmbOdDI0mSq5_XUiO64r7ObWNFKdsAixpJMnAGsNlGe5_RPqy608d5fnxrn2q3HBKIObEfmTYHBUduH_iIHa5w0PT0Ibz6ShhfoDxo5ZzPr_A8pWvms8DrzsehRedhEqH2u2nNHHNdaFOU5mATzOnmJ2CQruX4pyJ_xp0TP3UoANfsVq20o"

# Send logout request
response=$(curl -X GET \
    -H "Authorization: Bearer $token" \
    -H "Accept: application/json" \
    -H "Content-Type: application/json" \
    $logout_url)

# Check if the response contains "Logged out"
if [[ $response == *"Logged out"* ]]; then
    echo "Logged out"
elif [[ $response == *"Unauthenticated"* ]]; then
    echo "Unauthenticated"
    exit 1
else
    echo "Failed to log out"
    exit 1
fi
