import json
from news_api import NewsAPI
from text_processor import TextProcessor
from tfidf import TFIDF
from nltk.tokenize import word_tokenize
from sklearn.metrics.pairwise import cosine_similarity
from dashboard import ArticleDashboard

class Main:
    def run(self):
        # Load the API key from the config.json file
        with open('config.json') as f:
            config = json.load(f)

        api_key = config['API_KEY']
        topic = "technology"
        num_articles = 10

        news_api = NewsAPI(api_key)
        text_processor = TextProcessor()
        tfidf = TFIDF()

        articles = news_api.get_articles(topic, num_articles)

        preprocessed_articles = [text_processor.preprocess_text(article) for article in articles]

        tfidf_matrix, feature_names = tfidf.calculate_tfidf(preprocessed_articles)

        user_input = "Technology"
        user_keywords = word_tokenize(user_input.lower())
        user_keywords = [text_processor.lemmatizer.lemmatize(word) for word in user_keywords if word.isalnum() and word not in text_processor.stop_words]
        user_tfidf = tfidf.vectorizer.transform([" ".join(user_keywords)])

        similarity_scores = cosine_similarity(user_tfidf, tfidf_matrix).flatten()

        top_indices = similarity_scores.argsort()[::-1][:5]
        top_articles = [articles[idx] for idx in top_indices]

        dashboard = ArticleDashboard(top_articles, similarity_scores)
        dashboard.create_dashboard()

if __name__ == '__main__':
    main = Main()
    main.run()
