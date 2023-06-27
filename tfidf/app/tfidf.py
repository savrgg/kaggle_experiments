from sklearn.feature_extraction.text import TfidfVectorizer

class TFIDF:
    def __init__(self):
        self.vectorizer = TfidfVectorizer()

    def calculate_tfidf(self, texts):
        tfidf_matrix = self.vectorizer.fit_transform(texts)
        feature_names = self.vectorizer.get_feature_names_out()
        return tfidf_matrix, feature_names
