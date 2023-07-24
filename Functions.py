import sys
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
# from wordcloud import *
from sklearn.metrics import pairwise_distances
from sklearn.metrics.pairwise import linear_kernel 
from sklearn.feature_extraction.text import TfidfVectorizer
from surprise import Reader, Dataset, SVD
# from surprise.reader import Reader
from surprise import KNNBasic
from surprise import KNNWithMeans
from surprise.model_selection import cross_validate



ratings = pd.read_csv("ratings.csv", sep = '::', header = None, engine = 'python', encoding = 'latin-1',names=["userId", "movieId", "rating", "timestamp"])
# users = pd.read_csv("users.csv", sep = '::', header = None, engine = 'python', encoding = 'latin-1',names=["UserID", "Gender", "Age", "Occupation", "Zip-code"])
movies = pd.read_csv("movies.csv", sep = '::', header = None, engine = 'python', encoding = 'latin-1',names=["movieId", "title", "genres"])
ml1m_images=pd.read_csv("ml1m_images.csv",sep=',',header=None,engine = 'python', encoding = 'latin-1',names=["movieId","images"])

ratings.drop(columns='timestamp', axis=0, inplace=True)
# merge the two tables on movieId

data = pd.merge(movies, ratings, on='movieId')

movies['movieId'] = movies['movieId'].astype(str)
data_images = pd.merge(movies, ml1m_images, on='movieId')


reader = Reader()
ratings_data = Dataset.load_from_df(ratings[['userId', 'movieId', 'rating']], reader)



# Function to Create Pivot Table

def create_pivot_table(data, indx, val, colm):
    '''
    For Item-Item similarity: index='movieId', values='rating', columns='userId'
    For User-User similarity: index='userId', values='rating', columns='movieId'
    '''
    pivot_tab = data.pivot_table(index=data[indx], values=val, columns=colm).reset_index(drop=True)
    pivot_tab.fillna(0, inplace=True)
    return pivot_tab

# Function to Create Similarity Matrix

def calculate_similarity(piv_table, sim_metric):
    '''
    sim: cosine
    '''
    similarity = 1-pairwise_distances(piv_table.to_numpy(), metric=sim_metric)
    np.fill_diagonal(similarity, 0)
    similarity_matrix = pd.DataFrame(similarity) 
    return similarity_matrix


# function to find similar items
def similar_items(movieId, movie_similarity_matrix):
    similar_item_matrix = movie_similarity_matrix.sort_values(by=movieId, ascending=False)   # 1 is the movieId
    # You get the matrix, where the index is movieid which has highest score wrt the given movie
    # print(similar_item_matrix)
    similar_movie_scores = movie_similarity_matrix.sort_values(by=movieId, ascending=False).loc[:, movieId]
#     print(similar_user_scores)
    items_list = []
    for i in similar_movie_scores.index:
        items_list.append(i)  # items that have the highest similarity with the current item
    scores_list = []
    for i in similar_movie_scores:
        scores_list.append(i)  # similarity score between current movie(item) and all the other items
        
    similarity_data = pd.DataFrame(items_list, columns=['similar movie'])
    similarity_data['similarity score'] = scores_list
    similarity_data = similarity_data.sort_values(by='similarity score', ascending=False).reset_index(drop=True)
#     print(similarity_data)
    return similarity_data

# function to generate item-based recommendations
def item_item_based_reccommendations(movie_id, sim_matrix):
    similar_movies = similar_items(movie_id, sim_matrix)
#     print(similar_movies)
    movies['movieId'] = movies['movieId'].astype(int)

    df_recommended=pd.DataFrame(columns=['movieId','title','genres','userId','rating'])
    for id in similar_movies['similar movie']:
        if id not in movies[movies.index==id]:
            movie_idfd = movies[movies.index==id]['movieId'].iloc[0]
            df = data[(data['rating']>=4.0) & (data['movieId']==movie_idfd)]
            df_recommended = pd.concat([df_recommended, df])
    
    df_recommended_final = df_recommended.sort_values(by='rating', ascending=False).reset_index(drop=True)
    df_recommended_final = df_recommended_final.drop_duplicates(subset='movieId')
    print('Top 20 Movies Similar to', movies[movies['movieId']==movie_id]['title'].iloc[0], 'are:')
    return df_recommended_final.head(20)
# evaluation
def item_evaluation(movieid, predicted_movies):
    main_movie_genre = list_of_genres(movies[movies['movieId']==movieid]['genres'])
    movie_genres_list = []
    for each in predicted_movies['title']:
        genre_list_per_movie = list_of_genres(movies[movies['title']==each]['genres'])
        movie_genres_list.append(genre_list_per_movie)
    recc_list = []
    for each in movie_genres_list:
        for all in each:
            recc_list.append(all)
    hit = 0
    fault = 0
    total = 0
    for i in recc_list:
        if i in main_movie_genre:
            hit += 1
        else:
            fault += 1
        total += 1
    return hit/total

def list_of_genres(df):
    genre_list = []
    for i in range(len(df)):
        each_genre = df.iloc[i]
        string_split = each_genre.split("|")
        #     print(string_split)
        for each in string_split:
            if each not in genre_list:
                genre_list.append(each)
    return genre_list

# USER USER COLAB

# function to find similar users
def similar_users(user_id, similarity_matrix):
    similar_user_matrix = similarity_matrix.sort_values(by=user_id, ascending=False)   # 1 is the userId
    # You get the matrix, where the index is movieid which has highest score wrt the given movie
    # print(similar_user_matrix)
    similar_user_scores = similarity_matrix.sort_values(by=user_id, ascending=False).loc[:, user_id]
    # print(similar_user_scores)
    users_list = []
    for i in similar_user_scores.index:
        users_list.append(i)  # userId that have the highest similarity with the current user
    scores_list = []
    for i in similar_user_scores:
        scores_list.append(i)  # similarity score between current user and all the other users

    similarity_data = pd.DataFrame(users_list, columns=['similar user'])
    similarity_data['similarity score'] = scores_list
    similarity_data = similarity_data.sort_values(by='similarity score', ascending=False).reset_index(drop=True)
    return similarity_data


# function to generate user-based recommendations
def user_user_based_reccommendations(user_id, similarity_matrix):
    similar_user_data = similar_users(user_id, similarity_matrix)
    print('Top 10 Users Similar to User', user_id, 'are: \n', similar_user_data.head(10))
    top_user = similar_user_data.iloc[0,0]
    # top_user  # userid of the most similar user
    top_user_movieids = ratings[ratings['userId']==top_user]['movieId']
    df_recommended=pd.DataFrame(columns=['movieId','title','genres','userId','rating'])
    for id in ratings[ratings['userId']==user_id]['movieId']:
        if id not in top_user_movieids:
            df = data[(data['userId']==top_user) & (data['movieId']==id)]
            df_recommended = pd.concat([df_recommended, df])
  
    df_recommended = df_recommended.sort_values(by='rating', ascending=False).reset_index(drop=True)
    print('Top Movies Recommended to User', user_id, 'based on Similar Users are:')
    return df_recommended.head(20)

# evaluation
def user_evaluation(userid, predicted_movies):
    user_rated_movies = data[data['userId']==userid]  # items in user's history, rated by user
    user_rated_movies = user_rated_movies.sort_values(by='rating', ascending=False).reset_index()
    user_rated_movies = user_rated_movies[user_rated_movies['rating']>=4.0]
#     print(user_rated_movies)
    hit = 0
    fault = 0
    total = 0
    for each in user_rated_movies['movieId']:
        if each in predicted_movies['movieId']:
            hit += 1
        else:
            fault += 1
        total += 1
#         print(hit, fault)
    return hit/total   # hit rate



# Functions for Model-Based Collaborative Filtering

# function for to generate recommendation using best model
def recommend_by_model(algo_name, userid, rating_data, all_ratings, main_data):
    algo = algo_name()
    prev_movies = all_ratings[all_ratings['userId']==userid]
#     prev_movies = prev_movies.set_index(prev_movies['movieId']).reset_index(drop=True)
    prev_movies = prev_movies.reset_index(drop=True)
#     prev_movies
    train_data = rating_data.build_full_trainset()
    algo.fit(train_data)
    excluded_data = pd.merge(all_ratings, prev_movies, how='left')
    excluded_data = excluded_data.reset_index(drop=True)
    excluded_data['estimated rating'] = excluded_data['movieId'].apply(lambda x: algo.predict(userid, x).est)
    excluded_data = excluded_data.sort_values(by='estimated rating', ascending=False)
    excluded_data = excluded_data.reset_index(drop=True)
    final_recc = pd.merge(main_data, excluded_data, how='right')
    final_recc = final_recc[final_recc['estimated rating']>=4.0]
    final_recc = final_recc[final_recc['rating']>=4.0]
    final_recc = final_recc.drop_duplicates(subset='movieId').reset_index()
    final_recc = final_recc.drop(columns='index')
    print('Recommended Movies for user', userid, 'are:')
    return final_recc[:20]