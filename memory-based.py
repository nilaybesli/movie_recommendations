import sys
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from sklearn.metrics import pairwise_distances
from sklearn.metrics.pairwise import linear_kernel 
from sklearn.feature_extraction.text import TfidfVectorizer

from Functions import *

# Collaborative Filtering
# Memory-Based Collaborative Filtering Using Cosine Similarity Metric

# copy the main dataframe to be used
data_copy = data.copy(deep=True)
data_copy = data_copy.drop(columns=['genres', 'title'])
# data_copy.head(10)


# creating the movie rating matrix
item_user_pivot = create_pivot_table(data, 'movieId', 'rating', 'userId')
print(item_user_pivot)

# create the movie similarity matrix
movie_similarity_matrix = calculate_similarity(item_user_pivot, 'cosine')
print(movie_similarity_matrix)


recc1 = item_item_based_reccommendations(260, movie_similarity_matrix)
print(recc1)

# degerlendirme
# hit rate for item-based approach based on genres
hit_rate_movie = item_evaluation(260, recc1) #movieIdye göre
print('The Hit Rate for Item-based Collaborative Filtering is:', hit_rate_movie)



#User - user collabration
# create the user rating matrix
user_item_pivot = create_pivot_table(data, 'userId', 'rating', 'movieId')
print(user_item_pivot)

# create the user similarity matrix
user_user_similarity = calculate_similarity(user_item_pivot, 'cosine')
print(user_user_similarity)

# generate movie recommendations based on userId 147
recc2 = user_user_based_reccommendations(9, user_user_similarity)
print(recc2)
# degerlendirme
# hit rate for user-based approach based on user's past preferences
hit_rate_user = user_evaluation(50, recc2)
print('The Hit Rate for User-based Collaborative Filtering is:', hit_rate_user)
# movies seen by user 50
data[data['userId']==50].sort_values(by='rating', ascending=False)
# movies seen by user 287
data[data['userId']==287].sort_values(by='rating', ascending=False)