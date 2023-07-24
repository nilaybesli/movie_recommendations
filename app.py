from flask import Flask,request, jsonify 
from flask_restful import Resource, Api, reqparse
from Functions import recommend_by_model, ratings_data, ratings, data, SVD
from Functions import *
from sklearn.metrics import pairwise_distances

import json
import pandas as pd
    


app = Flask(__name__) 
api = Api(app)

 @app.route('/recommendations/<int:user_id>')
def recommend_by_model(user_id):
    final_recc = recommend_by_model(KNNBasic, user_id, ratings_data, ratings, main_data=data)
    return final_recc.to_json(orient='records')


@app.route('/recommend/<int:movie_id>')
def get_recommendations(movie_id):
    item_user_pivot = create_pivot_table(data, 'movieId', 'rating', 'userId')
    movie_similarity_matrix = calculate_similarity(item_user_pivot, 'cosine')
    
    recommended_movies = item_item_based_reccommendations(movie_id, movie_similarity_matrix)
    return recommended_movies.to_json(orient='records')


@app.route('/recommendations2/<int:user_id>')
def recommend_by_model2(user_id):
    user_item_pivot = create_pivot_table(data, 'userId', 'rating', 'movieId')
    user_user_similarity = calculate_similarity(user_item_pivot, 'cosine')

    final_recc = user_user_based_reccommendations(user_id, user_user_similarity)
    return final_recc.to_json(orient='records')

@app.route('/movies')
def get_movies():
    return movies.to_json(orient='records')

@app.route('/images/<int:movie_id>')
def get_images(movie_id):
    return data_images.to_json(orient='records')

@app.route('/images/action')
def get_action_images():
    action_movies = data_images[data_images['genres'].str.contains('action', case=False)]
    return  action_movies.to_json(orient='records')

@app.route('/images/comedy')
def get_comedy_images():
    comedy_movies = data_images[data_images['genres'].str.contains('comedy', case=False)]
    return comedy_movies.to_json(orient='records')

@app.route('/images/romance')
def get_romance_images():
    romance_movies = data_images[data_images['genres'].str.contains('romance', case=False)]
    return romance_movies.to_json(orient='records')





if __name__ == '__main__':
    app.run(debug=True)     
