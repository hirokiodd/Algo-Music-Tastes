# Import necessary libraries
from dotenv import load_dotenv
import spotipy
from spotipy.oauth2 import SpotifyOAuth
import json
import pandas as pd
from datetime import datetime
from collections import defaultdict

# Number of recommendations to get per cycle
# 5 is the maximum number of seeds for new recommendations
num_recs=5

# Number of cycles to get recommendations
num_cycles=10

# Functions to get recommendations
# Get recommendations based on seed genres, artists, or tracks
def get_recommendations(sp, genres=None, artists=None, tracks=None, num_recs=None):
    try:
        recs = sp.recommendations(seed_genres=genres, seed_artists=artists, seed_tracks=tracks, limit=num_recs)
        return recs["tracks"]
    except Exception as e:
        print(f"Error fetching recommendations: {e}")
        return []


# Get recommendations based on seed genres, artists, or tracks
def get_recommendations_by_genre(sp, seed_genres, num_recs=None):
    try:
        recs = sp.recommendations(seed_genres=seed_genres, seed_artists=None, seed_tracks=None, limit=num_recs)
        return recs["tracks"]
    except Exception as e:
        print(f"Error fetching recommendations: {e}")
        return []

# Function to get new recommendations based on previously recommended artists as seeds
def get_recommendations_by_artist(sp, artist_seeds, account_type, num_recs):
    # Get new recommendations based on previous recommendations
    new_recommendations = sp.recommendations(sp, artists=artist_seeds, num_recs=num_recs)
    new_extracted_info = extract_recommendation_info(new_recommendations)
    return new_extracted_info

# Function to extract relevant information from recommendations
def extract_recommendation_info(sp, recommendations):
    extracted_info = []
    for item in recommendations:
        track_info = {
            "track_name": item["name"],
            "track_id": item["id"],
            "artist_name": item["artists"][0]["name"],
            "artist_id": item["artists"][0]["id"],
            "popularity": item["popularity"],
        }
        extracted_info.append(track_info)

        # Fetch artist genres
        artist_uri = track_info["artist_id"]
        artist_info = sp.artist(artist_uri)
        extracted_info[-1]["artist_genres"] = artist_info["genres"]
    return extracted_info

# Function to get artist seeds from previous recommendations
def get_artist_seeds(extracted_info, account_type):
    artist_seeds = [rec["artist_id"] for rec in extracted_info]
    return artist_seeds

# Function to store recommendations results
def store_recommendations(results_list, account_type, recommendations):
    """
    Stores the recommendations in the results_list for a given account_type.

    Parameters:
    - results_list (dict): A dictionary containing the results for different account types. (It should be empty initially)
    - account_type (str): The type of the account for which the recommendations are being stored.
    - recommendations (list): A list of recommendation objects.

    Returns:
    - results_list (dict): The updated results_list with the new recommendations added.
    """
    timestamp = datetime.now().isoformat()
    for rec in recommendations:
        results_list[account_type].append(
            {
                "timestamp": timestamp,
                "track_name": rec["track_name"],
                "track_id": rec["track_id"],
                "artist_name": rec["artist_name"],
                "artist_id": rec["artist_id"],
                "popularity": rec["popularity"],
                "artist_genres": rec["artist_genres"],
            }
        )
    return results_list

# Function to get the first recommendations
# This is needed as the first recommendations are based on seed genres
def get_first_recommendations(sp, seed_genres, results_list, account_type, num_recs):
    recommendations = get_recommendations(sp=sp, genres=seed_genres, num_recs=num_recs)
    extracted_info = extract_recommendation_info(sp, recommendations)
    artist_seeds = get_artist_seeds(extracted_info, account_type)
    results = store_recommendations(results_list, account_type, extracted_info)
    return results, artist_seeds


# Function to get second recommendations
# This is needed as the first recommendations are based on seed genres but the second recommendations are based on seed artists
def get_second_recommendations(sp, results_list, artist_seeds, account_type, num_recs):
    new_recommendations = get_recommendations(sp=sp, artists=artist_seeds, num_recs=num_recs)
    new_extracted_info = extract_recommendation_info(sp, new_recommendations)
    new_artist_seeds = get_artist_seeds(new_extracted_info, account_type)
    new_results = store_recommendations(results_list, account_type, new_extracted_info)
    return new_results, new_artist_seeds


# Function to repeat the process of getting new recommendations based on artist seeds suggested by previous recommendations
def get_recommendations_cycle(sp, results_list, artist_seeds, account_type, num_cycles, num_recs):
    for _ in range(num_cycles):
        # Get artist seeds from previous recommendations
        new_recommendations = get_recommendations(sp=sp, artists=artist_seeds, num_recs=num_recs)
        new_extracted_info = extract_recommendation_info(sp, new_recommendations)
        # Update artist seeds for the next cycle
        artist_seeds = get_artist_seeds(new_extracted_info, account_type=account_type)
        # Store new recommendations
        new_results = store_recommendations(results_list, account_type, new_extracted_info)
        # Append new recommendations to previous recommendations
        # results = append_recommendations(results, new_results, account_type)
    return new_results

# Save the results to a JSON file
def save_results(results, filename):
    with open(filename, "w") as f:
        json.dump(results, f)
