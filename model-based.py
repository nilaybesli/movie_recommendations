#Model-Based Collaborative Filtering Using SVD and Clustering

from Functions import *


data_copy = data.copy(deep=True)
data_copy = data_copy.drop(columns=['genres', 'title'])
data_copy.head()

# use in-build functions in Surprise library to read and load ratings data
reader = Reader()
ratings_data = Dataset.load_from_df(ratings[['userId', 'movieId', 'rating']], reader)

benchmark = []
# Iterate over all algorithms
for algorithm in [SVD(), KNNBasic(), KNNWithMeans()]:
    # Perform cross validation
    results = cross_validate(algorithm, ratings_data, measures=['RMSE'], cv=3, verbose=False)
    
    # Get results append algorithm name
    tmp = pd.DataFrame.from_dict(results).mean(axis=0)
    tmp = pd.concat([tmp, pd.Series([str(algorithm).split(' ')[0].split('.')[-1]], index=['Algorithm'])], axis=0)
    benchmark.append(tmp)
    
# display the results of the 3-fold cross validation
surprise_results = pd.DataFrame(benchmark).reset_index().sort_values('test_rmse')
print(surprise_results)
# svd is best because it gives the least rmse on test data

# generate recommendations based on the estimated ratings of a particular user
print(recommend_by_model(SVD(), 180, ratings_data, ratings, data))

