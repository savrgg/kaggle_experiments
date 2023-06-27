from nltk.tokenize import word_tokenize
from nltk.corpus import stopwords
from nltk.stem import WordNetLemmatizer

class TextProcessor:
    def __init__(self):
        self.stop_words = set(stopwords.words("english"))
        self.lemmatizer = WordNetLemmatizer()

    def preprocess_text(self, text):
        words = word_tokenize(text.lower())
        filtered_words = [self.lemmatizer.lemmatize(word) for word in words if word.isalnum() and word not in self.stop_words]
        preprocessed_text = " ".join(filtered_words)
        return preprocessed_text
