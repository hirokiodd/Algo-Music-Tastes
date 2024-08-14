import os
from dotenv import  load_dotenv
load_dotenv('../.env')
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import spotipy
import networkx as nx
from spotipy.oauth2 import SpotifyOAuth

# Set up the Spotify API
my_id = os.environ.get('SPOTIPY_CLIENT_ID')
my_secret = os.environ.get('SPOTIPY_CLIENT_SECRET')
#redirect_uri = os.environ.get("SPOTIPY_REDIRECT_URI")

scope = "user-library-read user-read-recently-played"

sp = spotipy.Spotify(auth_manager=SpotifyOAuth(client_id=my_id,
                                               client_secret=my_secret,
                                               scope=scope,
                                               redirect_uri="http://localhost/"))

# Function to get top artists for a genre
def get_top_artists(genre, limit=10):
    results = sp.search(q=f'genre:"{genre}"', type='artist', limit=limit)
    artists = results['artists']['items']
    artist_names = [artist['name'] for artist in artists]
    return artist_names

# Function to get the genres of the artist
def get_genres(artist):
    try:
        artist = sp.search(q='artist:' + artist, type='artist')
        genres = artist["artists"]["items"][0]["genres"]
        return genres
    except:
        return []

# Create a function to calculate the atypicality of a sub-genre
def calculate_atypicality(sub_genre):
    # Filter the dataframe to get the rows where genre1 is the sub-genre
    df_edges_sub_genre = df_edges[df_edges["genre1"] == sub_genre]
    # Count the unique categories in the category2 column and minus 1 (to exclude the category of the genre itself)
    atypicality = df_edges_sub_genre["category2"].nunique() - 1
    return atypicality
